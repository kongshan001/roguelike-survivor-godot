extends GutTest
## Tests for enemy animation effects in enemy.gd and enemy_death_effects.gd.
## Validates: hit feedback (flash + shake), death animation dispatch,
## per-enemy-type death parameters, death max duration, animation state vars.
## R19 QA Task 2


var _enemy: CharacterBody2D
var _arena: Node2D
var _death_fx: RefCounted


func before_each():
	GameManager.reset()
	GameManager.elapsed_time = 0.0
	GameManager.selected_difficulty = "normal"
	_arena = Node2D.new()
	_arena.name = "Arena"
	add_child_autofree(_arena)
	# Add PickupManager so XP gem spawn has a parent (prevents orphan gems)
	var pm: Node = Node.new()
	pm.name = "PickupManager"
	_arena.add_child(pm)
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.name = "Player"
	player.add_to_group("players")
	_arena.add_child(player)
	if SaveManager:
		for id in SaveManager.SHOP_UPGRADES:
			SaveManager.shop_upgrades[id] = 0
	_enemy = _create_enemy()
	_arena.add_child(_enemy)
	_death_fx = load("res://scripts/enemies/enemy_death_effects.gd").new()


func after_each():
	# Wait for death animation + queue_free + call_deferred completions
	await get_tree().process_frame


func _create_enemy() -> CharacterBody2D:
	var data: EnemyData = EnemyData.new()
	data.enemy_id = "skeleton"
	data.enemy_name = "Skeleton"
	data.max_hp = 10.0
	data.speed = 60.0
	data.damage = 1.0
	data.xp_value = 1
	data.color = Color(0.6, 0.8, 0.4)
	data.size = 16.0
	data.drop_chance = 0.0
	var enemy: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	enemy.enemy_data = data
	enemy.global_position = Vector2(500, 300)
	return enemy


# ============================================================
# Section 1: enemy_death_effects.gd Constants
# ============================================================

func test_hit_flash_color_constant():
	assert_eq(_death_fx.HIT_FLASH_COLOR, Color(8, 8, 8),
		"HIT_FLASH_COLOR should be HDR white (8,8,8)")


func test_hit_flash_duration_constant():
	assert_eq(_death_fx.HIT_FLASH_DURATION, 0.1,
		"HIT_FLASH_DURATION should be 0.1s")


func test_shake_strength_constant():
	assert_eq(_death_fx.SHAKE_STRENGTH, 2.0,
		"SHAKE_STRENGTH should be 2.0px")


func test_shake_step_duration_constant():
	assert_eq(_death_fx.SHAKE_STEP_DURATION, 0.03,
		"SHAKE_STEP_DURATION should be 0.03s")


func test_shake_return_duration_constant():
	assert_eq(_death_fx.SHAKE_RETURN_DURATION, 0.02,
		"SHAKE_RETURN_DURATION should be 0.02s")


func test_elite_skeleton_red_linger_constant():
	assert_eq(_death_fx.ELITE_SKELETON_RED_LINGER, 0.08,
		"ELITE_SKELETON_RED_LINGER should be 0.08s")


func test_elite_skeleton_recover_constant():
	assert_eq(_death_fx.ELITE_SKELETON_RECOVER, 0.07,
		"ELITE_SKELETON_RECOVER should be 0.07s")


func test_elite_knight_purple_linger_constant():
	assert_eq(_death_fx.ELITE_KNIGHT_PURPLE_LINGER, 0.1,
		"ELITE_KNIGHT_PURPLE_LINGER should be 0.1s")


func test_elite_knight_recover_constant():
	assert_eq(_death_fx.ELITE_KNIGHT_RECOVER, 0.1,
		"ELITE_KNIGHT_RECOVER should be 0.1s")


# ============================================================
# Section 2: Death Animation Dispatch (per enemy_id)
# ============================================================

func test_death_animation_has_play_method():
	assert_true(_death_fx.has_method("play_death_animation"),
		"enemy_death_effects should have play_death_animation method")


func test_death_animation_has_play_hit_feedback():
	assert_true(_death_fx.has_method("play_hit_feedback"),
		"enemy_death_effects should have play_hit_feedback method")


func test_death_animation_dispatches_zombie():
	# Verify zombie death animation exists in the match table
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find('"zombie"') != -1, "Death dispatch should handle zombie")


func test_death_animation_dispatches_bat():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find('"bat"') != -1, "Death dispatch should handle bat")


func test_death_animation_dispatches_skeleton():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find('"skeleton"') != -1, "Death dispatch should handle skeleton")


func test_death_animation_dispatches_elite_skeleton():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find('"elite_skeleton"') != -1, "Death dispatch should handle elite_skeleton")


func test_death_animation_dispatches_ghost():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find('"ghost"') != -1, "Death dispatch should handle ghost")


func test_death_animation_dispatches_splitter():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find('"splitter"') != -1, "Death dispatch should handle splitter")


func test_death_animation_dispatches_fire_slime():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find('"fire_slime"') != -1, "Death dispatch should handle fire_slime")


func test_death_animation_dispatches_elite_knight():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find('"elite_knight"') != -1, "Death dispatch should handle elite_knight")


func test_death_animation_dispatches_boss():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find('"boss"') != -1, "Death dispatch should handle boss")


func test_death_animation_has_default_fallback():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find("_play_default_death") != -1,
		"Death dispatch should have _play_default_death fallback")


# ============================================================
# Section 3: Death Max Duration per Enemy Type (enemy.gd)
# ============================================================

func test_death_max_duration_skeleton():
	assert_eq(_enemy._get_death_max_duration(), 0.45,
		"Skeleton death max duration should be 0.45s")


func test_death_max_duration_default():
	# Skeleton is the default enemy in our test setup
	assert_eq(_enemy._get_death_max_duration(), 0.45,
		"Default death max duration for skeleton should be 0.45s")


func test_death_max_duration_boss():
	var boss_data: EnemyData = EnemyData.new()
	boss_data.enemy_id = "boss"
	boss_data.max_hp = 100.0
	boss_data.speed = 40.0
	boss_data.damage = 3.0
	boss_data.xp_value = 20
	boss_data.size = 32.0
	boss_data.is_boss = true
	boss_data.drop_chance = 0.0
	var boss: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	boss.enemy_data = boss_data
	boss.global_position = Vector2(400, 300)
	_arena.add_child(boss)
	assert_eq(boss._get_death_max_duration(), 0.85,
		"Boss death max duration should be 0.85s")


func test_death_max_duration_ghost():
	var ghost_data: EnemyData = EnemyData.new()
	ghost_data.enemy_id = "ghost"
	ghost_data.max_hp = 5.0
	ghost_data.speed = 80.0
	ghost_data.damage = 1.0
	ghost_data.xp_value = 2
	ghost_data.size = 16.0
	ghost_data.can_phase_shift = true
	ghost_data.drop_chance = 0.0
	var ghost: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	ghost.enemy_data = ghost_data
	ghost.global_position = Vector2(400, 300)
	_arena.add_child(ghost)
	assert_eq(ghost._get_death_max_duration(), 0.4,
		"Ghost death max duration should be 0.4s")


func test_death_max_duration_splitter():
	var splitter_data: EnemyData = EnemyData.new()
	splitter_data.enemy_id = "splitter"
	splitter_data.max_hp = 5.0
	splitter_data.speed = 50.0
	splitter_data.damage = 1.0
	splitter_data.xp_value = 1
	splitter_data.size = 16.0
	splitter_data.is_splitter = true
	splitter_data.split_count = 2
	splitter_data.drop_chance = 0.0
	var splitter: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	splitter.enemy_data = splitter_data
	splitter.global_position = Vector2(400, 300)
	_arena.add_child(splitter)
	assert_eq(splitter._get_death_max_duration(), 0.25,
		"Splitter death max duration should be 0.25s")


func test_death_max_duration_elite_skeleton():
	var elite_data: EnemyData = EnemyData.new()
	elite_data.enemy_id = "elite_skeleton"
	elite_data.max_hp = 30.0
	elite_data.speed = 55.0
	elite_data.damage = 2.0
	elite_data.xp_value = 8
	elite_data.size = 16.0
	elite_data.is_ranged = true
	elite_data.is_elite = true
	elite_data.drop_chance = 0.0
	var elite: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	elite.enemy_data = elite_data
	elite.global_position = Vector2(400, 300)
	_arena.add_child(elite)
	assert_eq(elite._get_death_max_duration(), 0.45,
		"Elite skeleton death max duration should be 0.45s")


func test_death_max_duration_fire_slime():
	var fire_data: EnemyData = EnemyData.new()
	fire_data.enemy_id = "fire_slime"
	fire_data.max_hp = 8.0
	fire_data.speed = 45.0
	fire_data.damage = 1.0
	fire_data.xp_value = 2
	fire_data.size = 16.0
	fire_data.has_burn_aura = true
	fire_data.drop_chance = 0.0
	var fire_slime: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	fire_slime.enemy_data = fire_data
	fire_slime.global_position = Vector2(400, 300)
	_arena.add_child(fire_slime)
	assert_eq(fire_slime._get_death_max_duration(), 0.4,
		"Fire slime death max duration should be 0.4s")


# ============================================================
# Section 4: Death Animation Integration (enemy.gd)
# ============================================================

func test_die_marks_not_alive():
	assert_true(_enemy.is_alive, "Enemy should start alive")
	_enemy.take_damage(999.0)
	assert_false(_enemy.is_alive, "Enemy should not be alive after die()")


func test_die_unregisters_from_game_manager_cache():
	# die() calls GameManager.unregister_enemy(self) which removes from cache
	_enemy.take_damage(999.0)
	# Verify enemy is no longer in GameManager's enemy cache
	var cached: Array = GameManager.get_cached_enemies()
	assert_false(_enemy in cached,
		"Dead enemy should be removed from GameManager cache")


func test_die_calls_queue_free_after_animation():
	# die() now calls _play_death_animation_and_free() which delays queue_free
	_enemy.take_damage(999.0)
	# Wait for death animation + queue_free
	await get_tree().create_timer(0.6).timeout
	assert_false(is_instance_valid(_enemy), "Enemy should be freed after death animation")


func test_double_die_protection():
	_enemy.take_damage(999.0)
	assert_false(_enemy.is_alive, "First die should kill enemy")
	_enemy.die()
	assert_false(_enemy.is_alive, "Double die should not cause errors")


func test_die_disables_physics():
	# die() calls set_physics_process(false) before animation
	_enemy.take_damage(999.0)
	assert_false(_enemy.is_physics_processing(),
		"Dead enemy should have physics processing disabled")


# ============================================================
# Section 5: Death Effects Module Structure
# ============================================================

func test_death_effects_is_refcounted():
	# enemy_death_effects.gd extends RefCounted (not Node)
	assert_true(_death_fx is RefCounted,
		"Death effects module should be RefCounted")


func test_death_effects_has_death_methods():
	var methods: Array = ["play_death_animation", "play_hit_feedback",
		"_play_default_death", "_play_zombie_death", "_play_bat_death",
		"_play_skeleton_death", "_play_ghost_death", "_play_boss_death"]
	for method in methods:
		assert_true(_death_fx.has_method(method),
			"Death effects should have method: %s" % method)


func test_death_effects_has_elite_methods():
	assert_true(_death_fx.has_method("_play_elite_skeleton_death"),
		"Should have _play_elite_skeleton_death")
	assert_true(_death_fx.has_method("_play_elite_knight_death"),
		"Should have _play_elite_knight_death")
	assert_true(_death_fx.has_method("_play_elite_skeleton_hit"),
		"Should have _play_elite_skeleton_hit")
	assert_true(_death_fx.has_method("_play_elite_knight_hit"),
		"Should have _play_elite_knight_hit")


# ============================================================
# Section 6: Death Animation Timeline Verification
# ============================================================

func test_boss_death_has_4_stages():
	# Boss death: shock -> shake(3x) -> explode -> gold_flash -> vanish
	var source: String = _death_fx.get_script().source_code
	# Stage 1: shock expand
	assert_true(source.find("1.15, 1.15") != -1, "Boss death should have shock expand")
	# Stage 3: explode
	assert_true(source.find("2.0, 2.0") != -1, "Boss death should have explode scale")
	# Stage 4: gold flash
	assert_true(source.find("1.0, 0.9, 0.3") != -1, "Boss death should have gold flash")


func test_zombie_death_darkens_to_brown():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find("0.3, 0.2, 0.1") != -1,
		"Zombie death should darken to brown (0.3, 0.2, 0.1)")


func test_bat_death_spins():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find("TAU") != -1,
		"Bat death should include full rotation (TAU)")


func test_splitter_death_expands_then_pops():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find("1.5, 1.5") != -1,
		"Splitter death should expand before popping")


func test_fire_slime_death_extinguish():
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find("0.3, 0.15, 0.05") != -1,
		"Fire slime death should darken to charred color")


func test_ghost_death_floats_up():
	# Ghost death: floats upward via position:y tween to (base_y - 15.0)
	var source: String = _death_fx.get_script().source_code
	assert_true(source.find("base_y - 15.0") != -1,
		"Ghost death should float upward by 15px")


# ============================================================
# Section 7: Enemy Animation State Variables
# ============================================================

func test_enemy_has_no_flash_timer():
	# R19: _flash_timer removed from enemy.gd, flash now handled by
	# enemy_death_effects.gd play_hit_feedback()
	assert_false("_flash_timer" in _enemy,
		"Enemy should NOT have _flash_timer (moved to enemy_death_effects.gd)")


func test_enemy_has_is_alive_variable():
	assert_true("is_alive" in _enemy, "Enemy should have is_alive variable")


func test_enemy_has_boss_ai_variable():
	assert_true("_boss_ai" in _enemy, "Enemy should have _boss_ai variable")


func test_enemy_boss_ai_null_for_non_boss():
	assert_null(_enemy._boss_ai, "Non-boss enemy should have null _boss_ai")


func test_enemy_has_split_flag():
	assert_true("_has_split" in _enemy, "Enemy should have _has_split variable")
	assert_false(_enemy._has_split, "Split flag should start false")


func test_enemy_has_death_effects_variable():
	assert_true("_death_effects" in _enemy, "Enemy should have _death_effects variable")


func test_enemy_has_get_death_effects_method():
	assert_true(_enemy.has_method("_get_death_effects"),
		"Enemy should have _get_death_effects method")


func test_enemy_has_play_death_animation_method():
	assert_true(_enemy.has_method("_play_death_animation_and_free"),
		"Enemy should have _play_death_animation_and_free method")


func test_enemy_has_get_death_max_duration_method():
	assert_true(_enemy.has_method("_get_death_max_duration"),
		"Enemy should have _get_death_max_duration method")
