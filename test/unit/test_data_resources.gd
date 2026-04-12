extends GutTest

# Test data resource classes: WeaponData, EnemyData, PassiveData, CharacterData, DifficultyData


# --- WeaponData ---

func test_weapon_data_defaults():
	var d = WeaponData.new()
	assert_eq(d.weapon_name, "Weapon")
	assert_eq(d.weapon_id, "")
	assert_eq(d.damage, 10.0)
	assert_eq(d.cooldown, 1.5)
	assert_eq(d.weapon_type, "projectile")
	assert_eq(d.projectile_pierce, 0)


func test_weapon_data_custom_values():
	var d = WeaponData.new()
	d.weapon_name = "飞刀"
	d.weapon_id = "knife"
	d.damage = 2.0
	d.cooldown = 0.7
	d.weapon_type = "projectile"
	d.projectile_count = 1
	d.projectile_speed = 350.0
	assert_eq(d.weapon_name, "飞刀")
	assert_eq(d.damage, 2.0)
	assert_eq(d.cooldown, 0.7)


func test_weapon_data_types():
	var types = ["projectile", "orbit", "lightning", "aoe", "cone", "aura", "boomerang"]
	for t in types:
		var d = WeaponData.new()
		d.weapon_type = t
		assert_eq(d.weapon_type, t, "Weapon type %s should be valid" % t)


func test_weapon_data_orbit_properties():
	var d = WeaponData.new()
	d.weapon_type = "orbit"
	d.orbit_count = 3
	d.orbit_radius = 60.0
	d.orbit_speed = 3.5
	assert_eq(d.orbit_count, 3)
	assert_eq(d.orbit_radius, 60.0)
	assert_eq(d.orbit_speed, 3.5)


func test_weapon_data_lightning_properties():
	var d = WeaponData.new()
	d.weapon_type = "lightning"
	d.chain_count = 2
	d.projectile_range = 300.0
	assert_eq(d.chain_count, 2)
	assert_eq(d.projectile_range, 300.0)


func test_weapon_data_cone_properties():
	var d = WeaponData.new()
	d.weapon_type = "cone"
	d.cone_angle = 100.0
	d.cone_range = 130.0
	d.burn_dps = 5.0
	d.burn_duration = 2.0
	assert_eq(d.cone_angle, 100.0)
	assert_eq(d.burn_dps, 5.0)


func test_weapon_data_aura_properties():
	var d = WeaponData.new()
	d.weapon_type = "aura"
	d.aoe_radius = 100.0
	d.slow_pct = 0.45
	d.freeze_pct = 0.08
	assert_eq(d.aoe_radius, 100.0)
	assert_eq(d.slow_pct, 0.45)
	assert_eq(d.freeze_pct, 0.08)


func test_weapon_data_boomerang_properties():
	var d = WeaponData.new()
	d.weapon_type = "boomerang"
	d.boomerang_max_dist = 300.0
	d.boomerang_return_speed = 320.0
	d.boomerang_curvature = 0.3
	d.boomerang_track_angle = 0.79
	assert_eq(d.boomerang_max_dist, 300.0)
	assert_eq(d.boomerang_return_speed, 320.0)


# --- EnemyData ---

func test_enemy_data_defaults():
	var d = EnemyData.new()
	assert_eq(d.enemy_name, "Enemy")
	assert_eq(d.max_hp, 20.0)
	assert_eq(d.speed, 60.0)
	assert_eq(d.damage, 10.0)
	assert_false(d.is_boss)


func test_enemy_data_custom_values():
	var d = EnemyData.new()
	d.enemy_name = "Bat"
	d.max_hp = 1.0
	d.speed = 80.0
	d.damage = 1.0
	d.xp_value = 3
	assert_eq(d.enemy_name, "Bat")
	assert_eq(d.max_hp, 1.0)
	assert_eq(d.speed, 80.0)


func test_enemy_data_shapes():
	var d = EnemyData.new()
	d.shape = "circle"
	assert_eq(d.shape, "circle")


func test_enemy_data_ranged_defaults():
	var d = EnemyData.new()
	assert_false(d.is_ranged, "is_ranged default should be false")
	assert_eq(d.shoot_cd, 2.0, "shoot_cd default should be 2.0")
	assert_false(d.is_elite, "is_elite default should be false")


func test_enemy_data_ghost_defaults():
	var d = EnemyData.new()
	assert_false(d.can_phase_shift, "can_phase_shift default should be false")
	assert_false(d.can_teleport, "can_teleport default should be false")


func test_enemy_data_splitter_defaults():
	var d = EnemyData.new()
	assert_false(d.is_splitter, "is_splitter default should be false")
	assert_false(d.is_child, "is_child default should be false")
	assert_eq(d.split_count, 2, "split_count default should be 2")


# --- PassiveData ---

func test_passive_data_defaults():
	var d = PassiveData.new()
	assert_eq(d.passive_name, "Passive")
	assert_eq(d.passive_id, "")
	assert_eq(d.description, "")


func test_passive_data_custom():
	var d = PassiveData.new()
	d.passive_name = "疾风靴"
	d.passive_id = "speedboots"
	d.description = "移动速度+15%"
	assert_eq(d.passive_name, "疾风靴")
	assert_eq(d.passive_id, "speedboots")


# --- Resource Inheritance ---

func test_weapon_data_is_resource():
	var d = WeaponData.new()
	assert_true(d is Resource, "WeaponData should extend Resource")


func test_enemy_data_is_resource():
	var d = EnemyData.new()
	assert_true(d is Resource, "EnemyData should extend Resource")


func test_passive_data_is_resource():
	var d = PassiveData.new()
	assert_true(d is Resource, "PassiveData should extend Resource")


func test_character_data_is_resource():
	var d = CharacterData.new()
	assert_true(d is Resource, "CharacterData should extend Resource")


func test_difficulty_data_is_resource():
	var d = DifficultyData.new()
	assert_true(d is Resource, "DifficultyData should extend Resource")
