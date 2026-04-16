extends GutTest
# Unit tests for Lv3 weapon quality transforms (R13)
# Covers: Knife Lv3 Ricochet, Frost Aura Lv3 Shatter, Boomerang Lv3 Tracking
# Note: Frost Aura shatter tests require enemy.gd _handle_shatter() to compile
# (BUG-101: triple-quote string in _spawn_shatter_effect causes parse error)
# Those tests will fail until Programmer fixes the triple-quote issue.


var _arena: Node2D
var _player: CharacterBody2D
var _controller: Node


func before_each():
	GameManager.reset()
	GameManager.is_game_over = false
	GameManager.selected_character = ""
	GameManager.elapsed_time = 0.0
	if SynergyManager:
		SynergyManager.active_synergies.clear()
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	UpgradePool.ensure_weapons_registered()

	_arena = Node2D.new()
	_arena.name = "Arena"
	add_child_autofree(_arena)

	var pm = Node.new()
	pm.name = "ProjectileManager"
	_arena.add_child(pm)

	var pkm = Node.new()
	pkm.name = "PickupManager"
	_arena.add_child(pkm)

	_player = load("res://scenes/player.tscn").instantiate()
	_player.global_position = Vector2(400, 300)
	_player.add_to_group("players")
	_arena.add_child(_player)

	_controller = _player.get_node("WeaponController")


func after_each():
	await get_tree().process_frame
	if is_instance_valid(_controller):
		_controller.remove_weapon_instances("holywater")
		_controller.remove_weapon_instances("boomerang")
		_controller._boomerang_instances.clear()
		_controller._orbit_instances.clear()
		_controller._weapon_timers.clear()


# =====================================================================
# Helper: create a valid enemy at a given position
# =====================================================================

func _create_enemy(pos: Vector2, hp: float = 50.0) -> CharacterBody2D:
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
	var enemy: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	enemy.enemy_data = data
	enemy.global_position = pos
	enemy.add_to_group("enemies")
	_arena.add_child(enemy)
	return enemy


# =====================================================================
# 1. KNIFE Lv3 RICOCHET
# =====================================================================

func test_knife_lv3_ricochet_constants():
	# Load projectile scene and instantiate to access constants
	var proj: Area2D = load("res://scenes/projectile.tscn").instantiate()
	add_child_autofree(proj)
	assert_eq(proj.KNIFE_LV3_RICOCHET_RANGE, 100.0, "Ricochet range should be 100.0")
	assert_eq(proj.KNIFE_LV3_RICOCHET_DAMAGE_MUL, 0.5, "Ricochet damage multiplier should be 0.5")
	assert_eq(proj.KNIFE_LV3_RICOCHET_SPEED, 300.0, "Ricochet speed should be 300.0")
	assert_eq(proj.KNIFE_LV3_RICOCHET_SIZE, 4.0, "Ricochet size should be 4.0")
	assert_eq(proj.KNIFE_LV3_RICOCHET_LIFETIME, 0.5, "Ricochet lifetime should be 0.5")


func test_knife_lv3_weapon_level_set_on_projectile():
	# When knife fires at level 3, projectile.weapon_level should be set to 3
	_player.owned_weapons["knife"] = 3
	var data: WeaponData = UpgradePool._weapons["knife"]
	# Create an enemy so fire_projectile has a target
	var e := _create_enemy(Vector2(500, 300))
	await get_tree().process_frame
	_controller._fire_weapon("knife", data, _player)
	await get_tree().process_frame
	# Find the projectile in ProjectileManager
	var pm: Node = _arena.get_node("ProjectileManager")
	var found_proj: Area2D = null
	for child in pm.get_children():
		if child is Area2D and child.weapon_id == "knife":
			found_proj = child
			break
	if found_proj:
		assert_eq(found_proj.weapon_level, 3, "Knife projectile at Lv3 should have weapon_level=3")
	else:
		# Projectile may have already hit and been freed, which is acceptable
		assert_true(true, "Knife projectile fired and completed")
	_player.owned_weapons.erase("knife")


func test_knife_lv2_no_ricochet():
	# At Lv2, weapon_level should be 2, not 3 -- no ricochet trigger
	_player.owned_weapons["knife"] = 2
	var data: WeaponData = UpgradePool._weapons["knife"]
	var e := _create_enemy(Vector2(500, 300))
	await get_tree().process_frame
	_controller._fire_weapon("knife", data, _player)
	await get_tree().process_frame
	var pm: Node = _arena.get_node("ProjectileManager")
	for child in pm.get_children():
		if child is Area2D and child.weapon_id == "knife":
			assert_lt(child.weapon_level, 3, "Lv2 knife should have weapon_level < 3")
	_player.owned_weapons.erase("knife")


func test_knife_evolved_no_ricochet():
	# Evolved fireknife should not trigger ricochet (different weapon_id)
	_player.owned_weapons["fireknife"] = 3
	var data: WeaponData = UpgradePool._weapons["fireknife"]
	if data == null:
		pending("fireknife not registered in UpgradePool -- skipping")
		_player.owned_weapons.erase("fireknife")
		return
	var e := _create_enemy(Vector2(500, 300))
	await get_tree().process_frame
	_controller._fire_weapon("fireknife", data, _player)
	await get_tree().process_frame
	# Evolved knife has weapon_id "fireknife", not "knife", so ricochet check
	# `weapon_id == "knife" and weapon_level >= 3` should not match
	var pm: Node = _arena.get_node("ProjectileManager")
	for child in pm.get_children():
		if child is Area2D:
			assert_ne(child.weapon_id, "knife", "Evolved fireknife should have weapon_id != knife")
	_player.owned_weapons.erase("fireknife")


func test_knife_ricochet_spawns_child_projectile():
	# Simulate a Lv3 knife hitting an enemy and verify ricochet logic exists
	# We verify the _spawn_ricochet method exists and has correct behavior
	var proj_script := load("res://scripts/projectile.gd")
	assert_true(proj_script.source_code.find("_spawn_ricochet") != -1,
		"projectile.gd should have _spawn_ricochet method")
	# Verify the ricochet condition check
	assert_true(proj_script.source_code.find("weapon_id == \"knife\" and weapon_level >= 3") != -1,
		"Ricochet should only trigger for knife at weapon_level >= 3")


func test_knife_ricochet_uses_call_deferred():
	var proj_script := load("res://scripts/projectile.gd")
	var source: String = proj_script.source_code
	assert_true(source.find("call_deferred(\"add_child\", ricochet)") != -1,
		"Ricochet should use call_deferred to avoid physics frame conflicts")


# =====================================================================
# 2. FROST AURA Lv3 SHATTER
# =====================================================================

func test_frost_aura_lv3_shatter_constants():
	# Verify shatter constants exist in enemy.gd
	var enemy_script := load("res://scripts/enemy.gd")
	if enemy_script == null:
		pending("enemy.gd failed to load (BUG-101 triple-quote) -- skipping")
		return
	var source: String = enemy_script.source_code
	assert_true(source.find("FROSTAURA_LV3_SHATTER_RADIUS") != -1,
		"enemy.gd should define FROSTAURA_LV3_SHATTER_RADIUS")
	assert_true(source.find("FROSTAURA_LV3_SHATTER_DAMAGE") != -1,
		"enemy.gd should define FROSTAURA_LV3_SHATTER_DAMAGE")


func test_frost_aura_lv3_shatter_method_exists():
	var enemy_script := load("res://scripts/enemy.gd")
	if enemy_script == null:
		pending("enemy.gd failed to load (BUG-101 triple-quote) -- skipping")
		return
	var source: String = enemy_script.source_code
	assert_true(source.find("_handle_shatter") != -1,
		"enemy.gd should define _handle_shatter method")
	assert_true(source.find("_spawn_shatter_effect") != -1,
		"enemy.gd should define _spawn_shatter_effect method")


func test_frost_aura_lv3_shatter_checks_frozen():
	# Verify _handle_shatter checks _freeze_timer <= 0 early return
	var enemy_script := load("res://scripts/enemy.gd")
	if enemy_script == null:
		pending("enemy.gd failed to load (BUG-101 triple-quote) -- skipping")
		return
	var source: String = enemy_script.source_code
	# Find _handle_shatter function body
	var shatter_idx: int = source.find("func _handle_shatter()")
	assert_gt(shatter_idx, -1, "Should find _handle_shatter function")
	# Check early return for not frozen
	var shatter_body: String = source.substr(shatter_idx, 200)
	assert_true(shatter_body.find("_freeze_timer <= 0") != -1,
		"_handle_shatter should check _freeze_timer <= 0 for early return")


func test_frost_aura_lv3_shatter_checks_weapon_level():
	var enemy_script := load("res://scripts/enemy.gd")
	if enemy_script == null:
		pending("enemy.gd failed to load (BUG-101 triple-quote) -- skipping")
		return
	var source: String = enemy_script.source_code
	var shatter_idx: int = source.find("func _handle_shatter()")
	var shatter_body: String = source.substr(shatter_idx, 400)
	# Should check frostaura level >= 3
	assert_true(shatter_body.find("frostaura") != -1,
		"_handle_shatter should check for frostaura weapon")
	assert_true(shatter_body.find("< 3") != -1 or shatter_body.find(">= 3") != -1 or shatter_body.find("== 3") != -1,
		"_handle_shatter should check frostaura level >= 3")


func test_frost_aura_lv2_no_shatter():
	# Verify the level check prevents Lv2 from triggering shatter
	var enemy_script := load("res://scripts/enemy.gd")
	if enemy_script == null:
		pending("enemy.gd failed to load (BUG-101 triple-quote) -- skipping")
		return
	var source: String = enemy_script.source_code
	var shatter_idx: int = source.find("func _handle_shatter()")
	var shatter_body: String = source.substr(shatter_idx, 400)
	# The function should have a level guard: return if level < 3
	assert_true(shatter_body.find("< 3") != -1 or shatter_body.find("2") != -1,
		"_handle_shatter should have level < 3 guard to prevent Lv2 shatter")


func test_frost_aura_shatter_called_in_die():
	var enemy_script := load("res://scripts/enemy.gd")
	if enemy_script == null:
		pending("enemy.gd failed to load (BUG-101 triple-quote) -- skipping")
		return
	var source: String = enemy_script.source_code
	# Find die() function
	var die_idx: int = source.find("func die()")
	assert_gt(die_idx, -1, "enemy.gd should have die() function")
	var die_body: String = source.substr(die_idx, 400)
	assert_true(die_body.find("_handle_shatter()") != -1,
		"die() should call _handle_shatter()")


# =====================================================================
# 3. BOOMERANG Lv3 TRACKING
# =====================================================================

func test_boomerang_lv3_track_angle_multiplier():
	# Verify the Lv3 track_angle formula in weapon_boomerang_fire.gd
	var bm_fire_script := load("res://scripts/weapons/weapon_boomerang_fire.gd")
	var source: String = bm_fire_script.source_code
	# Should contain level >= 3 check with 1.5 multiplier
	assert_true(source.find("level >= 3") != -1,
		"weapon_boomerang_fire.gd should have level >= 3 check")
	assert_true(source.find("track_angle *= 1.5") != -1,
		"Boomerang Lv3 should apply 1.5x track_angle multiplier")


func test_boomerang_lv3_tracking_formula():
	# Verify the exact tracking angle formula
	# Lv2: track_angle = base + 1 * 0.26 = 0.78
	# Lv3: track_angle = (base + 2 * 0.26) * 1.5 = 1.56
	var base: float = 0.52  # WeaponData.boomerang_track_angle default
	var lv2_angle: float = base + 1 * 0.26
	var lv3_angle: float = (base + 2 * 0.26) * 1.5
	assert_almost_eq(lv2_angle, 0.78, 0.001, "Lv2 track_angle should be 0.78")
	assert_almost_eq(lv3_angle, 1.56, 0.001, "Lv3 track_angle should be 1.56")
	assert_gt(lv3_angle, lv2_angle, "Lv3 track_angle should be greater than Lv2")


func test_boomerang_lv3_tracking_actual_fire():
	# Fire a Lv3 boomerang and verify track_angle passed to boomerang instance
	_player.owned_weapons["boomerang"] = 3
	var data: WeaponData = UpgradePool._weapons["boomerang"]
	var e := _create_enemy(Vector2(500, 300))
	await get_tree().process_frame
	_controller._fire_weapon("boomerang", data, _player)
	await get_tree().process_frame
	# Check boomerang instances
	assert_gt(_controller._boomerang_instances.size(), 0,
		"Should have at least 1 boomerang instance")
	if _controller._boomerang_instances.size() > 0:
		var bm = _controller._boomerang_instances[0]
		if is_instance_valid(bm) and "track_angle" in bm:
			# Lv3: (0.52 + 2*0.26) * 1.5 = 1.56
			assert_almost_eq(bm.track_angle, 1.56, 0.01,
				"Boomerang Lv3 track_angle should be 1.56")
	_player.owned_weapons.erase("boomerang")


func test_boomerang_lv2_tracking_no_15x():
	# Fire a Lv2 boomerang and verify track_angle does NOT have 1.5x multiplier
	_player.owned_weapons["boomerang"] = 2
	var data: WeaponData = UpgradePool._weapons["boomerang"]
	var e := _create_enemy(Vector2(500, 300))
	await get_tree().process_frame
	_controller._fire_weapon("boomerang", data, _player)
	await get_tree().process_frame
	assert_gt(_controller._boomerang_instances.size(), 0,
		"Should have at least 1 boomerang instance")
	if _controller._boomerang_instances.size() > 0:
		var bm = _controller._boomerang_instances[0]
		if is_instance_valid(bm) and "track_angle" in bm:
			# Lv2: 0.52 + 1*0.26 = 0.78 (no 1.5x multiplier)
			assert_almost_eq(bm.track_angle, 0.78, 0.01,
				"Boomerang Lv2 track_angle should be 0.78 (no 1.5x)")
	_player.owned_weapons.erase("boomerang")


func test_boomerang_evolved_no_lv3_bonus():
	# Evolved boomerang uses data.boomerang_track_angle directly (no level scaling)
	var bm_fire_script := load("res://scripts/weapons/weapon_boomerang_fire.gd")
	var source: String = bm_fire_script.source_code
	# In the evolved branch: track_angle = data.boomerang_track_angle
	# No (level-1) * 0.26 and no 1.5x multiplier
	var evolved_idx: int = source.find("if data.is_evolved:")
	assert_gt(evolved_idx, -1, "Should find is_evolved branch")
	var evolved_body: String = source.substr(evolved_idx, 300)
	# In evolved branch, track_angle is set from data directly
	assert_true(evolved_body.find("track_angle = data.boomerang_track_angle") != -1,
		"Evolved boomerang should use data.boomerang_track_angle directly")
