extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 200.0
var damage: float = 1.0
var color: Color = Color.WHITE
var size: float = 4.0
var _lifetime: float = 5.0


func _ready():
	# Set visual
	var sprite: ColorRect = $Sprite
	if sprite:
		sprite.color = color
		sprite.size = Vector2(size * 2, size * 2)
		sprite.position = -sprite.size / 2.0
	# Set collision shape
	var shape: CircleShape2D = $CollisionShape2D.shape
	if shape:
		shape.radius = size


func _physics_process(delta):
	position += direction * speed * delta
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()


func _on_body_entered(body: Node2D):
	if body.is_in_group("players") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
