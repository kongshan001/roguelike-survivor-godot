extends Area2D

var speed: float = 300.0
var damage: float = 10.0
var pierce: int = 1
var direction: Vector2 = Vector2.RIGHT
var color: Color = Color.WHITE
var size: float = 8.0
var lifetime: float = 5.0
var _hit_enemies: Array = []


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
	var sprite = $Sprite as ColorRect
	if sprite:
		sprite.color = color
		sprite.size = Vector2(size * 2, size * 2)
		sprite.position = -sprite.size / 2.0
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = size


func _physics_process(delta):
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	rotation = direction.angle()


func _on_body_entered(body: Node2D):
	if body.is_in_group("enemies") and body.has_method("take_damage") and not body in _hit_enemies:
		body.take_damage(damage)
		_hit_enemies.append(body)
		pierce -= 1
		if pierce <= 0:
			queue_free()
