extends Node

## 5-stage wave progression matching H5 WAVE_PROGRESS
## Endless mode: boss every 240s with scaling

var _spawn_timer: float = 0.0
var _boss_spawned: bool = false
var _endless_boss_timer: float = 240.0
var _endless_cycle: int = 0
var _camera: Camera2D = null

# Wave definitions
const WAVE_STAGES: Array = [
	{"time": 0, "enemies": ["zombie"]},
	{"time": 120, "enemies": ["bat"]},
	{"time": 180, "enemies": ["skeleton", "ghost"]},
	{"time": 210, "enemies": ["elite_skeleton", "splitter"]},
	{"time": 270, "enemies": []}  # Boss wave
]

# Enemy data templates (H5 values)
const ENEMY_TEMPLATES: Dictionary = {
	"zombie": {
		"enemy_id": "zombie", "enemy_name": "僵尸",
		"max_hp": 3.0, "speed": 40.0, "damage": 1.0,
		"xp_value": 2, "color": [0.3, 0.69, 0.31], "size": 16.0
	},
	"bat": {
		"enemy_id": "bat", "enemy_name": "蝙蝠",
		"max_hp": 1.0, "speed": 80.0, "damage": 1.0,
		"xp_value": 1, "color": [0.67, 0.28, 0.74], "size": 14.0
	},
	"skeleton": {
		"enemy_id": "skeleton", "enemy_name": "骷髅",
		"max_hp": 5.0, "speed": 20.0, "damage": 1.0,
		"xp_value": 3, "color": [0.88, 0.88, 0.88], "size": 14.0,
		"is_ranged": true, "shoot_cd": 2.0
	},
	"elite_skeleton": {
		"enemy_id": "elite_skeleton", "enemy_name": "精英骷髅",
		"max_hp": 12.0, "speed": 15.0, "damage": 2.0,
		"xp_value": 8, "color": [0.72, 0.11, 0.11], "size": 18.0,
		"is_ranged": true, "shoot_cd": 1.2, "is_elite": true
	},
	"ghost": {
		"enemy_id": "ghost", "enemy_name": "幽灵",
		"max_hp": 2.0, "speed": 55.0, "damage": 1.0,
		"xp_value": 4, "color": [0.69, 0.74, 0.77], "size": 12.0,
		"can_phase_shift": true, "can_teleport": true
	},
	"splitter": {
		"enemy_id": "splitter", "enemy_name": "分裂者",
		"max_hp": 4.0, "speed": 50.0, "damage": 1.0,
		"xp_value": 5, "color": [0.0, 0.54, 0.48], "size": 16.0,
		"is_splitter": true, "split_count": 2
	}
}


func _ready():
	_camera = get_node("/root/Arena/Camera2D")


func _physics_process(delta: float):
	if GameManager.is_game_over:
		return

	GameManager.elapsed_time += delta
	_spawn_timer -= delta

	if _spawn_timer <= 0:
		_spawn_timer = _get_spawn_interval()
		_spawn_wave_enemies()

	# Boss at 270s (normal mode) or endless bosses
	_process_boss_spawn(delta)


func _get_spawn_interval() -> float:
	var base: float
	var t: float = GameManager.elapsed_time
	if t < 30:
		base = 2.0
	elif t < 60:
		base = 1.5
	elif t < 120:
		base = 1.2
	elif t < 180:
		base = 1.0
	else:
		base = 0.8
	return base * GameManager.get_difficulty_mul("spawn_interval_mul")


func _get_spawn_count() -> int:
	var base: int
	var t: float = GameManager.elapsed_time
	if t < 30:
		base = 1
	elif t < 60:
		base = 2
	elif t < 120:
		base = 3
	elif t < 180:
		base = 4
	else:
		base = 5
	return maxi(1, base + GameManager.get_difficulty_count_mod())


func _get_available_types() -> Array:
	var t: float = GameManager.elapsed_time
	var types: Array = ["zombie"]
	if t >= 120:
		types.append("bat")
	if t >= 180:
		types.append_array(["skeleton", "ghost"])
	if t >= 210:
		types.append_array(["elite_skeleton", "splitter"])
	return types


func _spawn_wave_enemies() -> void:
	var count: int = _get_spawn_count()
	var types: Array = _get_available_types()
	var is_endless: bool = GameManager.selected_difficulty == "endless"

	for i in range(count):
		# Endless mode cap
		if is_endless and GameManager.enemy_count >= 100:
			break
		elif GameManager.enemy_count >= 70:
			break

		var type_key: String = types[randi() % types.size()]
		var data: EnemyData = _create_enemy_data(type_key)

		# Apply difficulty multipliers
		data.max_hp *= GameManager.get_difficulty_mul("enemy_hp_mul")
		data.speed *= GameManager.get_difficulty_mul("enemy_speed_mul")
		data.damage *= GameManager.get_difficulty_mul("enemy_dmg_mul")

		# Endless scaling
		if is_endless:
			var minutes: float = GameManager.elapsed_time / 60.0
			data.max_hp *= 1.0 + minutes * 0.1
			data.speed *= 1.0 + minutes * 0.05

		_spawn_enemy(data)


func _process_boss_spawn(delta: float) -> void:
	var is_endless: bool = GameManager.selected_difficulty == "endless"

	# First boss timing scaled by difficulty (hard spawns earlier)
	var boss_time: float = 270.0 * GameManager.get_difficulty_mul("spawn_interval_mul")
	boss_time = clampf(boss_time, 120.0, 300.0)
	if not _boss_spawned and GameManager.elapsed_time >= boss_time:
		_boss_spawned = true
		_spawn_boss(1.0)
		if is_endless:
			_endless_boss_timer = 240.0
		return

	# Endless mode: boss every 240s
	if is_endless and _boss_spawned:
		_endless_boss_timer -= delta
		if _endless_boss_timer <= 0:
			_endless_cycle += 1
			_endless_boss_timer = 240.0
			var hp_scale: float = pow(1.5, _endless_cycle)
			var spd_scale: float = pow(1.1, _endless_cycle)
			_spawn_boss(hp_scale, spd_scale)


func _spawn_boss(hp_scale: float = 1.0, spd_scale: float = 1.0) -> void:
	var data: EnemyData = EnemyData.new()
	data.enemy_id = "boss"
	data.enemy_name = "Boss"
	data.max_hp = 200.0 * hp_scale * GameManager.get_difficulty_mul("boss_hp_mul")
	data.speed = 30.0 * spd_scale * GameManager.get_difficulty_mul("boss_speed_mul")
	data.damage = 2.0 * GameManager.get_difficulty_mul("enemy_dmg_mul")
	data.xp_value = 100
	data.color = Color(0.96, 0.26, 0.21)
	data.size = 32.0
	data.is_boss = true
	data.drop_chance = 1.0
	_spawn_enemy(data)


func _create_enemy_data(type_key: String) -> EnemyData:
	var template: Dictionary = ENEMY_TEMPLATES.get(type_key, ENEMY_TEMPLATES["zombie"])
	var data: EnemyData = EnemyData.new()
	data.enemy_id = template.get("enemy_id", "")
	data.enemy_name = template.get("enemy_name", "Enemy")
	data.max_hp = template.get("max_hp", 20.0)
	data.speed = template.get("speed", 60.0)
	data.damage = template.get("damage", 10.0)
	data.xp_value = template.get("xp_value", 5)
	data.color = Color(
		template.get("color", [0.0, 1.0, 0.0])[0],
		template.get("color", [0.0, 1.0, 0.0])[1],
		template.get("color", [0.0, 1.0, 0.0])[2]
	)
	data.size = template.get("size", 16.0)
	data.is_ranged = template.get("is_ranged", false)
	data.shoot_cd = template.get("shoot_cd", 2.0)
	data.is_elite = template.get("is_elite", false)
	data.can_phase_shift = template.get("can_phase_shift", false)
	data.can_teleport = template.get("can_teleport", false)
	data.is_splitter = template.get("is_splitter", false)
	data.split_count = template.get("split_count", 2)
	data.is_child = template.get("is_child", false)
	data.drop_chance = 0.1
	return data


func _spawn_enemy(data: EnemyData) -> void:
	var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
	var enemy: CharacterBody2D = enemy_scene.instantiate()
	enemy.enemy_data = data
	var spawn_pos: Vector2 = _get_spawn_position()
	enemy.global_position = spawn_pos
	get_parent().add_child(enemy)
	GameManager.enemy_count += 1


func _get_spawn_position() -> Vector2:
	var camera: Camera2D = _camera
	if not camera:
		return Vector2(randf_range(-500, 500), randf_range(-500, 500))

	var viewport_size: Vector2 = camera.get_viewport().get_visible_rect().size
	var cam_pos: Vector2 = camera.global_position
	var margin: float = 50.0
	var edge: int = randi() % 4
	var pos: Vector2 = cam_pos
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
