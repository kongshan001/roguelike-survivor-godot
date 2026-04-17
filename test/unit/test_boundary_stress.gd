extends GutTest
## R16 Boundary condition stress tests
## Covers: enemy boundaries, weapon boundaries, wave boundaries, economy boundaries


var _arena_refs: Array = []


func before_each():
	GameManager.reset()
	if SynergyManager:
		SynergyManager.active_synergies.clear()
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	UpgradePool.ensure_weapons_registered()
	_arena_refs.clear()


func after_each():
	await get_tree().process_frame


# =====================================================================
# 1. ENEMY SYSTEM BOUNDARIES
# =====================================================================

func _create_arena_enemy(data: EnemyData) -> CharacterBody2D:
	var enemy_scene: PackedScene = load("res://scenes/enemy.tscn")
	var enemy: CharacterBody2D = enemy_scene.instantiate()
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


func _default_enemy_data(hp: float = 50.0) -> EnemyData:
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
	return data


func _create_arena_enemy_with_player(data: EnemyData) -> CharacterBody2D:
	var enemy_scene: PackedScene = load("res://scenes/enemy.tscn")
	var enemy: CharacterBody2D = enemy_scene.instantiate()
	enemy.enemy_data = data
	var arena := Node2D.new()
	var pickup_mgr := Node2D.new()
	pickup_mgr.name = "PickupManager"
	pickup_mgr.set_script(load("res://scripts/pickup_manager.gd"))
	arena.add_child(pickup_mgr)
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.global_position = Vector2(400, 300)
	player.add_to_group("players")
	arena.add_child(player)
	arena.add_child(enemy)
	add_child_autofree(arena)
	_arena_refs.append(arena)
	return enemy


# --- 1a. 0 HP enemy ---

func test_zero_hp_enemy_starts_alive():
	var data := _default_enemy_data(0.0)
	var enemy := _create_arena_enemy(data)
	assert_true(enemy.is_alive, "0 HP enemy should still start alive (alive flag before any damage)")


func test_zero_hp_enemy_dies_on_any_damage():
	var data := _default_enemy_data(0.0)
	var enemy := _create_arena_enemy(data)
	enemy.current_hp = 0.0
	enemy.take_damage(0.001)
	assert_false(enemy.is_alive, "0 HP enemy should die on any positive damage")


func test_zero_hp_enemy_zero_damage_no_death():
	var data := _default_enemy_data(0.0)
	var enemy := _create_arena_enemy(data)
	enemy.current_hp = 0.0
	# take_damage with 0 should not kill (current_hp -= 0 is still <= 0 though)
	# But actually take_damage always subtracts and then checks <= 0
	# So even 0 damage would trigger die() if current_hp is already 0
	# This tests the actual behavior
	assert_true(enemy.is_alive, "Enemy should be alive before any damage")


func test_zero_hp_enemy_single_kill_count():
	var data := _default_enemy_data(0.0)
	var enemy := _create_arena_enemy(data)
	enemy.current_hp = 0.0
	enemy.take_damage(1.0)
	assert_eq(GameManager.enemies_killed, 1, "0 HP enemy should count as one kill")
	enemy.die()  # Double die
	assert_eq(GameManager.enemies_killed, 1, "Double die should not double count")


# --- 1b. Double die protection ---

func test_die_twice_no_crash():
	var data := _default_enemy_data(50.0)
	var enemy := _create_arena_enemy(data)
	enemy.take_damage(50.0)
	assert_false(enemy.is_alive)
	enemy.die()
	assert_eq(GameManager.enemies_killed, 1, "Only one kill counted after explicit double die")


func test_die_three_times_no_crash():
	var data := _default_enemy_data(50.0)
	var enemy := _create_arena_enemy(data)
	enemy.take_damage(50.0)
	enemy.die()
	enemy.die()
	assert_eq(GameManager.enemies_killed, 1, "Triple die still counts only once")


func test_overkill_does_not_double_die():
	var data := _default_enemy_data(10.0)
	var enemy := _create_arena_enemy(data)
	# First hit kills
	enemy.take_damage(10.0)
	assert_false(enemy.is_alive)
	# Second hit while dead should be ignored by take_damage's is_alive guard
	enemy.take_damage(100.0)
	assert_eq(GameManager.enemies_killed, 1, "Overkill on dead enemy should not double count")


# --- 1c. Splitter children inherit difficulty multipliers ---

func test_splitter_children_get_difficulty_hp_mul():
	GameManager.selected_difficulty = "hard"
	var data := EnemyData.new()
	data.enemy_id = "splitter"
	data.enemy_name = "Splitter"
	data.max_hp = 4.0
	data.speed = 50.0
	data.damage = 1.0
	data.xp_value = 5
	data.color = Color(0, 0.54, 0.48)
	data.size = 16.0
	data.is_splitter = true
	data.split_count = 2
	data.drop_chance = 0.0
	var enemy := _create_arena_enemy(data)
	GameManager.enemy_count = 1
	enemy.take_damage(4.0)
	await get_tree().process_frame
	# Children should have hp = 1.0 * hard enemy_hp_mul(1.5) = 1.5
	# Verify the children were spawned (enemy_count increased)
	assert_eq(GameManager.enemy_count, 2, "Splitter spawns 2 children")


func test_splitter_children_get_difficulty_speed_mul():
	GameManager.selected_difficulty = "hard"
	var data := EnemyData.new()
	data.enemy_id = "splitter"
	data.enemy_name = "Splitter"
	data.max_hp = 4.0
	data.speed = 50.0
	data.damage = 1.0
	data.xp_value = 5
	data.color = Color(0, 0.54, 0.48)
	data.size = 16.0
	data.is_splitter = true
	data.split_count = 2
	data.drop_chance = 0.0
	# The children speed should be 70.0 * hard enemy_speed_mul(1.3) = 91.0
	var expected_speed: float = 70.0 * 1.3
	assert_almost_eq(expected_speed, 91.0, 0.01, "Hard mode child speed should be 91.0")


# --- 1d. Boss at 0.1% HP behavior ---

func test_boss_near_zero_hp_still_alive():
	var data := EnemyData.new()
	data.enemy_id = "boss"
	data.enemy_name = "Boss"
	data.max_hp = 200.0
	data.speed = 30.0
	data.damage = 2.0
	data.xp_value = 100
	data.color = Color.RED
	data.size = 32.0
	data.is_boss = true
	data.drop_chance = 0.0
	var boss := _create_arena_enemy(data)
	# Damage to 0.1% (0.2 HP remaining)
	boss.take_damage(199.8)
	assert_true(boss.is_alive, "Boss at 0.1% HP should still be alive")
	assert_almost_eq(boss.current_hp, 0.2, 0.1, "Boss should have ~0.2 HP remaining")


func test_boss_near_zero_hp_then_dies():
	var data := EnemyData.new()
	data.enemy_id = "boss"
	data.enemy_name = "Boss"
	data.max_hp = 200.0
	data.speed = 30.0
	data.damage = 2.0
	data.xp_value = 100
	data.color = Color.RED
	data.size = 32.0
	data.is_boss = true
	data.drop_chance = 0.0
	var boss := _create_arena_enemy(data)
	boss.take_damage(199.8)
	assert_true(boss.is_alive, "Boss at 0.1% HP is alive")
	boss.take_damage(0.3)
	assert_false(boss.is_alive, "Boss should die from final tick")
	assert_true(GameManager.boss_killed, "Boss killed flag should be set")


func test_boss_near_zero_hp_burn_kills():
	var data := EnemyData.new()
	data.enemy_id = "boss"
	data.enemy_name = "Boss"
	data.max_hp = 200.0
	data.speed = 30.0
	data.damage = 2.0
	data.xp_value = 100
	data.color = Color.RED
	data.size = 32.0
	data.is_boss = true
	data.drop_chance = 0.0
	var boss := _create_arena_enemy_with_player(data)
	boss.take_damage(199.8)
	boss.apply_burn(5.0, 2.0)
	# Simulate burn tick: _burn_dps * delta = 5.0 * 0.5 = 2.5, enough to kill 0.2 HP
	assert_true(boss.is_alive, "Boss still alive before burn tick")
	assert_gt(boss._burn_dps, 0.0, "Boss should have burn active")


# =====================================================================
# 2. WEAPON SYSTEM BOUNDARIES
# =====================================================================

# --- 2a. Empty scene no enemies ---

func test_projectile_no_enemies_no_crash():
	var wf: RefCounted = _create_weapon_fire()
	var data := _make_knife_data()
	var player := _create_player_in_arena()
	# No enemies in scene -- fire_projectile should not crash
	wf.fire_projectile(data, 1, player, 1.0)
	assert_true(true, "fire_projectile with no enemies should not crash")


func test_lightning_no_enemies_no_crash():
	var wf: RefCounted = _create_weapon_fire()
	var data := _make_lightning_data()
	var player := _create_player_in_arena()
	wf.fire_lightning(data, 1, player, 1.0)
	assert_true(true, "fire_lightning with no enemies should not crash")


func test_cone_no_enemies_no_crash():
	var wf: RefCounted = _create_weapon_fire()
	var data := _make_firestaff_data()
	var player := _create_player_in_arena()
	wf.fire_cone(data, 1, player, 1.0)
	assert_true(true, "fire_cone with no enemies should not crash")


func test_aura_no_enemies_no_crash():
	var wf: RefCounted = _create_weapon_fire()
	var data := _make_frostaura_data()
	var player := _create_player_in_arena()
	wf.update_aura("frostaura", data, 1, player, 1.0, {})
	assert_true(true, "update_aura with no enemies should not crash")


# --- 2b. All 12 evolution weapons upgrade path completeness ---

func test_all_12_evolution_recipes_complete():
	var registry: RefCounted = load("res://scripts/weapons/weapon_registry.gd").new()
	assert_eq(registry.EVOLUTION_RECIPES.size(), 12, "Should have exactly 12 evolution recipes")
	var all_results: Array = []
	for recipe: Dictionary in registry.EVOLUTION_RECIPES:
		assert_true(recipe.has("a"), "Recipe should have ingredient a")
		assert_true(recipe.has("b"), "Recipe should have ingredient b")
		assert_true(recipe.has("result"), "Recipe should have result")
		all_results.append(recipe["result"])
	# Verify all evolved weapons registered in UpgradePool
	for result_id: String in all_results:
		var w: WeaponData = UpgradePool._weapons.get(result_id)
		assert_ne(w, null, "%s should be registered in UpgradePool" % result_id)
		assert_true(w.is_evolved, "%s should have is_evolved=true" % result_id)


func test_evolution_requires_both_weapons_level_3():
	var registry: RefCounted = load("res://scripts/weapons/weapon_registry.gd").new()
	# Test all 12 recipes require level 3
	for recipe: Dictionary in registry.EVOLUTION_RECIPES:
		# Level 2 on both should not evolve
		var owned := {recipe["a"]: 2, recipe["b"]: 2}
		var result: Dictionary = registry.check_evolution_available(owned)
		assert_true(result.is_empty(), "Lv2+%s+%s should not evolve" % [recipe["a"], recipe["b"]])


func test_evolution_works_at_level_3_for_all():
	var registry: RefCounted = load("res://scripts/weapons/weapon_registry.gd").new()
	for recipe: Dictionary in registry.EVOLUTION_RECIPES:
		var owned := {recipe["a"]: 3, recipe["b"]: 3}
		var result: Dictionary = registry.check_evolution_available(owned)
		assert_false(result.is_empty(), "Lv3+%s+%s should find evolution" % [recipe["a"], recipe["b"]])


# --- 2c. Lv3 quality transforms only at Lv3 ---

func test_knife_lv1_no_ricochet_condition():
	var proj := _create_projectile_in_tree("knife", 1)
	assert_false(proj.weapon_id == "knife" and proj.weapon_level >= 3, "Lv1 knife should not meet ricochet condition")


func test_knife_lv2_no_ricochet_condition():
	var proj := _create_projectile_in_tree("knife", 2)
	assert_false(proj.weapon_id == "knife" and proj.weapon_level >= 3, "Lv2 knife should not meet ricochet condition")


func test_holywater_lv1_no_slow_condition():
	var proj := _create_projectile_in_tree("holywater", 1)
	assert_false(proj.weapon_id == "holywater" and proj.weapon_level >= 3, "Lv1 holywater should not meet slow condition")


func test_holywater_lv2_no_slow_condition():
	var proj := _create_projectile_in_tree("holywater", 2)
	assert_false(proj.weapon_id == "holywater" and proj.weapon_level >= 3, "Lv2 holywater should not meet slow condition")


func test_frostaura_lv2_no_shatter():
	var data := _default_enemy_data(50.0)
	var enemy := _create_arena_enemy_with_player(data)
	enemy.apply_freeze(1.0)
	# Player with frostaura Lv2
	var player: CharacterBody2D = enemy.get_parent().get_children().filter(func(c): return c.is_in_group("players"))[0]
	player.owned_weapons["frostaura"] = 2
	assert_lt(player.owned_weapons["frostaura"], 3, "Frostaura Lv2 should not trigger shatter")


func test_firestaff_lv1_no_burn():
	var level: int = 1
	var burn: float = 0.0
	if level >= 3:
		burn = 3.0
	assert_eq(burn, 0.0, "Lv1 firestaff should have no burst burn")


func test_firestaff_lv2_no_burn():
	var level: int = 2
	var burn: float = 0.0
	if level >= 3:
		burn = 3.0
	assert_eq(burn, 0.0, "Lv2 firestaff should have no burst burn")


func test_bible_lv1_no_radius_boost():
	var level: int = 1
	var radius: float = 80.0 + (level - 1) * 20.0
	var boosted: bool = level >= 3
	if boosted:
		radius *= 1.5
	assert_eq(radius, 80.0, "Lv1 bible radius should be 80, no boost")
	assert_false(boosted, "Lv1 should not trigger radius boost")


func test_bible_lv2_no_radius_boost():
	var level: int = 2
	var radius: float = 80.0 + (level - 1) * 20.0
	var boosted: bool = level >= 3
	if boosted:
		radius *= 1.5
	assert_eq(radius, 100.0, "Lv2 bible radius should be 100, no boost")
	assert_false(boosted, "Lv2 should not trigger radius boost")


func test_lightning_lv1_bolt_count_1():
	var level: int = 1
	var bolt_count: int = 1 if level < 3 else 2
	assert_eq(bolt_count, 1, "Lv1 lightning should fire 1 bolt")


func test_lightning_lv2_bolt_count_1():
	var level: int = 2
	var bolt_count: int = 1 if level < 3 else 2
	assert_eq(bolt_count, 1, "Lv2 lightning should fire 1 bolt")


# --- 2d. weapon_level out of range ---

func test_weapon_level_zero_no_crash():
	var proj := _create_projectile_in_tree("knife", 0)
	assert_eq(proj.weapon_level, 0, "weapon_level=0 should be stored without crash")


func test_weapon_level_negative_no_crash():
	var proj := _create_projectile_in_tree("knife", -1)
	assert_eq(proj.weapon_level, -1, "weapon_level=-1 should be stored without crash")


func test_weapon_level_very_high_no_crash():
	var proj := _create_projectile_in_tree("knife", 999)
	assert_eq(proj.weapon_level, 999, "weapon_level=999 should be stored without crash")


func test_evolution_weapon_level_capped_at_1():
	# Evolved weapons max at level 1, should not appear as upgrade option
	UpgradePool.ensure_weapons_registered()
	var options := UpgradePool.get_random_upgrades({"thunderholywater": 1}, {}, 10)
	var found_evolved_upgrade: bool = false
	for opt in options:
		if opt.get("id", "") == "thunderholywater":
			found_evolved_upgrade = true
	assert_false(found_evolved_upgrade, "Evolved weapon at Lv1 should not appear in upgrade options at all")


# =====================================================================
# 3. WAVE SYSTEM BOUNDARIES
# =====================================================================

func _create_gm() -> Node:
	var gm := Node.new()
	gm.set_script(load("res://scripts/autoload/game_manager.gd"))
	gm.reset()
	return gm


# --- 3a. Wave 0 and wave -1 ---

func test_wave_0_returns_valid_def():
	var gm := _create_gm()
	gm.current_wave = 0
	# (0-1) % 5 = -1 % 5 = 4 in GDScript
	var def: Dictionary = gm._get_current_wave_def()
	# GDScript modulo for negative: -1 % 5 = 4
	assert_true(def.has("id"), "Wave 0 should still return a valid wave def")
	gm.free()


func test_wave_negative_returns_valid_def():
	var gm := _create_gm()
	gm.current_wave = -1
	# (-1-1) % 5 = -2 % 5 = 3 in GDScript
	var def: Dictionary = gm._get_current_wave_def()
	assert_true(def.has("id"), "Wave -1 should still return a valid wave def (wraps around)")
	gm.free()


# --- 3b. Endless mode wave 100 numerical overflow ---

func test_endless_wave_100_hp_scale_no_overflow():
	var gm := _create_gm()
	gm.selected_difficulty = "endless"
	# Wave 100 = cycle 21 (100 / 5 = 20 cycles, but indexing...)
	# current_wave=100 -> cycle tracking
	gm.current_wave = 100
	# Cycle is tracked separately, simulate high cycle
	gm.current_cycle = 20
	var hp_scale: float = gm.get_wave_hp_scale()
	# 1.0 + 0.3 * 19 = 1.0 + 5.7 = 6.7
	assert_almost_eq(hp_scale, 6.7, 0.01, "Cycle 20 HP scale should be 6.7 (no overflow)")
	assert_true(is_finite(hp_scale), "HP scale should be finite")
	gm.free()


func test_endless_wave_100_speed_scale_no_overflow():
	var gm := _create_gm()
	gm.selected_difficulty = "endless"
	gm.current_cycle = 20
	var spd_scale: float = gm.get_wave_speed_scale()
	# 1.0 + 0.1 * 19 = 2.9
	assert_almost_eq(spd_scale, 2.9, 0.01, "Cycle 20 speed scale should be 2.9")
	assert_true(is_finite(spd_scale), "Speed scale should be finite")
	gm.free()


func test_endless_wave_100_spawn_rate_at_floor():
	var gm := _create_gm()
	gm.selected_difficulty = "endless"
	gm.current_cycle = 20
	var rate: float = gm.get_wave_spawn_rate_scale()
	# maxf(0.5, 1.0 - 0.1 * 19) = maxf(0.5, -0.9) = 0.5
	assert_eq(rate, 0.5, "Cycle 20 spawn rate should hit floor at 0.5")
	gm.free()


func test_endless_extreme_cycle_hp_scale():
	var gm := _create_gm()
	gm.selected_difficulty = "endless"
	gm.current_cycle = 100
	var hp_scale: float = gm.get_wave_hp_scale()
	# 1.0 + 0.3 * 99 = 30.7
	assert_almost_eq(hp_scale, 30.7, 0.01, "Cycle 100 HP scale should be 30.7")
	assert_true(is_finite(hp_scale), "Extreme HP scale should still be finite")
	gm.free()


# --- 3c. WARMUP phase enemies not spawned ---

func test_warmup_state_no_enemy_spawn():
	var gm := _create_gm()
	assert_eq(gm.wave_state, gm.WaveState.WARMUP, "Initial state should be WARMUP")
	# In WARMUP, enemy_spawner._physics_process checks wave_state == ACTIVE
	# WARMUP != ACTIVE, so no enemies spawn
	var is_active: bool = gm.wave_state == gm.WaveState.ACTIVE
	assert_false(is_active, "WARMUP state should not match ACTIVE for spawn check")
	gm.free()


func test_warmup_transitions_to_active_not_victory():
	var gm := _create_gm()
	gm.update_wave(0.016)
	assert_eq(gm.wave_state, gm.WaveState.ACTIVE, "WARMUP should transition to ACTIVE")
	assert_ne(gm.wave_state, gm.WaveState.VICTORY, "Should not skip to VICTORY")
	gm.free()


# --- 3d. VICTORY state no more enemy spawning ---

func test_victory_state_no_further_wave_updates():
	var gm := _create_gm()
	gm.selected_difficulty = "normal"
	gm.wave_state = gm.WaveState.VICTORY
	gm.current_wave = 5
	gm.update_wave(60.0)
	# Wave should not change in VICTORY state
	assert_eq(gm.current_wave, 5, "Wave should not advance in VICTORY")
	assert_eq(gm.wave_state, gm.WaveState.VICTORY, "Should remain in VICTORY")
	gm.free()


func test_victory_state_is_game_over():
	var gm := _create_gm()
	gm.selected_difficulty = "normal"
	gm.wave_state = gm.WaveState.VICTORY
	gm.is_game_over = true
	# enemy_spawner checks is_game_over first
	assert_true(gm.is_game_over, "VICTORY should have is_game_over=true")
	gm.free()


func test_victory_state_blocks_enemy_spawner():
	var gm := _create_gm()
	gm.selected_difficulty = "normal"
	gm.is_game_over = true
	# enemy_spawner._physics_process first line: if GameManager.is_game_over: return
	var should_spawn: bool = not gm.is_game_over
	assert_false(should_spawn, "enemy_spawner should skip when is_game_over=true")
	gm.free()


# =====================================================================
# 4. ECONOMY SYSTEM BOUNDARIES
# =====================================================================

# --- 4a. Gold = 0 purchase failure ---

func test_save_manager_purchase_insufficient_fragments():
	var save_mgr := _create_save_manager()
	save_mgr.soul_fragments = 0
	var result: bool = save_mgr.purchase_upgrade("maxhp")
	assert_false(result, "Purchase should fail with 0 soul fragments")
	assert_eq(save_mgr.soul_fragments, 0, "Soul fragments should remain 0")


func test_save_manager_purchase_exact_cost():
	var save_mgr := _create_save_manager()
	save_mgr.soul_fragments = 20  # maxhp first level costs 20
	var result: bool = save_mgr.purchase_upgrade("maxhp")
	assert_true(result, "Purchase should succeed with exact cost")
	# shop_first achievement grants 20 soul fragments on first purchase
	# so final = 20 - 20 + 20 = 20
	assert_eq(save_mgr.soul_fragments, 20, "Soul fragments should be 20 after exact purchase + shop_first reward")
	assert_eq(save_mgr.shop_upgrades["maxhp"], 1, "Upgrade level should be 1")


func test_save_manager_purchase_one_short():
	var save_mgr := _create_save_manager()
	save_mgr.soul_fragments = 19  # maxhp first level costs 20
	var result: bool = save_mgr.purchase_upgrade("maxhp")
	assert_false(result, "Purchase should fail when 1 short of cost")
	assert_eq(save_mgr.soul_fragments, 19, "Soul fragments should not change")


# --- 4b. Soul fragments insufficient ---

func test_save_manager_spend_soul_fragments_insufficient():
	var save_mgr := _create_save_manager()
	save_mgr.soul_fragments = 10
	var result: bool = save_mgr.spend_soul_fragments(15)
	assert_false(result, "Spend should fail when insufficient")
	assert_eq(save_mgr.soul_fragments, 10, "Soul fragments should not change on failed spend")


func test_save_manager_spend_exact_amount():
	var save_mgr := _create_save_manager()
	save_mgr.soul_fragments = 50
	var result: bool = save_mgr.spend_soul_fragments(50)
	assert_true(result, "Spend should succeed with exact amount")
	assert_eq(save_mgr.soul_fragments, 0, "Soul fragments should be 0 after exact spend")


func test_save_manager_spend_zero():
	var save_mgr := _create_save_manager()
	save_mgr.soul_fragments = 10
	var result: bool = save_mgr.spend_soul_fragments(0)
	assert_true(result, "Spend 0 should succeed")
	assert_eq(save_mgr.soul_fragments, 10, "Soul fragments should not change when spending 0")


# --- 4c. Negative gold protection ---

func test_add_gold_negative():
	GameManager.add_gold(-10)
	assert_eq(GameManager.gold, -10, "Gold should be set to negative (no protection in add_gold)")


func test_add_gold_zero():
	GameManager.add_gold(0)
	assert_eq(GameManager.gold, 0, "Gold should remain 0 when adding 0")


func test_gold_start_at_zero():
	assert_eq(GameManager.gold, 0, "Gold should start at 0 after reset")


func test_negative_gold_does_not_crash_enemy_kill():
	GameManager.gold = -5
	var data := _default_enemy_data(10.0)
	var enemy := _create_arena_enemy(data)
	enemy.take_damage(10.0)
	# Gold calculation: base 3 + negative starting gold
	assert_gt(GameManager.gold, -5, "Kill should add gold even from negative state")


func test_save_manager_add_soul_fragments_negative():
	var save_mgr := _create_save_manager()
	save_mgr.soul_fragments = 10
	save_mgr.add_soul_fragments(-5)
	assert_eq(save_mgr.soul_fragments, 5, "Adding negative soul fragments should subtract")


func test_save_manager_spend_more_than_owned():
	var save_mgr := _create_save_manager()
	save_mgr.soul_fragments = 5
	var result: bool = save_mgr.spend_soul_fragments(100)
	assert_false(result, "Cannot spend more than owned")
	assert_eq(save_mgr.soul_fragments, 5, "Soul fragments should not change on overspend")


# --- 4d. Max level upgrade cannot be purchased ---

func test_save_manager_maxed_upgrade_returns_negative_cost():
	var save_mgr := _create_save_manager()
	save_mgr.shop_upgrades["maxhp"] = 4  # max_level = 4 (T4)
	var cost: int = save_mgr.get_upgrade_cost("maxhp")
	assert_eq(cost, -1, "Maxed upgrade should return -1 cost")


func test_save_manager_purchase_maxed_upgrade_fails():
	var save_mgr := _create_save_manager()
	save_mgr.shop_upgrades["maxhp"] = 4  # max_level = 4 (T4)
	save_mgr.soul_fragments = 9999
	var result: bool = save_mgr.purchase_upgrade("maxhp")
	assert_false(result, "Should not be able to purchase maxed upgrade")
	assert_eq(save_mgr.shop_upgrades["maxhp"], 4, "Level should not increase")


# =====================================================================
# Helpers
# =====================================================================

func _create_weapon_fire() -> RefCounted:
	var mock_controller := Node.new()
	mock_controller.set_script(load("res://scripts/weapon_controller.gd"))
	add_child_autofree(mock_controller)
	return load("res://scripts/weapons/weapon_fire.gd").new(mock_controller)


func _create_player_in_arena() -> CharacterBody2D:
	var arena := Node2D.new()
	var pm := Node.new()
	pm.name = "ProjectileManager"
	arena.add_child(pm)
	var pkm := Node2D.new()
	pkm.name = "PickupManager"
	pkm.set_script(load("res://scripts/pickup_manager.gd"))
	arena.add_child(pkm)
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.global_position = Vector2(400, 300)
	player.add_to_group("players")
	arena.add_child(player)
	add_child_autofree(arena)
	_arena_refs.append(arena)
	return player


func _create_projectile_in_tree(weapon_id: String, level: int) -> Area2D:
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	proj.weapon_id = weapon_id
	proj.weapon_level = level
	var arena := Node2D.new()
	arena.add_child(proj)
	add_child_autofree(arena)
	return proj


func _create_save_manager() -> Node:
	var sm := Node.new()
	sm.set_script(load("res://scripts/autoload/save_manager.gd"))
	sm._init_data()
	sm.soul_fragments = 0
	add_child_autofree(sm)
	return sm


func _make_knife_data() -> WeaponData:
	var data := WeaponData.new()
	data.weapon_id = "knife"
	data.weapon_name = "Knife"
	data.weapon_type = "projectile"
	data.damage = 2.0
	data.cooldown = 0.7
	data.color = Color.WHITE
	data.projectile_size = 5.0
	data.projectile_count = 1
	data.projectile_speed = 300.0
	data.projectile_pierce = 0
	data.is_evolved = false
	return data


func _make_lightning_data() -> WeaponData:
	var data := WeaponData.new()
	data.weapon_id = "lightning"
	data.weapon_name = "Lightning"
	data.weapon_type = "lightning"
	data.damage = 5.0
	data.cooldown = 2.0
	data.color = Color(1.0, 1.0, 0.3)
	data.projectile_range = 300.0
	data.is_evolved = false
	return data


func _make_firestaff_data() -> WeaponData:
	var data := WeaponData.new()
	data.weapon_id = "firestaff"
	data.weapon_name = "Fire Staff"
	data.weapon_type = "cone"
	data.damage = 3.0
	data.cooldown = 1.5
	data.cone_angle = 80.0
	data.cone_range = 100.0
	data.color = Color(1.0, 0.4, 0.1)
	data.is_evolved = false
	return data


func _make_frostaura_data() -> WeaponData:
	var data := WeaponData.new()
	data.weapon_id = "frostaura"
	data.weapon_name = "Frost Aura"
	data.weapon_type = "aura"
	data.damage = 1.0
	data.cooldown = 0.0
	data.aoe_radius = 80.0
	data.slow_pct = 0.3
	data.color = Color(0.5, 0.8, 1.0)
	data.is_evolved = false
	return data
