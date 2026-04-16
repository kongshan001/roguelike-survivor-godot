extends Node

var _weapons: Dictionary = {}
var _passives: Dictionary = {}
var _character_passives: Dictionary = {}
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
	_register_character_passives()


func ensure_weapons_registered() -> void:
	## Called by weapon_controller on first frame to register all weapons
	if _weapons.is_empty():
		_register_base_weapons()
		_register_evolved_weapons()


func _register_base_weapons() -> void:
	# 1. Holy Water
	var hw := WeaponData.new()
	hw.weapon_name = "圣水"; hw.weapon_id = "holywater"; hw.weapon_type = "orbit"
	hw.damage = 1.5; hw.cooldown = 1.0; hw.orbit_count = 1; hw.orbit_radius = 50.0
	hw.orbit_speed = 3.0; hw.description = "环绕旋转"; hw.color = Color(0.3, 0.5, 1.0); hw.projectile_size = 8.0
	register_weapon("holywater", hw)
	# 2. Knife
	var kn := WeaponData.new()
	kn.weapon_name = "飞刀"; kn.weapon_id = "knife"; kn.weapon_type = "projectile"
	kn.damage = 2.0; kn.cooldown = 0.7; kn.projectile_speed = 350.0; kn.projectile_count = 1
	kn.projectile_pierce = 0; kn.description = "自动投掷"; kn.color = Color(0.75, 0.75, 0.8); kn.projectile_size = 5.0
	register_weapon("knife", kn)
	# 3. Lightning
	var lt := WeaponData.new()
	lt.weapon_name = "闪电"; lt.weapon_id = "lightning"; lt.weapon_type = "lightning"
	lt.damage = 5.0; lt.cooldown = 2.0; lt.chain_count = 0; lt.projectile_range = 300.0
	lt.description = "随机电击"; lt.color = Color(1.0, 1.0, 0.3)
	register_weapon("lightning", lt)
	# 4. Bible
	var bb := WeaponData.new()
	bb.weapon_name = "圣经"; bb.weapon_id = "bible"; bb.weapon_type = "orbit"
	bb.damage = 1.0; bb.cooldown = 1.0; bb.orbit_count = 1; bb.orbit_radius = 80.0
	bb.orbit_speed = 3.0; bb.description = "范围旋转"; bb.color = Color(0.9, 0.85, 0.7); bb.projectile_size = 20.0
	register_weapon("bible", bb)
	# 5. Fire Staff
	var fs := WeaponData.new()
	fs.weapon_name = "火焰法杖"; fs.weapon_id = "firestaff"; fs.weapon_type = "cone"
	fs.damage = 3.0; fs.cooldown = 1.5; fs.cone_angle = 80.0; fs.cone_range = 100.0
	fs.description = "锥形火焰"; fs.color = Color(1.0, 0.4, 0.1)
	register_weapon("firestaff", fs)
	# 6. Frost Aura
	var fa := WeaponData.new()
	fa.weapon_name = "冰冻光环"; fa.weapon_id = "frostaura"; fa.weapon_type = "aura"
	fa.damage = 1.0; fa.cooldown = 0.0; fa.aoe_radius = 80.0; fa.slow_pct = 0.3
	fa.description = "范围减速"; fa.color = Color(0.5, 0.8, 1.0)
	register_weapon("frostaura", fa)
	# 7. Boomerang
	var bm := WeaponData.new()
	bm.weapon_name = "回旋镖"; bm.weapon_id = "boomerang"; bm.weapon_type = "boomerang"
	bm.damage = 3.0; bm.cooldown = 1.8; bm.projectile_count = 1; bm.projectile_pierce = 0
	bm.boomerang_max_dist = 250.0; bm.boomerang_return_speed = 320.0; bm.boomerang_curvature = 0.3
	bm.boomerang_track_angle = 0.52; bm.description = "追踪回旋"; bm.color = Color(0.6, 0.4, 0.2); bm.projectile_size = 8.0
	register_weapon("boomerang", bm)


func _register_evolved_weapons() -> void:
	# 1. 雷暴圣水
	var thw := WeaponData.new()
	thw.weapon_name = "雷暴圣水"; thw.weapon_id = "thunderholywater"; thw.weapon_type = "orbit"
	thw.damage = 2.5; thw.cooldown = 1.0; thw.orbit_count = 3; thw.orbit_radius = 60.0
	thw.orbit_speed = 4.5; thw.color = Color(0.2, 0.4, 1.0); thw.projectile_size = 10.0
	thw.is_evolved = true; thw.description = "旋转+链式闪电"
	register_weapon("thunderholywater", thw)
	# 2. 火焰飞刀
	var fk := WeaponData.new()
	fk.weapon_name = "火焰飞刀"; fk.weapon_id = "fireknife"; fk.weapon_type = "projectile"
	fk.damage = 3.0; fk.cooldown = 0.5; fk.projectile_count = 3; fk.projectile_pierce = 2
	fk.projectile_speed = 400.0; fk.burn_dps = 2.0; fk.burn_duration = 2.0
	fk.color = Color(1.0, 0.6, 0.1); fk.projectile_size = 6.0; fk.is_evolved = true
	fk.description = "燃烧穿透飞刀"
	register_weapon("fireknife", fk)
	# 3. 圣光领域
	var hd := WeaponData.new()
	hd.weapon_name = "圣光领域"; hd.weapon_id = "holydomain"; hd.weapon_type = "orbit"
	hd.damage = 2.5; hd.cooldown = 1.0; hd.orbit_count = 4; hd.orbit_radius = 130.0
	hd.orbit_speed = 4.0; hd.color = Color(1.0, 1.0, 0.8); hd.projectile_size = 14.0
	hd.is_evolved = true; hd.description = "超大范围+圣光脉冲"
	register_weapon("holydomain", hd)
	# 4. 暴风雪
	var bz := WeaponData.new()
	bz.weapon_name = "暴风雪"; bz.weapon_id = "blizzard"; bz.weapon_type = "aura"
	bz.damage = 3.0; bz.cooldown = 0.0; bz.aoe_radius = 160.0; bz.slow_pct = 0.7
	bz.freeze_pct = 0.15; bz.color = Color(0.3, 0.6, 1.0); bz.is_evolved = true
	bz.description = "大范围暴风雪+闪电链"
	register_weapon("blizzard", bz)
	# 5. 冰霜飞刀
	var frk := WeaponData.new()
	frk.weapon_name = "冰霜飞刀"; frk.weapon_id = "frostknife"; frk.weapon_type = "projectile"
	frk.damage = 2.5; frk.cooldown = 0.6; frk.projectile_count = 4; frk.projectile_pierce = 2
	frk.projectile_speed = 380.0; frk.slow_pct = 0.4; frk.freeze_pct = 0.05
	frk.color = Color(0.4, 0.8, 1.0); frk.projectile_size = 6.0; frk.is_evolved = true
	frk.description = "减速穿透飞刀"
	register_weapon("frostknife", frk)
	# 6. 烈焰经文
	var fb := WeaponData.new()
	fb.weapon_name = "烈焰经文"; fb.weapon_id = "flamebible"; fb.weapon_type = "orbit"
	fb.damage = 5.0; fb.cooldown = 1.0; fb.orbit_count = 1; fb.orbit_radius = 140.0
	fb.orbit_speed = 4.0; fb.burn_dps = 3.0; fb.burn_duration = 2.0
	fb.color = Color(1.0, 0.3, 0.1); fb.projectile_size = 28.0; fb.is_evolved = true
	fb.description = "旋转灼烧+火焰脉冲"
	register_weapon("flamebible", fb)
	# 7. 雷霆回旋
	var tr := WeaponData.new()
	tr.weapon_name = "雷霆回旋"; tr.weapon_id = "thunderang"; tr.weapon_type = "boomerang"
	tr.damage = 5.0; tr.cooldown = 0.8; tr.projectile_count = 4; tr.projectile_pierce = 3
	tr.boomerang_max_dist = 400.0; tr.boomerang_return_speed = 380.0; tr.boomerang_curvature = 0.15
	tr.boomerang_track_angle = 1.31; tr.color = Color(0.5, 0.7, 1.0); tr.projectile_size = 10.0
	tr.is_evolved = true; tr.description = "追踪+闪电链"
	register_weapon("thunderang", tr)
	# 8. 烈焰回旋
	var br := WeaponData.new()
	br.weapon_name = "烈焰回旋"; br.weapon_id = "blazerang"; br.weapon_type = "boomerang"
	br.damage = 5.0; br.cooldown = 0.8; br.projectile_count = 3; br.projectile_pierce = 3
	br.boomerang_max_dist = 380.0; br.boomerang_return_speed = 360.0; br.boomerang_curvature = 0.2
	br.boomerang_track_angle = 1.05; br.burn_dps = 3.0; br.burn_duration = 2.5
	br.color = Color(1.0, 0.4, 0.0); br.projectile_size = 10.0; br.is_evolved = true
	br.description = "追踪+火焰轨迹"
	register_weapon("blazerang", br)
	# 9. Sentinel Totem (bible + boomerang) -- Simplified to orbit type
	var st := WeaponData.new()
	st.weapon_name = "守护图腾"; st.weapon_id = "sentineltotem"; st.weapon_type = "orbit"
	st.damage = 2.5; st.cooldown = 999.0; st.orbit_count = 2; st.orbit_radius = 120.0
	st.orbit_speed = 1.5; st.orbit_fire_rate = 0.8
	st.projectile_speed = 280.0; st.projectile_size = 6.0; st.color = Color(0.7, 0.6, 0.2)
	st.is_evolved = true; st.description = "环绕图腾+定向射击"
	register_weapon("sentineltotem", st)


func register_weapon(weapon_id: String, data: Resource):
	_ensure_initialized()
	_weapons[weapon_id] = data


func _register_character_passives() -> void:
	_character_passives = {
		"mage_damage_scale": {"name": "Elemental Mastery", "description": "All weapon damage +8%", "icon_color": Color(0.3, 0.5, 1.0), "max_stack": 1, "character": "mage"},
		"warrior_armor_mastery": {"name": "Iron Skin", "description": "Gain +2 armor", "icon_color": Color(0.6, 0.6, 0.6), "max_stack": 1, "character": "warrior"},
		"ranger_crit_boost": {"name": "Eagle Eye", "description": "+12% crit chance", "icon_color": Color(1.0, 0.8, 0.2), "max_stack": 1, "character": "ranger"},
	}


func get_random_upgrades(owned_weapons: Dictionary, owned_passives: Dictionary = {}, count: int = 3) -> Array[Dictionary]:
	_ensure_initialized()
	var options: Array[Dictionary] = []

	# Check for evolution options first (high priority)
	var registry_instance: RefCounted = load("res://scripts/weapons/weapon_registry.gd").new()
	var evo_recipe: Dictionary = registry_instance.check_evolution_available(owned_weapons)
	if not evo_recipe.is_empty():
		var result_data: Resource = _weapons.get(evo_recipe["result"])
		if result_data:
			options.append({
				"type": "evolution",
				"id": evo_recipe["result"],
				"name": result_data.weapon_name,
				"description": result_data.description + " (进化)",
				"icon_color": Color.GOLD,
				"recipe_a": evo_recipe["a"],
				"recipe_b": evo_recipe["b"],
			})

	for weapon_id in _weapons:
		var w: Resource = _weapons[weapon_id]
		# Skip evolved weapons that are not owned (they can't be picked up directly)
		if w.is_evolved and not owned_weapons.has(weapon_id):
			continue
		if not owned_weapons.has(weapon_id):
			if not w.is_evolved:
				options.append({
					"type": "new_weapon",
					"id": weapon_id,
					"name": w.weapon_name,
					"description": w.description,
					"icon_color": Color.ORANGE,
				})
		else:
			var current_level: int = owned_weapons[weapon_id]
			var max_lvl: int = 1 if w.is_evolved else 3
			if current_level < max_lvl:
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

	# Character exclusive passives (filtered by selected_character)
	var selected_char: String = GameManager.selected_character if GameManager else ""
	for cp_id in _character_passives:
		var cp: Dictionary = _character_passives[cp_id]
		if cp.get("character", "") != selected_char:
			continue
		var cp_stacks: int = owned_passives.get(cp_id, 0)
		var cp_max: int = cp.get("max_stack", 1)
		if cp_stacks < cp_max:
			options.append({
				"type": "character_passive",
				"id": cp_id,
				"name": cp.name,
				"description": cp.description,
				"icon_color": cp.icon_color,
			})

	options.shuffle()
	# Evolution options are guaranteed to appear
	var evolutions: Array[Dictionary] = []
	var rest: Array[Dictionary] = []
	for opt in options:
		if opt.type == "evolution":
			evolutions.append(opt)
		else:
			rest.append(opt)
	var result: Array[Dictionary] = []
	for evo in evolutions:
		result.append(evo)
	for i in range(mini(count - result.size(), rest.size())):
		result.append(rest[i])
	return result
