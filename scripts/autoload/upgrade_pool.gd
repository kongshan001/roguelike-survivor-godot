extends Node

var _weapons: Dictionary = {}
var _passives: Dictionary = {}
var _initialized: bool = false


func _ensure_initialized():
	if _initialized:
		return
	_initialized = true
	_passives = {
		"speedboots": {"name": "疾风靴", "description": "移动速度+15%", "icon_color": Color(0.3, 0.7, 1.0), "max_stack": 3},
		"armor": {"name": "护甲", "description": "受伤减少+1", "icon_color": Color(0.6, 0.6, 0.6), "max_stack": 3},
		"magnet": {"name": "磁铁", "description": "经验获取+30%", "icon_color": Color(1.0, 0.3, 0.3), "max_stack": 3},
		"crit": {"name": "暴击戒指", "description": "暴击率+8%", "icon_color": Color(1.0, 0.8, 0.2), "max_stack": 3},
		"maxhp": {"name": "生命结晶", "description": "最大HP+2", "icon_color": Color(0.9, 0.2, 0.3), "max_stack": 3},
		"regen": {"name": "再生护符", "description": "每5秒回复1HP", "icon_color": Color(0.2, 0.9, 0.4), "max_stack": 3},
		"luckycoin": {"name": "幸运硬币", "description": "暴击伤害+50%，金币+15%", "icon_color": Color(1.0, 0.85, 0.1), "max_stack": 3},
	}


func register_weapon(weapon_id: String, data: Resource):
	_ensure_initialized()
	_weapons[weapon_id] = data


func get_random_upgrades(owned_weapons: Dictionary, owned_passives: Dictionary = {}, count: int = 3) -> Array[Dictionary]:
	_ensure_initialized()
	var options: Array[Dictionary] = []

	for weapon_id in _weapons:
		if not owned_weapons.has(weapon_id):
			var w: Resource = _weapons[weapon_id]
			options.append({
				"type": "new_weapon",
				"id": weapon_id,
				"name": w.weapon_name,
				"description": w.description,
				"icon_color": Color.ORANGE,
			})
		else:
			var current_level: int = owned_weapons[weapon_id]
			if current_level < 3:
				var w: Resource = _weapons[weapon_id]
				options.append({
					"type": "weapon_upgrade",
					"id": weapon_id,
					"name": w.weapon_name + " Lv%d" % (current_level + 1),
					"description": "Upgrade %s" % w.weapon_name,
					"icon_color": Color.ORANGE,
				})

	for passive_id in _passives:
		var p: Dictionary = _passives[passive_id]
		var current_stacks: int = owned_passives.get(passive_id, 0)
		var max_stack: int = p.get("max_stack", 3)
		if current_stacks < max_stack:
			options.append({
				"type": "passive",
				"id": passive_id,
				"name": p.name,
				"description": p.description,
				"icon_color": p.icon_color,
			})

	options.shuffle()
	var result: Array[Dictionary] = []
	for i in range(mini(count, options.size())):
		result.append(options[i])
	return result
