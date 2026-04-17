extends Node2D
## Pulse ring effect for holyshockwave evolved weapon.
## Expanding damage ring centered on the player. Damages and burns enemies it passes through.
## Auto-destroys after expansion completes.

# --- Constants ---
const RING_SEGMENTS: int = 16
const SEGMENT_SIZE: Vector2 = Vector2(2.0, 2.0)

# --- Configuration (set via setup) ---
var damage: float = 12.0
var max_radius: float = 200.0
var expand_time: float = 0.3
var ring_width: float = 12.0
var burn_dps: float = 0.0
var burn_duration: float = 0.0
var center_color: Color = Color(1.0, 0.85, 0.3)
var edge_color: Color = Color(1.0, 0.4, 0.1)
var weapon_id: String = ""

# --- Internal state ---
var _current_radius: float = 0.0
var _hit_enemies: Dictionary = {}  # enemy -> bool (already hit)
var _elapsed: float = 0.0
var _segments: Array = []


func setup(dmg: float, r_max: float, exp_time: float, r_width: float, col: Color, b_dps: float, b_dur: float) -> void:
	damage = dmg
	max_radius = r_max
	expand_time = exp_time
	ring_width = r_width
	center_color = col
	burn_dps = b_dps
	burn_duration = b_dur


func _ready() -> void:
	_create_visual_segments()


func _create_visual_segments() -> void:
	for i in range(RING_SEGMENTS):
		var seg: ColorRect = ColorRect.new()
		seg.size = SEGMENT_SIZE
		seg.color = center_color
		add_child(seg)
		_segments.append(seg)


func _physics_process(delta: float) -> void:
	_elapsed += delta
	var t: float = minf(_elapsed / expand_time, 1.0)
	_current_radius = max_radius * t

	# Reposition ring segments
	for i in range(RING_SEGMENTS):
		var angle: float = TAU * i / RING_SEGMENTS
		var pos: Vector2 = Vector2(cos(angle), sin(angle)) * _current_radius
		_segments[i].position = pos - SEGMENT_SIZE * 0.5
		# Lerp color from center to edge
		_segments[i].color = center_color.lerp(edge_color, t)

	# Collision detection
	var all_enemies: Array = GameManager.get_cached_enemies() if GameManager else get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.is_alive and not _hit_enemies.has(enemy):
			var dist: float = global_position.distance_to(enemy.global_position)
			# Check if enemy is within the ring band (between current_radius - ring_width and current_radius)
			if dist <= _current_radius and dist >= maxf(0.0, _current_radius - ring_width):
				enemy.take_damage(damage, weapon_id)
				if burn_dps > 0.0 and enemy.has_method("apply_burn"):
					enemy.apply_burn(burn_dps, burn_duration)
				_hit_enemies[enemy] = true

	# Auto-destroy after expansion completes
	if t >= 1.0:
		queue_free()
