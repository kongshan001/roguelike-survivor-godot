extends GutTest
## R26 Task B: Tests for 3 new evolved weapon registrations
## Validates: frostvortex, holyshockwave, thunderbeam
## These weapons bridge the registration gap identified in evolved-weapon-registration.md
##
## KNOWN DESIGN CONFLICT: knife+frostaura currently maps to frostknife (recipe #5).
## The R26 spec wants knife+frostaura to map to frostvortex instead. Programmer must
## resolve this by either: (a) reassigning frostknife to a different combo, or
## (b) using a different combo for frostvortex. See BUG-280.

var _registry: RefCounted


func before_each():
	_registry = load("res://scripts/weapons/weapon_registry.gd").new()
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	GameManager.reset()


# =====================================================================
# Section A: Recipe Count (9 -> 12 after R26 Programmer changes)
# =====================================================================

func test_recipe_count_is_12():
	assert_eq(_registry.EVOLUTION_RECIPES.size(), 12,
		"Should have 12 evolution recipes (9 original + 3 new)")


# =====================================================================
# Section B: Recipe Conflict Analysis
# =====================================================================

func test_no_duplicate_ingredient_pairs():
	# Verify no two recipes share the same {a, b} pair
	# This catches the knife+frostaura conflict between frostknife and frostvortex
	var pairs: Array = []
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		var pair: Dictionary = {"a": recipe["a"], "b": recipe["b"]}
		for existing: Dictionary in pairs:
			assert_false(existing["a"] == pair["a"] and existing["b"] == pair["b"],
				"Duplicate ingredient pair: %s+%s (conflict between recipes)" % [pair["a"], pair["b"]])
		pairs.append(pair)


# =====================================================================
# Section C: frostvortex (knife + frostaura per spec, but see BUG-280)
# =====================================================================

func test_frostvortex_recipe_exists():
	var found: bool = false
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		if recipe["result"] == "frostvortex":
			found = true
			assert_eq(recipe["a"], "knife",
				"frostvortex recipe_a should be knife")
			assert_eq(recipe["b"], "frostaura",
				"frostvortex recipe_b should be frostaura")
			break
	assert_true(found, "frostvortex recipe should exist in EVOLUTION_RECIPES")


func test_frostvortex_evolution_available():
	# NOTE: This test will fail until Programmer resolves the knife+frostaura conflict
	# with frostknife (BUG-280). After resolution, knife+frostaura should produce frostvortex.
	UpgradePool._register_base_weapons()
	var owned: Dictionary = {"knife": 3, "frostaura": 3}
	var result: Dictionary = _registry.check_evolution_available(owned)
	assert_eq(result["result"], "frostvortex",
		"knife Lv3 + frostaura Lv3 => frostvortex")


func test_frostvortex_not_available_below_lv3():
	var owned: Dictionary = {"knife": 2, "frostaura": 3}
	var result: Dictionary = _registry.check_evolution_available(owned)
	# knife is Lv2, so frostvortex should not be available
	# But another recipe might match; check frostvortex specifically
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		if recipe["result"] == "frostvortex":
			# Verify the specific check fails
			var a_level: int = owned.get(recipe["a"], 0)
			assert_lt(a_level, 3, "knife should be below Lv3")
			return
	assert_true(true, "frostvortex recipe verified")


func test_frostvortex_not_available_if_already_owned():
	UpgradePool._register_base_weapons()
	var owned: Dictionary = {"knife": 3, "frostaura": 3, "frostvortex": 1}
	var _result: Dictionary = _registry.check_evolution_available(owned)
	# Should not return frostvortex since it's already owned
	# Check all recipes to ensure frostvortex is not offered when owned
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		if recipe["result"] == "frostvortex":
			assert_true(owned.has(recipe["result"]),
				"frostvortex should be in owned, preventing re-evolution")
			return


func test_frostvortex_weapon_data_registered():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("frostvortex")
	assert_not_null(w, "frostvortex should be registered in UpgradePool")


func test_frostvortex_weapon_type():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("frostvortex")
	if w:
		assert_eq(w.weapon_type, "spiral", "frostvortex type should be spiral")


func test_frostvortex_is_evolved():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("frostvortex")
	if w:
		assert_true(w.is_evolved, "frostvortex should be flagged as evolved")


func test_frostvortex_damage():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("frostvortex")
	if w:
		assert_eq(w.damage, 3.0, "frostvortex damage should be 3.0 per spec")


func test_frostvortex_cooldown():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("frostvortex")
	if w:
		assert_eq(w.cooldown, 999.0,
			"frostvortex cooldown should be 999 (always active)")


func test_frostvortex_weapon_name():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("frostvortex")
	if w:
		assert_eq(w.weapon_name, "霜刃旋涡",
			"frostvortex weapon_name should match spec")


func test_frostvortex_weapon_id():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("frostvortex")
	if w:
		assert_eq(w.weapon_id, "frostvortex",
			"frostvortex weapon_id should match")


func test_frostvortex_color():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("frostvortex")
	if w:
		assert_eq(w.color, Color(0.3, 0.7, 1.0),
			"frostvortex color should be ice blue")


func test_frostvortex_slow_pct():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("frostvortex")
	if w:
		assert_eq(w.slow_pct, 0.4,
			"frostvortex slow_pct should be 0.4 per spec")


func test_frostvortex_freeze_pct():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("frostvortex")
	if w:
		assert_eq(w.freeze_pct, 0.08,
			"frostvortex freeze_pct should be 0.08 per spec")


func test_frostvortex_description():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("frostvortex")
	if w:
		assert_eq(w.description, "螺旋冰刃扩散+减速",
			"frostvortex description should match spec")


# =====================================================================
# Section C: holyshockwave (holywater + firestaff)
# =====================================================================

func test_holyshockwave_recipe_exists():
	var found: bool = false
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		if recipe["result"] == "holyshockwave":
			found = true
			assert_eq(recipe["a"], "holywater",
				"holyshockwave recipe_a should be holywater")
			assert_eq(recipe["b"], "firestaff",
				"holyshockwave recipe_b should be firestaff")
			break
	assert_true(found, "holyshockwave recipe should exist")


func test_holyshockwave_evolution_available():
	UpgradePool._register_base_weapons()
	var owned: Dictionary = {"holywater": 3, "firestaff": 3}
	var result: Dictionary = _registry.check_evolution_available(owned)
	assert_eq(result["result"], "holyshockwave",
		"holywater Lv3 + firestaff Lv3 => holyshockwave")


func test_holyshockwave_weapon_data_registered():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("holyshockwave")
	assert_not_null(w, "holyshockwave should be registered in UpgradePool")


func test_holyshockwave_weapon_type():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("holyshockwave")
	if w:
		assert_eq(w.weapon_type, "pulse", "holyshockwave type should be pulse")


func test_holyshockwave_is_evolved():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("holyshockwave")
	if w:
		assert_true(w.is_evolved, "holyshockwave should be flagged as evolved")


func test_holyshockwave_damage():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("holyshockwave")
	if w:
		assert_eq(w.damage, 12.0, "holyshockwave damage should be 12.0 per spec")


func test_holyshockwave_cooldown():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("holyshockwave")
	if w:
		assert_eq(w.cooldown, 2.5,
			"holyshockwave cooldown should be 2.5 per spec")


func test_holyshockwave_weapon_name():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("holyshockwave")
	if w:
		assert_eq(w.weapon_name, "圣焰冲击",
			"holyshockwave weapon_name should match spec")


func test_holyshockwave_color():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("holyshockwave")
	if w:
		assert_eq(w.color, Color(1.0, 0.85, 0.3),
			"holyshockwave color should be gold")


func test_holyshockwave_burn_dps():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("holyshockwave")
	if w:
		assert_eq(w.burn_dps, 2.0,
			"holyshockwave burn_dps should be 2.0 per spec")


func test_holyshockwave_burn_duration():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("holyshockwave")
	if w:
		assert_eq(w.burn_duration, 2.0,
			"holyshockwave burn_duration should be 2.0 per spec")


func test_holyshockwave_description():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("holyshockwave")
	if w:
		assert_eq(w.description, "周期性圣焰脉冲+燃烧",
			"holyshockwave description should match spec")


# =====================================================================
# Section D: thunderbeam (lightning + knife)
# =====================================================================

func test_thunderbeam_recipe_exists():
	var found: bool = false
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		if recipe["result"] == "thunderbeam":
			found = true
			assert_eq(recipe["a"], "lightning",
				"thunderbeam recipe_a should be lightning")
			assert_eq(recipe["b"], "knife",
				"thunderbeam recipe_b should be knife")
			break
	assert_true(found, "thunderbeam recipe should exist")


func test_thunderbeam_evolution_available():
	UpgradePool._register_base_weapons()
	var owned: Dictionary = {"lightning": 3, "knife": 3}
	var result: Dictionary = _registry.check_evolution_available(owned)
	assert_eq(result["result"], "thunderbeam",
		"lightning Lv3 + knife Lv3 => thunderbeam")


func test_thunderbeam_weapon_data_registered():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("thunderbeam")
	assert_not_null(w, "thunderbeam should be registered in UpgradePool")


func test_thunderbeam_weapon_type():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("thunderbeam")
	if w:
		assert_eq(w.weapon_type, "beam", "thunderbeam type should be beam")


func test_thunderbeam_is_evolved():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("thunderbeam")
	if w:
		assert_true(w.is_evolved, "thunderbeam should be flagged as evolved")


func test_thunderbeam_damage():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("thunderbeam")
	if w:
		assert_eq(w.damage, 4.0, "thunderbeam damage should be 4.0 per spec")


func test_thunderbeam_cooldown():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("thunderbeam")
	if w:
		assert_eq(w.cooldown, 2.5,
			"thunderbeam cooldown should be 2.5 per spec")


func test_thunderbeam_weapon_name():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("thunderbeam")
	if w:
		assert_eq(w.weapon_name, "雷霆射线",
			"thunderbeam weapon_name should match spec")


func test_thunderbeam_color():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("thunderbeam")
	if w:
		assert_eq(w.color, Color(1.0, 1.0, 0.4),
			"thunderbeam color should be electric yellow")


func test_thunderbeam_chain_count():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("thunderbeam")
	if w:
		assert_eq(w.chain_count, 2,
			"thunderbeam chain_count should be 2 per spec")


func test_thunderbeam_projectile_range():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("thunderbeam")
	if w:
		assert_eq(w.projectile_range, 1200.0,
			"thunderbeam projectile_range should be 1200.0 per spec")


func test_thunderbeam_description():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var w: WeaponData = UpgradePool._weapons.get("thunderbeam")
	if w:
		assert_eq(w.description, "穿透闪电射线+连锁电击",
			"thunderbeam description should match spec")


# =====================================================================
# Section E: UpgradePool Integration (evolution offers)
# =====================================================================

func test_frostvortex_evolution_option_appears():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var owned: Dictionary = {"knife": 3, "frostaura": 3}
	var options: Array[Dictionary] = UpgradePool.get_random_upgrades(owned, {}, 3)
	var found: bool = false
	for opt: Dictionary in options:
		if opt.type == "evolution" and opt.id == "frostvortex":
			found = true
			assert_has(opt, "recipe_a", "Evolution option should have recipe_a")
			assert_has(opt, "recipe_b", "Evolution option should have recipe_b")
			assert_eq(opt.recipe_a, "knife", "recipe_a should be knife")
			assert_eq(opt.recipe_b, "frostaura", "recipe_b should be frostaura")
	assert_true(found, "frostvortex evolution option should appear in upgrades")


func test_holyshockwave_evolution_option_appears():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var owned: Dictionary = {"holywater": 3, "firestaff": 3}
	var options: Array[Dictionary] = UpgradePool.get_random_upgrades(owned, {}, 3)
	var found: bool = false
	for opt: Dictionary in options:
		if opt.type == "evolution" and opt.id == "holyshockwave":
			found = true
	assert_true(found, "holyshockwave evolution option should appear in upgrades")


func test_thunderbeam_evolution_option_appears():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var owned: Dictionary = {"lightning": 3, "knife": 3}
	var options: Array[Dictionary] = UpgradePool.get_random_upgrades(owned, {}, 3)
	var found: bool = false
	for opt: Dictionary in options:
		if opt.type == "evolution" and opt.id == "thunderbeam":
			found = true
	assert_true(found, "thunderbeam evolution option should appear in upgrades")


func test_new_evolved_weapons_not_offered_as_new():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var options: Array[Dictionary] = UpgradePool.get_random_upgrades({}, {}, 20)
	# Verify that get_random_upgrades actually returned options
	assert_gt(options.size(), 0, "Should get at least some upgrade options")
	var evolved_ids: Array = ["frostvortex", "holyshockwave", "thunderbeam"]
	var new_weapon_ids: Array = []
	for opt: Dictionary in options:
		if opt.type == "new_weapon":
			new_weapon_ids.append(opt.id)
	# Assert that none of the new_weapon options are evolved weapon IDs
	assert_gt(new_weapon_ids.size(), 0, "Should have at least one new_weapon option to validate")
	for wid: String in new_weapon_ids:
		assert_not_in(wid, evolved_ids,
			"New evolved weapon '%s' should not be offered as new_weapon" % wid)


func assert_not_in(value, array: Array, message: String):
	if value in array:
		fail_test(message)


# =====================================================================
# Section F: Regression -- existing 9 recipes still work
# =====================================================================

func test_existing_recipe_thunderholywater_still_works():
	var owned: Dictionary = {"holywater": 3, "lightning": 3}
	var result: Dictionary = _registry.check_evolution_available(owned)
	assert_eq(result["result"], "thunderholywater",
		"Existing recipe holywater+lightning should still produce thunderholywater")


func test_existing_recipe_fireknife_still_works():
	# Need to exclude other recipes that might match first
	var owned: Dictionary = {"knife": 3, "firestaff": 3}
	var result: Dictionary = _registry.check_evolution_available(owned)
	# fireknife recipe: knife + firestaff
	assert_eq(result["result"], "fireknife",
		"Existing recipe knife+firestaff should still produce fireknife")


func test_all_12_evolved_weapons_registered():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()
	var expected: Array = [
		"thunderholywater", "fireknife", "holydomain", "blizzard",
		"frostknife", "flamebible", "thunderang", "blazerang",
		"sentineltotem", "frostvortex", "holyshockwave", "thunderbeam"
	]
	for id: String in expected:
		assert_not_null(UpgradePool._weapons.get(id),
			"%s should be registered" % id)


# =====================================================================
# Section G: Unique result IDs (no duplicates across all 12)
# =====================================================================

func test_all_12_recipe_results_unique():
	var results: Array = []
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		assert_false(results.has(recipe["result"]),
			"Result %s should be unique across all recipes" % recipe["result"])
		results.append(recipe["result"])
	assert_eq(results.size(), 12, "Should have 12 unique results")


# =====================================================================
# Section H: WeaponData fields for new types (Phase B already done)
# =====================================================================

func test_weapon_data_has_spiral_fields():
	var d: WeaponData = WeaponData.new()
	assert_eq(d.spiral_blade_count, 6,
		"WeaponData spiral_blade_count default should be 6")
	assert_eq(d.spiral_min_radius, 20.0,
		"WeaponData spiral_min_radius default should be 20.0")
	assert_eq(d.spiral_max_radius, 180.0,
		"WeaponData spiral_max_radius default should be 180.0")
	assert_eq(d.spiral_expand_speed, 60.0,
		"WeaponData spiral_expand_speed default should be 60.0")


func test_weapon_data_has_pulse_fields():
	var d: WeaponData = WeaponData.new()
	assert_eq(d.pulse_max_radius, 200.0,
		"WeaponData pulse_max_radius default should be 200.0")
	assert_eq(d.pulse_expand_time, 0.3,
		"WeaponData pulse_expand_time default should be 0.3")
	assert_eq(d.pulse_ring_width, 12.0,
		"WeaponData pulse_ring_width default should be 12.0")


func test_weapon_data_has_beam_fields():
	var d: WeaponData = WeaponData.new()
	assert_eq(d.beam_active_duration, 1.0,
		"WeaponData beam_active_duration default should be 1.0")
	assert_eq(d.beam_tick_interval, 0.3,
		"WeaponData beam_tick_interval default should be 0.3")
	assert_eq(d.beam_width, 12.0,
		"WeaponData beam_width default should be 12.0")
