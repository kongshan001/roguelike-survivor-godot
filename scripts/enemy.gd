extends CharacterBody2D

@export var enemy_data: EnemyData

var current_hp: float
var is_alive: bool = true
var _flash_timer: float = 0.0
var _player: Node2D = null


func _ready():
	if enemy_data:
		current_hp = enemy_data.max_hp
		add_to_group("enemies")
		var sprite = $Sprite as ColorRect
		if sprite:
			sprite.color = enemy_data.color
			sprite.size = Vector2(enemy_data.size * 2, enemy_data.size * 2)
			sprite.position = -sprite.size / 2.0
		var shape = $CollisionShape2D.shape as CircleShape2D
		if shape:
			shape.radius = enemy_data.size
		var hitbox_shape = $Hitbox/CollisionShape2D.shape as CircleShape2D
		if hitbox_shape:
			hitbox_shape.radius = enemy_data.size

	var time_bonus = 1.0 + (GameManager.elapsed_time / 60.0) * 0.1
	current_hp *= time_bonus


func _physics_process(delta):
	if not is_alive:
		return

	if not _player or not is_instance_valid(_player):
		_player = _find_player()
		if not _player:
			return

	var direction = global_position.direction_to(_player.global_position)
	velocity = direction * enemy_data.speed
	move_and_slide()

	if _flash_timer > 0:
		_flash_timer -= delta
		var sprite = $Sprite as ColorRect
		if sprite:
			sprite.color = Color.WHITE if fmod(_flash_timer, 0.1) > 0.05 else enemy_data.color


func take_damage(amount: float):
	if not is_alive:
		return
	current_hp -= amount
	_flash_timer = 0.2
	if current_hp <= 0:
		die()


func die():
	is_alive = false
	GameManager.enemies_killed += 1
	GameManager.score += enemy_data.xp_value
	GameManager.enemy_count -= 1
	_spawn_xp_gem()
	if randf() < enemy_data.drop_chance:
		_spawn_item_crate()
	if enemy_data.is_boss:
		for i in range(5):
			_spawn_xp_gem()
	queue_free()


func _find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]
	return null


func _spawn_xp_gem():
	var gem_scene = preload("res://scenes/xp_gem.tscn")
	var gem = gem_scene.instantiate()
	gem.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	gem.xp_value = enemy_data.xp_value
	get_parent().get_node("PickupManager").add_child(gem)


func _spawn_item_crate():
	var crate_scene = preload("res://scenes/item_crate.tscn")
	var crate = crate_scene.instantiate()
	crate.global_position = global_position
	get_parent().get_node("PickupManager").add_child(crate)
