extends GutTest

# Test UpgradePool autoload: weapon registration, upgrade generation


func before_each():
	# Reset UpgradePool internal state via reflection
	UpgradePool._weapons = {}
	UpgradePool._passives = {}
	UpgradePool._initialized = false
	GameManager.reset()


# --- Weapon Registration ---

func test_register_weapon():
	var data = WeaponData.new()
	data.weapon_name = "Test Weapon"
	data.weapon_id = "test_wpn"
	UpgradePool.register_weapon("test_wpn", data)
	assert_true(UpgradePool._weapons.has("test_wpn"), "Weapon should be registered")


func test_register_multiple_weapons():
	for i in range(4):
		var data = WeaponData.new()
		data.weapon_name = "Weapon %d" % i
		UpgradePool.register_weapon("wpn_%d" % i, data)
	assert_eq(UpgradePool._weapons.size(), 4, "Should have 4 registered weapons")


# --- Upgrade Generation ---

func test_get_upgrades_returns_new_weapons():
	_register_test_weapons()
	var upgrades = UpgradePool.get_random_upgrades({}, {}, 3)
	assert_eq(upgrades.size(), 3, "Should return 3 upgrades")

	var types: Array = []
	for u in upgrades:
		types.append(u.type)
	# With no owned weapons, all should be new_weapon or passive
	for u in upgrades:
		assert_has(["new_weapon", "passive"], u.type, "Type should be new_weapon or passive")


func test_get_upgrades_includes_weapon_upgrade():
	_register_test_weapons()
	var owned = {"wpn_a": 1}
	var upgrades = UpgradePool.get_random_upgrades(owned, {}, 10)

	var has_upgrade = false
	for u in upgrades:
		if u.type == "weapon_upgrade" and u.id == "wpn_a":
			has_upgrade = true
	assert_true(has_upgrade, "Should include weapon upgrade for owned weapon")


func test_get_upgrades_max_level_weapon_excluded():
	_register_test_weapons()
	var owned = {"wpn_a": 3}  # Max level
	var upgrades = UpgradePool.get_random_upgrades(owned, {}, 20)

	var found_wpn_a_upgrade = false
	for u in upgrades:
		if u.id == "wpn_a" and u.type == "weapon_upgrade":
			found_wpn_a_upgrade = true
	assert_false(found_wpn_a_upgrade, "Max level weapon should not have upgrade option")


func test_get_upgrades_returns_correct_count():
	_register_test_weapons()
	var upgrades = UpgradePool.get_random_upgrades({}, {}, 2)
	assert_eq(upgrades.size(), 2, "Should return exactly 2 upgrades")


func test_get_upgrades_empty_pool():
	var upgrades = UpgradePool.get_random_upgrades({}, {}, 3)
	# Only passives available
	assert_gt(upgrades.size(), 0, "Should still return passives")


func test_upgrade_option_structure():
	_register_test_weapons()
	var upgrades = UpgradePool.get_random_upgrades({}, {}, 1)
	var u = upgrades[0]
	assert_has(u, "type", "Option should have 'type'")
	assert_has(u, "id", "Option should have 'id'")
	assert_has(u, "name", "Option should have 'name'")
	assert_has(u, "description", "Option should have 'description'")
	assert_has(u, "icon_color", "Option should have 'icon_color'")


func test_passives_always_available():
	var upgrades = UpgradePool.get_random_upgrades({}, {}, 10)
	var passive_count = 0
	for u in upgrades:
		if u.type == "passive":
			passive_count += 1
	assert_gt(passive_count, 0, "Should have at least one passive option")


func test_passive_respects_max_stack():
	_register_test_weapons()
	var owned_passives = {"armor": 3}  # max stack reached
	var upgrades = UpgradePool.get_random_upgrades({}, owned_passives, 20)
	for u in upgrades:
		if u.type == "passive" and u.id == "armor":
			fail_test("Maxed passive should not appear in upgrades")
			return
	assert_true(true, "No maxed passive in upgrades")


func test_7_passives_available():
	# Verify all 7 H5 passives are registered
	UpgradePool._ensure_initialized()
	assert_eq(UpgradePool._passives.size(), 7, "Should have 7 passive types")
	assert_has(UpgradePool._passives, "speedboots")
	assert_has(UpgradePool._passives, "armor")
	assert_has(UpgradePool._passives, "magnet")
	assert_has(UpgradePool._passives, "crit")
	assert_has(UpgradePool._passives, "maxhp")
	assert_has(UpgradePool._passives, "regen")
	assert_has(UpgradePool._passives, "luckycoin")


# --- Helper ---

func _register_test_weapons():
	var a = WeaponData.new()
	a.weapon_name = "Weapon A"
	a.weapon_id = "wpn_a"
	a.description = "Test weapon A"
	UpgradePool.register_weapon("wpn_a", a)

	var b = WeaponData.new()
	b.weapon_name = "Weapon B"
	b.weapon_id = "wpn_b"
	b.description = "Test weapon B"
	UpgradePool.register_weapon("wpn_b", b)
