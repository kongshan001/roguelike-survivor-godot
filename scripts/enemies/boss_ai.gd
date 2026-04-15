extends RefCounted
## Boss 三阶段 AI 逻辑，从 enemy.gd 中抽离以控制文件规模
## 使用 load("res://scripts/enemies/boss_ai.gd").new() 实例化，不用 class_name

var _phase: int = 1
var _charge_timer: float = 0.0
var _charge_cooldown: float = 4.0
var _is_charging: bool = false
var _charge_duration: float = 0.8
var _charge_speed_mult: float = 3.0
var _spiral_timer: float = 0.0
var _spiral_cd: float = 1.5
var _spiral_angle: float = 0.0
var _bullet_count_spiral: int = 16
var _bullet_count_burst: int = 8


func get_phase() -> int:
	return _phase


func is_charging() -> bool:
	return _is_charging


func update_phase(current_hp: float, max_hp: float) -> void:
	if _phase == 1 and current_hp <= max_hp * 0.66:
		_phase = 2
	elif _phase == 2 and current_hp <= max_hp * 0.33:
		_phase = 3


func process(delta: float, enemy: CharacterBody2D, player: Node2D) -> float:
	## Returns speed multiplier for this frame
	if not player or not is_instance_valid(player):
		return 1.0

	match _phase:
		1:
			return 1.0
		2:
			return _process_phase2(delta, enemy, player)
		3:
			return _process_phase3(delta, enemy, player)
	return 1.0


func _process_phase2(delta: float, enemy: CharacterBody2D, player: Node2D) -> float:
	if _is_charging:
		_charge_timer -= delta
		if _charge_timer <= 0:
			_is_charging = false
			_fire_burst(enemy, player)
		return _charge_speed_mult

	_charge_timer -= delta
	if _charge_timer <= 0:
		_is_charging = true
		_charge_timer = _charge_duration
		_charge_cooldown = 4.0
	_charge_cooldown -= delta
	return 1.0


func _process_phase3(delta: float, enemy: CharacterBody2D, player: Node2D) -> float:
	_spiral_timer -= delta
	if _spiral_timer <= 0:
		_spiral_timer = _spiral_cd
		_fire_spiral(enemy)
	return 1.5  # 50% speed boost


func _fire_burst(enemy: CharacterBody2D, _player: Node2D) -> void:
	for i in range(_bullet_count_burst):
		var angle: float = (TAU * i) / _bullet_count_burst
		_spawn_bullet(enemy, angle)


func _fire_spiral(enemy: CharacterBody2D) -> void:
	for i in range(_bullet_count_spiral):
		var angle: float = _spiral_angle + (TAU * i) / _bullet_count_spiral
		_spawn_bullet(enemy, angle)
	_spiral_angle += 0.5


func _spawn_bullet(enemy: CharacterBody2D, angle: float) -> void:
	var bullet_scene: PackedScene = preload("res://scenes/enemy_bullet.tscn")
	var bullet: Area2D = bullet_scene.instantiate()
	bullet.direction = Vector2(cos(angle), sin(angle))
	bullet.speed = 200.0
	bullet.damage = enemy.enemy_data.damage
	bullet.color = Color(1.0, 0.3, 0.2)
	bullet.size = 5.0
	bullet.global_position = enemy.global_position
	enemy.get_parent().call_deferred("add_child", bullet)
