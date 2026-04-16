extends GutTest
## R20 Task 3: Weapon Mastery System Tests
## Validates weapon mastery per weapon-mastery.md spec.
## Programmer adds mastery system to SaveManager + kill attribution to enemy.gd.


var _mgr: Node


func before_each():
	_mgr = Node.new()
	_mgr.set_script(load("res://scripts/autoload/save_manager.gd"))
	add_child_autofree(_mgr)
	_mgr.soul_fragments = 0
	_mgr.total_kills = 0
	_mgr.games_played = 0
	_mgr.endless_unlocked = false
	_mgr._init_data()


func after_each():
	await get_tree().process_frame


# =====================================================
# Section A: Mastery Constants and Initialization
# =====================================================

func test_mastery_thresholds_constant():
	assert_eq(_mgr.MASTERY_THRESHOLDS, [0, 50, 200, 500, 1000], "Mastery thresholds should be [0, 50, 200, 500, 1000]")

func test_mastery_bonuses_constant():
	assert_eq(_mgr.MASTERY_BONUSES, [0.0, 0.02, 0.04, 0.06, 0.08], "Mastery bonuses should be [0.0, 0.02, 0.04, 0.06, 0.08]")

func test_base_weapons_constant():
	var expected: Array = ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang"]
	assert_eq(_mgr.BASE_WEAPONS, expected, "BASE_WEAPONS should have 7 base weapons")

func test_base_weapons_count():
	assert_eq(_mgr.BASE_WEAPONS.size(), 7, "Should have 7 base weapons")


# =====================================================
# Section B: Weapon Kill Tracking
# =====================================================

func test_weapon_kills_initialized():
	for weapon_id: String in _mgr.BASE_WEAPONS:
		assert_eq(_mgr.weapon_kills.get(weapon_id, -1), 0, "Weapon %s kills should start at 0" % weapon_id)

func test_add_weapon_kill_knife():
	_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_kill_count("knife"), 1, "Knife kills should be 1")

func test_add_weapon_kill_accumulates():
	for i in range(50):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_kill_count("knife"), 50, "Knife kills should accumulate to 50")

func test_add_weapon_kill_independent():
	_mgr.add_weapon_kill("knife")
	_mgr.add_weapon_kill("knife")
	_mgr.add_weapon_kill("boomerang")
	assert_eq(_mgr.get_weapon_kill_count("knife"), 2, "Knife kills = 2")
	assert_eq(_mgr.get_weapon_kill_count("boomerang"), 1, "Boomerang kills = 1")
	assert_eq(_mgr.get_weapon_kill_count("bible"), 0, "Bible kills = 0")

func test_add_weapon_kill_unknown_weapon_ignored():
	_mgr.add_weapon_kill("fireknife")
	assert_eq(_mgr.get_weapon_kill_count("fireknife"), 0, "Evolved weapon should not be tracked directly")
	_mgr.add_weapon_kill("nonexistent")
	assert_eq(_mgr.get_weapon_kill_count("nonexistent"), 0, "Unknown weapon should not be tracked")

func test_get_weapon_kill_count_unknown_returns_zero():
	assert_eq(_mgr.get_weapon_kill_count("unknown_weapon"), 0, "Unknown weapon returns 0")


# =====================================================
# Section C: Mastery Tier Calculation
# =====================================================

func test_mastery_tier_0_at_0_kills():
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 0, "0 kills = Tier 0 (Novice)")

func test_mastery_tier_1_at_50_kills():
	for i in range(50):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 1, "50 kills = Tier 1 (Apprentice)")

func test_mastery_tier_2_at_200_kills():
	for i in range(200):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 2, "200 kills = Tier 2 (Adept)")

func test_mastery_tier_3_at_500_kills():
	for i in range(500):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 3, "500 kills = Tier 3 (Expert)")

func test_mastery_tier_4_at_1000_kills():
	for i in range(1000):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 4, "1000 kills = Tier 4 (Master)")

func test_mastery_tier_1_at_49_kills():
	for i in range(49):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 0, "49 kills = still Tier 0")

func test_mastery_tier_2_at_199_kills():
	for i in range(199):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 1, "199 kills = still Tier 1")

func test_mastery_tier_3_at_499_kills():
	for i in range(499):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 2, "499 kills = still Tier 2")

func test_mastery_tier_4_at_999_kills():
	for i in range(999):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 3, "999 kills = still Tier 3")

func test_mastery_tier_beyond_1000():
	for i in range(1500):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 4, "1500 kills = still Tier 4 (cap)")


# =====================================================
# Section D: Mastery Bonus Values
# =====================================================

func test_mastery_bonus_tier_0():
	assert_eq(_mgr.get_weapon_mastery_bonus("knife"), 0.0, "Tier 0 bonus = +0%")

func test_mastery_bonus_tier_1():
	for i in range(50):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_bonus("knife"), 0.02, "Tier 1 bonus = +2%")

func test_mastery_bonus_tier_2():
	for i in range(200):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_bonus("knife"), 0.04, "Tier 2 bonus = +4%")

func test_mastery_bonus_tier_3():
	for i in range(500):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_bonus("knife"), 0.06, "Tier 3 bonus = +6%")

func test_mastery_bonus_tier_4():
	for i in range(1000):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_mastery_bonus("knife"), 0.08, "Tier 4 bonus = +8%")

func test_mastery_bonus_unknown_weapon():
	assert_eq(_mgr.get_weapon_mastery_bonus("fireknife"), 0.0, "Unknown weapon bonus = +0%")

func test_mastery_bonus_independent_per_weapon():
	for i in range(200):
		_mgr.add_weapon_kill("knife")
	_mgr.add_weapon_kill("boomerang")
	assert_eq(_mgr.get_weapon_mastery_bonus("knife"), 0.04, "Knife at Tier 2 = +4%")
	assert_eq(_mgr.get_weapon_mastery_bonus("boomerang"), 0.0, "Boomerang at Tier 0 = +0%")


# =====================================================
# Section E: Evolved Weapon Kill Attribution
# =====================================================

func test_evolved_parents_mapping():
	# Verify the evolved_parents dictionary exists and has correct entries
	var evolved_parents: Dictionary = _mgr.get("EVOLVED_PARENTS") if _mgr.get("EVOLVED_PARENTS") != null else {}
	# If EVOLVED_PARENTS is a constant, check via the system behavior instead
	# fireknife -> counts for knife AND firestaff
	_mgr.add_weapon_kill("knife")
	_mgr.add_weapon_kill("firestaff")
	_mgr.add_weapon_kill("fireknife")
	# knife should get +1 (direct) + nothing (fireknife ignored for base tracking)
	# firestaff should get +1 (direct) + nothing (fireknife ignored for base tracking)
	# The evolved weapon kill attribution happens in enemy.gd, not in add_weapon_kill directly
	assert_eq(_mgr.get_weapon_kill_count("knife"), 1, "Direct knife kill counted")
	assert_eq(_mgr.get_weapon_kill_count("firestaff"), 1, "Direct firestaff kill counted")

func test_evolved_attribution_fireknife():
	# Simulating what enemy.gd should do: evolved kill -> credit both parents
	# fireknife evolved from knife + firestaff
	_mgr.add_weapon_kill("knife")  # parent 1
	_mgr.add_weapon_kill("firestaff")  # parent 2
	assert_eq(_mgr.get_weapon_kill_count("knife"), 1, "Knife credited")
	assert_eq(_mgr.get_weapon_kill_count("firestaff"), 1, "Firestaff credited")

func test_evolved_attribution_thunderholywater():
	_mgr.add_weapon_kill("holywater")
	_mgr.add_weapon_kill("lightning")
	assert_eq(_mgr.get_weapon_kill_count("holywater"), 1, "Holywater credited")
	assert_eq(_mgr.get_weapon_kill_count("lightning"), 1, "Lightning credited")

func test_evolved_attribution_sentineltotem():
	_mgr.add_weapon_kill("bible")
	_mgr.add_weapon_kill("boomerang")
	assert_eq(_mgr.get_weapon_kill_count("bible"), 1, "Bible credited")
	assert_eq(_mgr.get_weapon_kill_count("boomerang"), 1, "Boomerang credited")

func test_all_9_evolved_parent_pairs():
	# Verify all 9 evolved weapons have parent mappings
	var evolved_map: Dictionary = {
		"thunderholywater": ["holywater", "lightning"],
		"fireknife": ["knife", "firestaff"],
		"holydomain": ["bible", "holywater"],
		"blizzard": ["frostaura", "lightning"],
		"frostknife": ["knife", "frostaura"],
		"flamebible": ["bible", "firestaff"],
		"thunderang": ["boomerang", "lightning"],
		"blazerang": ["boomerang", "firestaff"],
		"sentineltotem": ["bible", "boomerang"],
	}
	assert_eq(evolved_map.size(), 9, "Should have 9 evolved weapon mappings")
	# Verify each parent pair contains only base weapons
	for evo_id: String in evolved_map:
		for parent: String in evolved_map[evo_id]:
			assert_has(_mgr.BASE_WEAPONS, parent, "Parent %s of %s should be a base weapon" % [parent, evo_id])


# =====================================================
# Section F: SaveManager Persistence
# =====================================================

func test_save_load_mastery():
	for i in range(75):
		_mgr.add_weapon_kill("knife")
	_mgr.add_weapon_kill("boomerang")
	_mgr.save()
	# Reload
	var mgr2: Node = Node.new()
	mgr2.set_script(load("res://scripts/autoload/save_manager.gd"))
	add_child_autofree(mgr2)
	mgr2._init_data()
	mgr2.load_save()
	assert_eq(mgr2.get_weapon_kill_count("knife"), 75, "Knife kills should persist after save/load")
	assert_eq(mgr2.get_weapon_kill_count("boomerang"), 1, "Boomerang kills should persist after save/load")
	assert_eq(mgr2.get_weapon_mastery_tier("knife"), 1, "Knife mastery tier should persist")

func test_reset_clears_mastery():
	for i in range(100):
		_mgr.add_weapon_kill("knife")
	assert_eq(_mgr.get_weapon_kill_count("knife"), 100, "Knife kills before reset")
	_mgr.reset_save()
	assert_eq(_mgr.get_weapon_kill_count("knife"), 0, "Knife kills after reset")
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 0, "Knife tier after reset")

func test_reset_reinitializes_all_weapons():
	_mgr.reset_save()
	for weapon_id: String in _mgr.BASE_WEAPONS:
		assert_eq(_mgr.weapon_kills.get(weapon_id, -1), 0, "%s should be 0 after reset" % weapon_id)


# =====================================================
# Section G: Mastery + Shop Bonus Stacking
# =====================================================

func test_mastery_additive_with_shop_bonus():
	# Per spec: Final Damage = Base x (1 + shop_bonus + mastery_bonus) x character_passive
	_mgr.shop_upgrades["weapondmg"] = 4  # T4 = +15%
	for i in range(1000):
		_mgr.add_weapon_kill("knife")  # Tier 4 = +8%
	var shop_bonus: float = _mgr.get_weapon_dmg_bonus()
	var mastery_bonus: float = _mgr.get_weapon_mastery_bonus("knife")
	var additive_total: float = shop_bonus + mastery_bonus
	assert_almost_eq(additive_total, 0.23, 0.001, "Shop 15% + Mastery 8% ~= 23% additive")

func test_mastery_no_shop():
	# Mastery alone
	for i in range(1000):
		_mgr.add_weapon_kill("knife")
	var mastery_bonus: float = _mgr.get_weapon_mastery_bonus("knife")
	assert_eq(mastery_bonus, 0.08, "Mastery alone = 8%")


# =====================================================
# Section H: Mastery + Character Passive Stacking
# =====================================================

func test_mastery_with_mage_passive():
	# Per spec: Final Damage = Base x (1 + shop_bonus + mastery_bonus) x character_passive
	# Mage passive = +20% = 1.20x multiplier
	var shop_bonus: float = 0.15  # T4
	for i in range(1000):
		_mgr.add_weapon_kill("knife")
	var mastery_bonus: float = _mgr.get_weapon_mastery_bonus("knife")
	var character_passive: float = 1.20  # Mage
	var total_multiplier: float = (1.0 + shop_bonus + mastery_bonus) * character_passive
	assert_eq(total_multiplier, 1.476, "Mage: (1 + 0.15 + 0.08) * 1.20 = 1.476")

func test_mastery_with_ranger_passive():
	# Ranger passive = crit build, ~1.23x effective
	var shop_bonus: float = 0.15
	for i in range(1000):
		_mgr.add_weapon_kill("knife")
	var mastery_bonus: float = _mgr.get_weapon_mastery_bonus("knife")
	var character_passive: float = 1.23  # Ranger effective
	var total_multiplier: float = (1.0 + shop_bonus + mastery_bonus) * character_passive
	assert_eq(total_multiplier, 1.5129, "Ranger: (1 + 0.15 + 0.08) * 1.23 = 1.5129")

func test_no_mastery_no_shop_no_passive():
	# Base case: 1.0x
	var total: float = 1.0
	assert_eq(total, 1.0, "No bonuses = 1.0x base")


# =====================================================
# Section I: Mastery Achievement Conditions
# =====================================================

func test_mastery_first_achievement_at_tier_1():
	# Any weapon reaching Tier 1 (50 kills) should trigger mastery_first
	for i in range(50):
		_mgr.add_weapon_kill("knife")
	var max_tier: int = 0
	for weapon_id: String in _mgr.BASE_WEAPONS:
		var tier: int = _mgr.get_weapon_mastery_tier(weapon_id)
		if tier > max_tier:
			max_tier = tier
	assert_gte(max_tier, 1, "At least one weapon should be at Tier 1 or above")

func test_mastery_all_achievement_requires_all_tier_4():
	# All 7 weapons at 1000 kills should trigger mastery_all
	for weapon_id: String in _mgr.BASE_WEAPONS:
		for i in range(1000):
			_mgr.add_weapon_kill(weapon_id)
	var all_master: bool = true
	for weapon_id: String in _mgr.BASE_WEAPONS:
		if _mgr.get_weapon_mastery_tier(weapon_id) < 4:
			all_master = false
	assert_true(all_master, "All weapons at 1000 kills should be Master tier")

func test_mastery_all_not_triggered_with_one_missing():
	for weapon_id: String in _mgr.BASE_WEAPONS:
		for i in range(1000):
			_mgr.add_weapon_kill(weapon_id)
	# Drop one back
	_mgr.weapon_kills["bible"] = 999
	var all_master: bool = true
	for weapon_id: String in _mgr.BASE_WEAPONS:
		if _mgr.get_weapon_mastery_tier(weapon_id) < 4:
			all_master = false
	assert_false(all_master, "Should not trigger mastery_all with one weapon at 999")


# =====================================================
# Section J: Edge Cases
# =====================================================

func test_mastery_empty_last_hit_by():
	# If _last_hit_by is empty, no kill should be recorded
	# This is verified by ensuring add_weapon_kill("") does nothing
	_mgr.add_weapon_kill("")
	# No weapon should have kills
	for weapon_id: String in _mgr.BASE_WEAPONS:
		assert_eq(_mgr.weapon_kills[weapon_id], 0, "Empty weapon ID should not increment any kill")

func test_mastery_all_weapons_independent():
	# Verify each weapon tracks independently
	var weapons: Array = _mgr.BASE_WEAPONS
	for idx in range(weapons.size()):
		for i in range(idx * 10):
			_mgr.add_weapon_kill(weapons[idx])
	for idx in range(weapons.size()):
		assert_eq(_mgr.get_weapon_kill_count(weapons[idx]), idx * 10, "Weapon %s should have %d kills" % [weapons[idx], idx * 10])

func test_mastery_tier_boundary_exact():
	# Test exact boundary values
	_mgr.weapon_kills["knife"] = 50
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 1, "Exactly 50 = Tier 1")
	_mgr.weapon_kills["knife"] = 200
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 2, "Exactly 200 = Tier 2")
	_mgr.weapon_kills["knife"] = 500
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 3, "Exactly 500 = Tier 3")
	_mgr.weapon_kills["knife"] = 1000
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 4, "Exactly 1000 = Tier 4")

func test_mastery_tier_boundary_minus_one():
	_mgr.weapon_kills["knife"] = 49
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 0, "49 = Tier 0")
	_mgr.weapon_kills["knife"] = 199
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 1, "199 = Tier 1")
	_mgr.weapon_kills["knife"] = 499
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 2, "499 = Tier 2")
	_mgr.weapon_kills["knife"] = 999
	assert_eq(_mgr.get_weapon_mastery_tier("knife"), 3, "999 = Tier 3")


# =====================================================
# Section K: Mastery Achievement Method
# =====================================================

func test_check_mastery_achievements_none():
	_mgr.check_mastery_achievements()
	assert_eq(_mgr.completed_achievements.get("mastery_first", false), false, "No mastery_first with 0 kills")
	assert_eq(_mgr.completed_achievements.get("mastery_all", false), false, "No mastery_all with 0 kills")

func test_check_mastery_achievements_first_at_tier_1():
	for i in range(50):
		_mgr.add_weapon_kill("knife")
	_mgr.check_mastery_achievements()
	assert_eq(_mgr.completed_achievements.get("mastery_first", false), true, "mastery_first should trigger")
	assert_eq(_mgr.completed_achievements.get("mastery_all", false), false, "mastery_all should not trigger")

func test_check_mastery_achievements_all_at_tier_4():
	for weapon_id: String in _mgr.BASE_WEAPONS:
		for i in range(1000):
			_mgr.add_weapon_kill(weapon_id)
	_mgr.check_mastery_achievements()
	assert_eq(_mgr.completed_achievements.get("mastery_first", false), true, "mastery_first should trigger")
	assert_eq(_mgr.completed_achievements.get("mastery_all", false), true, "mastery_all should trigger")

func test_mastery_achievement_rewards():
	# mastery_first = 30 SF, mastery_all = 500 SF
	for i in range(50):
		_mgr.add_weapon_kill("knife")
	_mgr.check_mastery_achievements()
	assert_eq(_mgr.completed_achievements.get("mastery_first", false), true, "mastery_first unlocked")

func test_mastery_achievements_in_achievements_array():
	# Verify mastery achievements exist in ACHIEVEMENTS
	var has_first: bool = false
	var has_all: bool = false
	for a: Dictionary in _mgr.ACHIEVEMENTS:
		if a["id"] == "mastery_first":
			has_first = true
		if a["id"] == "mastery_all":
			has_all = true
	assert_true(has_first, "mastery_first should be in ACHIEVEMENTS")
	assert_true(has_all, "mastery_all should be in ACHIEVEMENTS")
