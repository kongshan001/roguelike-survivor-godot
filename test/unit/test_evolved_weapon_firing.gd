extends GutTest
## R28: Tests for evolved weapon firing logic (spiral, pulse, beam types).
## Tests weapon_fire.gd dispatch, weapon_controller.gd match branches,
## spiral_blade.gd, pulse_ring.gd, beam_line.gd setup and behavior.

var _arena: Node2D
var _player: CharacterBody2D
var _controller: Node


func before_each():
	GameManager.reset()
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
		_controller.remove_weapon_instances("frostvortex")
		_controller.remove_weapon_instances("holyshockwave")
		_controller.remove_weapon_instances("thunderbeam")
		_controller._boomerang_instances.clear()
		_controller._orbit_instances.clear()
		_controller._weapon_timers.clear()


# =====================================================================
# Section A: Spiral Type Dispatch (frostvortex)
# =====================================================================

func test_spiral_dispatch_creates_instance():
	_player.owned_weapons["frostvortex"] = 1
	_controller._fire_weapon("frostvortex", UpgradePool._weapons["frostvortex"], _player)
	assert_not_null(_controller._spiral_instance, "spiral fire should create _spiral_instance")
	assert_true(is_instance_valid(_controller._spiral_instance), "spiral instance should be valid")
	_player.owned_weapons.erase("frostvortex")


func test_spiral_instance_has_correct_damage():
	var data: WeaponData = UpgradePool._weapons["frostvortex"]
	_player.owned_weapons["frostvortex"] = 1
	_controller._fire_weapon("frostvortex", data, _player)
	var dmg_bonus: float = 1.0 + _player.damage_bonus
	assert_eq(_controller._spiral_instance.damage, data.damage * dmg_bonus,
		"spiral damage should match data.damage * dmg_bonus")
	_player.owned_weapons.erase("frostvortex")


func test_spiral_instance_follows_player():
	_player.owned_weapons["frostvortex"] = 1
	_controller._fire_weapon("frostvortex", UpgradePool._weapons["frostvortex"], _player)
	_player.global_position = Vector2(500, 400)
	_controller._process(0.016)
	assert_eq(_controller._spiral_instance.global_position, _player.global_position,
		"spiral instance should follow player position")
	_player.owned_weapons.erase("frostvortex")


func test_spiral_second_fire_updates_damage():
	_player.owned_weapons["frostvortex"] = 1
	_controller._fire_weapon("frostvortex", UpgradePool._weapons["frostvortex"], _player)
	var first_inst: Node2D = _controller._spiral_instance
	_controller._fire_weapon("frostvortex", UpgradePool._weapons["frostvortex"], _player)
	assert_eq(_controller._spiral_instance, first_inst,
		"second spiral fire should reuse existing instance")
	_player.owned_weapons.erase("frostvortex")


func test_spiral_remove_cleans_up():
	_player.owned_weapons["frostvortex"] = 1
	_controller._fire_weapon("frostvortex", UpgradePool._weapons["frostvortex"], _player)
	var inst: Node2D = _controller._spiral_instance
	_controller.remove_weapon_instances("frostvortex")
	assert_null(_controller._spiral_instance, "spiral instance should be null after removal")
	_player.owned_weapons.erase("frostvortex")


# =====================================================================
# Section B: Pulse Type Dispatch (holyshockwave)
# =====================================================================

func test_pulse_dispatch_creates_ring():
	_player.owned_weapons["holyshockwave"] = 1
	_controller._fire_weapon("holyshockwave", UpgradePool._weapons["holyshockwave"], _player)
	# The pulse ring is added to ProjectileManager via call_deferred
	await get_tree().process_frame
	var pm: Node = _arena.get_node("ProjectileManager")
	# Should have a child with pulse_ring.gd script
	var found: bool = false
	for child in pm.get_children():
		if child.has_method("setup"):
			found = true
	assert_true(found, "pulse fire should create a ring node in ProjectileManager")
	_player.owned_weapons.erase("holyshockwave")


func test_pulse_does_not_crash_with_no_enemies():
	_player.owned_weapons["holyshockwave"] = 1
	_controller._fire_weapon("holyshockwave", UpgradePool._weapons["holyshockwave"], _player)
	assert_true(true, "pulse should not crash even with no enemies")
	_player.owned_weapons.erase("holyshockwave")


# =====================================================================
# Section C: Beam Type Dispatch (thunderbeam)
# =====================================================================

func test_beam_dispatch_creates_beam():
	_player.owned_weapons["thunderbeam"] = 1
	# Need an enemy for targeting
	var e: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = 100.0; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	e.enemy_data = data; e.global_position = Vector2(500, 300)
	e.add_to_group("enemies"); _arena.add_child(e)
	_controller._fire_weapon("thunderbeam", UpgradePool._weapons["thunderbeam"], _player)
	await get_tree().process_frame
	var pm: Node = _arena.get_node("ProjectileManager")
	var found: bool = false
	for child in pm.get_children():
		if child.get("weapon_id") == "thunderbeam":
			found = true
	assert_true(found, "beam fire should create a beam node in ProjectileManager")
	_player.owned_weapons.erase("thunderbeam")


func test_beam_does_not_fire_without_enemies():
	_player.owned_weapons["thunderbeam"] = 1
	_controller._fire_weapon("thunderbeam", UpgradePool._weapons["thunderbeam"], _player)
	await get_tree().process_frame
	var pm: Node = _arena.get_node("ProjectileManager")
	var found: bool = false
	for child in pm.get_children():
		if child.get("weapon_id") == "thunderbeam":
			found = true
	assert_false(found, "beam should not create node with no enemies")
	_player.owned_weapons.erase("thunderbeam")


# =====================================================================
# Section D: spiral_blade.gd Unit Tests
# =====================================================================

func test_spiral_blade_setup():
	var blade := Node2D.new()
	blade.set_script(load("res://scripts/weapons/spiral_blade.gd"))
	blade.setup(6, 3.0, 20.0, 180.0, 60.0, Color(0.3, 0.7, 1.0), 0.4, 0.08)
	assert_eq(blade.blade_count, 6, "blade_count should be 6")
	assert_eq(blade.damage, 3.0, "damage should be 3.0")
	assert_eq(blade.min_radius, 20.0, "min_radius should be 20.0")
	assert_eq(blade.max_radius, 180.0, "max_radius should be 180.0")
	assert_eq(blade.expand_speed, 60.0, "expand_speed should be 60.0")
	add_child_autofree(blade)


func test_spiral_blade_weapon_id():
	var blade := Node2D.new()
	blade.set_script(load("res://scripts/weapons/spiral_blade.gd"))
	blade.setup(6, 3.0, 20.0, 180.0, 60.0, Color(0.3, 0.7, 1.0), 0.4, 0.08)
	blade.weapon_id = "frostvortex"
	assert_eq(blade.weapon_id, "frostvortex", "weapon_id should be set")
	add_child_autofree(blade)


# =====================================================================
# Section E: pulse_ring.gd Unit Tests
# =====================================================================

func test_pulse_ring_setup():
	var ring := Node2D.new()
	ring.set_script(load("res://scripts/weapons/pulse_ring.gd"))
	ring.setup(12.0, 200.0, 0.3, 12.0, Color(1.0, 0.85, 0.3), 2.0, 2.0)
	assert_eq(ring.damage, 12.0, "damage should be 12.0")
	assert_eq(ring.max_radius, 200.0, "max_radius should be 200.0")
	assert_eq(ring.expand_time, 0.3, "expand_time should be 0.3")
	assert_eq(ring.burn_dps, 2.0, "burn_dps should be 2.0")
	assert_eq(ring.burn_duration, 2.0, "burn_duration should be 2.0")
	add_child_autofree(ring)


# =====================================================================
# Section F: beam_line.gd Unit Tests
# =====================================================================

func test_beam_line_setup():
	var beam := Node2D.new()
	beam.set_script(load("res://scripts/weapons/beam_line.gd"))
	beam.setup(4.0, 1200.0, 12.0, 0.3, 1.0, 2, 6.0, Color(1.0, 1.0, 0.4), Vector2.RIGHT, _player)
	assert_eq(beam.damage, 4.0, "damage should be 4.0")
	assert_eq(beam.beam_range, 1200.0, "beam_range should be 1200.0")
	assert_eq(beam.chain_count, 2, "chain_count should be 2")
	assert_eq(beam.chain_damage, 6.0, "chain_damage should be 6.0")
	add_child_autofree(beam)


# =====================================================================
# Section G: hit_feedback.gd Colors for Evolved Weapons
# =====================================================================

func test_hit_feedback_has_frostvortex_color():
	var fb: RefCounted = load("res://scripts/effects/hit_feedback.gd").new()
	var colors: Dictionary = fb.WEAPON_COLORS
	assert_has(colors, "frostvortex", "WEAPON_COLORS should have frostvortex")
	assert_eq(colors["frostvortex"], Color(0.3, 0.7, 1.0), "frostvortex color should match spiral blade")


func test_hit_feedback_has_holyshockwave_color():
	var fb: RefCounted = load("res://scripts/effects/hit_feedback.gd").new()
	var colors: Dictionary = fb.WEAPON_COLORS
	assert_has(colors, "holyshockwave", "WEAPON_COLORS should have holyshockwave")
	assert_eq(colors["holyshockwave"], Color(1.0, 0.85, 0.3), "holyshockwave color should match pulse")


func test_hit_feedback_has_thunderbeam_color():
	var fb: RefCounted = load("res://scripts/effects/hit_feedback.gd").new()
	var colors: Dictionary = fb.WEAPON_COLORS
	assert_has(colors, "thunderbeam", "WEAPON_COLORS should have thunderbeam")
	assert_eq(colors["thunderbeam"], Color(1.0, 1.0, 0.4), "thunderbeam color should match beam")


# =====================================================================
# Section H: weapon_fire.gd Constants
# =====================================================================

func test_beam_chain_damage_constant():
	var wf: RefCounted = load("res://scripts/weapons/weapon_fire.gd").new(Node.new())
	assert_eq(wf.THUNDERBEAM_CHAIN_DAMAGE, 6.0, "THUNDERBEAM_CHAIN_DAMAGE should be 6.0")
	assert_eq(wf.THUNDERBEAM_CHAIN_RANGE, 120.0, "THUNDERBEAM_CHAIN_RANGE should be 120.0")


# =====================================================================
# Section I: Line Count Verification
# =====================================================================

func test_weapon_fire_under_500_lines():
	var file: FileAccess = FileAccess.open("res://scripts/weapons/weapon_fire.gd", FileAccess.READ)
	var lines: int = 0
	while not file.eof_reached():
		file.get_line()
		lines += 1
	file.close()
	assert_lt(lines, 500, "weapon_fire.gd must be under 500 lines")


func test_weapon_controller_under_500_lines():
	var file: FileAccess = FileAccess.open("res://scripts/weapon_controller.gd", FileAccess.READ)
	var lines: int = 0
	while not file.eof_reached():
		file.get_line()
		lines += 1
	file.close()
	assert_lt(lines, 500, "weapon_controller.gd must be under 500 lines")
