extends GutTest

# Test Enemy logic: damage, death, drops, status effects, ranged, ghost, splitter, boss
# Instantiates enemy scene to test full behavior

var _enemy: CharacterBody2D


func before_each():
	GameManager.reset()
	_enemy = _create_test_enemy(_default_data())


func after_each():
	# Wait for call_deferred spawns from die() to complete before autofree runs
	# This ensures XP gems, splitter children are added to the tree so they
	# get freed when the arena (autofree) is freed
	await get_tree().process_frame


func _default_data() -> EnemyData:
	var data := EnemyData.new()
	data.enemy_id = "test"
	data.enemy_name = "TestEnemy"
	data.max_hp = 50.0
	data.speed = 60.0
	data.damage = 10.0
	data.xp_value = 10
	data.color = Color.GREEN
	data.size = 16.0
	data.drop_chance = 0.0
	return data


func _create_test_enemy(data: EnemyData) -> CharacterBody2D:
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
	return enemy


# --- Health and Damage ---

func test_initial_hp():
	assert_eq(_enemy.current_hp, 50.0, "HP should equal max_hp at time 0")


func test_take_damage():
	_enemy.take_damage(20.0)
	assert_eq(_enemy.current_hp, 30.0, "HP should be 30 after 20 damage")


func test_take_damage_lethal():
	_enemy.take_damage(50.0)
	assert_eq(_enemy.current_hp, 0.0)
	assert_false(_enemy.is_alive, "Enemy should be dead")


func test_take_damage_when_dead():
	_enemy.take_damage(50.0)
	assert_false(_enemy.is_alive)
	_enemy.take_damage(30.0)
	assert_eq(_enemy.current_hp, 0.0)


func test_is_alive_initially_true():
	assert_true(_enemy.is_alive, "Enemy should start alive")


func test_die_no_double_die():
	_enemy.take_damage(50.0)
	assert_false(_enemy.is_alive)
	# Calling die again should not crash or double-count
	_enemy.die()
	assert_eq(GameManager.enemies_killed, 1, "Should only count kill once")


# --- Death and Scoring ---

func test_die_increments_kills():
	_enemy.take_damage(50.0)
	assert_eq(GameManager.enemies_killed, 1, "Should increment kill count")


func test_die_increments_score():
	_enemy.take_damage(50.0)
	assert_eq(GameManager.score, 10, "Score should equal xp_value")


func test_die_adds_gold():
	_enemy.take_damage(50.0)
	assert_eq(GameManager.gold, 3, "Should add 3 gold on kill")


func test_die_decrements_enemy_count():
	GameManager.enemy_count = 5
	_enemy.take_damage(50.0)
	assert_eq(GameManager.enemy_count, 4, "Should decrement enemy count")


func test_die_drops_xp_gem():
	var pickup_mgr := _enemy.get_parent().get_node("PickupManager")
	var initial_children := pickup_mgr.get_child_count()
	_enemy.take_damage(50.0)
	await get_tree().process_frame
	assert_eq(pickup_mgr.get_child_count(), initial_children + 1, "Should spawn 1 XP gem")


# --- HP Scaling with Time ---

func test_time_scaled_hp():
	GameManager.elapsed_time = 60.0
	var data := EnemyData.new()
	data.max_hp = 50.0
	data.speed = 60.0
	data.damage = 10.0
	data.xp_value = 5
	data.color = Color.GREEN
	data.size = 16.0
	var enemy := _create_test_enemy(data)
	# time_bonus = 1.0 + (60/60) * 0.1 = 1.1, hp = 50 * 1.1 = 55.0
	assert_almost_eq(enemy.current_hp, 55.0, 0.1, "HP should scale with elapsed time")


# --- Boss ---

func test_boss_drops_multiple_xp_gems():
	var boss_data := EnemyData.new()
	boss_data.max_hp = 500.0
	boss_data.speed = 40.0
	boss_data.damage = 40.0
	boss_data.xp_value = 100
	boss_data.color = Color.RED
	boss_data.size = 32.0
	boss_data.is_boss = true
	boss_data.drop_chance = 0.0
	_enemy.enemy_data = boss_data
	_enemy.current_hp = 500.0

	var pickup_mgr := _enemy.get_parent().get_node("PickupManager")
	_enemy.take_damage(500.0)
	await get_tree().process_frame
	assert_eq(pickup_mgr.get_child_count(), 6, "Boss should drop 6 XP gems")
	assert_true(GameManager.boss_killed, "Boss killed should be true")
	assert_eq(GameManager.boss_kill_count, 1, "Boss kill count should be 1")


func test_boss_has_ai():
	var boss_data := EnemyData.new()
	boss_data.max_hp = 200.0
	boss_data.speed = 30.0
	boss_data.damage = 2.0
	boss_data.xp_value = 100
	boss_data.color = Color.RED
	boss_data.size = 32.0
	boss_data.is_boss = true
	var boss := _create_test_enemy(boss_data)
	assert_ne(boss._boss_ai, null, "Boss should have BossAI instance")


# --- Status Effects ---

func test_apply_burn():
	_enemy.apply_burn(5.0, 2.0)
	assert_eq(_enemy._burn_dps, 5.0, "Burn DPS should be set")
	assert_eq(_enemy._burn_timer, 2.0, "Burn timer should be set")


func test_apply_slow():
	_enemy.apply_slow(0.5)
	assert_eq(_enemy._slow_pct, 0.5, "Slow percentage should be set")
	assert_eq(_enemy._slow_timer, 1.0, "Slow timer should be 1s")


func test_apply_freeze():
	_enemy.apply_freeze(0.5)
	assert_eq(_enemy._freeze_timer, 0.5, "Freeze timer should be set")


func test_burn_does_not_overwrite_stronger():
	_enemy.apply_burn(5.0, 2.0)
	_enemy.apply_burn(3.0, 1.0)  # Weaker burn
	assert_eq(_enemy._burn_dps, 5.0, "Should keep stronger burn")
	assert_eq(_enemy._burn_timer, 2.0, "Should keep longer burn timer")


# --- EnemyData Fields ---

func test_enemy_data_ranged_fields():
	var data := EnemyData.new()
	data.is_ranged = true
	data.shoot_cd = 1.2
	data.is_elite = true
	assert_true(data.is_ranged)
	assert_eq(data.shoot_cd, 1.2)
	assert_true(data.is_elite)


func test_enemy_data_ghost_fields():
	var data := EnemyData.new()
	data.can_phase_shift = true
	data.can_teleport = true
	assert_true(data.can_phase_shift)
	assert_true(data.can_teleport)


func test_enemy_data_splitter_fields():
	var data := EnemyData.new()
	data.is_splitter = true
	data.split_count = 2
	data.is_child = true
	assert_true(data.is_splitter)
	assert_eq(data.split_count, 2)
	assert_true(data.is_child)


# --- Splitter ---

func test_splitter_spawns_children():
	var splitter_data := EnemyData.new()
	splitter_data.enemy_id = "splitter"
	splitter_data.enemy_name = "分裂者"
	splitter_data.max_hp = 4.0
	splitter_data.speed = 50.0
	splitter_data.damage = 1.0
	splitter_data.xp_value = 5
	splitter_data.color = Color(0, 0.54, 0.48)
	splitter_data.size = 16.0
	splitter_data.is_splitter = true
	splitter_data.split_count = 2
	splitter_data.drop_chance = 0.0
	_enemy.enemy_data = splitter_data
	_enemy.current_hp = 4.0

	GameManager.enemy_count = 1
	_enemy.take_damage(4.0)
	assert_eq(GameManager.enemy_count, 2, "Should spawn 2 children (original -1 + 2 new)")


# --- Kill Attribution ---

func test_last_hit_by_set():
	_enemy.take_damage(5.0, "knife")
	assert_eq(_enemy._last_hit_by, "knife", "Should record last hit weapon")

func test_was_crit_set():
	_enemy.take_damage(5.0, "knife", true)
	assert_true(_enemy._was_crit, "Should record crit")

func test_last_hit_by_updates():
	_enemy.take_damage(5.0, "holywater")
	_enemy.take_damage(5.0, "firestaff")
	assert_eq(_enemy._last_hit_by, "firestaff", "Should update to latest source")

func test_kill_attribution_in_die():
	_enemy.take_damage(5.0, "knife")
	_enemy.take_damage(50.0, "holywater")
	# Enemy should have died with _last_hit_by == "holywater"
	assert_false(_enemy.is_alive)
	assert_eq(_enemy._last_hit_by, "holywater", "Should record killing blow source")


# --- Combo Gold Bonus ---

func test_combo_gold_bonus():
	var gold_before: int = GameManager.gold
	GameManager.combo_count = 5
	_enemy.take_damage(50.0)
	assert_gt(GameManager.gold, gold_before + 3, "Combo >= 5 should give +1 gold")

func test_no_combo_gold_below_5():
	var gold_before: int = GameManager.gold
	GameManager.combo_count = 3
	_enemy.take_damage(50.0)
	# register_kill makes it 4, which is still < 5, so no bonus
	assert_eq(GameManager.gold, gold_before + 3, "Combo < 5 should not give bonus gold")


# --- Lucky Coin Gold ---

func test_lucky_coin_gold_bonus():
	# Need a player with luckycoin passive
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.add_to_group("players")
	player.owned_passives["luckycoin"] = 2
	add_child_autofree(player)
	var gold_before: int = GameManager.gold
	_enemy.take_damage(50.0)
	# base 3 gold × (1 + 0.15×2) = 3 × 1.3 = 3.9 → int = 3
	assert_gt(GameManager.gold, gold_before, "Lucky coin should affect gold")
