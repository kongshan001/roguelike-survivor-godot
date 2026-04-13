extends Area2D
## Food pickup — heals 1 HP on contact with player

var heal_amount: int = 1
var magnet_speed: float = 200.0
var is_moving_to_player: bool = false
var _player: Node2D = null


func _ready():
	body_entered.connect(_on_body_entered)


func _physics_process(delta):
	if not _player or not is_instance_valid(_player):
		_player = _find_player()
		if not _player:
			return

	var dist = global_position.distance_to(_player.global_position)
	if dist <= _player.pickup_range:
		is_moving_to_player = true

	if is_moving_to_player:
		var direction = global_position.direction_to(_player.global_position)
		global_position += direction * magnet_speed * delta
		magnet_speed += 150.0 * delta
		if dist < 10.0:
			_collect()


func _find_player() -> Node2D:
	return GameManager.find_player()


func _on_body_entered(body: Node2D):
	if body.is_in_group("players") and body.is_alive:
		_collect()


func _collect():
	if _player and is_instance_valid(_player) and _player.is_alive:
		_player.heal(float(heal_amount))
	queue_free()
