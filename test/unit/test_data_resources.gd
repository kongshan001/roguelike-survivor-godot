extends GutTest

# Test data resource classes: WeaponData, EnemyData, PassiveData


# --- WeaponData ---

func test_weapon_data_defaults():
	var data = WeaponData.new()
	assert_eq(data.weapon_name, "Weapon")
	assert_eq(data.weapon_id, "")
	assert_eq(data.damage, 10.0)
	assert_eq(data.cooldown, 1.5)
	assert_eq(data.projectile_speed, 300.0)
	assert_eq(data.projectile_count, 1)
	assert_eq(data.projectile_pierce, 1)
	assert_eq(data.projectile_range, 500.0)
	assert_eq(data.description, "")
	assert_eq(data.color, Color.WHITE)
	assert_eq(data.projectile_size, 8.0)
	assert_eq(data.weapon_type, "projectile")


func test_weapon_data_custom_values():
	var data = WeaponData.new()
	data.weapon_name = "Magic Orb"
	data.weapon_id = "magic_orb"
	data.damage = 25.0
	data.cooldown = 1.0
	data.weapon_type = "projectile"
	assert_eq(data.weapon_name, "Magic Orb")
	assert_eq(data.damage, 25.0)
	assert_eq(data.weapon_type, "projectile")


func test_weapon_data_types():
	var types = ["projectile", "orbit", "lightning", "aoe"]
	for t in types:
		var data = WeaponData.new()
		data.weapon_type = t
		assert_eq(data.weapon_type, t, "Should accept weapon type: %s" % t)


func test_weapon_data_orbit_properties():
	var data = WeaponData.new()
	data.weapon_type = "orbit"
	data.orbit_count = 3
	data.orbit_radius = 100.0
	assert_eq(data.orbit_count, 3)
	assert_eq(data.orbit_radius, 100.0)


func test_weapon_data_lightning_properties():
	var data = WeaponData.new()
	data.weapon_type = "lightning"
	data.chain_count = 3
	assert_eq(data.chain_count, 3)


func test_weapon_data_aoe_properties():
	var data = WeaponData.new()
	data.weapon_type = "aoe"
	data.aoe_radius = 120.0
	assert_eq(data.aoe_radius, 120.0)


# --- EnemyData ---

func test_enemy_data_defaults():
	var data = EnemyData.new()
	assert_eq(data.enemy_name, "Enemy")
	assert_eq(data.max_hp, 20.0)
	assert_eq(data.speed, 60.0)
	assert_eq(data.damage, 10.0)
	assert_eq(data.xp_value, 5)
	assert_eq(data.color, Color.GREEN)
	assert_eq(data.size, 16.0)
	assert_eq(data.shape, "circle")
	assert_false(data.is_boss)
	assert_eq(data.drop_chance, 0.1)


func test_enemy_data_custom_values():
	var data = EnemyData.new()
	data.enemy_name = "Dragon"
	data.max_hp = 500.0
	data.speed = 80.0
	data.damage = 50.0
	data.xp_value = 100
	data.is_boss = true
	data.drop_chance = 1.0
	assert_eq(data.enemy_name, "Dragon")
	assert_eq(data.max_hp, 500.0)
	assert_true(data.is_boss)
	assert_eq(data.drop_chance, 1.0)


func test_enemy_data_shapes():
	var shapes = ["circle", "triangle", "square", "hexagon"]
	for s in shapes:
		var data = EnemyData.new()
		data.shape = s
		assert_eq(data.shape, s, "Should accept shape: %s" % s)


# --- PassiveData ---

func test_passive_data_defaults():
	var data = PassiveData.new()
	assert_eq(data.passive_name, "Passive")
	assert_eq(data.passive_id, "")
	assert_eq(data.description, "")
	assert_eq(data.icon_color, Color.WHITE)


func test_passive_data_custom():
	var data = PassiveData.new()
	data.passive_name = "Speed Up"
	data.passive_id = "speed_up"
	data.description = "+15% Move Speed"
	data.icon_color = Color.CYAN
	assert_eq(data.passive_name, "Speed Up")
	assert_eq(data.passive_id, "speed_up")
	assert_eq(data.icon_color, Color.CYAN)


# --- Resource Inheritance ---

func test_weapon_data_is_resource():
	var data = WeaponData.new()
	assert_true(data is Resource, "WeaponData should extend Resource")


func test_enemy_data_is_resource():
	var data = EnemyData.new()
	assert_true(data is Resource, "EnemyData should extend Resource")


func test_passive_data_is_resource():
	var data = PassiveData.new()
	assert_true(data is Resource, "PassiveData should extend Resource")
