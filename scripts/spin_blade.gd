extends Node2D

var orbit_count: int = 2
var damage: float = 15.0
var orbit_radius: float = 80.0
var color: Color = Color.WHITE
var blade_size: float = 10.0
var rotation_speed: float = 3.0
var _angle: float = 0.0
var _hit_cooldowns: Dictionary = {}
var weapon_id: String = ""
var weapon_level: int = 1


func setup(count: int, dmg: float, radius: float, col: Color, sz: float):
	orbit_count = count
	damage = dmg
	orbit_radius = radius
	color = col
	blade_size = sz


func set_rotation_speed(spd: float):
	rotation_speed = spd


func _physics_process(delta):
	_angle += rotation_speed * delta

	var to_remove: Array = []
	for enemy in _hit_cooldowns:
		_hit_cooldowns[enemy] -= delta
		if _hit_cooldowns[enemy] <= 0:
			to_remove.append(enemy)
	for e in to_remove:
		_hit_cooldowns.erase(e)

	queue_redraw()

	var all_enemies = get_tree().get_nodes_in_group("enemies")
	for i in range(orbit_count):
		var blade_angle = _angle + (TAU * i / orbit_count)
		var blade_pos = Vector2(cos(blade_angle), sin(blade_angle)) * orbit_radius
		for enemy in all_enemies:
			if is_instance_valid(enemy) and enemy.is_alive and not _hit_cooldowns.has(enemy):
				var dist = blade_pos.distance_to(enemy.global_position - global_position)
				if dist < blade_size + 10.0:
					enemy.take_damage(damage, weapon_id)
					_hit_cooldowns[enemy] = 0.3


func _draw():
	for i in range(orbit_count):
		var blade_angle = _angle + (TAU * i / orbit_count)
		var pos = Vector2(cos(blade_angle), sin(blade_angle)) * orbit_radius
		draw_set_transform(pos, blade_angle, Vector2.ONE)
		var half = blade_size
		draw_rect(Rect2(-half * 0.3, -half, half * 0.6, half * 2), color)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
