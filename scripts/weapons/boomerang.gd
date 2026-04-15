extends Area2D
# Boomerang weapon - flies out, tracks enemies, returns to player

var speed: float = 280.0
var damage: float = 3.0
var pierce: int = 0
var direction: Vector2 = Vector2.RIGHT
var color: Color = Color.WHITE
var size: float = 8.0
var lifetime: float = 5.0
var _hit_enemies: Array = []
var weapon_id: String = ""
var is_crit: bool = false

var _start_pos: Vector2 = Vector2.ZERO
var _max_dist: float = 250.0
var _return_speed: float = 320.0
var _track_angle: float = 0.52
var _returning: bool = false
var _player_pos: Vector2 = Vector2.ZERO
var _dist_traveled: float = 0.0


func setup(pos: Vector2, dir: Vector2, start_pos: Vector2):
	global_position = pos
	_start_pos = start_pos
	_player_pos = start_pos
	direction = dir
	_dist_traveled = 0.0
	_returning = false
	var sprite = $Sprite as Sprite2D
	if sprite:
		sprite.modulate = color
		var tex_path := "res://assets/sprites/weapons/%s.png" % weapon_id
		if weapon_id != "" and ResourceLoader.exists(tex_path):
			sprite.texture = load(tex_path)
		elif ResourceLoader.exists("res://assets/sprites/weapons/boomerang.png"):
			sprite.texture = load("res://assets/sprites/weapons/boomerang.png")
		else:
			sprite.texture = preload("res://assets/sprites/weapons/enemy_bullet.png")
		var base_size: float = 16.0
		var scale_factor: float = (size * 2.0) / base_size
		sprite.scale = Vector2(scale_factor, scale_factor)
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = size


func setup_boomerang(start_pos: Vector2, dir: Vector2, max_dist: float, return_spd: float, track_angle: float):
	_start_pos = start_pos
	_player_pos = start_pos
	direction = dir
	_max_dist = max_dist
	_return_speed = return_spd
	_track_angle = track_angle
	# Load sprite based on weapon_id (evolved weapons get custom sprites)
	var sprite = $Sprite as Sprite2D
	if sprite:
		sprite.modulate = color
		var tex_path := "res://assets/sprites/weapons/%s.png" % weapon_id
		if weapon_id != "" and ResourceLoader.exists(tex_path):
			sprite.texture = load(tex_path)
		elif ResourceLoader.exists("res://assets/sprites/weapons/boomerang.png"):
			sprite.texture = load("res://assets/sprites/weapons/boomerang.png")
		else:
			sprite.texture = preload("res://assets/sprites/weapons/enemy_bullet.png")
		var base_size: float = 16.0
		var scale_factor: float = (size * 2.0) / base_size
		sprite.scale = Vector2(scale_factor, scale_factor)
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = size


func update_player_pos(pos: Vector2):
	_player_pos = pos


func _physics_process(delta):
	if _returning:
		# Return to player with slight curve
		var to_player = _player_pos - global_position
		var dist_to_player = to_player.length()
		if dist_to_player < 15.0:
			queue_free()
			return
		var target_dir = to_player.normalized()
		# Smoothly rotate toward player
		var current_angle = direction.angle()
		var target_angle = target_dir.angle()
		var new_angle = lerp_angle(current_angle, target_angle, 0.15)
		direction = Vector2.from_angle(new_angle)
		position += direction * _return_speed * delta
	else:
		# Fly outward, try to track nearest enemy
		var closest_enemy = _get_nearest_enemy_in_cone()
		if closest_enemy:
			var to_enemy = (closest_enemy.global_position - global_position).normalized()
			var current_angle = direction.angle()
			var enemy_angle = to_enemy.angle()
			var diff = wrapf(enemy_angle - current_angle, -PI, PI)
			if absf(diff) < _track_angle:
				var new_angle = lerp_angle(current_angle, enemy_angle, 0.1)
				direction = Vector2.from_angle(new_angle)

		position += direction * speed * delta
		_dist_traveled += speed * delta
		if _dist_traveled >= _max_dist:
			_returning = true

	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	rotation = direction.angle()

	# boomerang_magnet synergy: attract nearby xp_gems
	if SynergyManager and SynergyManager.has_synergy("boomerang_magnet"):
		for area in get_overlapping_areas():
			if is_instance_valid(area) and "xp_value" in area:
				area.is_moving_to_player = true


func _get_nearest_enemy_in_cone() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var closest_dist: float = 200.0
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			var dist = global_position.distance_to(enemy.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = enemy
	return closest


func _on_body_entered(body: Node2D):
	if body.is_in_group("enemies") and body.has_method("take_damage") and not body in _hit_enemies:
		body.take_damage(damage, "boomerang", is_crit)
		_hit_enemies.append(body)
		# Clear hit list on return to allow re-hitting
		if _returning:
			_hit_enemies.clear()
		pierce -= 1
		if pierce < 0:
			queue_free()
