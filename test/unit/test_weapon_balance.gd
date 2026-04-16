extends GutTest

# DPS balance regression tests for R11 weapon tuning.
# Validates that all 6 weapon nerfs/buffs were applied correctly.


func before_each():
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	GameManager.reset()


func _register_all_weapons():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()


# --- Specific balance changes (R11) ---

func test_thunderang_damage_is_5():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("thunderang")
	assert_ne(data, null, "thunderang should exist")
	assert_eq(data.damage, 5.0, "thunderang damage should be 5.0 (nerfed from 7)")


func test_fireknife_count_is_3():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("fireknife")
	assert_ne(data, null, "fireknife should exist")
	assert_eq(data.projectile_count, 3, "fireknife projectile_count should be 3 (nerfed from 5)")


func test_fireknife_burn_dps_is_2():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("fireknife")
	assert_ne(data, null, "fireknife should exist")
	assert_eq(data.burn_dps, 2.0, "fireknife burn_dps should be 2.0 (nerfed from 3)")


func test_blazerang_damage_is_5():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("blazerang")
	assert_ne(data, null, "blazerang should exist")
	assert_eq(data.damage, 5.0, "blazerang damage should be 5.0 (nerfed from 6)")


func test_frostknife_count_is_4():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("frostknife")
	assert_ne(data, null, "frostknife should exist")
	assert_eq(data.projectile_count, 4, "frostknife projectile_count should be 4 (nerfed from 5)")


func test_thunderholywater_damage_is_2_5():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("thunderholywater")
	assert_ne(data, null, "thunderholywater should exist")
	assert_eq(data.damage, 2.5, "thunderholywater damage should be 2.5 (buffed from 1.5)")


func test_thunderholywater_speed_is_4_5():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("thunderholywater")
	assert_ne(data, null, "thunderholywater should exist")
	assert_eq(data.orbit_speed, 4.5, "thunderholywater orbit_speed should be 4.5 (buffed from 3.5)")


# --- Global weapon invariant checks ---

func test_all_weapons_damage_positive():
	_register_all_weapons()
	for weapon_id in UpgradePool._weapons:
		var data: WeaponData = UpgradePool._weapons[weapon_id]
		assert_gt(data.damage, 0.0, "%s damage should be > 0 (got %s)" % [weapon_id, str(data.damage)])


func test_all_weapons_cooldown_positive():
	_register_all_weapons()
	for weapon_id in UpgradePool._weapons:
		var data: WeaponData = UpgradePool._weapons[weapon_id]
		assert_gte(data.cooldown, 0.0, "%s cooldown should be >= 0 (got %s)" % [weapon_id, str(data.cooldown)])


# --- Additional balance sanity checks ---

func test_all_base_weapons_registered():
	UpgradePool._register_base_weapons()
	assert_eq(UpgradePool._weapons.size(), 7, "Should have 7 base weapons")


func test_all_evolved_weapons_registered():
	_register_all_weapons()
	var evolved_count: int = 0
	for weapon_id in UpgradePool._weapons:
		var data: WeaponData = UpgradePool._weapons[weapon_id]
		if data.is_evolved:
			evolved_count += 1
	assert_eq(evolved_count, 9, "Should have 9 evolved weapons (including sentineltotem)")


func test_thunderang_is_evolved():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("thunderang")
	assert_true(data.is_evolved, "thunderang should be evolved")


func test_fireknife_is_evolved():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("fireknife")
	assert_true(data.is_evolved, "fireknife should be evolved")


func test_blazerang_is_evolved():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("blazerang")
	assert_true(data.is_evolved, "blazerang should be evolved")


func test_frostknife_is_evolved():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("frostknife")
	assert_true(data.is_evolved, "frostknife should be evolved")


func test_thunderholywater_is_evolved():
	_register_all_weapons()
	var data: WeaponData = UpgradePool._weapons.get("thunderholywater")
	assert_true(data.is_evolved, "thunderholywater should be evolved")
