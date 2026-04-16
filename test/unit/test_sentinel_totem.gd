extends GutTest

# Test Sentinel Totem (bible + boomerang evolution) weapon data and registration

var _registry: RefCounted


func before_all():
	_registry = load("res://scripts/weapons/weapon_registry.gd").new()


func before_each():
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	GameManager.reset()


func _register_all_weapons():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()


# --- Registration ---

func test_sentinel_registered_in_upgrade_pool():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_ne(data, null, "sentineltotem should be registered in UpgradePool")
	assert_eq(data.weapon_type, "orbit", "sentineltotem should be orbit type")


func test_sentinel_weapon_id():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_eq(data.weapon_id, "sentineltotem", "weapon_id should be sentineltotem")


func test_sentinel_is_evolved():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_true(data.is_evolved, "sentineltotem should be flagged as evolved")


# --- orbit_fire_rate ---

func test_sentinel_orbit_fire_rate_field():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_gt(data.orbit_fire_rate, 0.0, "orbit_fire_rate should be > 0 (fires projectiles)")


func test_sentinel_orbit_fire_rate_value():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_eq(data.orbit_fire_rate, 0.8, "orbit_fire_rate should be 0.8 seconds")


# --- Evolution recipe ---

func test_sentinel_evolution_recipe():
	var found: bool = false
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		if recipe["result"] == "sentineltotem":
			found = true
			assert_eq(recipe["a"], "bible", "Recipe ingredient a should be bible")
			assert_eq(recipe["b"], "boomerang", "Recipe ingredient b should be boomerang")
	if not found:
		fail_test("sentineltotem recipe not found in EVOLUTION_RECIPES")


func test_sentinel_evolution_triggers():
	_register_all_weapons()
	var owned := {"bible": 3, "boomerang": 3}
	var result: Dictionary = _registry.check_evolution_available(owned)
	assert_eq(result.get("result", ""), "sentineltotem", "bible+boomerang Lv3 should yield sentineltotem")


# --- Damage ---

func test_sentinel_damage_value():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_gt(data.damage, 0.0, "damage should be > 0")


func test_sentinel_damage_exact():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_eq(data.damage, 2.5, "damage should be 2.5")


# --- Orbit count ---

func test_sentinel_orbit_count():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_gte(data.orbit_count, 2, "orbit_count should be >= 2")


func test_sentinel_orbit_count_exact():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_eq(data.orbit_count, 2, "orbit_count should be 2")


# --- Additional fields ---

func test_sentinel_orbit_radius():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_eq(data.orbit_radius, 120.0, "orbit_radius should be 120")


func test_sentinel_orbit_speed():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_eq(data.orbit_speed, 1.5, "orbit_speed should be 1.5")


func test_sentinel_projectile_speed():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_eq(data.projectile_speed, 280.0, "projectile_speed should be 280")


func test_sentinel_weapon_name():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("sentineltotem")
	assert_eq(data.weapon_name, "守护图腾", "weapon_name should match Chinese name")


# --- WeaponData default orbit_fire_rate ---

func test_weapon_data_default_orbit_fire_rate_is_zero():
	var d := WeaponData.new()
	assert_eq(d.orbit_fire_rate, 0.0, "Default orbit_fire_rate should be 0.0 (no firing)")
