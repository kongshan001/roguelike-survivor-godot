extends RefCounted
## AchievementChecker -- Quest/Achievement checking logic extracted from save_manager.gd
## Receives run stats as a Dictionary parameter instead of directly reading GameManager/SynergyManager.
## Emits signals back to SaveManager to trigger quest/achievement completion and soul fragment rewards.
## This resolves the autoload cross-reference violation (SaveManager -> GameManager/SynergyManager).

signal quest_check_requested(quest_id: String, condition: bool)
signal achievement_check_requested(achievement_id: String, condition: bool)
signal soul_reward_requested(amount: int)
signal state_update_requested(key: String, value: Variant)

# All 9 evolution weapon IDs
const ALL_EVO_IDS: Array[String] = [
	"thunderholywater", "fireknife", "holydomain", "blizzard",
	"frostknife", "flamebible", "thunderang", "blazerang", "sentineltotem",
]


## Run all quest and achievement checks for the completed run.
## run_stats keys: kills, elapsed, boss_kills, best_combo, difficulty, character,
##   char_kills, damage_taken, kills_at_60, gold, evolutions, synergies
## save_data keys: total_kills, games_played, completed_quests, characters_cleared,
##   evolution_history, synergy_history, endless_unlocked, weapon_kills,
##   mastery_thresholds, base_weapons
func check_all(run_stats: Dictionary, save_data: Dictionary) -> Dictionary:
	var kills: int = run_stats.get("kills", 0)
	var elapsed: float = run_stats.get("elapsed", 0.0)
	var boss_kills: int = run_stats.get("boss_kills", 0)
	var best_combo: int = run_stats.get("best_combo", 0)
	var difficulty: String = run_stats.get("difficulty", "")
	var character: String = run_stats.get("character", "")
	var char_kills: int = run_stats.get("char_kills", 0)
	var damage_taken: bool = run_stats.get("damage_taken", true)
	var kills_at_60: int = run_stats.get("kills_at_60", -1)
	var gold: int = run_stats.get("gold", 0)
	var evolutions: Dictionary = run_stats.get("evolutions", {})
	var synergies: Array = run_stats.get("synergies", [])

	var total_kills: int = save_data.get("total_kills", 0) + kills
	var games_played: int = save_data.get("games_played", 0) + 1
	var completed_quests: Dictionary = save_data.get("completed_quests", {})
	var characters_cleared: Dictionary = save_data.get("characters_cleared", {})
	var evolution_history: Dictionary = save_data.get("evolution_history", {})
	var synergy_history: Dictionary = save_data.get("synergy_history", {})
	var endless_unlocked: bool = save_data.get("endless_unlocked", false)

	_check_quests(kills, elapsed, boss_kills, best_combo, difficulty, character, char_kills, damage_taken)
	_check_achievements(kills, elapsed, boss_kills, best_combo, difficulty, damage_taken,
		total_kills, games_played, characters_cleared, completed_quests, kills_at_60)
	_accumulate_history(evolutions, synergies, evolution_history, synergy_history)
	_check_history_achievements(evolution_history, synergy_history, synergies)
	_check_gold_conversion(gold, difficulty)
	_check_mastery_achievements(save_data)
	_update_state(characters_cleared, endless_unlocked, boss_kills, character, elapsed,
		total_kills, games_played, evolution_history, synergy_history)

	return {
		"total_kills": total_kills,
		"games_played": games_played,
		"endless_unlocked": endless_unlocked or boss_kills > 0,
		"characters_cleared": characters_cleared,
		"evolution_history": evolution_history,
		"synergy_history": synergy_history,
	}


func _check_quests(kills: int, elapsed: float, boss_kills: int, best_combo: int,
		difficulty: String, character: String, char_kills: int, damage_taken: bool) -> void:
	quest_check_requested.emit("warrior_30", character == "warrior" and char_kills >= 30)
	quest_check_requested.emit("ranger_30", character == "ranger" and char_kills >= 30)
	quest_check_requested.emit("kill_50", kills >= 50)
	quest_check_requested.emit("kill_100", kills >= 100)
	quest_check_requested.emit("kill_boss", boss_kills > 0)
	quest_check_requested.emit("combo_20", best_combo >= 20)
	quest_check_requested.emit("combo_50", best_combo >= 50)
	quest_check_requested.emit("endless_5min", difficulty == "endless" and elapsed >= 300.0)
	quest_check_requested.emit("endless_10min", difficulty == "endless" and elapsed >= 600.0)
	quest_check_requested.emit("endless_boss3", difficulty == "endless" and boss_kills >= 3)
	quest_check_requested.emit("endless_kill200", difficulty == "endless" and kills >= 200)
	quest_check_requested.emit("hard_survive", difficulty == "hard" and elapsed >= 120.0)
	quest_check_requested.emit("hard_boss", difficulty == "hard" and boss_kills > 0)
	quest_check_requested.emit("no_damage", not damage_taken and elapsed >= 60.0)


func _check_achievements(kills: int, elapsed: float, boss_kills: int, best_combo: int,
		difficulty: String, damage_taken: bool, total_kills: int, games_played: int,
		characters_cleared: Dictionary, completed_quests: Dictionary, kills_at_60: int) -> void:
	achievement_check_requested.emit("total_kills_100", total_kills >= 100)
	achievement_check_requested.emit("total_kills_500", total_kills >= 500)
	achievement_check_requested.emit("total_kills_2000", total_kills >= 2000)
	achievement_check_requested.emit("games_10", games_played >= 10)
	achievement_check_requested.emit("games_50", games_played >= 50)
	achievement_check_requested.emit("survive_3min", difficulty == "normal" and elapsed >= 180.0)
	achievement_check_requested.emit("survive_5min", difficulty == "normal" and elapsed >= 300.0)
	achievement_check_requested.emit("survive_hard_5min", difficulty == "hard" and elapsed >= 300.0)
	achievement_check_requested.emit("boss_kill", boss_kills > 0)
	achievement_check_requested.emit("hard_boss_kill", difficulty == "hard" and boss_kills > 0)
	achievement_check_requested.emit("no_damage_survive", not damage_taken and elapsed >= 120.0 and kills > 0)
	achievement_check_requested.emit("kill_100_single", kills >= 100)
	achievement_check_requested.emit("survive_10min", elapsed >= 600.0)
	achievement_check_requested.emit("combo_30", best_combo >= 30)
	achievement_check_requested.emit("combo_50", best_combo >= 50)
	achievement_check_requested.emit("hard_survive_ach", difficulty == "hard" and elapsed >= 120.0)
	achievement_check_requested.emit("fast_boss", boss_kills > 0 and elapsed <= 180.0)
	achievement_check_requested.emit("pacifist_1min", elapsed >= 60.0 and kills_at_60 == 0)
	achievement_check_requested.emit("all_chars", characters_cleared.size() >= 3)
	# Quest completion achievements
	var completed_count: int = 0
	for id in completed_quests:
		if completed_quests[id]:
			completed_count += 1
	achievement_check_requested.emit("quests_half", completed_count >= 7)
	achievement_check_requested.emit("quests_all", completed_count >= 14)


func _accumulate_history(evolutions: Dictionary, synergies: Array,
		evolution_history: Dictionary, synergy_history: Dictionary) -> void:
	for evo_id: String in evolutions:
		evolution_history[evo_id] = true
	for syn_id: String in synergies:
		synergy_history[syn_id] = true


func _check_history_achievements(evolution_history: Dictionary, synergy_history: Dictionary,
		synergies: Array) -> void:
	achievement_check_requested.emit("evolve_weapon", evolution_history.size() >= 1)
	var evo_count: int = 0
	for eid: String in ALL_EVO_IDS:
		if evolution_history.has(eid):
			evo_count += 1
	achievement_check_requested.emit("all_evolved", evo_count >= ALL_EVO_IDS.size())
	achievement_check_requested.emit("synergy_first", synergy_history.size() >= 1 or synergies.size() >= 1)
	achievement_check_requested.emit("all_synergies", synergy_history.size() >= 18)


func _check_gold_conversion(gold: int, difficulty: String) -> void:
	var soul_rate: float = 0.3
	if difficulty == "endless":
		soul_rate = 0.45
	soul_reward_requested.emit(int(gold * soul_rate))


func _check_mastery_achievements(save_data: Dictionary) -> void:
	var weapon_kills: Dictionary = save_data.get("weapon_kills", {})
	var thresholds: Array = save_data.get("mastery_thresholds", [])
	var base_weapons: Array = save_data.get("base_weapons", [])
	var max_tier: int = 0
	var all_master: bool = true
	for weapon_id: String in base_weapons:
		var wk: int = weapon_kills.get(weapon_id, 0)
		var tier: int = 0
		for i in range(thresholds.size() - 1, -1, -1):
			if wk >= thresholds[i]:
				tier = i
				break
		if tier > max_tier:
			max_tier = tier
		if tier < 4:
			all_master = false
	achievement_check_requested.emit("mastery_first", max_tier >= 1)
	achievement_check_requested.emit("mastery_all", all_master)


func _update_state(characters_cleared: Dictionary, endless_unlocked: bool,
		boss_kills: int, character: String, elapsed: float,
		total_kills: int, games_played: int,
		evolution_history: Dictionary, synergy_history: Dictionary) -> void:
	if character != "" and elapsed >= 180.0:
		characters_cleared[character] = true
	if boss_kills > 0:
		endless_unlocked = true
	state_update_requested.emit("total_kills", total_kills)
	state_update_requested.emit("games_played", games_played)
	state_update_requested.emit("endless_unlocked", endless_unlocked)
	state_update_requested.emit("characters_cleared", characters_cleared)
	state_update_requested.emit("evolution_history", evolution_history)
	state_update_requested.emit("synergy_history", synergy_history)
