extends Node2D
## Beam line effect for thunderbeam evolved weapon.
## Persistent penetrating laser toward the nearest enemy.
## Ticks damage at regular intervals, then chain-lightnings nearby enemies.

# --- Constants ---
const BEAM_VISUAL_WIDTH: float = 2.0
const BEAM_Z_INDEX: int = 5
const SPARK_INTERVAL: float = 0.1
const SPARK_LIFETIME: float = 0.15
const SPARK_COLOR: Color = Color(1.0, 1.0, 1.0)
const SPARK_SIZE: Vector2 = Vector2(2.0, 2.0)
const CHAIN_RANGE: float = 120.0

# --- Configuration (set via setup) ---
var damage: float = 4.0
var beam_range: float = 1200.0
var beam_width: float = 12.0
var tick_interval: float = 0.3
var active_duration: float = 1.0
var chain_count: int = 2
var chain_damage: float = 6.0
var beam_color: Color = Color(1.0, 1.0, 0.4)
var weapon_id: String = ""
var direction: Vector2 = Vector2.RIGHT

# --- Internal state ---
var _elapsed: float = 0.0
var _tick_timer: float = 0.0
var _spark_timer: float = 0.0
var _hit_enemies: Array = []  # Enemies hit during entire beam lifetime
var _beam_visual: ColorRect = null
var _player: CharacterBody2D = null


func setup(dmg: float, rng: float, b_width: float, tick_int: float, act_dur: float, chains: int, ch_dmg: float, col: Color, dir: Vector2, player: CharacterBody2D) -> void:
	damage = dmg
	beam_range = rng
	beam_width = b_width
	tick_interval = tick_int
	active_duration = act_dur
	chain_count = chains
	chain_damage = ch_dmg
	beam_color = col
	direction = dir
	_player = player


func _ready() -> void:
	# Create visual beam line
	_beam_visual = ColorRect.new()
	_beam_visual.color = beam_color
	_beam_visual.size = Vector2(beam_range, BEAM_VISUAL_WIDTH)
	_beam_visual.position = Vector2(0.0, -BEAM_VISUAL_WIDTH * 0.5)
	_beam_visual.z_index = BEAM_Z_INDEX
	add_child(_beam_visual)
	# Rotate toward direction
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	_elapsed += delta
	_tick_timer += delta
	_spark_timer += delta

	# Tick damage
	if _tick_timer >= tick_interval:
		_tick_timer -= tick_interval
		_apply_tick_damage()

	# Spark particles
	if _spark_timer >= SPARK_INTERVAL:
		_spark_timer -= SPARK_INTERVAL
		_spawn_spark()

	# End of beam lifetime
	if _elapsed >= active_duration:
		_apply_chain_lightning()
		queue_free()


func _apply_tick_damage() -> void:
	var all_enemies: Array = GameManager.get_cached_enemies() if GameManager else get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			var to_enemy: Vector2 = enemy.global_position - global_position
			# Project enemy position onto beam direction
			var proj: float = to_enemy.dot(direction)
			if proj < 0.0 or proj > beam_range:
				continue
			# Check perpendicular distance (within beam width)
			var perp_dist: float = absf(to_enemy.cross(direction))
			if perp_dist <= beam_width:
				enemy.take_damage(damage, weapon_id)
				_hit_enemies.append(enemy)


func _spawn_spark() -> void:
	var spark: ColorRect = ColorRect.new()
	spark.size = SPARK_SIZE
	spark.color = SPARK_COLOR
	spark.position = Vector2(randf() * beam_range, randf_range(-BEAM_VISUAL_WIDTH, BEAM_VISUAL_WIDTH))
	add_child(spark)
	var tween: Tween = create_tween()
	tween.tween_property(spark, "modulate:a", 0.0, SPARK_LIFETIME)
	tween.tween_callback(spark.queue_free)


func _apply_chain_lightning() -> void:
	if _hit_enemies.is_empty():
		return
	# Use last hit enemy as chain origin
	var origin_enemy: Node2D = _hit_enemies.back()
	if not is_instance_valid(origin_enemy):
		return

	var chain_targets: Array = []
	var all_enemies: Array = GameManager.get_cached_enemies() if GameManager else get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.is_alive and enemy != origin_enemy:
			var dist: float = origin_enemy.global_position.distance_to(enemy.global_position)
			if dist <= CHAIN_RANGE:
				chain_targets.append(enemy)
	# Sort by distance
	chain_targets.sort_custom(func(a, b):
		return origin_enemy.global_position.distance_to(a.global_position) < origin_enemy.global_position.distance_to(b.global_position)
	)

	for i in range(mini(chain_count, chain_targets.size())):
		var target: Node2D = chain_targets[i]
		target.take_damage(chain_damage, weapon_id)
		# Lightning visual effect
		var parent: Node = get_parent()
		if parent:
			var effects: RefCounted = load("res://scripts/weapons/weapon_effects.gd").new()
			effects.create_lightning_effect(origin_enemy.global_position, target.global_position, beam_color, parent)
