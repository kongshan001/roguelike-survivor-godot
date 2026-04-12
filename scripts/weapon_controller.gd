extends Node

var _weapon_timers: Dictionary = {}
var _registered: bool = false
var _orbit_instances: Dictionary = {}  # weapon_id -> Node2D
var _boomerang_instances: Array = []


func _physics_process(delta):
	if not _registered:
		_register_weapons()
		_registered = true

	if GameManager.is_game_over:
		return

	var player: CharacterBody2D = get_parent()
	if not player.is_alive:
		return

	for weapon_id in player.owned_weapons:
		if not _weapon_timers.has(weapon_id):
			_weapon_timers[weapon_id] = 0.0

		_weapon_timers[weapon_id] -= delta
		if _weapon_timers[weapon_id] <= 0.0:
			var data: WeaponData = UpgradePool._weapons.get(weapon_id)
			if data:
				_fire_weapon(weapon_id, data, player)
				_weapon_timers[weapon_id] = data.cooldown

	# Update boomerang positions
	_update_boomerangs(delta)


func _register_weapons():
	# 1. Holy Water - orbiting orbs
	var hw = WeaponData.new()
	hw.weapon_name = "圣水"
	hw.weapon_id = "holywater"
	hw.weapon_type = "orbit"
	hw.damage = 1.5
	hw.cooldown = 999.0  # Continuous, no cooldown
	hw.orbit_count = 1
	hw.orbit_radius = 50.0
	hw.orbit_speed = 3.0
	hw.description = "环绕旋转"
	hw.color = Color(0.3, 0.5, 1.0)
	hw.projectile_size = 8.0
	UpgradePool.register_weapon("holywater", hw)

	# 2. Knife - auto-throw at nearest enemy
	var kn = WeaponData.new()
	kn.weapon_name = "飞刀"
	kn.weapon_id = "knife"
	kn.weapon_type = "projectile"
	kn.damage = 2.0
	kn.cooldown = 0.7
	kn.projectile_speed = 350.0
	kn.projectile_count = 1
	kn.projectile_pierce = 0
	kn.description = "自动投掷"
	kn.color = Color(0.75, 0.75, 0.8)
	kn.projectile_size = 5.0
	UpgradePool.register_weapon("knife", kn)

	# 3. Lightning - instant hit random enemies
	var lt = WeaponData.new()
	lt.weapon_name = "闪电"
	lt.weapon_id = "lightning"
	lt.weapon_type = "lightning"
	lt.damage = 5.0
	lt.cooldown = 2.0
	lt.chain_count = 0
	lt.projectile_range = 300.0
	lt.description = "随机电击"
	lt.color = Color(1.0, 1.0, 0.3)
	UpgradePool.register_weapon("lightning", lt)

	# 4. Bible - large rotating area
	var bb = WeaponData.new()
	bb.weapon_name = "圣经"
	bb.weapon_id = "bible"
	bb.weapon_type = "orbit"
	bb.damage = 1.0
	bb.cooldown = 999.0
	bb.orbit_count = 1
	bb.orbit_radius = 80.0
	bb.orbit_speed = 3.0
	bb.description = "范围旋转"
	bb.color = Color(0.9, 0.85, 0.7)
	bb.projectile_size = 20.0
	UpgradePool.register_weapon("bible", bb)

	# 5. Fire Staff - cone burn
	var fs = WeaponData.new()
	fs.weapon_name = "火焰法杖"
	fs.weapon_id = "firestaff"
	fs.weapon_type = "cone"
	fs.damage = 3.0
	fs.cooldown = 1.5
	fs.cone_angle = 80.0
	fs.cone_range = 100.0
	fs.burn_dps = 0.0
	fs.burn_duration = 0.0
	fs.description = "锥形火焰"
	fs.color = Color(1.0, 0.4, 0.1)
	UpgradePool.register_weapon("firestaff", fs)

	# 6. Frost Aura - slow/freeze aura
	var fa = WeaponData.new()
	fa.weapon_name = "冰冻光环"
	fa.weapon_id = "frostaura"
	fa.weapon_type = "aura"
	fa.damage = 1.0
	fa.cooldown = 999.0
	fa.aoe_radius = 80.0
	fa.slow_pct = 0.3
	fa.freeze_pct = 0.0
	fa.description = "范围减速"
	fa.color = Color(0.5, 0.8, 1.0)
	UpgradePool.register_weapon("frostaura", fa)

	# 7. Boomerang - tracking return
	var bm = WeaponData.new()
	bm.weapon_name = "回旋镖"
	bm.weapon_id = "boomerang"
	bm.weapon_type = "boomerang"
	bm.damage = 3.0
	bm.cooldown = 1.8
	bm.projectile_count = 1
	bm.projectile_pierce = 0
	bm.boomerang_max_dist = 250.0
	bm.boomerang_return_speed = 320.0
	bm.boomerang_curvature = 0.3
	bm.boomerang_track_angle = 0.52
	bm.description = "追踪回旋"
	bm.color = Color(0.6, 0.4, 0.2)
	bm.projectile_size = 8.0
	UpgradePool.register_weapon("boomerang", bm)


func _fire_weapon(weapon_id: String, data: WeaponData, player: CharacterBody2D):
	var level: int = player.owned_weapons[weapon_id]
	var dmg_bonus: float = 1.0 + player.damage_bonus
	match data.weapon_type:
		"projectile":
			_fire_projectile(data, level, player, dmg_bonus)
		"orbit":
			_update_orbit(weapon_id, data, level, player, dmg_bonus)
		"lightning":
			_fire_lightning(data, level, player, dmg_bonus)
		"cone":
			_fire_cone(data, level, player, dmg_bonus)
		"aura":
			_update_aura(weapon_id, data, level, player, dmg_bonus)
		"boomerang":
			_fire_boomerang(data, level, player, dmg_bonus)


# --- Knife ---
func _fire_projectile(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var count: int = data.projectile_count + (level - 1)
	var damage: float = data.damage + (level - 1) * 0.6
	var pierce: int = data.projectile_pierce + (level - 1)

	var enemies = _get_enemies_in_range(player, 600.0)
	if enemies.is_empty():
		return

	for i in range(count):
		var target: Node2D = enemies[i % enemies.size()]
		var projectile_scene = preload("res://scenes/projectile.tscn")
		var proj = projectile_scene.instantiate()
		proj.setup(
			player.global_position,
			target.global_position,
			data.projectile_speed,
			damage * dmg_bonus,
			pierce,
			data.color,
			data.projectile_size
		)
		player.get_parent().get_node("ProjectileManager").add_child(proj)


# --- Holy Water & Bible (orbit) ---
func _update_orbit(weapon_id: String, data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var orbit_count: int
	var radius: float
	var damage: float

	if weapon_id == "holywater":
		# Lv1: 1 orb, Lv2: 2 orbs, Lv3: 3 orbs
		orbit_count = level
		radius = 50.0 + (level - 1) * 5.0
		damage = (1.5 if level < 3 else 2.0) * dmg_bonus
	elif weapon_id == "bible":
		# Lv1: r=80, Lv2: r=104, Lv3: r=120
		orbit_count = 1
		radius = 80.0 + (level - 1) * 20.0
		damage = (1.0 if level < 3 else 2.0) * dmg_bonus
	else:
		return

	# Remove old instance if count changed
	var key = weapon_id
	if _orbit_instances.has(key) and is_instance_valid(_orbit_instances[key]):
		var existing = _orbit_instances[key]
		if existing.orbit_count != orbit_count or existing.orbit_radius != radius:
			existing.queue_free()
			_orbit_instances.erase(key)
		else:
			existing.damage = damage
			existing.global_position = player.global_position
			return

	var instance = Node2D.new()
	instance.set_script(load("res://scripts/spin_blade.gd"))
	instance.setup(orbit_count, damage, radius, data.color, data.projectile_size)
	instance.rotation_speed = 3.0 + (level - 1) * 0.6
	player.get_parent().get_node("ProjectileManager").add_child(instance)
	instance.global_position = player.global_position
	_orbit_instances[key] = instance


# --- Lightning ---
func _fire_lightning(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var damage: float = (5.0 + (level - 1)) * dmg_bonus
	var chains: int = level - 1
	var bolt_count: int = 1 if level < 3 else 2
	var range_val: float = data.projectile_range

	var enemies = _get_enemies_in_range(player, range_val)
	if enemies.is_empty():
		return

	var hit_count = mini(bolt_count + chains, enemies.size())
	for i in range(hit_count):
		var target: Node2D = enemies[i]
		if target.has_method("take_damage"):
			target.take_damage(damage)
		_create_lightning_effect(player.global_position, target.global_position, data.color)


# --- Fire Staff (cone) ---
func _fire_cone(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var angle: float = data.cone_angle + (level - 1) * 20.0
	var range_val: float = data.cone_range + (level - 1) * 30.0
	var damage: float = (data.damage + (level - 1) * 2.0) * dmg_bonus
	var burn: float = 0.0
	var burn_dur: float = 0.0
	if level >= 3:
		burn = 2.0
		burn_dur = 2.0

	var player_dir: Vector2 = Vector2.RIGHT
	var velocity = player.velocity
	if velocity.length_squared() > 1.0:
		player_dir = velocity.normalized()

	var half_angle = deg_to_rad(angle / 2.0)
	var dir_angle = player_dir.angle()

	var enemies = _get_enemies_in_range(player, range_val)
	for enemy in enemies:
		var to_enemy = enemy.global_position - player.global_position
		var enemy_angle = to_enemy.angle()
		var angle_diff = absf(wrapf(enemy_angle - dir_angle, -PI, PI))
		if angle_diff <= half_angle:
			enemy.take_damage(damage)
			if burn > 0.0 and enemy.has_method("apply_burn"):
				enemy.apply_burn(burn, burn_dur)

	_create_cone_effect(player.global_position, dir_angle, half_angle, range_val, data.color)


# --- Frost Aura ---
func _update_aura(weapon_id: String, data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var radius: float = 80.0 + (level - 1) * 25.0
	var slow: float = 0.3 + (level - 1) * 0.15
	var damage: float = (1.0 + (level - 1) * 0.5) * dmg_bonus
	var freeze_pct: float = 0.08 if level >= 3 else 0.0

	# Apply aura damage and slow every frame (DPS)
	var enemies = _get_enemies_in_range(player, radius)
	for enemy in enemies:
		enemy.take_damage(damage * get_process_delta_time())
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(slow)
		if freeze_pct > 0.0 and enemy.has_method("apply_freeze"):
			enemy.apply_freeze(freeze_pct * get_process_delta_time())


# --- Boomerang ---
func _fire_boomerang(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var count: int = data.projectile_count + (level - 1)
	var damage: float = (data.damage + (level - 1)) * dmg_bonus
	var pierce: int = data.projectile_pierce + (level - 1)
	var max_dist: float = data.boomerang_max_dist + (level - 1) * 50.0
	var cooldown: float = data.cooldown - (level - 1) * 0.4
	var track_angle: float = data.boomerang_track_angle + (level - 1) * 0.26

	_weapon_timers["boomerang"] = maxf(cooldown, 0.5)

	# Clean up old boomerangs
	_boomerang_instances = _boomerang_instances.filter(func(b): return is_instance_valid(b))

	for i in range(count):
		if _boomerang_instances.size() >= 6:
			break  # Max active boomerangs

		var enemies = _get_enemies_in_range(player, 400.0)
		var target_dir: Vector2 = Vector2.RIGHT.rotated(randf() * TAU)
		if not enemies.is_empty():
			target_dir = player.global_position.direction_to(enemies[i % enemies.size()].global_position)

		var bm = _create_boomerang(player.global_position, target_dir, damage, pierce, max_dist, data.boomerang_return_speed, track_angle, data.color, data.projectile_size)
		player.get_parent().get_node("ProjectileManager").add_child(bm)
		_boomerang_instances.append(bm)


func _create_boomerang(pos: Vector2, dir: Vector2, dmg: float, prc: int, max_dist: float, return_spd: float, track_angle: float, col: Color, sz: float) -> Area2D:
	var bm_scene = preload("res://scenes/projectile.tscn")
	var bm = bm_scene.instantiate()
	bm.global_position = pos
	bm.direction = dir
	bm.speed = 280.0
	bm.damage = dmg
	bm.pierce = prc
	bm.color = col
	bm.size = sz
	bm.set_script(load("res://scripts/weapons/boomerang.gd"))
	bm.setup_boomerang(pos, dir, max_dist, return_spd, track_angle)
	return bm


func _update_boomerangs(_delta: float):
	var player: CharacterBody2D = get_parent()
	if not player or not is_instance_valid(player):
		return
	for bm in _boomerang_instances:
		if is_instance_valid(bm) and bm.has_method("update_player_pos"):
			bm.update_player_pos(player.global_position)


# --- Helpers ---

func _get_enemies_in_range(player: Node2D, range_val: float) -> Array:
	var enemies: Array = []
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			var dist = player.global_position.distance_to(enemy.global_position)
			if dist <= range_val:
				enemies.append(enemy)
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	return enemies


func _create_lightning_effect(from: Vector2, to: Vector2, color: Color):
	var line = Line2D.new()
	line.width = 3.0
	line.default_color = color
	var points = [from]
	var segments = 5
	for i in range(1, segments):
		var t = float(i) / segments
		var point = from.lerp(to, t)
		point += Vector2(randf_range(-15, 15), randf_range(-15, 15))
		points.append(point)
	points.append(to)
	line.points = points
	get_parent().get_parent().get_node("ProjectileManager").add_child(line)
	var tween = line.create_tween()
	tween.tween_interval(0.15)
	tween.tween_callback(line.queue_free)


func _create_cone_effect(pos: Vector2, dir_angle: float, half_angle: float, range_val: float, color: Color):
	var node = Node2D.new()
	var script = GDScript.new()
	script.source_code = """
extends Node2D
var dir_angle: float = 0.0
var half_angle: float = 0.0
var range_val: float = 0.0
var color: Color = Color.WHITE
var alpha: float = 0.4

func _process(delta):
	alpha -= delta * 3.0
	if alpha <= 0.0:
		queue_free()
	queue_redraw()

func _draw():
	var points = [Vector2.ZERO]
	var steps = 12
	for i in range(steps + 1):
		var a = dir_angle - half_angle + (2.0 * half_angle * i / steps)
		points.append(Vector2(cos(a), sin(a)) * range_val)
	points.append(Vector2.ZERO)
	draw_colored_polygon(points, Color(color.r, color.g, color.b, alpha))
	"""
	node.set_script(script)
	node.dir_angle = dir_angle
	node.half_angle = half_angle
	node.range_val = range_val
	node.color = color
	node.global_position = pos
	get_parent().get_parent().get_node("ProjectileManager").add_child(node)


func _process(_delta):
	# Keep orbit instances following player
	for key in _orbit_instances:
		var inst = _orbit_instances[key]
		if is_instance_valid(inst):
			var player: CharacterBody2D = get_parent()
			if player and is_instance_valid(player):
				inst.global_position = player.global_position
