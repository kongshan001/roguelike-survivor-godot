extends Area2D

var xp_value: int = 5
var magnet_speed: float = 300.0
var is_moving_to_player: bool = false
var _player: Node2D = null


func _ready():
	var sprite = $Sprite as ColorRect
	if sprite:
		if xp_value >= 15:
			sprite.color = Color(0.2, 0.4, 1.0)
			sprite.size = Vector2(12, 12)
		elif xp_value >= 10:
			sprite.color = Color.GREEN
			sprite.size = Vector2(10, 10)
		else:
			sprite.color = Color.YELLOW
			sprite.size = Vector2(8, 8)
		sprite.position = -sprite.size / 2.0


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
		magnet_speed += 200.0 * delta
		if dist < 10.0:
			_collect()


func _find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]
	return null


func _collect():
	var xp: float = float(xp_value)
	if SaveManager:
		xp *= (1.0 + SaveManager.get_exp_bonus())
	xp *= GameManager.get_difficulty_mul("exp_mul")
	GameManager.add_xp(xp)
	queue_free()
