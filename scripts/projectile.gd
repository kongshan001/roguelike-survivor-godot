extends Area2D

var speed: float = 300.0
var damage: float = 10.0
var pierce: int = 1
var direction: Vector2 = Vector2.RIGHT
var color: Color = Color.WHITE
var size: float = 8.0
var lifetime: float = 5.0
var _hit_enemies: Array = []

# Status effect support
var burn_dps: float = 0.0
var burn_duration: float = 0.0
var slow_pct: float = 0.0

# Kill attribution
var weapon_id: String = ""
var is_crit: bool = false


func setup(pos: Vector2, target_pos: Vector2, spd: float, dmg: float, prc: int, col: Color, sz: float):
	global_position = pos
	direction = pos.direction_to(target_pos)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	speed = spd
	damage = dmg
	pierce = prc
	color = col
	size = sz
	var sprite = $Sprite as Sprite2D
	if sprite:
		sprite.modulate = color
		var tex_path := "res://assets/sprites/weapons/%s.png" % weapon_id
		if weapon_id != "" and ResourceLoader.exists(tex_path):
			sprite.texture = load(tex_path)
		else:
			sprite.texture = preload("res://assets/sprites/weapons/enemy_bullet.png")
		var base_size: float = 16.0
		var scale_factor: float = (size * 2.0) / base_size
		sprite.scale = Vector2(scale_factor, scale_factor)
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = size


func set_status_effects(burn: float = 0.0, burn_dur: float = 0.0, slow: float = 0.0):
	burn_dps = burn
	burn_duration = burn_dur
	slow_pct = slow


func _physics_process(delta):
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	rotation = direction.angle()


func _on_body_entered(body: Node2D):
	if body.is_in_group("enemies") and body.has_method("take_damage") and not body in _hit_enemies:
		body.take_damage(damage, weapon_id, is_crit)
		# Apply status effects
		if burn_dps > 0.0 and burn_duration > 0.0 and body.has_method("apply_burn"):
			body.apply_burn(burn_dps, burn_duration)
		if slow_pct > 0.0 and body.has_method("apply_slow"):
			body.apply_slow(slow_pct)
		_hit_enemies.append(body)
		pierce -= 1
		if pierce <= 0:
			queue_free()
