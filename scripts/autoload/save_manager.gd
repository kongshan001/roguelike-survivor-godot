extends Node
## 存档管理器 — 灵魂碎片、商店升级、任务/成就进度持久化
## 挂载为 Autoload，使用 Godot ConfigFile 存储到 user://save.cfg

signal soul_fragments_changed(amount: int)
signal achievement_unlocked(achievement_id: String)
signal quest_completed(quest_id: String)
signal mastery_tier_up(weapon_id: String, new_tier: int)

var soul_fragments: int = 0
var shop_upgrades: Dictionary = {}  # id -> level (0-4)
var completed_quests: Dictionary = {}
var completed_achievements: Dictionary = {}
var total_kills: int = 0
var games_played: int = 0
var endless_unlocked: bool = false
# Track per-character clears for all_chars achievement
var characters_cleared: Dictionary = {}
# Track cumulative evolution/synergy history across sessions
var evolution_history: Dictionary = {}  # evo_id -> true
var synergy_history: Dictionary = {}    # synergy_id -> true
# Tutorial progress: 0=not started, 1-8=steps completed, tutorial_completed=all done
var tutorial_step: int = 0
var tutorial_completed: bool = false
# Weapon mastery kill counts (base weapons only)
var weapon_kills: Dictionary = {}  # weapon_id -> kill count

const SAVE_PATH: String = "user://save.cfg"

# Weapon mastery constants
const MASTERY_THRESHOLDS: Array[int] = [0, 50, 200, 500, 1000]
const MASTERY_BONUSES: Array[float] = [0.0, 0.02, 0.04, 0.06, 0.08]
const BASE_WEAPONS: Array[String] = ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang"]

# Shop upgrade definitions
const SHOP_UPGRADES: Dictionary = {
	"maxhp": {"name": "生命强化", "icon": "❤️", "costs": [20, 40, 80, 160], "max_level": 4},
	"speed": {"name": "速度训练", "icon": "👟", "costs": [20, 40, 80, 160], "max_level": 4},
	"pickup": {"name": "拾取精通", "icon": "📡", "costs": [15, 30, 60, 120], "max_level": 4},
	"expbonus": {"name": "知识汲取", "icon": "📚", "costs": [25, 50, 100, 200], "max_level": 4},
	"weapondmg": {"name": "武器精通", "icon": "⚔️", "costs": [30, 60, 120, 240], "max_level": 4},
	"gold": {"name": "贪婪之心", "icon": "💰", "costs": [15, 30, 60, 120], "max_level": 4},
}

# Quest definitions
const QUESTS: Array = [
	{"id": "warrior_30", "name": "战士之道", "desc": "用战士击杀30只敌人", "reward": 50},
	{"id": "ranger_30", "name": "箭无虚发", "desc": "用游侠击杀30只敌人", "reward": 50},
	{"id": "hard_survive", "name": "勇者无惧", "desc": "噩梦难度存活2分钟", "reward": 100},
	{"id": "hard_boss", "name": "噩梦征服者", "desc": "噩梦难度击败Boss", "reward": 200},
	{"id": "kill_50", "name": "屠戮者", "desc": "单局击杀50个敌人", "reward": 75},
	{"id": "kill_100", "name": "百人斩", "desc": "单局击杀100个敌人", "reward": 150},
	{"id": "kill_boss", "name": "屠龙者", "desc": "击败Boss", "reward": 100},
	{"id": "no_damage", "name": "完美闪避", "desc": "不受伤存活1分钟", "reward": 120},
	{"id": "combo_20", "name": "连击大师", "desc": "达成20连击", "reward": 100},
	{"id": "combo_50", "name": "连击之王", "desc": "达成50连击", "reward": 200},
	{"id": "endless_5min", "name": "无尽征途", "desc": "无尽模式存活5分钟", "reward": 150},
	{"id": "endless_10min", "name": "不朽传说", "desc": "无尽模式存活10分钟", "reward": 300},
	{"id": "endless_boss3", "name": "连斩三龙", "desc": "无尽击杀3Boss", "reward": 400},
	{"id": "endless_kill200", "name": "无尽屠戮", "desc": "无尽击杀200敌人", "reward": 250},
]

# Achievement definitions (27 total, 8 categories)
const ACHIEVEMENTS: Array = [
	# 里程碑(5)
	{"id": "total_kills_100", "name": "初出茅庐", "desc": "累计击杀100", "reward": 30},
	{"id": "total_kills_500", "name": "身经百战", "desc": "累计击杀500", "reward": 80},
	{"id": "total_kills_2000", "name": "杀戮机器", "desc": "累计击杀2000", "reward": 200},
	{"id": "games_10", "name": "常客", "desc": "游玩10局", "reward": 20},
	{"id": "games_50", "name": "老手", "desc": "游玩50局", "reward": 60},
	# 生存(3)
	{"id": "survive_3min", "name": "站稳脚跟", "desc": "标准存活3分钟", "reward": 30},
	{"id": "survive_5min", "name": "生存专家", "desc": "标准存活5分钟", "reward": 80},
	{"id": "survive_hard_5min", "name": "噩梦幸存者", "desc": "噩梦存活5分钟", "reward": 150},
	# 角色(1)
	{"id": "all_chars", "name": "全角色精通", "desc": "使用全部角色通关", "reward": 100},
	# 击杀/挑战(8)
	{"id": "boss_kill", "name": "Boss猎人", "desc": "击败Boss", "reward": 50},
	{"id": "hard_boss_kill", "name": "噩梦征服", "desc": "噩梦击败Boss", "reward": 150},
	{"id": "no_damage_survive", "name": "无伤生存", "desc": "不受伤存活2分钟", "reward": 120},
	{"id": "kill_100_single", "name": "单局百杀", "desc": "单局击杀100敌人", "reward": 100},
	{"id": "survive_10min", "name": "生存大师", "desc": "存活10分钟", "reward": 200},
	{"id": "combo_30", "name": "连击达人", "desc": "30连击", "reward": 60},
	{"id": "combo_50", "name": "连击之王", "desc": "50连击", "reward": 120},
	{"id": "hard_survive_ach", "name": "勇者无惧成就", "desc": "噩梦存活2分钟", "reward": 100},
	# 进化/协同(4)
	{"id": "evolve_weapon", "name": "武器觉醒", "desc": "首次武器进化", "reward": 40},
	{"id": "synergy_first", "name": "协同初现", "desc": "首次触发协同", "reward": 40},
	{"id": "all_evolved", "name": "进化大师", "desc": "收集全部进化武器", "reward": 200},
	{"id": "all_synergies", "name": "协同全览", "desc": "触发全部协同效应", "reward": 200},
	# 商店(3)
	{"id": "shop_first", "name": "初次投资", "desc": "首次商店购买", "reward": 20},
	{"id": "shop_single_max", "name": "专精一项", "desc": "单项升级满级", "reward": 50},
	{"id": "shop_max_all", "name": "全部满级", "desc": "所有商店升级满级", "reward": 300},
	# 任务(2)
	{"id": "quests_half", "name": "半程", "desc": "完成一半任务", "reward": 50},
	{"id": "quests_all", "name": "全任务完成", "desc": "完成所有任务", "reward": 150},
	# 隐藏(2)
	{"id": "fast_boss", "name": "速杀", "desc": "3分钟内击败Boss", "reward": 200},
	{"id": "pacifist_1min", "name": "和平主义者", "desc": "开局1分钟不杀敌", "reward": 60},
	# 武器精通(2)
	{"id": "mastery_first", "name": "初窥门径", "desc": "任意武器达到学徒等级", "reward": 30},
	{"id": "mastery_all", "name": "万物精通", "desc": "全部7把武器达到宗师等级", "reward": 500},
]


func _ready():
	_init_data()
	load_save()


func _init_data() -> void:
	for id in SHOP_UPGRADES:
		shop_upgrades[id] = 0
	for q: Dictionary in QUESTS:
		completed_quests[q["id"]] = false
	for a: Dictionary in ACHIEVEMENTS:
		completed_achievements[a["id"]] = false
	for weapon_id: String in BASE_WEAPONS:
		weapon_kills[weapon_id] = 0


# --- Soul Fragments ---

func add_soul_fragments(amount: int) -> void:
	soul_fragments += amount
	soul_fragments_changed.emit(soul_fragments)


func spend_soul_fragments(amount: int) -> bool:
	if soul_fragments >= amount:
		soul_fragments -= amount
		soul_fragments_changed.emit(soul_fragments)
		return true
	return false


# --- Shop ---

func get_upgrade_cost(upgrade_id: String) -> int:
	var level: int = shop_upgrades.get(upgrade_id, 0)
	var def: Dictionary = SHOP_UPGRADES.get(upgrade_id, {})
	if level >= def.get("max_level", 3):
		return -1  # Maxed
	return def.get("costs", [])[level] if level < def.get("costs", []).size() else -1


func purchase_upgrade(upgrade_id: String) -> bool:
	var cost: int = get_upgrade_cost(upgrade_id)
	if cost < 0:
		return false
	if not spend_soul_fragments(cost):
		return false
	shop_upgrades[upgrade_id] = shop_upgrades.get(upgrade_id, 0) + 1
	# Check shop achievements
	_check_shop_achievements()
	save()
	return true


func get_upgrade_level(upgrade_id: String) -> int:
	return shop_upgrades.get(upgrade_id, 0)


# --- Shop bonus application ---

func get_hp_bonus() -> int:
	var level: int = shop_upgrades.get("maxhp", 0)
	return [0, 1, 2, 3, 5][level]


func get_speed_bonus() -> float:
	var level: int = shop_upgrades.get("speed", 0)
	return [0.0, 0.05, 0.10, 0.15, 0.20][level]


func get_pickup_bonus() -> float:
	var level: int = shop_upgrades.get("pickup", 0)
	return [0.0, 5.0, 10.0, 15.0, 20.0][level]


func get_exp_bonus() -> float:
	var level: int = shop_upgrades.get("expbonus", 0)
	return [0.0, 0.05, 0.10, 0.15, 0.20][level]


func get_weapon_dmg_bonus() -> float:
	var level: int = shop_upgrades.get("weapondmg", 0)
	return [0.0, 0.03, 0.06, 0.10, 0.15][level]


func get_gold_bonus() -> float:
	var level: int = shop_upgrades.get("gold", 0)
	return [0.0, 0.10, 0.20, 0.30, 0.40][level]


# --- Quest/Achievement Checking ---

func check_quests_and_achievements() -> void:
	# Called at end of game or during gameplay
	var kills: int = GameManager.enemies_killed
	var elapsed: float = GameManager.elapsed_time
	var boss_kills: int = GameManager.boss_kill_count
	var best_combo: int = GameManager.best_combo
	var difficulty: String = GameManager.selected_difficulty
	var character: String = GameManager.selected_character

	# Quests
	var char_kills: int = GameManager.character_kills
	_check_quest("warrior_30", character == "warrior" and char_kills >= 30)
	_check_quest("ranger_30", character == "ranger" and char_kills >= 30)
	_check_quest("kill_50", kills >= 50)
	_check_quest("kill_100", kills >= 100)
	_check_quest("kill_boss", boss_kills > 0)
	_check_quest("combo_20", best_combo >= 20)
	_check_quest("combo_50", best_combo >= 50)
	_check_quest("endless_5min", difficulty == "endless" and elapsed >= 300.0)
	_check_quest("endless_10min", difficulty == "endless" and elapsed >= 600.0)
	_check_quest("endless_boss3", difficulty == "endless" and boss_kills >= 3)
	_check_quest("endless_kill200", difficulty == "endless" and kills >= 200)
	_check_quest("hard_survive", difficulty == "hard" and elapsed >= 120.0)
	_check_quest("hard_boss", difficulty == "hard" and boss_kills > 0)
	_check_quest("no_damage", not GameManager.damage_taken and elapsed >= 60.0)
	# Achievements
	total_kills += kills
	games_played += 1
	_check_achievement("total_kills_100", total_kills >= 100)
	_check_achievement("total_kills_500", total_kills >= 500)
	_check_achievement("total_kills_2000", total_kills >= 2000)
	_check_achievement("games_10", games_played >= 10)
	_check_achievement("games_50", games_played >= 50)
	_check_achievement("survive_3min", difficulty == "normal" and elapsed >= 180.0)
	_check_achievement("survive_5min", difficulty == "normal" and elapsed >= 300.0)
	_check_achievement("survive_hard_5min", difficulty == "hard" and elapsed >= 300.0)
	_check_achievement("boss_kill", boss_kills > 0)
	_check_achievement("hard_boss_kill", difficulty == "hard" and boss_kills > 0)
	_check_achievement("no_damage_survive", not GameManager.damage_taken and elapsed >= 120.0 and kills > 0)
	_check_achievement("kill_100_single", kills >= 100)
	_check_achievement("survive_10min", elapsed >= 600.0)
	_check_achievement("combo_30", best_combo >= 30)
	_check_achievement("combo_50", best_combo >= 50)
	_check_achievement("hard_survive_ach", difficulty == "hard" and elapsed >= 120.0)
	# Fast boss: kill boss within 3 minutes
	_check_achievement("fast_boss", boss_kills > 0 and elapsed <= 180.0)
	# Pacifist: 1 minute without killing
	_check_achievement("pacifist_1min", elapsed >= 60.0 and GameManager.kills_at_60 == 0)
	# Character clears
	if character != "" and elapsed >= 180.0:
		characters_cleared[character] = true
	_check_achievement("all_chars", characters_cleared.size() >= 3)

	# Quest completion achievements
	var completed_count: int = 0
	for id in completed_quests:
		if completed_quests[id]:
			completed_count += 1
	_check_achievement("quests_half", completed_count >= QUESTS.size() / 2)
	_check_achievement("quests_all", completed_count >= QUESTS.size())
	# Endless unlock: beat boss
	if boss_kills > 0:
		endless_unlocked = true

	# Accumulate evolution history across sessions
	if GameManager.has_meta("evolutions"):
		for evo_id: String in GameManager.get_meta("evolutions"):
			evolution_history[evo_id] = true
	# Accumulate synergy history
	if SynergyManager:
		for syn: Dictionary in SynergyManager.SYNERGY_DEFINITIONS:
			if SynergyManager.has_synergy(syn["id"]):
				synergy_history[syn["id"]] = true

	# Evolution achievements
	var evolutions: Array = []
	if GameManager.has_meta("evolutions"):
		evolutions = GameManager.get_meta("evolutions")
	_check_achievement("evolve_weapon", evolutions.size() >= 1)

	# All evolved: collected all 9 evolution weapons (cumulative)
	var all_evo_ids: Array = ["thunderholywater", "fireknife", "holydomain", "blizzard", "frostknife", "flamebible", "thunderang", "blazerang", "sentineltotem"]
	var evo_count: int = 0
	for eid: String in all_evo_ids:
		if evolution_history.has(eid):
			evo_count += 1
	_check_achievement("all_evolved", evo_count >= all_evo_ids.size())

	# Synergy achievements
	if SynergyManager:
		var syn_count: int = 0
		for syn: Dictionary in SynergyManager.SYNERGY_DEFINITIONS:
			if SynergyManager.has_synergy(syn["id"]):
				syn_count += 1
		_check_achievement("synergy_first", syn_count >= 1)

	# All synergies: triggered all 18 synergy effects (cumulative)
	_check_achievement("all_synergies", SynergyManager != null and synergy_history.size() >= SynergyManager.SYNERGY_DEFINITIONS.size())

	# Convert gold to soul fragments (normal: 30%, endless: 45% with 1.5x bonus)
	var soul_rate: float = 0.3
	if GameManager.selected_difficulty == "endless":
		soul_rate = 0.45
	var soul_reward: int = int(GameManager.gold * soul_rate)
	add_soul_fragments(soul_reward)

	# Mastery achievements
	check_mastery_achievements()

	save()


func _check_quest(quest_id: String, condition: bool) -> void:
	if condition and not completed_quests.get(quest_id, false):
		completed_quests[quest_id] = true
		for q: Dictionary in QUESTS:
			if q["id"] == quest_id:
				add_soul_fragments(q["reward"])
				quest_completed.emit(quest_id)
				return


func _check_achievement(achievement_id: String, condition: bool) -> void:
	if condition and not completed_achievements.get(achievement_id, false):
		completed_achievements[achievement_id] = true
		for a: Dictionary in ACHIEVEMENTS:
			if a["id"] == achievement_id:
				add_soul_fragments(a["reward"])
				achievement_unlocked.emit(achievement_id)
				return


func _check_shop_achievements() -> void:
	# First purchase
	_check_achievement("shop_first", true)
	# Any single maxed
	for id in shop_upgrades:
		if shop_upgrades[id] >= SHOP_UPGRADES[id]["max_level"]:
			_check_achievement("shop_single_max", true)
			break
	# All maxed
	var all_maxed := true
	for id in shop_upgrades:
		if shop_upgrades[id] < SHOP_UPGRADES[id]["max_level"]:
			all_maxed = false
	_check_achievement("shop_max_all", all_maxed)


# --- Weapon Mastery ---

func add_weapon_kill(weapon_id: String) -> void:
	if weapon_id in BASE_WEAPONS:
		var old_tier: int = get_weapon_mastery_tier(weapon_id)
		weapon_kills[weapon_id] = weapon_kills.get(weapon_id, 0) + 1
		var new_tier: int = get_weapon_mastery_tier(weapon_id)
		if new_tier > old_tier:
			mastery_tier_up.emit(weapon_id, new_tier)


func get_weapon_kill_count(weapon_id: String) -> int:
	return weapon_kills.get(weapon_id, 0)


func get_weapon_mastery_tier(weapon_id: String) -> int:
	var kills: int = get_weapon_kill_count(weapon_id)
	var tier: int = 0
	for i in range(MASTERY_THRESHOLDS.size() - 1, -1, -1):
		if kills >= MASTERY_THRESHOLDS[i]:
			tier = i
			break
	return tier


func get_weapon_mastery_bonus(weapon_id: String) -> float:
	var tier: int = get_weapon_mastery_tier(weapon_id)
	if tier < MASTERY_BONUSES.size():
		return MASTERY_BONUSES[tier]
	return 0.0


func check_mastery_achievements() -> void:
	var max_tier: int = 0
	var all_master: bool = true
	for weapon_id: String in BASE_WEAPONS:
		var tier: int = get_weapon_mastery_tier(weapon_id)
		if tier > max_tier:
			max_tier = tier
		if tier < 4:
			all_master = false
	_check_achievement("mastery_first", max_tier >= 1)
	_check_achievement("mastery_all", all_master)


# --- Save/Load ---

func save() -> void:
	var config := ConfigFile.new()
	config.set_value("soul_fragments", "amount", soul_fragments)
	config.set_value("stats", "total_kills", total_kills)
	config.set_value("stats", "games_played", games_played)
	config.set_value("stats", "endless_unlocked", endless_unlocked)

	for id in shop_upgrades:
		config.set_value("shop", id, shop_upgrades[id])
	for id in completed_quests:
		config.set_value("quests", id, completed_quests[id])
	for id in completed_achievements:
		config.set_value("achievements", id, completed_achievements[id])
	for char_id in characters_cleared:
		config.set_value("chars_cleared", char_id, characters_cleared[char_id])
	for evo_id in evolution_history:
		config.set_value("evo_history", evo_id, true)
	for syn_id in synergy_history:
		config.set_value("syn_history", syn_id, true)

	config.set_value("tutorial", "step", tutorial_step)
	config.set_value("tutorial", "completed", tutorial_completed)

	for weapon_id in weapon_kills:
		config.set_value("mastery", weapon_id, weapon_kills[weapon_id])

	config.save(SAVE_PATH)


func load_save() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return

	soul_fragments = config.get_value("soul_fragments", "amount", 0)
	total_kills = config.get_value("stats", "total_kills", 0)
	games_played = config.get_value("stats", "games_played", 0)
	endless_unlocked = config.get_value("stats", "endless_unlocked", false)

	for id in SHOP_UPGRADES:
		shop_upgrades[id] = config.get_value("shop", id, 0)
	for q: Dictionary in QUESTS:
		completed_quests[q["id"]] = config.get_value("quests", q["id"], false)
	for a: Dictionary in ACHIEVEMENTS:
		completed_achievements[a["id"]] = config.get_value("achievements", a["id"], false)
	# Load character clears
	var chars: PackedStringArray = ["mage", "warrior", "ranger"]
	for c: String in chars:
		if config.get_value("chars_cleared", c, false):
			characters_cleared[c] = true
	# Load evolution/synergy history
	if config.has_section("evo_history"):
		for key in config.get_section_keys("evo_history"):
			if config.get_value("evo_history", key, false):
				evolution_history[key] = true
	if config.has_section("syn_history"):
		for key in config.get_section_keys("syn_history"):
			if config.get_value("syn_history", key, false):
				synergy_history[key] = true

	# Load tutorial progress
	tutorial_step = config.get_value("tutorial", "step", 0)
	tutorial_completed = config.get_value("tutorial", "completed", false)

	# Load weapon mastery
	for weapon_id: String in BASE_WEAPONS:
		weapon_kills[weapon_id] = config.get_value("mastery", weapon_id, 0)


func reset_save() -> void:
	soul_fragments = 0
	total_kills = 0
	games_played = 0
	endless_unlocked = false
	characters_cleared = {}
	evolution_history = {}
	synergy_history = {}
	weapon_kills.clear()
	tutorial_step = 0
	tutorial_completed = false
	_init_data()
	save()
