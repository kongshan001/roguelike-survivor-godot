extends RefCounted
## 武器进化配方定义（仅数据，不引用 UpgradePool）
## 通过 load("res://scripts/weapons/weapon_registry.gd").new() 使用


## 12 种进化武器配方
const EVOLUTION_RECIPES: Array = [
	{"a": "holywater", "b": "lightning", "result": "thunderholywater"},
	{"a": "knife", "b": "firestaff", "result": "fireknife"},
	{"a": "bible", "b": "holywater", "result": "holydomain"},
	{"a": "frostaura", "b": "lightning", "result": "blizzard"},
	{"a": "bible", "b": "firestaff", "result": "flamebible"},
	{"a": "boomerang", "b": "lightning", "result": "thunderang"},
	{"a": "boomerang", "b": "firestaff", "result": "blazerang"},
	{"a": "bible", "b": "boomerang", "result": "sentineltotem"},
	{"a": "frostaura", "b": "boomerang", "result": "frostknife"},
	{"a": "knife", "b": "frostaura", "result": "frostvortex"},
	{"a": "holywater", "b": "firestaff", "result": "holyshockwave"},
	{"a": "lightning", "b": "knife", "result": "thunderbeam"},
]


## 检查玩家是否满足某个进化配方条件
func check_evolution_available(owned_weapons: Dictionary) -> Dictionary:
	for recipe: Dictionary in EVOLUTION_RECIPES:
		var a_level: int = owned_weapons.get(recipe["a"], 0)
		var b_level: int = owned_weapons.get(recipe["b"], 0)
		if a_level >= 3 and b_level >= 3 and not owned_weapons.has(recipe["result"]):
			return recipe
	return {}
