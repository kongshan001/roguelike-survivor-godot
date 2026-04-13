extends Area2D

var crate_type: String = ""
var _player: Node2D = null


func _ready():
	var roll = randf()
	if roll < 0.5:
		crate_type = "heal"
		$Sprite.texture = preload("res://assets/sprites/pickups/crate_heal.png")
	elif roll < 0.8:
		crate_type = "xp_bonus"
		$Sprite.texture = preload("res://assets/sprites/pickups/crate_xp.png")
	else:
		crate_type = "speed_boost"
		$Sprite.texture = preload("res://assets/sprites/pickups/crate_speed.png")


func _physics_process(_delta):
	if not _player or not is_instance_valid(_player):
		_player = _find_player()
		if not _player:
			return

	var dist = global_position.distance_to(_player.global_position)
	if dist < 20.0:
		_collect()


func _find_player() -> Node2D:
	return GameManager.find_player()


func _collect():
	match crate_type:
		"heal":
			_player.heal(30.0)
		"xp_bonus":
			GameManager.add_xp(50.0)
		"speed_boost":
			_player.speed_multiplier += 0.3
			get_tree().create_timer(10.0).timeout.connect(func():
				if is_instance_valid(_player):
					_player.speed_multiplier -= 0.3
			)
	queue_free()
