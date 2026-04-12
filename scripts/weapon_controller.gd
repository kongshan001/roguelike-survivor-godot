extends Node

var _weapon_timers: Dictionary = {}
var _registered: bool = false
var _spin_blade_instance: Node2D = null


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


func _register_weapons():
	var orb = WeaponData.new()
	orb.weapon_name = "Magic Orb"
	orb.weapon_id = "magic_orb"
	orb.damage = 10.0
	orb.cooldown = 1.5
	orb.projectile_speed = 300.0
	orb.projectile_count = 1
	orb.projectile_pierce = 1
	orb.projectile_range = 500.0
	orb.description = "Fires an orb at the nearest enemy"
	orb.color = Color(0.4, 0.6, 1.0)
	orb.projectile_size = 8.0
	orb.weapon_type = "projectile"
	UpgradePool.register_weapon("magic_orb", orb)

	var sb = WeaponData.new()
	sb.weapon_name = "Spin Blade"
	sb.weapon_id = "spin_blade"
	sb.damage = 15.0
	sb.cooldown = 3.0
	sb.description = "Orbiting blades around the player"
	sb.color = Color(0.8, 0.8, 0.9)
	sb.weapon_type = "orbit"
	sb.orbit_count = 2
	sb.orbit_radius = 80.0
	UpgradePool.register_weapon("spin_blade", sb)

	var lt = WeaponData.new()
	lt.weapon_name = "Lightning"
	lt.weapon_id = "lightning"
	lt.damage = 20.0
	lt.cooldown = 2.0
	lt.description = "Strikes a random nearby enemy"
	lt.color = Color(1.0, 1.0, 0.3)
	lt.weapon_type = "lightning"
	lt.projectile_range = 300.0
	lt.chain_count = 1
	UpgradePool.register_weapon("lightning", lt)

	var fb = WeaponData.new()
	fb.weapon_name = "Fire Burst"
	fb.weapon_id = "fire_burst"
	fb.damage = 12.0
	fb.cooldown = 3.0
	fb.description = "AoE explosion around the player"
	fb.color = Color(1.0, 0.3, 0.1)
	fb.weapon_type = "aoe"
	fb.aoe_radius = 80.0
	UpgradePool.register_weapon("fire_burst", fb)


func _fire_weapon(weapon_id: String, data: WeaponData, player: CharacterBody2D):
	var level: int = player.owned_weapons[weapon_id]
	match data.weapon_type:
		"projectile":
			_fire_projectile(data, level, player)
		"orbit":
			_activate_spin_blade(data, level, player)
		"lightning":
			_fire_lightning(data, level, player)
		"aoe":
			_fire_aoe(data, level, player)


func _fire_projectile(data: WeaponData, level: int, player: CharacterBody2D):
	var count: int = data.projectile_count + (level - 1)
	var pierce: int = data.projectile_pierce + (level - 1)
	var damage: float = data.damage + (level - 1) * 3.0

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
			damage,
			pierce,
			data.color,
			data.projectile_size
		)
		player.get_parent().get_node("ProjectileManager").add_child(proj)


func _activate_spin_blade(data: WeaponData, level: int, player: CharacterBody2D):
	var orbit_count: int = data.orbit_count + (level - 1)
	var damage: float = data.damage + (level - 1) * 4.0
	var radius: float = data.orbit_radius + (level - 1) * 10.0

	if _spin_blade_instance and is_instance_valid(_spin_blade_instance):
		_spin_blade_instance.queue_free()

	_spin_blade_instance = Node2D.new()
	_spin_blade_instance.set_script(load("res://scripts/spin_blade.gd"))
	_spin_blade_instance.setup(orbit_count, damage, radius, data.color, data.projectile_size)
	player.get_parent().get_node("ProjectileManager").add_child(_spin_blade_instance)
	_spin_blade_instance.global_position = player.global_position


func _fire_lightning(data: WeaponData, level: int, player: CharacterBody2D):
	var damage: float = data.damage + (level - 1) * 5.0
	var range_val: float = data.projectile_range + (level - 1) * 30.0
	var chains: int = data.chain_count + (level - 1)

	var enemies = _get_enemies_in_range(player, range_val)
	if enemies.is_empty():
		return

	for i in range(mini(1 + chains, enemies.size())):
		var target: Node2D = enemies[i]
		if target.has_method("take_damage"):
			target.take_damage(damage)
		_create_lightning_effect(player.global_position, target.global_position, data.color)


func _fire_aoe(data: WeaponData, level: int, player: CharacterBody2D):
	var damage: float = data.damage + (level - 1) * 3.0
	var radius: float = data.aoe_radius + (level - 1) * 15.0

	var enemies = _get_enemies_in_range(player, radius)
	for enemy in enemies:
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)

	_create_aoe_effect(player.global_position, radius, data.color)


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


func _create_aoe_effect(pos: Vector2, radius: float, color: Color):
	var circle = Node2D.new()
	var script = GDScript.new()
	script.source_code = """
extends Node2D
var radius: float = 0.0
var target_radius: float = 0.0
var color: Color = Color.WHITE
var alpha: float = 0.6

func _process(delta):
	radius = lerpf(radius, target_radius, delta * 10.0)
	alpha -= delta * 3.0
	if alpha <= 0.0:
		queue_free()
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, alpha))
"""
	circle.set_script(script)
	circle.radius = 0.0
	circle.target_radius = radius
	circle.color = color
	circle.global_position = pos
	get_parent().get_parent().get_node("ProjectileManager").add_child(circle)


func _process(_delta):
	if _spin_blade_instance and is_instance_valid(_spin_blade_instance):
		var player: CharacterBody2D = get_parent()
		_spin_blade_instance.global_position = player.global_position
