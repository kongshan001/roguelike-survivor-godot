extends GutTest
## R20 Task 2: Shop Tier 4 Tests
## Validates T4 shop upgrade per shop-t4-design.md spec.
## Programmer extends SHOP_UPGRADES to max_level=4 with 4th cost entry.


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


# --- 1. All 6 shop upgrades have T4 (max_level=4) ---

func test_maxhp_has_max_level_4():
	assert_eq(_mgr.SHOP_UPGRADES["maxhp"]["max_level"], 4, "maxhp max_level should be 4")

func test_speed_has_max_level_4():
	assert_eq(_mgr.SHOP_UPGRADES["speed"]["max_level"], 4, "speed max_level should be 4")

func test_pickup_has_max_level_4():
	assert_eq(_mgr.SHOP_UPGRADES["pickup"]["max_level"], 4, "pickup max_level should be 4")

func test_expbonus_has_max_level_4():
	assert_eq(_mgr.SHOP_UPGRADES["expbonus"]["max_level"], 4, "expbonus max_level should be 4")

func test_weapondmg_has_max_level_4():
	assert_eq(_mgr.SHOP_UPGRADES["weapondmg"]["max_level"], 4, "weapondmg max_level should be 4")

func test_gold_has_max_level_4():
	assert_eq(_mgr.SHOP_UPGRADES["gold"]["max_level"], 4, "gold max_level should be 4")


# --- 2. T4 cost = T3 * 2 ---

func test_maxhp_t4_cost_is_double_t3():
	var costs: Array = _mgr.SHOP_UPGRADES["maxhp"]["costs"]
	assert_eq(costs.size(), 4, "maxhp should have 4 cost entries")
	assert_eq(costs[3], costs[2] * 2, "T4 cost should be 2x T3 cost")

func test_speed_t4_cost_is_double_t3():
	var costs: Array = _mgr.SHOP_UPGRADES["speed"]["costs"]
	assert_eq(costs.size(), 4, "speed should have 4 cost entries")
	assert_eq(costs[3], costs[2] * 2, "T4 cost should be 2x T3 cost")

func test_pickup_t4_cost_is_double_t3():
	var costs: Array = _mgr.SHOP_UPGRADES["pickup"]["costs"]
	assert_eq(costs.size(), 4, "pickup should have 4 cost entries")
	assert_eq(costs[3], costs[2] * 2, "T4 cost should be 2x T3 cost")

func test_expbonus_t4_cost_is_double_t3():
	var costs: Array = _mgr.SHOP_UPGRADES["expbonus"]["costs"]
	assert_eq(costs.size(), 4, "expbonus should have 4 cost entries")
	assert_eq(costs[3], costs[2] * 2, "T4 cost should be 2x T3 cost")

func test_weapondmg_t4_cost_is_double_t3():
	var costs: Array = _mgr.SHOP_UPGRADES["weapondmg"]["costs"]
	assert_eq(costs.size(), 4, "weapondmg should have 4 cost entries")
	assert_eq(costs[3], costs[2] * 2, "T4 cost should be 2x T3 cost")

func test_gold_t4_cost_is_double_t3():
	var costs: Array = _mgr.SHOP_UPGRADES["gold"]["costs"]
	assert_eq(costs.size(), 4, "gold should have 4 cost entries")
	assert_eq(costs[3], costs[2] * 2, "T4 cost should be 2x T3 cost")


# --- 3. Specific T4 cost values ---

func test_maxhp_t4_cost_160():
	assert_eq(_mgr.SHOP_UPGRADES["maxhp"]["costs"][3], 160, "maxhp T4 cost = 160")

func test_speed_t4_cost_160():
	assert_eq(_mgr.SHOP_UPGRADES["speed"]["costs"][3], 160, "speed T4 cost = 160")

func test_pickup_t4_cost_120():
	assert_eq(_mgr.SHOP_UPGRADES["pickup"]["costs"][3], 120, "pickup T4 cost = 120")

func test_expbonus_t4_cost_200():
	assert_eq(_mgr.SHOP_UPGRADES["expbonus"]["costs"][3], 200, "expbonus T4 cost = 200")

func test_weapondmg_t4_cost_240():
	assert_eq(_mgr.SHOP_UPGRADES["weapondmg"]["costs"][3], 240, "weapondmg T4 cost = 240")

func test_gold_t4_cost_120():
	assert_eq(_mgr.SHOP_UPGRADES["gold"]["costs"][3], 120, "gold T4 cost = 120")


# --- 4. T4 purchase flow ---

func test_purchase_t4_maxhp():
	_mgr.soul_fragments = 500
	_mgr.shop_upgrades["maxhp"] = 3  # At T3, need T4
	var result: bool = _mgr.purchase_upgrade("maxhp")
	assert_true(result, "Should succeed purchasing T4")
	assert_eq(_mgr.shop_upgrades["maxhp"], 4, "Should be level 4")

func test_purchase_t4_insufficient_fragments():
	_mgr.soul_fragments = 100
	_mgr.shop_upgrades["maxhp"] = 3  # Need 160
	var result: bool = _mgr.purchase_upgrade("maxhp")
	assert_false(result, "Should fail with insufficient fragments for T4")
	assert_eq(_mgr.shop_upgrades["maxhp"], 3, "Should stay at level 3")

func test_purchase_t4_exact_cost():
	_mgr.shop_upgrades["weapondmg"] = 3  # Need 240 for T4
	_mgr.soul_fragments = 240
	var result: bool = _mgr.purchase_upgrade("weapondmg")
	assert_true(result, "Should succeed with exact T4 cost")
	assert_eq(_mgr.shop_upgrades["weapondmg"], 4, "Should be level 4")

func test_purchase_blocked_at_level_4():
	_mgr.soul_fragments = 9999
	_mgr.shop_upgrades["maxhp"] = 4  # Already at max
	var result: bool = _mgr.purchase_upgrade("maxhp")
	assert_false(result, "Should fail at max level 4")
	assert_eq(_mgr.shop_upgrades["maxhp"], 4, "Should stay at level 4")

func test_get_upgrade_cost_at_level_3_returns_t4():
	_mgr.shop_upgrades["maxhp"] = 3
	assert_eq(_mgr.get_upgrade_cost("maxhp"), 160, "Level 3 should return T4 cost 160")

func test_get_upgrade_cost_at_level_4_returns_negative():
	_mgr.shop_upgrades["maxhp"] = 4
	assert_eq(_mgr.get_upgrade_cost("maxhp"), -1, "Level 4 should return -1 (maxed)")


# --- 5. T4 bonus effects ---

func test_hp_bonus_at_level_4():
	_mgr.shop_upgrades["maxhp"] = 4
	assert_eq(_mgr.get_hp_bonus(), 5, "Level 4 HP bonus should be +5 (cumulative)")

func test_hp_bonus_progression():
	# Verify full progression
	assert_eq(_mgr.get_hp_bonus(), 0, "Level 0 = +0 HP")
	_mgr.shop_upgrades["maxhp"] = 1
	assert_eq(_mgr.get_hp_bonus(), 1, "Level 1 = +1 HP")
	_mgr.shop_upgrades["maxhp"] = 2
	assert_eq(_mgr.get_hp_bonus(), 2, "Level 2 = +2 HP")
	_mgr.shop_upgrades["maxhp"] = 3
	assert_eq(_mgr.get_hp_bonus(), 3, "Level 3 = +3 HP")
	_mgr.shop_upgrades["maxhp"] = 4
	assert_eq(_mgr.get_hp_bonus(), 5, "Level 4 = +5 HP (breakthrough)")

func test_speed_bonus_at_level_4():
	_mgr.shop_upgrades["speed"] = 4
	assert_eq(_mgr.get_speed_bonus(), 0.20, "Level 4 speed bonus = +20%")

func test_pickup_bonus_at_level_4():
	_mgr.shop_upgrades["pickup"] = 4
	assert_eq(_mgr.get_pickup_bonus(), 20.0, "Level 4 pickup bonus = +20 range")

func test_exp_bonus_at_level_4():
	_mgr.shop_upgrades["expbonus"] = 4
	assert_eq(_mgr.get_exp_bonus(), 0.20, "Level 4 exp bonus = +20%")

func test_weapon_dmg_bonus_at_level_4():
	_mgr.shop_upgrades["weapondmg"] = 4
	assert_eq(_mgr.get_weapon_dmg_bonus(), 0.15, "Level 4 weapon dmg bonus = +15%")

func test_gold_bonus_at_level_4():
	_mgr.shop_upgrades["gold"] = 4
	assert_eq(_mgr.get_gold_bonus(), 0.40, "Level 4 gold bonus = +40%")


# --- 6. T3 save data compatibility ---

func test_t3_save_loads_correctly():
	# Simulate a save with level 3 (old max)
	_mgr.shop_upgrades["maxhp"] = 3
	_mgr.shop_upgrades["speed"] = 3
	_mgr.shop_upgrades["pickup"] = 3
	# Verify they load correctly and T4 is available
	assert_eq(_mgr.get_upgrade_cost("maxhp"), 160, "T3 save should allow T4 purchase")
	assert_eq(_mgr.get_upgrade_cost("speed"), 160, "T3 save should allow T4 purchase")
	assert_eq(_mgr.get_upgrade_cost("pickup"), 120, "T3 save should allow T4 purchase")

func test_t3_bonuses_preserved():
	_mgr.shop_upgrades["weapondmg"] = 3
	assert_eq(_mgr.get_weapon_dmg_bonus(), 0.10, "T3 weapon dmg bonus unchanged at 10%")


# --- 7. Achievement conditions with max_level=4 ---

func test_shop_single_max_ach_at_level_4():
	# With max_level=4, the achievement should trigger at level 4 (not 3)
	_mgr.shop_upgrades["maxhp"] = 3
	var has_max: bool = false
	for id in _mgr.shop_upgrades:
		if _mgr.shop_upgrades[id] >= _mgr.SHOP_UPGRADES[id]["max_level"]:
			has_max = true
			break
	assert_false(has_max, "Level 3 should NOT trigger shop_single_max with max_level=4")
	_mgr.shop_upgrades["maxhp"] = 4
	for id in _mgr.shop_upgrades:
		if _mgr.shop_upgrades[id] >= _mgr.SHOP_UPGRADES[id]["max_level"]:
			has_max = true
			break
	assert_true(has_max, "Level 4 should trigger shop_single_max")

func test_shop_max_all_ach_requires_level_4():
	# Set all to level 3 -- should not trigger
	for id in _mgr.SHOP_UPGRADES:
		_mgr.shop_upgrades[id] = 3
	var all_maxed: bool = true
	for id in _mgr.shop_upgrades:
		if _mgr.shop_upgrades[id] < _mgr.SHOP_UPGRADES[id]["max_level"]:
			all_maxed = false
	assert_false(all_maxed, "All at level 3 should not trigger shop_max_all")
	# Set all to level 4 -- should trigger
	for id in _mgr.SHOP_UPGRADES:
		_mgr.shop_upgrades[id] = 4
	all_maxed = true
	for id in _mgr.shop_upgrades:
		if _mgr.shop_upgrades[id] < _mgr.SHOP_UPGRADES[id]["max_level"]:
			all_maxed = false
	assert_true(all_maxed, "All at level 4 should trigger shop_max_all")


# --- 8. Total shop cost validation ---

func test_total_shop_cost_increased():
	var total: int = 0
	for id in _mgr.SHOP_UPGRADES:
		var costs: Array = _mgr.SHOP_UPGRADES[id]["costs"]
		for cost in costs:
			total += cost
	assert_eq(total, 1875, "Total shop cost with T4 should be 1875 (was 875)")


# --- 9. T1-T3 costs unchanged ---

func test_t1_costs_unchanged():
	assert_eq(_mgr.SHOP_UPGRADES["maxhp"]["costs"][0], 20, "maxhp T1 unchanged")
	assert_eq(_mgr.SHOP_UPGRADES["speed"]["costs"][0], 20, "speed T1 unchanged")
	assert_eq(_mgr.SHOP_UPGRADES["pickup"]["costs"][0], 15, "pickup T1 unchanged")
	assert_eq(_mgr.SHOP_UPGRADES["expbonus"]["costs"][0], 25, "expbonus T1 unchanged")
	assert_eq(_mgr.SHOP_UPGRADES["weapondmg"]["costs"][0], 30, "weapondmg T1 unchanged")
	assert_eq(_mgr.SHOP_UPGRADES["gold"]["costs"][0], 15, "gold T1 unchanged")

func test_t2_costs_unchanged():
	assert_eq(_mgr.SHOP_UPGRADES["maxhp"]["costs"][1], 40, "maxhp T2 unchanged")
	assert_eq(_mgr.SHOP_UPGRADES["weapondmg"]["costs"][1], 60, "weapondmg T2 unchanged")

func test_t3_costs_unchanged():
	assert_eq(_mgr.SHOP_UPGRADES["maxhp"]["costs"][2], 80, "maxhp T3 unchanged")
	assert_eq(_mgr.SHOP_UPGRADES["weapondmg"]["costs"][2], 120, "weapondmg T3 unchanged")
