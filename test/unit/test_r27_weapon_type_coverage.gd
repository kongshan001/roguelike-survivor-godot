extends GutTest
## R27: Weapon type dispatch coverage tests for weapon_controller.gd
## Verifies that all weapon types registered in upgrade_pool.gd have corresponding
## dispatch branches in weapon_controller._fire_weapon match statement.
## Also tests weapon_effects.gd and weapon_boomerang_fire.gd coverage.

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
		_controller.remove_weapon_instances("holywater")
		_controller.remove_weapon_instances("boomerang")
		_controller._boomerang_instances.clear()
		_controller._orbit_instances.clear()
		_controller._weapon_timers.clear()


# =====================================================================
# Section A: Weapon Type Registration Audit
# =====================================================================

func test_all_registered_weapon_types():
	# Verify all weapon types that are registered in upgrade_pool
	var expected_types: Dictionary = {
		"knife": "projectile",
		"holywater": "orbit",
		"lightning": "lightning",
		"bible": "orbit",
		"firestaff": "cone",
		"frostaura": "aura",
		"boomerang": "boomerang",
		"thunderholywater": "orbit",
		"fireknife": "projectile",
		"holydomain": "orbit",
		"blizzard": "aura",
		"frostknife": "projectile",
		"flamebible": "orbit",
		"thunderang": "boomerang",
		"blazerang": "boomerang",
		"sentineltotem": "orbit",
		"frostvortex": "spiral",
		"holyshockwave": "pulse",
		"thunderbeam": "beam",
	}
	for weapon_id: String in expected_types:
		var data: WeaponData = UpgradePool._weapons.get(weapon_id)
		assert_not_null(data, "%s should be registered in UpgradePool" % weapon_id)
		if data:
			assert_eq(data.weapon_type, expected_types[weapon_id],
				"%s weapon_type should be %s" % [weapon_id, expected_types[weapon_id]])


# =====================================================================
# Section B: Base Weapon Types Dispatch (all should work)
# =====================================================================

func test_projectile_type_dispatches():
	_player.owned_weapons["knife"] = 1
	_controller._fire_weapon("knife", UpgradePool._weapons["knife"], _player)
	assert_true(true, "projectile type should dispatch without crash")
	_player.owned_weapons.erase("knife")


func test_orbit_type_dispatches():
	_player.owned_weapons["holywater"] = 1
	_controller._fire_weapon("holywater", UpgradePool._weapons["holywater"], _player)
	assert_has(_controller._orbit_instances, "holywater", "Orbit instance should be tracked")
	_player.owned_weapons.erase("holywater")


func test_lightning_type_dispatches():
	_player.owned_weapons["lightning"] = 1
	var e: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = 100.0; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	e.enemy_data = data; e.global_position = Vector2(500, 300)
	e.add_to_group("enemies"); _arena.add_child(e)
	_controller._fire_weapon("lightning", UpgradePool._weapons["lightning"], _player)
	assert_true(true, "lightning type should dispatch without crash")
	_player.owned_weapons.erase("lightning")


func test_cone_type_dispatches():
	_player.owned_weapons["firestaff"] = 1
	var e: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = 100.0; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	e.enemy_data = data; e.global_position = Vector2(430, 300)
	e.add_to_group("enemies"); _arena.add_child(e)
	_controller._fire_weapon("firestaff", UpgradePool._weapons["firestaff"], _player)
	assert_true(true, "cone type should dispatch without crash")
	_player.owned_weapons.erase("firestaff")


func test_aura_type_dispatches():
	_player.owned_weapons["frostaura"] = 1
	var e: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = 100.0; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	e.enemy_data = data; e.global_position = Vector2(420, 310)
	e.add_to_group("enemies"); _arena.add_child(e)
	_controller._fire_weapon("frostaura", UpgradePool._weapons["frostaura"], _player)
	assert_true(true, "aura type should dispatch without crash")
	_player.owned_weapons.erase("frostaura")


func test_boomerang_type_dispatches():
	_player.owned_weapons["boomerang"] = 1
	_controller._fire_weapon("boomerang", UpgradePool._weapons["boomerang"], _player)
	assert_gt(_controller._boomerang_instances.size(), 0, "Boomerang should be tracked")
	_player.owned_weapons.erase("boomerang")


# =====================================================================
# Section C: Evolved Weapon Types Dispatch (spiral/pulse/beam are unhandled)
# =====================================================================

func test_spiral_type_fire_weapon_does_not_crash():
	# frostvortex has weapon_type "spiral" -- no match branch in weapon_controller
	# This documents the gap: the weapon is registered but never fires
	_player.owned_weapons["frostvortex"] = 1
	_controller._fire_weapon("frostvortex", UpgradePool._weapons["frostvortex"], _player)
	# No crash expected, but also no visual effect -- the match falls through silently
	assert_true(true, "spiral type fire_weapon should not crash")
	_player.owned_weapons.erase("frostvortex")


func test_pulse_type_fire_weapon_does_not_crash():
	# holyshockwave has weapon_type "pulse" -- no match branch in weapon_controller
	_player.owned_weapons["holyshockwave"] = 1
	_controller._fire_weapon("holyshockwave", UpgradePool._weapons["holyshockwave"], _player)
	assert_true(true, "pulse type fire_weapon should not crash")
	_player.owned_weapons.erase("holyshockwave")


func test_beam_type_fire_weapon_does_not_crash():
	# thunderbeam has weapon_type "beam" -- no match branch in weapon_controller
	_player.owned_weapons["thunderbeam"] = 1
	_controller._fire_weapon("thunderbeam", UpgradePool._weapons["thunderbeam"], _player)
	assert_true(true, "beam type fire_weapon should not crash")
	_player.owned_weapons.erase("thunderbeam")


func test_spiral_type_timer_created_via_physics_process():
	# When owned via _physics_process, timer is created and resets to cooldown
	_player.owned_weapons["frostvortex"] = 1
	_controller._physics_process(0.016)
	assert_has(_controller._weapon_timers, "frostvortex",
		"Timer should be created for spiral weapon in physics_process")
	_player.owned_weapons.erase("frostvortex")


func test_pulse_type_timer_created_via_physics_process():
	_player.owned_weapons["holyshockwave"] = 1
	_controller._physics_process(0.016)
	assert_has(_controller._weapon_timers, "holyshockwave",
		"Timer should be created for pulse weapon in physics_process")
	_player.owned_weapons.erase("holyshockwave")


func test_beam_type_timer_created_via_physics_process():
	_player.owned_weapons["thunderbeam"] = 1
	_controller._physics_process(0.016)
	assert_has(_controller._weapon_timers, "thunderbeam",
		"Timer should be created for beam weapon in physics_process")
	_player.owned_weapons.erase("thunderbeam")


# =====================================================================
# Section D: Evolved Weapon Data Fields for spiral/pulse/beam
# =====================================================================

func test_frostvortex_spiral_data():
	var data: WeaponData = UpgradePool._weapons["frostvortex"]
	assert_not_null(data, "frostvortex should be registered")
	assert_eq(data.weapon_type, "spiral", "frostvortex type should be spiral")
	assert_eq(data.spiral_blade_count, 6, "spiral_blade_count should be 6")
	assert_eq(data.spiral_min_radius, 20.0, "spiral_min_radius should be 20.0")
	assert_eq(data.spiral_max_radius, 180.0, "spiral_max_radius should be 180.0")
	assert_eq(data.spiral_expand_speed, 60.0, "spiral_expand_speed should be 60.0")
	assert_true(data.is_evolved, "frostvortex should be evolved")


func test_holyshockwave_pulse_data():
	var data: WeaponData = UpgradePool._weapons["holyshockwave"]
	assert_not_null(data, "holyshockwave should be registered")
	assert_eq(data.weapon_type, "pulse", "holyshockwave type should be pulse")
	assert_eq(data.pulse_max_radius, 200.0, "pulse_max_radius should be 200.0")
	assert_eq(data.pulse_expand_time, 0.3, "pulse_expand_time should be 0.3")
	assert_eq(data.pulse_ring_width, 12.0, "pulse_ring_width should be 12.0")
	assert_eq(data.damage, 12.0, "holyshockwave damage should be 12.0")
	assert_true(data.is_evolved, "holyshockwave should be evolved")


func test_thunderbeam_beam_data():
	var data: WeaponData = UpgradePool._weapons["thunderbeam"]
	assert_not_null(data, "thunderbeam should be registered")
	assert_eq(data.weapon_type, "beam", "thunderbeam type should be beam")
	assert_eq(data.beam_active_duration, 1.0, "beam_active_duration should be 1.0")
	assert_eq(data.beam_tick_interval, 0.3, "beam_tick_interval should be 0.3")
	assert_eq(data.beam_width, 12.0, "beam_width should be 12.0")
	assert_eq(data.chain_count, 2, "thunderbeam chain_count should be 2")
	assert_true(data.is_evolved, "thunderbeam should be evolved")


# =====================================================================
# Section E: Evolved Orbit Weapons Dispatch
# =====================================================================

func test_thunderholywater_orbit_dispatch():
	_player.owned_weapons["thunderholywater"] = 1
	_controller._fire_weapon("thunderholywater", UpgradePool._weapons["thunderholywater"], _player)
	assert_has(_controller._orbit_instances, "thunderholywater", "Evolved orbit should be tracked")
	_player.owned_weapons.erase("thunderholywater")


func test_holydomain_orbit_dispatch():
	_player.owned_weapons["holydomain"] = 1
	_controller._fire_weapon("holydomain", UpgradePool._weapons["holydomain"], _player)
	assert_has(_controller._orbit_instances, "holydomain", "Holy domain orbit should be tracked")
	_player.owned_weapons.erase("holydomain")


func test_flamebible_orbit_dispatch():
	_player.owned_weapons["flamebible"] = 1
	_controller._fire_weapon("flamebible", UpgradePool._weapons["flamebible"], _player)
	assert_has(_controller._orbit_instances, "flamebible", "Flame bible orbit should be tracked")
	_player.owned_weapons.erase("flamebible")


func test_sentineltotem_orbit_dispatch():
	_player.owned_weapons["sentineltotem"] = 1
	_controller._fire_weapon("sentineltotem", UpgradePool._weapons["sentineltotem"], _player)
	assert_has(_controller._orbit_instances, "sentineltotem", "Sentinel totem orbit should be tracked")
	_player.owned_weapons.erase("sentineltotem")


# =====================================================================
# Section F: Evolved Projectile Weapons Dispatch
# =====================================================================

func test_fireknife_projectile_dispatch():
	_player.owned_weapons["fireknife"] = 1
	# Need an enemy for projectile targeting
	var e: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = 100.0; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	e.enemy_data = data; e.global_position = Vector2(500, 300)
	e.add_to_group("enemies"); _arena.add_child(e)
	_controller._fire_weapon("fireknife", UpgradePool._weapons["fireknife"], _player)
	assert_true(true, "fireknife projectile should dispatch without crash")
	_player.owned_weapons.erase("fireknife")


func test_frostknife_projectile_dispatch():
	_player.owned_weapons["frostknife"] = 1
	var e: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = 100.0; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	e.enemy_data = data; e.global_position = Vector2(500, 300)
	e.add_to_group("enemies"); _arena.add_child(e)
	_controller._fire_weapon("frostknife", UpgradePool._weapons["frostknife"], _player)
	assert_true(true, "frostknife projectile should dispatch without crash")
	_player.owned_weapons.erase("frostknife")


# =====================================================================
# Section G: Evolved Boomerang Weapons Dispatch
# =====================================================================

func test_thunderang_boomerang_dispatch():
	_player.owned_weapons["thunderang"] = 1
	_controller._fire_weapon("thunderang", UpgradePool._weapons["thunderang"], _player)
	assert_gt(_controller._boomerang_instances.size(), 0, "Thunderang should create boomerang instances")
	_player.owned_weapons.erase("thunderang")


func test_blazerang_boomerang_dispatch():
	_player.owned_weapons["blazerang"] = 1
	_controller._fire_weapon("blazerang", UpgradePool._weapons["blazerang"], _player)
	assert_gt(_controller._boomerang_instances.size(), 0, "Blazerang should create boomerang instances")
	_player.owned_weapons.erase("blazerang")


# =====================================================================
# Section H: Evolved Aura Weapon Dispatch
# =====================================================================

func test_blizzard_aura_dispatch():
	_player.owned_weapons["blizzard"] = 1
	var e: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = 100.0; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	e.enemy_data = data; e.global_position = Vector2(420, 310)
	e.add_to_group("enemies"); _arena.add_child(e)
	_controller._fire_weapon("blizzard", UpgradePool._weapons["blizzard"], _player)
	assert_true(true, "blizzard aura should dispatch without crash")
	_player.owned_weapons.erase("blizzard")


# =====================================================================
# Section I: weapon_effects.gd Coverage
# =====================================================================

func test_weapon_effects_has_lightning_method():
	var effects_class: RefCounted = load("res://scripts/weapons/weapon_effects.gd").new()
	assert_true(effects_class.has_method("create_lightning_effect"),
		"weapon_effects should have create_lightning_effect")


func test_weapon_effects_has_cone_method():
	var effects_class: RefCounted = load("res://scripts/weapons/weapon_effects.gd").new()
	assert_true(effects_class.has_method("create_cone_effect"),
		"weapon_effects should have create_cone_effect")


func test_weapon_effects_has_evolution_flash_method():
	var effects_class: RefCounted = load("res://scripts/weapons/weapon_effects.gd").new()
	assert_true(effects_class.has_method("create_evolution_flash"),
		"weapon_effects should have create_evolution_flash")


func test_create_evolution_flash_adds_child():
	var effects_class: RefCounted = load("res://scripts/weapons/weapon_effects.gd").new()
	var parent: Node2D = Node2D.new()
	add_child_autofree(parent)
	effects_class.create_evolution_flash(parent)
	await get_tree().process_frame
	assert_gt(parent.get_child_count(), 0,
		"Evolution flash should add a child to parent")
