extends GutTest
## Integration smoke tests: verify ALL weapons fire without crash,
## ALL passives apply, and core game flows work end-to-end.
## Primary goal: catch regressions like the firestaff dir_angle crash.

var _wf: RefCounted
var _mock_controller: Node
var _arena: Node2D
var _player: CharacterBody2D
var _pm: Node  # ProjectileManager
var _pkm: Node  # PickupManager


func before_each():
	GameManager.reset()
	if SynergyManager:
		SynergyManager.active_synergies.clear()
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	UpgradePool.ensure_weapons_registered()

	# Build minimal arena tree with scene-instantiated player
	_arena = Node2D.new()
	_arena.name = "Arena"
	add_child_autofree(_arena)

	_pm = Node.new(); _pm.name = "ProjectileManager"
	_arena.add_child(_pm)
	_pkm = Node.new(); _pkm.name = "PickupManager"
	_arena.add_child(_pkm)

	# Use scene instantiation so $CollisionShape2D etc. resolve correctly
	_player = load("res://scenes/player.tscn").instantiate() as CharacterBody2D
	_player.global_position = Vector2(400, 300)
	_player.add_to_group("players")
	_arena.add_child(_player)

	# weapon_controller is already a child of player.tscn
	_mock_controller = _player.get_node("WeaponController")
	_wf = load("res://scripts/weapons/weapon_fire.gd").new(_mock_controller)


func after_each():
	# Wait for call_deferred spawns from die() to complete before autofree runs
	await get_tree().process_frame
	# Clean up weapon instances to reduce orphan RIDs
	if is_instance_valid(_mock_controller):
		_mock_controller.remove_weapon_instances("holywater")
		_mock_controller.remove_weapon_instances("boomerang")
		_mock_controller.remove_weapon_instances("thunderang")
		_mock_controller.remove_weapon_instances("blazerang")
		_mock_controller._boomerang_instances.clear()
		_mock_controller._orbit_instances.clear()
		_mock_controller._weapon_timers.clear()


func _create_enemy(pos: Vector2, hp: float = 10.0, is_boss: bool = false) -> CharacterBody2D:
	var e: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate() as CharacterBody2D
	var data := EnemyData.new()
	data.enemy_id = "test_enemy"; data.max_hp = hp; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.is_boss = is_boss; data.drop_chance = 0.0
	e.enemy_data = data; e.global_position = pos
	e.add_to_group("enemies"); _arena.add_child(e)
	return e


# =====================================================================
# 1. BASE WEAPON DATA REGISTRATION
# =====================================================================

func test_all_base_weapons_registered_and_valid():
	var base_ids := ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang"]
	assert_eq(base_ids.size(), 7, "Should have 7 base weapons")
	for wid in base_ids:
		assert_has(UpgradePool._weapons, wid, "%s registered" % wid)
		var data: WeaponData = UpgradePool._weapons[wid]
		assert_ne(data.weapon_type, "", "%s has weapon_type" % wid)
		assert_gt(data.damage, 0.0, "%s damage > 0" % wid)
		assert_ne(data.weapon_id, "", "%s has weapon_id" % wid)
		assert_ne(data.weapon_name, "", "%s has weapon_name" % wid)


# =====================================================================
# 2. EVOLVED WEAPON DATA REGISTRATION
# =====================================================================

func test_all_evolved_weapons_registered_and_valid():
	var evolved_ids := [
		"thunderholywater", "fireknife", "holydomain", "blizzard",
		"frostknife", "flamebible", "thunderang", "blazerang", "sentineltotem"
	]
	assert_eq(evolved_ids.size(), 9, "Should have 9 evolved weapons")
	for wid in evolved_ids:
		assert_has(UpgradePool._weapons, wid, "%s registered" % wid)
		var data: WeaponData = UpgradePool._weapons[wid]
		assert_true(data.is_evolved, "%s is_evolved" % wid)
		assert_ne(data.description, "", "%s has description" % wid)
		assert_ne(data.weapon_type, "", "%s has weapon_type" % wid)


# =====================================================================
# 3. FIRE EACH WEAPON TYPE WITHOUT CRASH
# =====================================================================

func test_fire_projectile_weapon_no_crash():
	_create_enemy(Vector2(500, 300))
	_wf.fire_projectile(UpgradePool._weapons["knife"], 1, _player, 1.0)
	await get_tree().process_frame
	assert_true(true, "fire_projectile (knife) did not crash")


func test_fire_projectile_evolved_no_crash():
	_create_enemy(Vector2(500, 300))
	_wf.fire_projectile(UpgradePool._weapons["fireknife"], 1, _player, 1.0)
	await get_tree().process_frame
	assert_true(true, "fire_projectile (fireknife) did not crash")


func test_fire_projectile_empty_no_crash():
	_wf.fire_projectile(UpgradePool._weapons["knife"], 1, _player, 1.0)
	await get_tree().process_frame
	assert_true(true, "fire_projectile with no enemies did not crash")


func test_fire_orbit_weapon_no_crash():
	var data: WeaponData = UpgradePool._weapons["holywater"]
	var orbits: Dictionary = {}
	orbits = _wf.update_orbit("holywater", data, 1, _player, 1.0, orbits)
	assert_true(orbits.has("holywater"), "holywater orbit created")
	assert_true(is_instance_valid(orbits["holywater"]), "holywater instance valid")


func test_fire_orbit_bible_no_crash():
	var data: WeaponData = UpgradePool._weapons["bible"]
	var orbits: Dictionary = {}
	orbits = _wf.update_orbit("bible", data, 1, _player, 1.0, orbits)
	assert_true(orbits.has("bible"), "bible orbit created")


func test_fire_orbit_evolved_no_crash():
	var data: WeaponData = UpgradePool._weapons["holydomain"]
	var orbits: Dictionary = {}
	orbits = _wf.update_orbit("holydomain", data, 1, _player, 1.0, orbits)
	assert_true(orbits.has("holydomain"), "holydomain orbit created")


func test_fire_lightning_no_crash():
	_create_enemy(Vector2(450, 300))
	_wf.fire_lightning(UpgradePool._weapons["lightning"], 1, _player, 1.0)
	assert_true(true, "fire_lightning did not crash")


func test_fire_lightning_empty_no_crash():
	_wf.fire_lightning(UpgradePool._weapons["lightning"], 1, _player, 1.0)
	assert_true(true, "fire_lightning with no enemies did not crash")


func test_fire_cone_no_crash():
	# FIRESTAFF -- this was the crash bug (dir_angle property)
	_create_enemy(Vector2(430, 300))
	_wf.fire_cone(UpgradePool._weapons["firestaff"], 1, _player, 1.0)
	await get_tree().process_frame
	assert_true(true, "fire_cone (firestaff) did not crash -- dir_angle bug fixed")


func test_fire_cone_with_moving_player():
	_player.velocity = Vector2(100, 0)
	_create_enemy(Vector2(430, 300))
	_wf.fire_cone(UpgradePool._weapons["firestaff"], 1, _player, 1.0)
	await get_tree().process_frame
	assert_true(true, "fire_cone with moving player did not crash")


func test_fire_cone_at_level3_with_burn():
	_create_enemy(Vector2(430, 300))
	_wf.fire_cone(UpgradePool._weapons["firestaff"], 3, _player, 1.0)
	await get_tree().process_frame
	assert_true(true, "fire_cone level 3 with burn did not crash")


func test_fire_cone_no_enemies_no_crash():
	_wf.fire_cone(UpgradePool._weapons["firestaff"], 1, _player, 1.0)
	await get_tree().process_frame
	assert_true(true, "fire_cone with no enemies did not crash")


func test_fire_aura_no_crash():
	_create_enemy(Vector2(420, 310))
	var timers: Dictionary = {}
	_wf.update_aura("frostaura", UpgradePool._weapons["frostaura"], 1, _player, 1.0, timers)
	assert_true(true, "update_aura (frostaura) did not crash")


func test_fire_aura_blizzard_no_crash():
	_create_enemy(Vector2(420, 310))
	var timers: Dictionary = {}
	_wf.update_aura("blizzard", UpgradePool._weapons["blizzard"], 1, _player, 1.0, timers)
	assert_true(true, "update_aura (blizzard evolved) did not crash")


func test_fire_boomerang_no_crash():
	var timers: Dictionary = {}
	var instances: Array = []
	instances = _wf.fire_boomerang(UpgradePool._weapons["boomerang"], 1, _player, 1.0, timers, instances)
	assert_eq(instances.size(), 1, "Should create 1 boomerang")
	await get_tree().process_frame
	assert_true(true, "boomerang processed without crash")


func test_fire_boomerang_evolved_no_crash():
	_create_enemy(Vector2(500, 300))
	var timers: Dictionary = {}
	var instances: Array = []
	instances = _wf.fire_boomerang(UpgradePool._weapons["thunderang"], 1, _player, 1.0, timers, instances)
	assert_eq(instances.size(), 4, "thunderang should create 4 boomerangs")
	await get_tree().process_frame
	assert_true(true, "thunderang processed without crash")


func test_fire_boomerang_blazerang_no_crash():
	var timers: Dictionary = {}
	var instances: Array = []
	instances = _wf.fire_boomerang(UpgradePool._weapons["blazerang"], 1, _player, 1.0, timers, instances)
	assert_eq(instances.size(), 3, "blazerang should create 3 boomerangs")
	await get_tree().process_frame
	assert_true(true, "blazerang processed without crash")


# =====================================================================
# 4. WEAPON CONTROLLER DISPATCH FOR ALL TYPES
# =====================================================================

func test_controller_dispatch_projectile():
	_player.owned_weapons["knife"] = 1
	_create_enemy(Vector2(500, 300))
	_mock_controller._fire_weapon("knife", UpgradePool._weapons["knife"], _player)
	await get_tree().process_frame
	assert_true(true, "controller dispatched projectile without crash")
	_player.owned_weapons.erase("knife")


func test_controller_dispatch_orbit():
	_player.owned_weapons["holywater"] = 1
	_mock_controller._fire_weapon("holywater", UpgradePool._weapons["holywater"], _player)
	assert_true(true, "controller dispatched orbit without crash")
	_player.owned_weapons.erase("holywater")


func test_controller_dispatch_lightning():
	_player.owned_weapons["lightning"] = 1
	_create_enemy(Vector2(400, 350))
	_mock_controller._fire_weapon("lightning", UpgradePool._weapons["lightning"], _player)
	assert_true(true, "controller dispatched lightning without crash")
	_player.owned_weapons.erase("lightning")


func test_controller_dispatch_cone():
	_player.owned_weapons["firestaff"] = 1
	_create_enemy(Vector2(430, 300))
	_mock_controller._fire_weapon("firestaff", UpgradePool._weapons["firestaff"], _player)
	await get_tree().process_frame
	assert_true(true, "controller dispatched cone without crash")
	_player.owned_weapons.erase("firestaff")


func test_controller_dispatch_aura():
	_player.owned_weapons["frostaura"] = 1
	_create_enemy(Vector2(420, 310))
	_mock_controller._fire_weapon("frostaura", UpgradePool._weapons["frostaura"], _player)
	assert_true(true, "controller dispatched aura without crash")
	_player.owned_weapons.erase("frostaura")


func test_controller_dispatch_boomerang():
	_player.owned_weapons["boomerang"] = 1
	_mock_controller._fire_weapon("boomerang", UpgradePool._weapons["boomerang"], _player)
	await get_tree().process_frame
	assert_true(true, "controller dispatched boomerang without crash")
	_player.owned_weapons.erase("boomerang")


# =====================================================================
# 5. ALL PASSIVE ITEMS APPLY WITHOUT CRASH
# =====================================================================

func test_all_passives_apply_individually():
	_player.apply_passive("speedboots")
	assert_gt(_player.speed_multiplier, 1.0, "speedboots increases speed")
	var old_armor: int = _player.armor
	_player.apply_passive("armor")
	assert_eq(_player.armor, old_armor + 1, "armor increases by 1")
	var old_range: float = _player.pickup_range
	_player.apply_passive("magnet")
	assert_gt(_player.pickup_range, old_range, "magnet increases pickup_range")
	_player.apply_passive("crit")
	assert_gt(_player.crit_chance, 0.0, "crit increases crit_chance")
	var old_max: float = _player.max_health
	_player.apply_passive("maxhp")
	assert_gt(_player.max_health, old_max, "maxhp increases max_health")
	_player.apply_passive("regen")
	assert_gt(_player.regen_amount, 0.0, "regen increases regen_amount")
	var old_mul: float = _player.crit_damage_mul
	_player.apply_passive("luckycoin")
	assert_gt(_player.crit_damage_mul, old_mul, "luckycoin increases crit_damage_mul")


func test_all_passives_stacked_max():
	var passives := ["speedboots", "armor", "magnet", "crit", "maxhp", "regen", "luckycoin"]
	for pid in passives:
		for _i in range(3):
			_player.apply_passive(pid)
	assert_true(true, "All 7 passives stacked to max (3) without crash")


# =====================================================================
# 6. CORE GAME FLOW
# =====================================================================

func test_enemy_takes_damage_and_dies():
	var enemy := _create_enemy(Vector2(500, 300), 5.0)
	enemy.take_damage(5.0, "knife")
	assert_false(enemy.is_alive, "Enemy should be dead after lethal damage")


func test_xp_gem_spawned_on_kill():
	var initial: int = _pkm.get_child_count()
	var enemy := _create_enemy(Vector2(500, 300), 1.0)
	enemy.take_damage(1.0, "knife")
	await get_tree().process_frame
	await get_tree().process_frame
	assert_gt(_pkm.get_child_count(), initial, "XP gem spawned in PickupManager")


func test_level_up_triggers():
	var levels: Array = []
	GameManager.level_up.connect(func(lvl: int): levels.append(lvl))
	GameManager.add_xp(100.0)
	assert_gt(levels.size(), 0, "level_up signal should fire")


func test_boss_death_spawns_multiple_gems():
	var initial: int = _pkm.get_child_count()
	var boss := _create_enemy(Vector2(500, 300), 1.0, true)
	boss.take_damage(1.0, "knife")
	await get_tree().process_frame
	await get_tree().process_frame
	assert_gte(_pkm.get_child_count(), initial + 5, "Boss spawns at least 5 bonus gems")


func test_splitter_death_spawns_children():
	var initial: int = _arena.get_child_count()
	var data := EnemyData.new()
	data.enemy_id = "splitter"; data.max_hp = 1.0; data.speed = 40.0
	data.damage = 1.0; data.xp_value = 3; data.color = Color.TEAL
	data.size = 16.0; data.is_splitter = true; data.split_count = 3
	data.drop_chance = 0.0
	var splitter := load("res://scenes/enemy.tscn").instantiate() as CharacterBody2D
	splitter.enemy_data = data
	splitter.global_position = Vector2(500, 300)
	splitter.add_to_group("enemies")
	_arena.add_child(splitter)
	GameManager.enemy_count = 1
	splitter.take_damage(1.0, "knife")
	# Children are spawned via call_deferred, wait for them
	await get_tree().process_frame
	await get_tree().process_frame
	assert_gt(_arena.get_child_count(), initial, "Splitter death spawns child enemies in arena")
	# die() decrements enemy_count (-1), then 3 children each increment (+3) = net +2
	assert_eq(GameManager.enemy_count, 3, "3 splitter children tracked in enemy_count")


# =====================================================================
# 7. SYNERGY SYSTEM SMOKE TESTS
# =====================================================================

func test_synergy_definitions_load_and_count():
	var mgr := Node.new()
	mgr.set_script(load("res://scripts/autoload/synergy_manager.gd"))
	add_child_autofree(mgr)
	assert_eq(mgr.SYNERGY_DEFINITIONS.size(), 18, "Should have 18 synergy definitions")
	mgr.check_synergies({"knife": 3}, {"crit": 1})
	assert_true(mgr.has_synergy("knife_crit"), "knife_crit synergy detected")


func test_all_weapon_passive_synergies_detectable():
	var mgr := Node.new()
	mgr.set_script(load("res://scripts/autoload/synergy_manager.gd"))
	add_child_autofree(mgr)
	var wpn_synergy_ids := [
		"holywater_maxhp", "knife_crit", "lightning_magnet",
		"bible_boots", "firestaff_armor", "frost_regen",
		"holywater_luckycoin", "firestaff_luckycoin",
		"frostaura_luckycoin", "boomerang_magnet", "boomerang_crit"
	]
	assert_eq(wpn_synergy_ids.size(), 11, "Should test 11 weapon+passive synergies")
	for sid in wpn_synergy_ids:
		var def: Dictionary = {}
		for d in mgr.SYNERGY_DEFINITIONS:
			if d["id"] == sid:
				def = d; break
		assert_ne(def.size(), 0, "Found definition for %s" % sid)
		mgr.check_synergies({def["weapon"]: 1}, {def["passive"]: 1})
		assert_true(mgr.has_synergy(sid), "%s detected" % sid)


# =====================================================================
# 8. EVOLUTION RECIPES VALIDATION
# =====================================================================

func test_evolution_recipes_reference_valid_weapons():
	var registry: RefCounted = load("res://scripts/weapons/weapon_registry.gd").new()
	assert_eq(registry.EVOLUTION_RECIPES.size(), 9, "Should have 9 recipes")
	for recipe: Dictionary in registry.EVOLUTION_RECIPES:
		assert_has(UpgradePool._weapons, recipe["a"], "Ingredient '%s' registered" % recipe["a"])
		assert_has(UpgradePool._weapons, recipe["b"], "Ingredient '%s' registered" % recipe["b"])
		assert_has(UpgradePool._weapons, recipe["result"], "Result '%s' registered" % recipe["result"])


func test_evolution_available_when_max_level():
	var registry: RefCounted = load("res://scripts/weapons/weapon_registry.gd").new()
	var result: Dictionary = registry.check_evolution_available({"holywater": 3, "lightning": 3})
	assert_ne(result.size(), 0, "Evolution available")
	assert_eq(result["result"], "thunderholywater", "Evolve to thunderholywater")


# =====================================================================
# 9. VISUAL EFFECTS CRASH REGRESSION (dir_angle cone crash)
# =====================================================================

func test_cone_effect_creates_without_crash():
	# Directly call the method that caused the firestaff dir_angle crash
	var effects: RefCounted = load("res://scripts/weapons/weapon_effects.gd").new()
	var container := Node2D.new()
	add_child_autofree(container)
	effects.create_cone_effect(Vector2(100, 200), 0.785, 0.5, 100.0, Color.ORANGE, container)
	await get_tree().process_frame
	assert_gt(container.get_child_count(), 0, "Cone effect node added")


func test_cone_effect_edge_cases():
	var effects: RefCounted = load("res://scripts/weapons/weapon_effects.gd").new()
	var container := Node2D.new()
	add_child_autofree(container)
	# Negative angle
	effects.create_cone_effect(Vector2.ZERO, -2.5, 1.0, 80.0, Color.RED, container)
	await get_tree().process_frame
	assert_gt(container.get_child_count(), 0, "Cone negative angle ok")
	# Zero angle
	effects.create_cone_effect(Vector2.ZERO, 0.0, 0.0, 50.0, Color.YELLOW, container)
	await get_tree().process_frame
	assert_gt(container.get_child_count(), 1, "Cone zero angle ok")


func test_lightning_effect_and_evolution_flash_no_crash():
	var effects: RefCounted = load("res://scripts/weapons/weapon_effects.gd").new()
	var container := Node2D.new()
	add_child_autofree(container)
	effects.create_lightning_effect(Vector2.ZERO, Vector2(100, 100), Color.YELLOW, container)
	await get_tree().process_frame
	assert_gt(container.get_child_count(), 0, "Lightning line created")
	var flash_container := Node2D.new()
	add_child_autofree(flash_container)
	effects.create_evolution_flash(flash_container)
	assert_gt(flash_container.get_child_count(), 0, "Evolution flash added")
