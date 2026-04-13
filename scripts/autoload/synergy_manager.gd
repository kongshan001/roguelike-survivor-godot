extends Node
## 协同效应管理器 — 检测武器+被动组合，实时激活协同效果
## 挂载为 Autoload 单例

var active_synergies: Dictionary = {}  # synergy_id -> Dictionary (definition)

# 18 种协同配方定义
const SYNERGY_DEFINITIONS: Array = [
	# --- 被动+被动 (7种) ---
	{
		"id": "crit_boots", "name": "风之锋刃", "type": "passive_passive",
		"a": "crit", "b": "speedboots",
		"effect": "crit_knife", "desc": "暴击时发射飞刀"
	},
	{
		"id": "armor_maxhp", "name": "铁壁之心", "type": "passive_passive",
		"a": "armor", "b": "maxhp",
		"effect": "armor_double", "desc": "护甲效果翻倍"
	},
	{
		"id": "magnet_crit", "name": "贪婪之魂", "type": "passive_passive",
		"a": "magnet", "b": "crit",
		"effect": "bonus_gem_value", "value": 2, "desc": "暴击额外掉落宝石"
	},
	{
		"id": "boots_regen", "name": "生命奔流", "type": "passive_passive",
		"a": "speedboots", "b": "regen",
		"effect": "moving_regen_mul", "value": 2.0, "desc": "移动时再生速度×2"
	},
	{
		"id": "armor_regen", "name": "钢铁堡垒", "type": "passive_passive",
		"a": "armor", "b": "regen",
		"effect": "low_hp_armor", "threshold": 0.3, "bonus": 3, "desc": "低HP时+3护甲"
	},
	{
		"id": "magnet_maxhp", "name": "命运齿轮", "type": "passive_passive",
		"a": "magnet", "b": "maxhp",
		"effect": "gem_heal_chance", "value": 0.02, "desc": "拾取宝石2%回复1HP"
	},
	{
		"id": "crit_luckycoin", "name": "命运赌徒", "type": "passive_passive",
		"a": "crit", "b": "luckycoin",
		"effect": "crit_double_gold", "desc": "暴击时双倍金币"
	},
	# --- 武器+被动 (11种) ---
	{
		"id": "holywater_maxhp", "name": "圣水膨胀", "type": "weapon_passive",
		"weapon": "holywater", "passive": "maxhp",
		"effect": "radius_mul", "value": 1.3, "desc": "圣水半径×1.3"
	},
	{
		"id": "knife_crit", "name": "致命飞刀", "type": "weapon_passive",
		"weapon": "knife", "passive": "crit",
		"effect": "can_crit", "desc": "飞刀可暴击"
	},
	{
		"id": "lightning_magnet", "name": "过载闪电", "type": "weapon_passive",
		"weapon": "lightning", "passive": "magnet",
		"effect": "extra_chains", "chains": 1, "range_bonus": 50.0, "desc": "闪电+1链,范围+50"
	},
	{
		"id": "bible_boots", "name": "疾风圣经", "type": "weapon_passive",
		"weapon": "bible", "passive": "speedboots",
		"effect": "speed_mul", "value": 1.5, "radius_bonus": 20.0, "desc": "圣经速度×1.5,半径+20"
	},
	{
		"id": "firestaff_armor", "name": "熔岩法杖", "type": "weapon_passive",
		"weapon": "firestaff", "passive": "armor",
		"effect": "cone_bonus", "angle": 40.0, "burn_dur_bonus": 1.0, "desc": "锥形+40°,燃烧+1s"
	},
	{
		"id": "frost_regen", "name": "极寒光环", "type": "weapon_passive",
		"weapon": "frostaura", "passive": "regen",
		"effect": "freeze_bonus", "chance": 0.05, "dur_bonus": 0.5, "desc": "冰冻+5%,持续+0.5s"
	},
	{
		"id": "holywater_luckycoin", "name": "圣水炼金", "type": "weapon_passive",
		"weapon": "holywater", "passive": "luckycoin",
		"effect": "kill_gold_bonus", "value": 1, "desc": "圣水击杀+1金币"
	},
	{
		"id": "firestaff_luckycoin", "name": "炼金烈焰", "type": "weapon_passive",
		"weapon": "firestaff", "passive": "luckycoin",
		"effect": "burn_gem_bonus", "value": 1, "desc": "燃烧击杀+1宝石"
	},
	{
		"id": "frostaura_luckycoin", "name": "冰霜拾荒", "type": "weapon_passive",
		"weapon": "frostaura", "passive": "luckycoin",
		"effect": "frozen_pull_bonus", "value": 30.0, "desc": "冰冻敌人宝石吸引+30"
	},
	{
		"id": "boomerang_magnet", "name": "磁力回旋", "type": "weapon_passive",
		"weapon": "boomerang", "passive": "magnet",
		"effect": "flight_pull", "value": 30.0, "desc": "回旋镖飞行时吸引宝石30"
	},
	{
		"id": "boomerang_crit", "name": "致命回旋", "type": "weapon_passive",
		"weapon": "boomerang", "passive": "crit",
		"effect": "can_crit_boomerang", "size_mul": 1.2, "pierce_bonus": 1, "desc": "回旋镖可暴击"
	},
]


func check_synergies(owned_weapons: Dictionary, owned_passives: Dictionary) -> void:
	active_synergies.clear()
	for def: Dictionary in SYNERGY_DEFINITIONS:
		var is_match: bool = false
		if def["type"] == "passive_passive":
			var has_a: bool = owned_passives.get(def["a"], 0) > 0
			var has_b: bool = owned_passives.get(def["b"], 0) > 0
			is_match = has_a and has_b
		elif def["type"] == "weapon_passive":
			var has_w: bool = owned_weapons.get(def["weapon"], 0) > 0
			var has_p: bool = owned_passives.get(def["passive"], 0) > 0
			is_match = has_w and has_p
		if is_match:
			active_synergies[def["id"]] = def


func has_synergy(synergy_id: String) -> bool:
	return active_synergies.has(synergy_id)


func get_synergy_value(synergy_id: String, key: String, default: Variant = null) -> Variant:
	if not active_synergies.has(synergy_id):
		return default
	return active_synergies[synergy_id].get(key, default)


func get_active_count() -> int:
	return active_synergies.size()


func get_active_names() -> Array:
	var names: Array = []
	for id in active_synergies:
		names.append(active_synergies[id]["name"])
	return names
