extends Node

var _spawn_timer: float = 0.0
var _boss_timer: float = 60.0
var _camera: Camera2D = null


func _ready():
	_camera = get_node("/root/Arena/Camera2D")


func _physics_process(delta):
	if GameManager.is_game_over:
		return

	GameManager.elapsed_time += delta
	_spawn_timer -= delta
	_boss_timer -= delta

	if _spawn_timer <= 0:
		var spawn_count = _get_spawn_count()
		var spawn_interval = _get_spawn_interval()
		_spawn_timer = spawn_interval
		for i in range(spawn_count):
			_spawn_enemy(_get_random_enemy_data())

	if _boss_timer <= 0:
		_boss_timer = 60.0
		_spawn_boss()


func _get_spawn_interval() -> float:
	var t = GameManager.elapsed_time
	if t < 30:
		return 2.0
	elif t < 60:
		return 1.5
	elif t < 120:
		return 1.2
	else:
		return 0.8


func _get_spawn_count() -> int:
	var t = GameManager.elapsed_time
	if t < 30:
		return 1
	elif t < 60:
		return 2
	elif t < 120:
		return 3
	else:
		return 4


func _get_random_enemy_data() -> EnemyData:
	var t = GameManager.elapsed_time
	var data = EnemyData.new()
	var roll = randf()
	if t < 30:
		data.enemy_name = "Slime"
		data.max_hp = 20.0
		data.speed = 60.0
		data.damage = 10.0
		data.xp_value = 5
		data.color = Color.GREEN
		data.size = 16.0
	elif t < 60:
		if roll < 0.6:
			data.enemy_name = "Slime"
			data.max_hp = 25.0
			data.speed = 65.0
			data.damage = 12.0
			data.xp_value = 6
			data.color = Color.GREEN
			data.size = 16.0
		else:
			data.enemy_name = "Bat"
			data.max_hp = 10.0
			data.speed = 120.0
			data.damage = 5.0
			data.xp_value = 3
			data.color = Color(0.6, 0.3, 0.8)
			data.size = 10.0
	else:
		if roll < 0.4:
			data.enemy_name = "Slime"
			data.max_hp = 30.0
			data.speed = 70.0
			data.damage = 14.0
			data.xp_value = 7
			data.color = Color.GREEN
			data.size = 16.0
		elif roll < 0.7:
			data.enemy_name = "Bat"
			data.max_hp = 15.0
			data.speed = 130.0
			data.damage = 7.0
			data.xp_value = 4
			data.color = Color(0.6, 0.3, 0.8)
			data.size = 10.0
		else:
			data.enemy_name = "Golem"
			data.max_hp = 80.0
			data.speed = 30.0
			data.damage = 25.0
			data.xp_value = 15
			data.color = Color(0.6, 0.4, 0.2)
			data.size = 24.0
	data.drop_chance = 0.1
	return data


func _spawn_boss():
	var data = EnemyData.new()
	data.enemy_name = "Boss"
	data.max_hp = 500.0
	data.speed = 40.0
	data.damage = 40.0
	data.xp_value = 100
	data.color = Color(0.9, 0.1, 0.1)
	data.size = 32.0
	data.is_boss = true
	data.drop_chance = 1.0
	_spawn_enemy(data)


func _spawn_enemy(data: EnemyData):
	var enemy_scene = preload("res://scenes/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.enemy_data = data
	var spawn_pos = _get_spawn_position()
	enemy.global_position = spawn_pos
	get_parent().add_child(enemy)
	GameManager.enemy_count += 1


func _get_spawn_position() -> Vector2:
	var camera: Camera2D = _camera
	if not camera:
		return Vector2(randf_range(-500, 500), randf_range(-500, 500))

	var viewport_size = camera.get_viewport().get_visible_rect().size
	var cam_pos = camera.global_position
	var margin = 50.0
	var edge = randi() % 4
	var pos = cam_pos
	match edge:
		0:
			pos = Vector2(cam_pos.x + randf_range(-viewport_size.x, viewport_size.x), cam_pos.y - viewport_size.y / 2 - margin)
		1:
			pos = Vector2(cam_pos.x + randf_range(-viewport_size.x, viewport_size.x), cam_pos.y + viewport_size.y / 2 + margin)
		2:
			pos = Vector2(cam_pos.x - viewport_size.x / 2 - margin, cam_pos.y + randf_range(-viewport_size.y, viewport_size.y))
		3:
			pos = Vector2(cam_pos.x + viewport_size.x / 2 + margin, cam_pos.y + randf_range(-viewport_size.y, viewport_size.y))
	pos = pos.clamp(Vector2(-1500, -1500), Vector2(1500, 1500))
	return pos
