extends Node2D
## Spiral blade effect for frostvortex evolved weapon.
## Six ice blades spiral outward from the player in an expanding vortex pattern.
## Continuously active; follows the player position.

# --- Constants ---
const ROTATION_SPEED: float = 4.0
const HIT_COOLDOWN: float = 0.5
const SYNERGY_ACCEL_MUL: float = 1.5
const SYNERGY_ACCEL_DUR: float = 0.5
const BLADE_WIDTH: float = 5.0
const BLADE_HEIGHT: float = 12.0

# --- Configuration (set via setup) ---
var blade_count: int = 6
var damage: float = 3.0
var min_radius: float = 20.0
var max_radius: float = 180.0
var expand_speed: float = 60.0
var blade_color: Color = Color(0.3, 0.7, 1.0)
var slow_pct: float = 0.0
var freeze_pct: float = 0.0
var weapon_id: String = ""

# --- Internal state ---
var _angle: float = 0.0
var _current_radius: float = 20.0
var _hit_cooldowns: Dictionary = {}  # enemy -> float (time remaining)
var _accel_timer: float = 0.0


func setup(count: int, dmg: float, r_min: float, r_max: float, expand_spd: float, col: Color, slow: float, freeze: float) -> void:
	blade_count = count
	damage = dmg
	min_radius = r_min
	max_radius = r_max
	expand_speed = expand_spd
	blade_color = col
	slow_pct = slow
	freeze_pct = freeze
	_current_radius = r_min


func _physics_process(delta: float) -> void:
	# Rotate blades
	_angle += ROTATION_SPEED * delta

	# Expand radius with synergy acceleration
	var effective_expand: float = expand_speed
	if _accel_timer > 0.0:
		effective_expand *= SYNERGY_ACCEL_MUL
		_accel_timer -= delta

	if _current_radius < max_radius:
		_current_radius += effective_expand * delta
	else:
		_current_radius = min_radius  # Reset cycle

	# Decay hit cooldowns
	var to_remove: Array = []
	for enemy in _hit_cooldowns:
		_hit_cooldowns[enemy] -= delta
		if _hit_cooldowns[enemy] <= 0.0:
			to_remove.append(enemy)
	for e in to_remove:
		_hit_cooldowns.erase(e)

	# Collision detection: check each blade against enemies
	var all_enemies: Array = GameManager.get_cached_enemies() if GameManager else get_tree().get_nodes_in_group("enemies")
	for i in range(blade_count):
		var blade_angle: float = _angle + (TAU * i / blade_count)
		var blade_pos: Vector2 = Vector2(cos(blade_angle), sin(blade_angle)) * _current_radius
		for enemy in all_enemies:
			if is_instance_valid(enemy) and enemy.is_alive and not _hit_cooldowns.has(enemy):
				var dist: float = blade_pos.distance_to(enemy.global_position - global_position)
				if dist < BLADE_HEIGHT + 10.0:
					enemy.take_damage(damage, weapon_id)
					_hit_cooldowns[enemy] = HIT_COOLDOWN
					# Apply slow
					if slow_pct > 0.0 and enemy.has_method("apply_slow"):
						enemy.apply_slow(slow_pct)
					# Apply freeze
					if freeze_pct > 0.0 and enemy.has_method("apply_freeze"):
						enemy.apply_freeze(freeze_pct * delta)
						# Frostbite Loop synergy: accelerate blades on freeze
						_accel_timer = SYNERGY_ACCEL_DUR

	queue_redraw()


func _draw() -> void:
	for i in range(blade_count):
		var blade_angle: float = _angle + (TAU * i / blade_count)
		var pos: Vector2 = Vector2(cos(blade_angle), sin(blade_angle)) * _current_radius
		draw_set_transform(pos, blade_angle, Vector2.ONE)
		draw_rect(Rect2(-BLADE_WIDTH * 0.5, -BLADE_HEIGHT * 0.5, BLADE_WIDTH, BLADE_HEIGHT), blade_color)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
