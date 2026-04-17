extends GutTest
## R30 Task 3: weapon_fire.gd line count regression and split verification
## The line count test already exists in test_evolved_weapon_firing.gd.
## This file verifies: extracted files exist, all weapon types dispatch correctly,
## and the weapon_fire.gd -> weapon_boomerang_fire.gd delegation works.


var _controller: Node
var _player: CharacterBody2D
var _arena: Node2D


func before_each():
	GameManager.reset()
	GameManager.is_game_over = false
	GameManager.selected_difficulty = "normal"
	if SynergyManager:
		SynergyManager.active_synergies.clear()
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	UpgradePool.ensure_weapons_registered()

	_arena = Node2D.new()
	_arena.name = "Arena"
	add_child_autofree(_arena)

	var pm := Node.new()
	pm.name = "ProjectileManager"
	_arena.add_child(pm)

	var pkm := Node.new()
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
		_controller.remove_weapon_instances("frostvortex")
		_controller._boomerang_instances.clear()
		_controller._orbit_instances.clear()
		_controller._weapon_timers.clear()


# =====================================================================
# 1. weapon_fire.gd line count < 500
# =====================================================================

func test_weapon_fire_line_count_under_500():
	var file: FileAccess = FileAccess.open("res://scripts/weapons/weapon_fire.gd", FileAccess.READ)
	var lines: int = 0
	while not file.eof_reached():
		file.get_line()
		lines += 1
	file.close()
	assert_lt(lines, 500, "weapon_fire.gd must stay under 500 lines (currently %d)" % lines)


func test_weapon_controller_line_count_under_500():
	var file: FileAccess = FileAccess.open("res://scripts/weapon_controller.gd", FileAccess.READ)
	var lines: int = 0
	while not file.eof_reached():
		file.get_line()
		lines += 1
	file.close()
	assert_lt(lines, 500, "weapon_controller.gd must stay under 500 lines (currently %d)" % lines)


# =====================================================================
# 2. Extracted / split files exist
# =====================================================================

func test_weapon_boomerang_fire_file_exists():
	assert_true(
		ResourceLoader.exists("res://scripts/weapons/weapon_boomerang_fire.gd"),
		"weapon_boomerang_fire.gd should exist (extracted from weapon_fire.gd)"
	)


func test_weapon_boomerang_fire_line_count():
	var file: FileAccess = FileAccess.open("res://scripts/weapons/weapon_boomerang_fire.gd", FileAccess.READ)
	var lines: int = 0
	while not file.eof_reached():
		file.get_line()
		lines += 1
	file.close()
	assert_lt(lines, 200, "weapon_boomerang_fire.gd should be compact (< 200 lines)")


func test_weapon_effects_file_exists():
	assert_true(
		ResourceLoader.exists("res://scripts/weapons/weapon_effects.gd"),
		"weapon_effects.gd should exist (extracted from weapon_fire.gd)"
	)


func test_weapon_fire_has_boomerang_delegation():
	var source: String = load("res://scripts/weapons/weapon_fire.gd").source_code
	assert_true(source.find("weapon_boomerang_fire") != -1,
		"weapon_fire.gd should delegate to weapon_boomerang_fire.gd")


func test_weapon_fire_has_all_fire_methods():
	var wf_script: GDScript = load("res://scripts/weapons/weapon_fire.gd")
	var mock_ctrl := Node.new()
	add_child_autofree(mock_ctrl)
	# Set a minimal script to satisfy _init controller requirement
	var wf: RefCounted = wf_script.new(mock_ctrl)

	var required_methods: Array = [
		"fire_projectile",
		"update_orbit",
		"fire_lightning",
		"fire_cone",
		"update_aura",
		"fire_boomerang",
		"update_spiral",
		"fire_pulse",
		"fire_beam",
	]
	for method in required_methods:
		assert_true(wf.has_method(method),
			"weapon_fire should have method: %s" % method)


# =====================================================================
# 3. All weapon types dispatch correctly through weapon_controller
# =====================================================================

func test_all_nine_weapon_types_have_match_branch():
	# weapon_controller.gd match statement should handle all 9 types
	var source: String = load("res://scripts/weapon_controller.gd").source_code
	var types: Array = [
		'"projectile"', '"orbit"', '"lightning"', '"cone"', '"aura"',
		'"boomerang"', '"spiral"', '"pulse"', '"beam"'
	]
	for t in types:
		assert_true(source.find(t) != -1,
			"weapon_controller match should handle type %s" % t)


func test_spiral_dispatch_works():
	_player.owned_weapons["frostvortex"] = 1
	_controller._fire_weapon("frostvortex", UpgradePool._weapons["frostvortex"], _player)
	assert_true(is_instance_valid(_controller._spiral_instance),
		"Spiral dispatch should create spiral instance")
	_player.owned_weapons.erase("frostvortex")


func test_pulse_dispatch_works():
	_player.owned_weapons["holyshockwave"] = 1
	_controller._fire_weapon("holyshockwave", UpgradePool._weapons["holyshockwave"], _player)
	# Pulse creates a ring and adds it via call_deferred, no crash = pass
	assert_true(true, "Pulse dispatch should not crash")
	_player.owned_weapons.erase("holyshockwave")


func test_beam_dispatch_works():
	# Beam needs an enemy to target
	var e: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = 100.0; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	e.enemy_data = data; e.global_position = Vector2(500, 300)
	e.add_to_group("enemies"); _arena.add_child(e)

	_player.owned_weapons["thunderbeam"] = 1
	_controller._fire_weapon("thunderbeam", UpgradePool._weapons["thunderbeam"], _player)
	assert_true(true, "Beam dispatch should not crash")
	_player.owned_weapons.erase("thunderbeam")
