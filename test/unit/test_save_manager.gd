extends GutTest
## Tests for SaveManager autoload

var _mgr: Node


func before_each():
	_mgr = Node.new()
	_mgr.set_script(load("res://scripts/autoload/save_manager.gd"))
	add_child_autofree(_mgr)
	# Override any loaded save data to ensure clean state
	_mgr.soul_fragments = 0
	_mgr.total_kills = 0
	_mgr.games_played = 0
	_mgr.endless_unlocked = false
	_mgr._init_data()


func test_initial_state():
	assert_eq(_mgr.soul_fragments, 0, "Should start with 0 soul fragments")
	assert_eq(_mgr.total_kills, 0, "Should start with 0 total kills")
	assert_eq(_mgr.games_played, 0, "Should start with 0 games played")
	assert_eq(_mgr.endless_unlocked, false, "Should start with endless locked")


func test_shop_upgrades_initialized():
	for id in _mgr.SHOP_UPGRADES:
		assert_eq(_mgr.shop_upgrades[id], 0, "Upgrade %s should start at 0" % id)


func test_quests_initialized():
	for q: Dictionary in _mgr.QUESTS:
		assert_eq(_mgr.completed_quests[q["id"]], false, "Quest %s should start false" % q["id"])


func test_achievements_initialized():
	for a: Dictionary in _mgr.ACHIEVEMENTS:
		assert_eq(_mgr.completed_achievements[a["id"]], false, "Achievement %s should start false" % a["id"])


func test_add_soul_fragments():
	_mgr.add_soul_fragments(50)
	assert_eq(_mgr.soul_fragments, 50, "Should have 50 fragments")


func test_add_soul_fragments_accumulates():
	_mgr.add_soul_fragments(30)
	_mgr.add_soul_fragments(20)
	assert_eq(_mgr.soul_fragments, 50, "Should accumulate to 50")


func test_spend_soul_fragments_success():
	_mgr.add_soul_fragments(100)
	var result: bool = _mgr.spend_soul_fragments(40)
	assert_eq(result, true, "Should succeed spending")
	assert_eq(_mgr.soul_fragments, 60, "Should have 60 remaining")


func test_spend_soul_fragments_insufficient():
	var result: bool = _mgr.spend_soul_fragments(10)
	assert_eq(result, false, "Should fail spending")
	assert_eq(_mgr.soul_fragments, 0, "Should still have 0")


func test_spend_soul_fragments_exact():
	_mgr.add_soul_fragments(50)
	var result: bool = _mgr.spend_soul_fragments(50)
	assert_eq(result, true, "Should succeed exact spend")
	assert_eq(_mgr.soul_fragments, 0, "Should have 0 remaining")


func test_get_upgrade_cost_level0():
	assert_eq(_mgr.get_upgrade_cost("maxhp"), 20, "maxhp Lv1 should cost 20")
	assert_eq(_mgr.get_upgrade_cost("speed"), 20, "speed Lv1 should cost 20")
	assert_eq(_mgr.get_upgrade_cost("pickup"), 15, "pickup Lv1 should cost 15")
	assert_eq(_mgr.get_upgrade_cost("expbonus"), 25, "expbonus Lv1 should cost 25")
	assert_eq(_mgr.get_upgrade_cost("weapondmg"), 30, "weapondmg Lv1 should cost 30")
	assert_eq(_mgr.get_upgrade_cost("gold"), 15, "gold Lv1 should cost 15")


func test_get_upgrade_cost_maxed():
	_mgr.shop_upgrades["maxhp"] = 3
	assert_eq(_mgr.get_upgrade_cost("maxhp"), -1, "Maxed should return -1")


func test_purchase_upgrade_success():
	_mgr.add_soul_fragments(100)
	var result: bool = _mgr.purchase_upgrade("maxhp")
	assert_eq(result, true, "Should succeed purchase")
	assert_eq(_mgr.shop_upgrades["maxhp"], 1, "Should be level 1")
	# Cost 20 + shop_first achievement reward 20 = net 0 change
	assert_eq(_mgr.soul_fragments, 100, "Should spend 20 but gain 20 from shop_first")


func test_purchase_upgrade_insufficient():
	var result: bool = _mgr.purchase_upgrade("maxhp")
	assert_eq(result, false, "Should fail purchase with 0 fragments")
	assert_eq(_mgr.shop_upgrades["maxhp"], 0, "Should stay level 0")


func test_purchase_upgrade_maxed():
	_mgr.shop_upgrades["maxhp"] = 3
	_mgr.add_soul_fragments(1000)
	var result: bool = _mgr.purchase_upgrade("maxhp")
	assert_eq(result, false, "Should fail purchase at max level")


func test_get_upgrade_level():
	assert_eq(_mgr.get_upgrade_level("maxhp"), 0, "Default level is 0")
	_mgr.shop_upgrades["maxhp"] = 2
	assert_eq(_mgr.get_upgrade_level("maxhp"), 2, "Should be level 2")


func test_hp_bonus():
	assert_eq(_mgr.get_hp_bonus(), 0, "Level 0 = +0 HP")
	_mgr.shop_upgrades["maxhp"] = 1
	assert_eq(_mgr.get_hp_bonus(), 1, "Level 1 = +1 HP")
	_mgr.shop_upgrades["maxhp"] = 3
	assert_eq(_mgr.get_hp_bonus(), 3, "Level 3 = +3 HP")


func test_speed_bonus():
	assert_eq(_mgr.get_speed_bonus(), 0.0, "Level 0 = +0% speed")
	_mgr.shop_upgrades["speed"] = 2
	assert_eq(_mgr.get_speed_bonus(), 0.10, "Level 2 = +10% speed")


func test_pickup_bonus():
	assert_eq(_mgr.get_pickup_bonus(), 0.0, "Level 0 = +0 pickup")
	_mgr.shop_upgrades["pickup"] = 3
	assert_eq(_mgr.get_pickup_bonus(), 15.0, "Level 3 = +15 pickup")


func test_exp_bonus():
	assert_eq(_mgr.get_exp_bonus(), 0.0, "Level 0 = +0% exp")
	_mgr.shop_upgrades["expbonus"] = 1
	assert_eq(_mgr.get_exp_bonus(), 0.05, "Level 1 = +5% exp")


func test_weapon_dmg_bonus():
	assert_eq(_mgr.get_weapon_dmg_bonus(), 0.0, "Level 0 = +0% dmg")
	_mgr.shop_upgrades["weapondmg"] = 3
	assert_eq(_mgr.get_weapon_dmg_bonus(), 0.10, "Level 3 = +10% dmg")


func test_gold_bonus():
	assert_eq(_mgr.get_gold_bonus(), 0.0, "Level 0 = +0% gold")
	_mgr.shop_upgrades["gold"] = 2
	assert_eq(_mgr.get_gold_bonus(), 0.20, "Level 2 = +20% gold")


func test_check_quest():
	_mgr._check_quest("kill_50", true)
	assert_eq(_mgr.completed_quests["kill_50"], true, "Quest should be completed")
	# Already completed should not double-fire
	_mgr._check_quest("kill_50", true)


func test_check_quest_false_condition():
	_mgr._check_quest("kill_50", false)
	assert_eq(_mgr.completed_quests["kill_50"], false, "Quest should stay incomplete")


func test_check_achievement():
	_mgr._check_achievement("total_kills_100", true)
	assert_eq(_mgr.completed_achievements["total_kills_100"], true, "Achievement should unlock")


func test_check_achievement_false_condition():
	_mgr._check_achievement("total_kills_100", false)
	assert_eq(_mgr.completed_achievements["total_kills_100"], false, "Achievement should stay locked")


func test_reset_save():
	_mgr.add_soul_fragments(100)
	_mgr.shop_upgrades["maxhp"] = 2
	_mgr.total_kills = 50
	_mgr.games_played = 5
	_mgr.endless_unlocked = true

	_mgr.reset_save()

	assert_eq(_mgr.soul_fragments, 0, "Should reset fragments")
	assert_eq(_mgr.shop_upgrades["maxhp"], 0, "Should reset upgrades")
	assert_eq(_mgr.total_kills, 0, "Should reset kills")
	assert_eq(_mgr.games_played, 0, "Should reset games")
	assert_eq(_mgr.endless_unlocked, false, "Should lock endless")


func test_quest_count():
	assert_eq(_mgr.QUESTS.size(), 14, "Should have 14 quests")


func test_achievement_count():
	assert_eq(_mgr.ACHIEVEMENTS.size(), 28, "Should have 28 achievements")


func test_shop_upgrade_count():
	assert_eq(_mgr.SHOP_UPGRADES.size(), 6, "Should have 6 shop upgrades")


func test_quest_rewards():
	for q: Dictionary in _mgr.QUESTS:
		assert_has(q, "reward", "Quest %s should have reward" % q["id"])
		assert_gt(q["reward"], 0, "Quest %s reward should be positive" % q["id"])


func test_achievement_rewards():
	for a: Dictionary in _mgr.ACHIEVEMENTS:
		assert_has(a, "reward", "Achievement %s should have reward" % a["id"])
		assert_gt(a["reward"], 0, "Achievement %s reward should be positive" % a["id"])


# --- New achievement categories ---

func test_all_chars_achievement():
	assert_eq(_mgr.completed_achievements.get("all_chars", false), false, "Should start locked")
	_mgr.characters_cleared["mage"] = true
	_mgr.characters_cleared["warrior"] = true
	_mgr.characters_cleared["ranger"] = true
	_mgr._check_achievement("all_chars", _mgr.characters_cleared.size() >= 3)
	assert_eq(_mgr.completed_achievements["all_chars"], true, "Should unlock with 3 chars")


func test_hard_boss_kill_achievement():
	_mgr._check_achievement("hard_boss_kill", true)
	assert_eq(_mgr.completed_achievements["hard_boss_kill"], true, "Should unlock")


func test_no_damage_survive_achievement():
	_mgr._check_achievement("no_damage_survive", true)
	assert_eq(_mgr.completed_achievements["no_damage_survive"], true, "Should unlock")


func test_kill_100_single_achievement():
	_mgr._check_achievement("kill_100_single", true)
	assert_eq(_mgr.completed_achievements["kill_100_single"], true, "Should unlock")


func test_survive_10min_achievement():
	_mgr._check_achievement("survive_10min", true)
	assert_eq(_mgr.completed_achievements["survive_10min"], true, "Should unlock")


func test_hard_survive_ach_achievement():
	_mgr._check_achievement("hard_survive_ach", true)
	assert_eq(_mgr.completed_achievements["hard_survive_ach"], true, "Should unlock")


func test_all_evolved_achievement():
	_mgr._check_achievement("all_evolved", true)
	assert_eq(_mgr.completed_achievements["all_evolved"], true, "Should unlock")


func test_all_synergies_achievement():
	_mgr._check_achievement("all_synergies", true)
	assert_eq(_mgr.completed_achievements["all_synergies"], true, "Should unlock")


func test_shop_single_max_achievement():
	_mgr._check_achievement("shop_single_max", true)
	assert_eq(_mgr.completed_achievements["shop_single_max"], true, "Should unlock")


func test_fast_boss_achievement():
	_mgr._check_achievement("fast_boss", true)
	assert_eq(_mgr.completed_achievements["fast_boss"], true, "Should unlock")


func test_pacifist_1min_achievement():
	_mgr._check_achievement("pacifist_1min", true)
	assert_eq(_mgr.completed_achievements["pacifist_1min"], true, "Should unlock")


func test_characters_cleared_persist():
	_mgr.characters_cleared["mage"] = true
	_mgr.characters_cleared["warrior"] = true
	assert_eq(_mgr.characters_cleared.size(), 2, "Should track 2 chars")


func test_reset_clears_characters():
	_mgr.characters_cleared["mage"] = true
	_mgr.reset_save()
	assert_eq(_mgr.characters_cleared.size(), 0, "Should clear on reset")


func test_evolve_weapon_achievement():
	_mgr._check_achievement("evolve_weapon", true)
	assert_eq(_mgr.completed_achievements["evolve_weapon"], true, "Should unlock on first evolution")


func test_synergy_first_achievement():
	_mgr._check_achievement("synergy_first", true)
	assert_eq(_mgr.completed_achievements["synergy_first"], true, "Should unlock on first synergy")


func test_evolution_history_initialized():
	assert_eq(_mgr.evolution_history.size(), 0, "Should start empty")


func test_synergy_history_initialized():
	assert_eq(_mgr.synergy_history.size(), 0, "Should start empty")


func test_reset_clears_evolution_history():
	_mgr.evolution_history["fireknife"] = true
	_mgr.reset_save()
	assert_eq(_mgr.evolution_history.size(), 0, "Should clear on reset")


func test_reset_clears_synergy_history():
	_mgr.synergy_history["knife_crit"] = true
	_mgr.reset_save()
	assert_eq(_mgr.synergy_history.size(), 0, "Should clear on reset")
