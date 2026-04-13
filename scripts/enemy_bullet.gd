extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 200.0
var damage: float = 1.0
var color: Color = Color.WHITE
var size: float = 4.0
var _lifetime: float = 5.0


func _ready():
	# Set visual
	var sprite: Sprite2D = $Sprite
	if sprite:
		sprite.modulate = color
		if ResourceLoader.exists("res://assets/sprites/weapons/enemy_bullet.png"):
			sprite.texture = load("res://assets/sprites/weapons/enemy_bullet.png")
		var base_size: float = 16.0
		var scale_factor: float = (size * 2.0) / base_size
		sprite.scale = Vector2(scale_factor, scale_factor)
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
