extends Node

# Chest System constants (from design spec, H5 CFG.CHEST)
const CHEST_SPAWN_INTERVAL: float = 90.0
const CHEST_RETRY_INTERVAL: float = 30.0
const CHEST_MAX_CONCURRENT: int = 2
const CHEST_SPAWN_MIN_RANGE: float = 300.0
const CHEST_SPAWN_MAX_RANGE: float = 500.0
const CHEST_COST: int = 20
const ARENA_HALF_SIZE: float = 1500.0

var _spawn_timer: float = CHEST_SPAWN_INTERVAL
var _active_chests: Array[Node2D] = []

var _chest_scene: PackedScene = preload("res://scenes/chest.tscn")


func _process(delta: float) -> void:
	_spawn_timer -= delta

	if _spawn_timer <= 0.0:
		_try_spawn()


func _try_spawn() -> void:
	# Clean up destroyed chests from the tracking array
	_cleanup_invalid_chests()

	if _active_chests.size() >= CHEST_MAX_CONCURRENT:
		_spawn_timer = CHEST_RETRY_INTERVAL
		return

	var player: Node2D = GameManager.find_player()
	if not player:
		_spawn_timer = CHEST_RETRY_INTERVAL
		return

	if GameManager.gold < CHEST_COST:
		_spawn_timer = CHEST_RETRY_INTERVAL
		return

	var spawn_pos: Vector2 = _calculate_spawn_position(player.global_position)
	var chest: Node2D = _chest_scene.instantiate() as Node2D
	chest.global_position = spawn_pos

	# Add as sibling of player (child of Arena)
	var arena: Node = player.get_parent()
	if arena:
		arena.call_deferred("add_child", chest)
	_active_chests.append(chest)

	_spawn_timer = CHEST_SPAWN_INTERVAL


func _calculate_spawn_position(player_pos: Vector2) -> Vector2:
	var angle: float = randf() * TAU
	var dist: float = randf_range(CHEST_SPAWN_MIN_RANGE, CHEST_SPAWN_MAX_RANGE)
	var pos: Vector2 = player_pos + Vector2(cos(angle), sin(angle)) * dist
	return pos.clamp(
		Vector2(-ARENA_HALF_SIZE, -ARENA_HALF_SIZE),
		Vector2(ARENA_HALF_SIZE, ARENA_HALF_SIZE)
	)


func _cleanup_invalid_chests() -> void:
	var valid: Array[Node2D] = []
	for chest in _active_chests:
		if is_instance_valid(chest):
			valid.append(chest)
	_active_chests = valid


func get_active_chest_count() -> int:
	_cleanup_invalid_chests()
	return _active_chests.size()
