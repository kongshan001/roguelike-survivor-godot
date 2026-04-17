extends GutTest
## R25: achievement_checker.gd extracted module tests
## Validates the achievement/quest checking logic extracted from save_manager.gd.

var _checker: RefCounted


func before_each():
	GameManager.reset()
	SaveManager.reset_save()
	_checker = load("res://scripts/autoload/achievement_checker.gd").new()


func after_each():
	await get_tree().process_frame


# =====================================================================
# Section A: Script Existence & Constants
# =====================================================================

func test_checker_loads():
	assert_true(_checker != null, "AchievementChecker should load without errors")


func test_checker_extends_refcounted():
	assert_true(_checker is RefCounted,
		"AchievementChecker should extend RefCounted")


func test_all_evo_ids_constant():
	assert_eq(_checker.ALL_EVO_IDS.size(), 12,
		"Should have 12 evolution weapon IDs")
	assert_true("thunderholywater" in _checker.ALL_EVO_IDS,
		"Should contain thunderholywater")
	assert_true("fireknife" in _checker.ALL_EVO_IDS,
		"Should contain fireknife")
	assert_true("sentineltotem" in _checker.ALL_EVO_IDS,
		"Should contain sentineltotem")


# =====================================================================
# Section B: Signal Existence
# =====================================================================

func test_has_quest_check_signal():
	assert_true(_checker.has_signal("quest_check_requested"),
		"Should have quest_check_requested signal")


func test_has_achievement_check_signal():
	assert_true(_checker.has_signal("achievement_check_requested"),
		"Should have achievement_check_requested signal")


func test_has_soul_reward_signal():
	assert_true(_checker.has_signal("soul_reward_requested"),
		"Should have soul_reward_requested signal")


func test_has_state_update_signal():
	assert_true(_checker.has_signal("state_update_requested"),
		"Should have state_update_requested signal")


# =====================================================================
# Section C: Method Existence
# =====================================================================

func test_has_check_all():
	assert_true(_checker.has_method("check_all"),
		"Should have check_all method")


func test_has_check_quests():
	assert_true(_checker.has_method("_check_quests"),
		"Should have _check_quests method")


func test_has_check_achievements():
	assert_true(_checker.has_method("_check_achievements"),
		"Should have _check_achievements method")


func test_has_accumulate_history():
	assert_true(_checker.has_method("_accumulate_history"),
		"Should have _accumulate_history method")


func test_has_check_history_achievements():
	assert_true(_checker.has_method("_check_history_achievements"),
		"Should have _check_history_achievements method")


func test_has_check_gold_conversion():
	assert_true(_checker.has_method("_check_gold_conversion"),
		"Should have _check_gold_conversion method")


func test_has_check_mastery_achievements():
	assert_true(_checker.has_method("_check_mastery_achievements"),
		"Should have _check_mastery_achievements method")


func test_has_update_state():
	assert_true(_checker.has_method("_update_state"),
		"Should have _update_state method")


# =====================================================================
# Section D: Quest Signal Emission
# =====================================================================

func test_quest_signal_emitted_on_check_all():
	var emitted_quests: Array = []
	_checker.quest_check_requested.connect(func(qid: String, cond: bool):
		emitted_quests.append({"id": qid, "cond": cond})
	)
	var run_stats: Dictionary = {
		"kills": 100, "elapsed": 120.0, "boss_kills": 1,
		"best_combo": 10, "difficulty": "normal", "character": "warrior",
		"char_kills": 50, "damage_taken": false, "kills_at_60": 0,
		"gold": 200, "evolutions": {}, "synergies": [],
	}
	var save_data: Dictionary = {
		"total_kills": 100, "games_played": 5,
		"completed_quests": {}, "characters_cleared": {},
		"evolution_history": {}, "synergy_history": {},
		"endless_unlocked": false, "weapon_kills": {},
		"mastery_thresholds": [0, 50, 200, 500, 1000],
		"base_weapons": ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang"],
	}
	_checker.check_all(run_stats, save_data)
	assert_gt(emitted_quests.size(), 0,
		"Should emit quest check signals")


func test_quest_kill_50_condition():
	# Use Dictionary to capture signal value (GDScript lambdas capture by value for primitives)
	var captured: Dictionary = {"kill_50": false}
	_checker.quest_check_requested.connect(func(qid: String, cond: bool):
		if qid == "kill_50":
			captured["kill_50"] = cond
	)
	_checker._check_quests(50, 60.0, 0, 10, "normal", "mage", 0, false)
	assert_true(captured["kill_50"], "kill_50 should be true with 50 kills")


func test_quest_kill_50_false_below_threshold():
	var captured: Dictionary = {"kill_50": true}
	_checker.quest_check_requested.connect(func(qid: String, cond: bool):
		if qid == "kill_50":
			captured["kill_50"] = cond
	)
	_checker._check_quests(49, 60.0, 0, 10, "normal", "mage", 0, false)
	assert_false(captured["kill_50"], "kill_50 should be false with 49 kills")


func test_quest_warrior_30_condition():
	var captured: Dictionary = {"warrior_30": false}
	_checker.quest_check_requested.connect(func(qid: String, cond: bool):
		if qid == "warrior_30":
			captured["warrior_30"] = cond
	)
	_checker._check_quests(100, 60.0, 0, 10, "normal", "warrior", 30, false)
	assert_true(captured["warrior_30"], "warrior_30 should be true with warrior and 30 char_kills")


func test_quest_warrior_30_wrong_class():
	var captured: Dictionary = {"warrior_30": true}
	_checker.quest_check_requested.connect(func(qid: String, cond: bool):
		if qid == "warrior_30":
			captured["warrior_30"] = cond
	)
	_checker._check_quests(100, 60.0, 0, 10, "normal", "mage", 30, false)
	assert_false(captured["warrior_30"], "warrior_30 should be false for mage")


func test_quest_endless_5min():
	var captured: Dictionary = {"endless_5min": false}
	_checker.quest_check_requested.connect(func(qid: String, cond: bool):
		if qid == "endless_5min":
			captured["endless_5min"] = cond
	)
	_checker._check_quests(50, 300.0, 0, 10, "endless", "mage", 0, false)
	assert_true(captured["endless_5min"], "endless_5min should be true at 300s in endless")


func test_quest_no_damage():
	var captured: Dictionary = {"no_damage": false}
	_checker.quest_check_requested.connect(func(qid: String, cond: bool):
		if qid == "no_damage":
			captured["no_damage"] = cond
	)
	_checker._check_quests(50, 60.0, 0, 10, "normal", "mage", 0, false)
	assert_true(captured["no_damage"], "no_damage should be true with no damage and 60s")


# =====================================================================
# Section E: Achievement Signal Emission
# =====================================================================

func test_achievement_signal_emitted_on_check_all():
	var emitted_achievements: Array = []
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		emitted_achievements.append({"id": aid, "cond": cond})
	)
	var run_stats: Dictionary = {
		"kills": 100, "elapsed": 200.0, "boss_kills": 1,
		"best_combo": 30, "difficulty": "normal", "character": "warrior",
		"char_kills": 50, "damage_taken": false, "kills_at_60": 0,
		"gold": 200, "evolutions": {"thunderholywater": true}, "synergies": [],
	}
	var save_data: Dictionary = {
		"total_kills": 500, "games_played": 10,
		"completed_quests": {}, "characters_cleared": {},
		"evolution_history": {}, "synergy_history": {},
		"endless_unlocked": false, "weapon_kills": {},
		"mastery_thresholds": [0, 50, 200, 500, 1000],
		"base_weapons": ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang"],
	}
	_checker.check_all(run_stats, save_data)
	assert_gt(emitted_achievements.size(), 0,
		"Should emit achievement check signals")


func test_achievement_total_kills_100():
	var captured: Dictionary = {"total_kills_100": false}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "total_kills_100":
			captured["total_kills_100"] = cond
	)
	_checker._check_achievements(50, 60.0, 0, 10, "normal", false, 150, 5, {}, {}, 0)
	assert_true(captured["total_kills_100"], "total_kills_100 should be true at 150 total kills")


func test_achievement_total_kills_100_false():
	var captured: Dictionary = {"total_kills_100": true}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "total_kills_100":
			captured["total_kills_100"] = cond
	)
	_checker._check_achievements(50, 60.0, 0, 10, "normal", false, 99, 5, {}, {}, 0)
	assert_false(captured["total_kills_100"], "total_kills_100 should be false at 99 total kills")


func test_achievement_boss_kill():
	var captured: Dictionary = {"boss_kill": false}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "boss_kill":
			captured["boss_kill"] = cond
	)
	_checker._check_achievements(10, 60.0, 1, 5, "normal", false, 10, 1, {}, {}, 0)
	assert_true(captured["boss_kill"], "boss_kill should be true with boss_kills > 0")


func test_achievement_survive_3min_normal():
	var captured: Dictionary = {"survive_3min": false}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "survive_3min":
			captured["survive_3min"] = cond
	)
	_checker._check_achievements(10, 180.0, 0, 5, "normal", false, 10, 1, {}, {}, 0)
	assert_true(captured["survive_3min"], "survive_3min should be true at 180s in normal")


func test_achievement_survive_3min_wrong_difficulty():
	var captured: Dictionary = {"survive_3min": true}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "survive_3min":
			captured["survive_3min"] = cond
	)
	_checker._check_achievements(10, 180.0, 0, 5, "hard", false, 10, 1, {}, {}, 0)
	assert_false(captured["survive_3min"], "survive_3min should be false in hard difficulty")


# =====================================================================
# Section F: History & Evolution Achievements
# =====================================================================

func test_evolve_weapon_achievement():
	var captured: Dictionary = {"evolve_weapon": false}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "evolve_weapon":
			captured["evolve_weapon"] = cond
	)
	_checker._check_history_achievements({"thunderholywater": true}, {}, [])
	assert_true(captured["evolve_weapon"], "evolve_weapon should be true with 1 evolution")


func test_all_evolved_achievement():
	var captured: Dictionary = {"all_evolved": false}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "all_evolved":
			captured["all_evolved"] = cond
	)
	var all_evos: Dictionary = {}
	for eid: String in _checker.ALL_EVO_IDS:
		all_evos[eid] = true
	_checker._check_history_achievements(all_evos, {}, [])
	assert_true(captured["all_evolved"], "all_evolved should be true with all 12 evolutions")


func test_all_evolved_partial():
	var captured: Dictionary = {"all_evolved": true}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "all_evolved":
			captured["all_evolved"] = cond
	)
	_checker._check_history_achievements({"thunderholywater": true}, {}, [])
	assert_false(captured["all_evolved"], "all_evolved should be false with only 1 evolution")


func test_accumulate_history_evolutions():
	var evo_hist: Dictionary = {}
	_checker._accumulate_history({"fireknife": true, "blizzard": true}, [], evo_hist, {})
	assert_true(evo_hist.has("fireknife"), "Should accumulate fireknife")
	assert_true(evo_hist.has("blizzard"), "Should accumulate blizzard")


func test_accumulate_history_synergies():
	var syn_hist: Dictionary = {}
	_checker._accumulate_history({}, ["crit_luckycoin"], {}, syn_hist)
	assert_true(syn_hist.has("crit_luckycoin"), "Should accumulate synergy")


func test_synergy_first_achievement():
	var captured: Dictionary = {"synergy_first": false}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "synergy_first":
			captured["synergy_first"] = cond
	)
	_checker._check_history_achievements({}, {"crit_luckycoin": true}, [])
	assert_true(captured["synergy_first"], "synergy_first should be true with 1 synergy in history")


# =====================================================================
# Section G: Gold Conversion
# =====================================================================

func test_gold_conversion_normal():
	var captured: Dictionary = {"amount": -1}
	_checker.soul_reward_requested.connect(func(amount: int):
		captured["amount"] = amount
	)
	_checker._check_gold_conversion(100, "normal")
	assert_eq(captured["amount"], 30, "Normal mode should convert 30% gold to souls (100 * 0.3 = 30)")


func test_gold_conversion_endless():
	var captured: Dictionary = {"amount": -1}
	_checker.soul_reward_requested.connect(func(amount: int):
		captured["amount"] = amount
	)
	_checker._check_gold_conversion(100, "endless")
	assert_eq(captured["amount"], 45, "Endless mode should convert 45% gold to souls (100 * 0.45 = 45)")


func test_gold_conversion_zero_gold():
	var captured: Dictionary = {"amount": -1}
	_checker.soul_reward_requested.connect(func(amount: int):
		captured["amount"] = amount
	)
	_checker._check_gold_conversion(0, "normal")
	assert_eq(captured["amount"], 0, "Zero gold should give zero soul reward")


# =====================================================================
# Section H: Mastery Achievements
# =====================================================================

func test_mastery_first_achievement():
	var captured: Dictionary = {"mastery_first": false}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "mastery_first":
			captured["mastery_first"] = cond
	)
	var save_data: Dictionary = {
		"weapon_kills": {"knife": 50},
		"mastery_thresholds": [0, 50, 200, 500, 1000],
		"base_weapons": ["knife"],
	}
	_checker._check_mastery_achievements(save_data)
	assert_true(captured["mastery_first"], "mastery_first should be true with tier 1 weapon")


func test_mastery_first_achievement_false():
	var captured: Dictionary = {"mastery_first": true}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "mastery_first":
			captured["mastery_first"] = cond
	)
	var save_data: Dictionary = {
		"weapon_kills": {"knife": 10},
		"mastery_thresholds": [0, 50, 200, 500, 1000],
		"base_weapons": ["knife"],
	}
	_checker._check_mastery_achievements(save_data)
	assert_false(captured["mastery_first"], "mastery_first should be false with tier 0 weapon")


func test_mastery_all_achievement():
	var captured: Dictionary = {"mastery_all": false}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "mastery_all":
			captured["mastery_all"] = cond
	)
	var weapon_kills_data: Dictionary = {}
	for w: String in ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang"]:
		weapon_kills_data[w] = 1000
	var save_data: Dictionary = {
		"weapon_kills": weapon_kills_data,
		"mastery_thresholds": [0, 50, 200, 500, 1000],
		"base_weapons": ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang"],
	}
	_checker._check_mastery_achievements(save_data)
	assert_true(captured["mastery_all"], "mastery_all should be true when all 7 weapons at 1000 kills (tier 4)")


func test_mastery_all_false_partial():
	var captured: Dictionary = {"mastery_all": true}
	_checker.achievement_check_requested.connect(func(aid: String, cond: bool):
		if aid == "mastery_all":
			captured["mastery_all"] = cond
	)
	var weapon_kills_data: Dictionary = {}
	for w: String in ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang"]:
		weapon_kills_data[w] = 1000
	weapon_kills_data["knife"] = 10  # One weapon not at tier 4
	var save_data: Dictionary = {
		"weapon_kills": weapon_kills_data,
		"mastery_thresholds": [0, 50, 200, 500, 1000],
		"base_weapons": ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang"],
	}
	_checker._check_mastery_achievements(save_data)
	assert_false(captured["mastery_all"], "mastery_all should be false when one weapon is below tier 4")


# =====================================================================
# Section I: State Update
# =====================================================================

func test_state_update_emits_total_kills():
	var updates: Dictionary = {}
	_checker.state_update_requested.connect(func(key: String, value: Variant):
		updates[key] = value
	)
	_checker._update_state({}, false, 0, "mage", 200.0, 100, 5, {}, {})
	assert_eq(updates.get("total_kills", -1), 100, "Should emit total_kills update")


func test_state_update_emits_games_played():
	var updates: Dictionary = {}
	_checker.state_update_requested.connect(func(key: String, value: Variant):
		updates[key] = value
	)
	_checker._update_state({}, false, 0, "mage", 200.0, 100, 5, {}, {})
	assert_eq(updates.get("games_played", -1), 5, "Should emit games_played update")


func test_state_update_endless_unlock_on_boss():
	var updates: Dictionary = {}
	_checker.state_update_requested.connect(func(key: String, value: Variant):
		updates[key] = value
	)
	_checker._update_state({}, false, 1, "mage", 200.0, 100, 5, {}, {})
	assert_eq(updates.get("endless_unlocked", false), true,
		"Should unlock endless on boss kill")


func test_state_update_character_clear():
	var chars: Dictionary = {}
	_checker._update_state(chars, false, 0, "warrior", 200.0, 100, 5, {}, {})
	# The function modifies the characters_cleared dict in-place
	assert_true(chars.has("warrior"), "warrior should be marked as cleared after 200s")
	assert_true(chars["warrior"], "warrior clear flag should be true")


# =====================================================================
# Section J: check_all Return Value
# =====================================================================

func test_check_all_returns_dictionary():
	var run_stats: Dictionary = {
		"kills": 50, "elapsed": 120.0, "boss_kills": 1,
		"best_combo": 10, "difficulty": "normal", "character": "warrior",
		"char_kills": 30, "damage_taken": false, "kills_at_60": 0,
		"gold": 100, "evolutions": {}, "synergies": [],
	}
	var save_data: Dictionary = {
		"total_kills": 100, "games_played": 5,
		"completed_quests": {}, "characters_cleared": {},
		"evolution_history": {}, "synergy_history": {},
		"endless_unlocked": false, "weapon_kills": {},
		"mastery_thresholds": [0, 50, 200, 500, 1000],
		"base_weapons": ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang"],
	}
	var result: Dictionary = _checker.check_all(run_stats, save_data)
	assert_true(result.has("total_kills"), "Should return total_kills")
	assert_true(result.has("games_played"), "Should return games_played")
	assert_true(result.has("endless_unlocked"), "Should return endless_unlocked")
	assert_true(result.has("characters_cleared"), "Should return characters_cleared")
	assert_true(result.has("evolution_history"), "Should return evolution_history")
	assert_true(result.has("synergy_history"), "Should return synergy_history")


func test_check_all_accumulates_kills():
	var run_stats: Dictionary = {
		"kills": 50, "elapsed": 120.0, "boss_kills": 0,
		"best_combo": 5, "difficulty": "normal", "character": "",
		"char_kills": 0, "damage_taken": true, "kills_at_60": 0,
		"gold": 0, "evolutions": {}, "synergies": [],
	}
	var save_data: Dictionary = {
		"total_kills": 100, "games_played": 5,
		"completed_quests": {}, "characters_cleared": {},
		"evolution_history": {}, "synergy_history": {},
		"endless_unlocked": false, "weapon_kills": {},
		"mastery_thresholds": [0, 50, 200, 500, 1000],
		"base_weapons": ["knife"],
	}
	var result: Dictionary = _checker.check_all(run_stats, save_data)
	assert_eq(result["total_kills"], 150, "Should accumulate 100 + 50 = 150 total kills")
	assert_eq(result["games_played"], 6, "Should increment games_played by 1")
