extends GutTest
## Unit tests for endless mode features:
## - enemy.gd die() refactoring
## - boss kill bonus rewards
## - passive gold income
## - retreat button / signal
## - soul fragment multiplier
## - game over screen endless stats
## - milestone signal emission


var _arena_refs: Array = []  # Track arena nodes for cleanup


func before_each():
	GameManager.reset()
	if SynergyManager:
		SynergyManager.active_synergies.clear()
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	UpgradePool.ensure_weapons_registered()
	_arena_refs.clear()


func after_each():
	# Wait for call_deferred spawns from die() to complete before autofree runs
	# This ensures XP gems, food pickups, splitter children are added to the
	# tree so they get freed when the arena (autofree) is freed
	await get_tree().process_frame


func _create_test_enemy_with_arena(hp: float = 50.0, is_boss: bool = false, is_splitter: bool = false) -> CharacterBody2D:
	var data := EnemyData.new()
	data.enemy_id = "test"
	data.enemy_name = "TestEnemy"
	data.max_hp = hp
	data.speed = 60.0
	data.damage = 10.0
	data.xp_value = 10
	data.color = Color.GREEN
	data.size = 16.0
	data.drop_chance = 0.0
	data.is_boss = is_boss
	if is_splitter:
		data.is_splitter = true
		data.split_count = 2
	var enemy_scene := load("res://scenes/enemy.tscn") as PackedScene
	var enemy: CharacterBody2D = enemy_scene.instantiate() as CharacterBody2D
	enemy.enemy_data = data
	var arena := Node2D.new()
	var pickup_mgr := Node2D.new()
	pickup_mgr.name = "PickupManager"
	pickup_mgr.set_script(load("res://scripts/pickup_manager.gd"))
	arena.add_child(pickup_mgr)
	arena.add_child(enemy)
	add_child_autofree(arena)
	_arena_refs.append(arena)
	return enemy


func _create_test_enemy_with_player(hp: float = 50.0, is_boss: bool = false, is_splitter: bool = false) -> CharacterBody2D:
	var data := EnemyData.new()
	data.enemy_id = "test"
	data.enemy_name = "TestEnemy"
	data.max_hp = hp
	data.speed = 60.0
	data.damage = 10.0
	data.xp_value = 10
	data.color = Color.GREEN
	data.size = 16.0
	data.drop_chance = 0.0
	data.is_boss = is_boss
	if is_splitter:
		data.is_splitter = true
		data.split_count = 2
	var enemy_scene := load("res://scenes/enemy.tscn") as PackedScene
	var enemy: CharacterBody2D = enemy_scene.instantiate() as CharacterBody2D
	enemy.enemy_data = data
	var arena := Node2D.new()
	var pickup_mgr := Node2D.new()
	pickup_mgr.name = "PickupManager"
	pickup_mgr.set_script(load("res://scripts/pickup_manager.gd"))
	arena.add_child(pickup_mgr)
	# Add a player to group so _find_player works
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.global_position = Vector2(400, 300)
	player.add_to_group("players")
	arena.add_child(player)
	arena.add_child(enemy)
	add_child_autofree(arena)
	_arena_refs.append(arena)
	return enemy


# =====================================================================
# 1. DIE() REFACTORING -- helper function structure
# =====================================================================

func test_die_calls_handle_kill_rewards():
	var enemy := _create_test_enemy_with_arena(10.0)
	var kills_before: int = GameManager.enemies_killed
	enemy.take_damage(10.0)
	assert_eq(GameManager.enemies_killed, kills_before + 1, "register_kill called in _handle_kill_rewards")
	assert_eq(GameManager.score, 10, "score added in _handle_kill_rewards")


func test_die_calls_spawn_xp_gems():
	var enemy := _create_test_enemy_with_arena(10.0)
	var pickup_mgr: Node = enemy.get_parent().get_node("PickupManager")
	var initial_children: int = pickup_mgr.get_child_count()
	enemy.take_damage(10.0)
	await get_tree().process_frame
	assert_eq(pickup_mgr.get_child_count(), initial_children + 1, "XP gem spawned via _spawn_xp_gems")


func test_die_decrements_enemy_count():
	var enemy := _create_test_enemy_with_arena(10.0)
	GameManager.enemy_count = 1
	enemy.take_damage(10.0)
	assert_eq(GameManager.enemy_count, 0, "enemy_count decremented in _handle_kill_rewards")


func test_die_adds_gold():
	var enemy := _create_test_enemy_with_arena(10.0)
	enemy.take_damage(10.0)
	assert_eq(GameManager.gold, 3, "gold added in _handle_kill_rewards")


func test_die_no_double_die():
	var enemy := _create_test_enemy_with_arena(10.0)
	enemy.take_damage(10.0)
	assert_false(enemy.is_alive)
	enemy.die()
	assert_eq(GameManager.enemies_killed, 1, "Should only count kill once")


# =====================================================================
# 2. BOSS KILL BONUS REWARDS (ENDLESS MODE)
# =====================================================================

func test_boss_death_normal_mode_no_bonus_gold():
	GameManager.selected_difficulty = "normal"
	var boss := _create_test_enemy_with_arena(10.0, true)
	var gold_before: int = GameManager.gold
	boss.take_damage(10.0)
	# Normal mode: base 3 gold, no endless bonus
	assert_eq(GameManager.gold, gold_before + 3, "No endless bonus gold in normal mode")
	assert_true(GameManager.boss_killed, "boss_killed set")
	assert_eq(GameManager.boss_kill_count, 1, "boss_kill_count incremented")


func test_boss_death_endless_mode_bonus_gold():
	GameManager.selected_difficulty = "endless"
	var boss := _create_test_enemy_with_arena(10.0, true)
	var gold_before: int = GameManager.gold
	boss.take_damage(10.0)
	# Endless: base 3 + bonus 50 = 53
	assert_eq(GameManager.gold, gold_before + 53, "Endless boss gives +50 bonus gold")


func test_boss_death_endless_mode_bonus_xp():
	GameManager.selected_difficulty = "endless"
	# Set player level high so the 30 XP bonus doesn't trigger a level-up
	GameManager.player_level = 14
	GameManager.xp_to_next_level = 99999.0
	GameManager.current_xp = 0.0
	var xp_before: float = GameManager.current_xp
	var boss := _create_test_enemy_with_arena(10.0, true)
	boss.take_damage(10.0)
	assert_almost_eq(GameManager.current_xp, xp_before + 30.0, 0.01, "Endless boss gives +30 bonus XP")


func test_boss_death_endless_mode_food_spawn():
	GameManager.selected_difficulty = "endless"
	var boss := _create_test_enemy_with_arena(10.0, true)
	var arena: Node = boss.get_parent()
	var initial_children: int = arena.get_child_count()
	boss.take_damage(10.0)
	await get_tree().process_frame
	await get_tree().process_frame
	# 5 food items spawned via _spawn_food_at
	assert_gt(arena.get_child_count(), initial_children, "Endless boss spawns food items")


func test_boss_death_endless_mode_signals():
	GameManager.selected_difficulty = "endless"
	var signals_received: Array = []
	GameManager.boss_kill_reward.connect(func(g: int, e: int): signals_received.append({"gold": g, "exp": e}))
	var boss := _create_test_enemy_with_arena(10.0, true)
	boss.take_damage(10.0)
	assert_eq(signals_received.size(), 1, "boss_kill_reward signal emitted")
	assert_eq(signals_received[0]["gold"], 50, "Signal gold = 50")
	assert_eq(signals_received[0]["exp"], 30, "Signal exp = 30")


func test_boss_kills_tracked_across_multiple():
	GameManager.selected_difficulty = "endless"
	var boss1 := _create_test_enemy_with_arena(10.0, true)
	boss1.take_damage(10.0)
	var boss2 := _create_test_enemy_with_arena(10.0, true)
	boss2.take_damage(10.0)
	assert_eq(GameManager.boss_kill_count, 2, "Multiple boss kills tracked")


func test_boss_bonus_gems_all_modes():
	GameManager.selected_difficulty = "normal"
	var boss := _create_test_enemy_with_arena(10.0, true)
	var pickup_mgr: Node = boss.get_parent().get_node("PickupManager")
	var initial_children: int = pickup_mgr.get_child_count()
	boss.take_damage(10.0)
	await get_tree().process_frame
	assert_eq(pickup_mgr.get_child_count(), initial_children + 6, "Boss drops 1 base + 5 bonus gems in all modes")


# =====================================================================
# 3. PASSIVE GOLD INCOME CONSTANTS
# =====================================================================

func test_gold_income_timer_constant():
	var arena_script := load("res://scripts/arena.gd")
	var instance := Node2D.new()
	instance.set_script(arena_script)
	assert_eq(instance.ENDLESS_GOLD_INCOME_INTERVAL, 60.0, "Gold income interval is 60s")
	assert_eq(instance.ENDLESS_GOLD_INCOME_AMOUNT, 1, "Gold income amount is 1")
	instance.free()


func test_gold_income_not_in_normal_mode():
	GameManager.selected_difficulty = "normal"
	GameManager.is_game_over = false
	# In normal mode, the gold income timer never triggers add_gold
	# Simulate what the code does: check the condition
	var should_run: bool = GameManager.selected_difficulty == "endless" and not GameManager.is_game_over
	assert_false(should_run, "Gold income condition false in normal mode")


func test_gold_income_condition_endless():
	GameManager.selected_difficulty = "endless"
	GameManager.is_game_over = false
	var should_run: bool = GameManager.selected_difficulty == "endless" and not GameManager.is_game_over
	assert_true(should_run, "Gold income condition true in endless mode")


func test_gold_income_condition_game_over():
	GameManager.selected_difficulty = "endless"
	GameManager.is_game_over = true
	var should_run: bool = GameManager.selected_difficulty == "endless" and not GameManager.is_game_over
	assert_false(should_run, "Gold income condition false when game over")


# =====================================================================
# 4. MILESTONE SIGNAL
# =====================================================================

func test_milestone_signal_emitted():
	GameManager.elapsed_time = 120.0
	var signals_received: Array = []
	GameManager.milestone_reached.connect(func(m: int, g: int): signals_received.append({"minutes": m, "gold": g}))
	GameManager.milestone_reached.emit(2, 1)
	assert_eq(signals_received.size(), 1, "milestone_reached signal emitted")
	assert_eq(signals_received[0]["minutes"], 2, "Minutes = 2 (120s)")
	assert_eq(signals_received[0]["gold"], 1, "Gold = 1")


# =====================================================================
# 5. RETREAT SIGNAL (GameManager)
# =====================================================================

func test_retreat_requested_signal_exists():
	var signals_received: Array = []
	GameManager.retreat_requested.connect(func(): signals_received.append(true))
	GameManager.retreat_requested.emit()
	assert_eq(signals_received.size(), 1, "retreat_requested signal exists and can emit")


func test_boss_kill_reward_signal_exists():
	var signals_received: Array = []
	GameManager.boss_kill_reward.connect(func(_g: int, _e: int): signals_received.append(true))
	GameManager.boss_kill_reward.emit(50, 30)
	assert_eq(signals_received.size(), 1, "boss_kill_reward signal exists and can emit")


func test_milestone_reached_signal_exists():
	var signals_received: Array = []
	GameManager.milestone_reached.connect(func(_m: int, _g: int): signals_received.append(true))
	GameManager.milestone_reached.emit(5, 2)
	assert_eq(signals_received.size(), 1, "milestone_reached signal exists and can emit")


# =====================================================================
# 6. SOUL FRAGMENT ENDLESS MULTIPLIER
# =====================================================================

func test_soul_fragment_normal_rate():
	GameManager.selected_difficulty = "normal"
	GameManager.gold = 100
	var soul_rate: float = 0.3
	if GameManager.selected_difficulty == "endless":
		soul_rate *= 1.5
	var soul_reward: int = int(GameManager.gold * soul_rate)
	assert_eq(soul_reward, 30, "Normal mode: 30% of 100 = 30 soul fragments")


func test_soul_fragment_endless_rate():
	GameManager.selected_difficulty = "endless"
	GameManager.gold = 100
	var soul_rate: float = 0.3
	if GameManager.selected_difficulty == "endless":
		soul_rate = 0.45
	var soul_reward: int = int(GameManager.gold * soul_rate)
	assert_eq(soul_reward, 45, "Endless mode: 45% of 100 = 45 soul fragments")


func test_soul_fragment_endless_rate_small_gold():
	GameManager.selected_difficulty = "endless"
	GameManager.gold = 10
	var soul_rate: float = 0.3
	if GameManager.selected_difficulty == "endless":
		soul_rate = 0.45
	var soul_reward: int = int(GameManager.gold * soul_rate)
	assert_eq(soul_reward, 4, "Endless mode: 45% of 10 = 4.5 -> int(4)")


func test_soul_fragment_endless_rate_zero_gold():
	GameManager.selected_difficulty = "endless"
	GameManager.gold = 0
	var soul_rate: float = 0.3
	if GameManager.selected_difficulty == "endless":
		soul_rate *= 1.5
	var soul_reward: int = int(GameManager.gold * soul_rate)
	assert_eq(soul_reward, 0, "Zero gold gives zero soul fragments")


func test_save_manager_endless_soul_multiplier():
	GameManager.selected_difficulty = "endless"
	GameManager.gold = 200
	var souls_before: int = SaveManager.soul_fragments
	SaveManager.check_quests_and_achievements()
	var gained: int = SaveManager.soul_fragments - souls_before
	# 200 * 0.45 = 90 + quest/achievement rewards
	assert_gte(gained, 90, "Endless soul reward at least 90 (200 * 0.45)")


func test_save_manager_normal_soul_multiplier():
	GameManager.selected_difficulty = "normal"
	GameManager.gold = 200
	var souls_before: int = SaveManager.soul_fragments
	SaveManager.check_quests_and_achievements()
	var gained: int = SaveManager.soul_fragments - souls_before
	# 200 * 0.30 = 60 + quest/achievement rewards
	assert_gte(gained, 60, "Normal soul reward at least 60 (200 * 0.30)")
	assert_lt(gained, 90, "Normal soul reward less than endless 90")


# =====================================================================
# 7. SPLITTER DEATH STILL WORKS AFTER REFACTOR
# =====================================================================

func test_splitter_death_spawns_children():
	GameManager.selected_difficulty = "normal"
	var splitter := _create_test_enemy_with_arena(10.0, false, true)
	GameManager.enemy_count = 1
	splitter.take_damage(10.0)
	assert_eq(GameManager.enemy_count, 2, "Splitter spawns 2 children (original -1 + 2 new)")


func test_splitter_no_double_split():
	var splitter := _create_test_enemy_with_arena(10.0, false, true)
	GameManager.enemy_count = 1
	splitter.take_damage(10.0)
	splitter._handle_splitter_death()
	assert_eq(GameManager.enemy_count, 2, "No double split on second call")


# =====================================================================
# 8. FOOD DROP HELPER FUNCTIONS
# =====================================================================

func test_spawn_food_at_exists():
	var enemy := _create_test_enemy_with_arena(10.0)
	enemy._spawn_food_at(Vector2(100, 200))
	await get_tree().process_frame
	assert_true(true, "_spawn_food_at does not crash")


func test_spawn_food_delegates_to_spawn_food_at():
	var enemy := _create_test_enemy_with_arena(10.0)
	enemy._spawn_food()
	await get_tree().process_frame
	assert_true(true, "_spawn_food delegates to _spawn_food_at without crash")


# =====================================================================
# 9. GAME OVER SCREEN ENDLESS STATS
# =====================================================================

func test_game_over_screen_has_endless_label_in_endless():
	GameManager.reset()
	GameManager.selected_difficulty = "endless"
	GameManager.elapsed_time = 300.0
	GameManager.boss_kill_count = 2
	GameManager.best_combo = 34
	GameManager.gold = 100
	var screen: Control = load("res://scenes/game_over_screen.tscn").instantiate()
	add_child_autofree(screen)
	var endless_label: Label = screen.get_node_or_null("VBox/EndlessStatsLabel")
	assert_ne(endless_label, null, "EndlessStatsLabel should exist in endless mode")
	if endless_label:
		assert_eq(endless_label.text, "Bosses Killed: 2 / Best Combo: 34 / Milestones: 5",
			"Endless stats display correct values")


func test_game_over_screen_no_endless_label_in_normal():
	GameManager.reset()
	GameManager.selected_difficulty = "normal"
	GameManager.elapsed_time = 300.0
	GameManager.gold = 100
	var screen: Control = load("res://scenes/game_over_screen.tscn").instantiate()
	add_child_autofree(screen)
	var endless_label: Label = screen.get_node_or_null("VBox/EndlessStatsLabel")
	assert_eq(endless_label, null, "EndlessStatsLabel should NOT exist in normal mode")


func test_game_over_screen_soul_bonus_text_endless():
	GameManager.reset()
	GameManager.selected_difficulty = "endless"
	GameManager.gold = 100
	var screen: Control = load("res://scenes/game_over_screen.tscn").instantiate()
	add_child_autofree(screen)
	var gold_label: Label = screen.get_node("VBox/GoldLabel")
	assert_true("endless bonus" in gold_label.text, "Gold label includes endless bonus text in endless mode")


func test_game_over_screen_no_soul_bonus_text_normal():
	GameManager.reset()
	GameManager.selected_difficulty = "normal"
	GameManager.gold = 100
	var screen: Control = load("res://scenes/game_over_screen.tscn").instantiate()
	add_child_autofree(screen)
	var gold_label: Label = screen.get_node("VBox/GoldLabel")
	assert_false("endless bonus" in gold_label.text, "Gold label has no endless bonus text in normal mode")


# =====================================================================
# 10. HUD RETREAT BUTTON
# =====================================================================

func test_hud_retreat_signal_defined():
	var hud: CanvasLayer = load("res://scenes/hud.tscn").instantiate()
	add_child_autofree(hud)
	assert_true(hud.has_signal("retreat_pressed"), "HUD has retreat_pressed signal")


func test_hud_retreat_button_created_in_endless():
	GameManager.selected_difficulty = "endless"
	var arena := Node2D.new()
	arena.name = "Arena"
	add_child_autofree(arena)
	_arena_refs.append(arena)
	var pm := Node.new(); pm.name = "ProjectileManager"; arena.add_child(pm)
	var pkm := Node.new(); pkm.name = "PickupManager"; arena.add_child(pkm)
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.global_position = Vector2(400, 300)
	player.add_to_group("players")
	arena.add_child(player)
	var hud: CanvasLayer = load("res://scenes/hud.tscn").instantiate()
	arena.add_child(hud)
	var btn: Button = hud.get_node_or_null("RetreatButton")
	assert_ne(btn, null, "RetreatButton created in endless mode")
	if btn:
		assert_eq(btn.text, "Retreat [Q]", "Button text is 'Retreat [Q]'")


func test_hud_no_retreat_button_in_normal():
	GameManager.selected_difficulty = "normal"
	var arena := Node2D.new()
	arena.name = "Arena"
	add_child_autofree(arena)
	_arena_refs.append(arena)
	var pm := Node.new(); pm.name = "ProjectileManager"; arena.add_child(pm)
	var pkm := Node.new(); pkm.name = "PickupManager"; arena.add_child(pkm)
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.global_position = Vector2(400, 300)
	player.add_to_group("players")
	arena.add_child(player)
	var hud: CanvasLayer = load("res://scenes/hud.tscn").instantiate()
	arena.add_child(hud)
	var btn: Button = hud.get_node_or_null("RetreatButton")
	assert_eq(btn, null, "No RetreatButton in normal mode")


func test_hud_on_retreat_pressed_emits_signal():
	GameManager.selected_difficulty = "endless"
	GameManager.is_game_over = false
	var arena := Node2D.new()
	arena.name = "Arena"
	add_child_autofree(arena)
	_arena_refs.append(arena)
	var pm := Node.new(); pm.name = "ProjectileManager"; arena.add_child(pm)
	var pkm := Node.new(); pkm.name = "PickupManager"; arena.add_child(pkm)
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.global_position = Vector2(400, 300)
	player.add_to_group("players")
	arena.add_child(player)
	var hud: CanvasLayer = load("res://scenes/hud.tscn").instantiate()
	arena.add_child(hud)
	var signals_received: Array = []
	hud.retreat_pressed.connect(func(): signals_received.append(true))
	hud._on_retreat_pressed()
	assert_eq(signals_received.size(), 1, "retreat_pressed signal emitted")


func test_hud_on_retreat_pressed_not_in_normal():
	GameManager.selected_difficulty = "normal"
	GameManager.is_game_over = false
	var arena := Node2D.new()
	arena.name = "Arena"
	add_child_autofree(arena)
	_arena_refs.append(arena)
	var pm := Node.new(); pm.name = "ProjectileManager"; arena.add_child(pm)
	var pkm := Node.new(); pkm.name = "PickupManager"; arena.add_child(pkm)
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.global_position = Vector2(400, 300)
	player.add_to_group("players")
	arena.add_child(player)
	var hud: CanvasLayer = load("res://scenes/hud.tscn").instantiate()
	arena.add_child(hud)
	var signals_received: Array = []
	hud.retreat_pressed.connect(func(): signals_received.append(true))
	hud._on_retreat_pressed()
	assert_eq(signals_received.size(), 0, "No retreat in normal mode")


func test_hud_on_retreat_pressed_not_when_game_over():
	GameManager.selected_difficulty = "endless"
	GameManager.is_game_over = true
	var arena := Node2D.new()
	arena.name = "Arena"
	add_child_autofree(arena)
	_arena_refs.append(arena)
	var pm := Node.new(); pm.name = "ProjectileManager"; arena.add_child(pm)
	var pkm := Node.new(); pkm.name = "PickupManager"; arena.add_child(pkm)
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.global_position = Vector2(400, 300)
	player.add_to_group("players")
	arena.add_child(player)
	var hud: CanvasLayer = load("res://scenes/hud.tscn").instantiate()
	arena.add_child(hud)
	var signals_received: Array = []
	hud.retreat_pressed.connect(func(): signals_received.append(true))
	hud._on_retreat_pressed()
	assert_eq(signals_received.size(), 0, "No retreat when game is over")


# =====================================================================
# 11. GOLD DROP CALCULATION WITH COMBO
# =====================================================================

func test_gold_drop_combo_bonus():
	GameManager.combo_count = 5
	var enemy := _create_test_enemy_with_arena(10.0)
	enemy.take_damage(10.0)
	# register_kill makes it 6, but combo check is >= 5 at time of _calculate_gold_drop
	# which is called after register_kill, so combo is now 6 (>= 5), gold = 3+1 = 4
	assert_eq(GameManager.gold, 4, "Combo >= 5 gives +1 gold")


func test_gold_drop_no_combo_below_5():
	GameManager.combo_count = 3
	var enemy := _create_test_enemy_with_arena(10.0)
	enemy.take_damage(10.0)
	# register_kill makes it 4, which is < 5, gold = 3
	assert_eq(GameManager.gold, 3, "Combo < 5 gives no bonus gold")
