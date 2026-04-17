extends RefCounted
## Hit feedback system -- particles and damage numbers on enemy hit.
## RefCounted module instantiated lazily by enemy.gd.
## Reference: docs/superpowers/specs/hit-feedback-design.md

# --- Pool limits ---
const MAX_PARTICLES: int = 60
const MAX_DAMAGE_NUMBERS: int = 20

# --- Particle constants ---
const PARTICLE_SIZE: Vector2 = Vector2(2.0, 2.0)
const PARTICLE_COUNT_NORMAL: int = 3
const PARTICLE_COUNT_CRIT: int = 5
const PARTICLE_LIFETIME_NORMAL: float = 0.15
const PARTICLE_LIFETIME_CRIT: float = 0.2
const PARTICLE_SPEED_MIN: float = 40.0
const PARTICLE_SPEED_MAX: float = 60.0
const PARTICLE_SPEED_CRIT_MIN: float = 60.0
const PARTICLE_SPEED_CRIT_MAX: float = 80.0

# --- Damage number constants ---
const DMG_FONT_SIZE_NORMAL: int = 10
const DMG_FONT_SIZE_CRIT: int = 14
const DMG_COLOR_NORMAL: Color = Color(1.0, 1.0, 1.0)
const DMG_COLOR_CRIT: Color = Color(1.0, 0.84, 0.0)
const DMG_DRIFT_DISTANCE: float = 30.0
const DMG_DRIFT_DURATION: float = 0.6
const DMG_FADE_START: float = 0.4
const DMG_FADE_DURATION: float = 0.2
const DMG_X_OFFSET: float = 4.0
const DMG_Y_OFFSET: float = 8.0

# --- Crit shake constants ---
const CRIT_SHAKE_PIXELS: float = 2.0
const CRIT_SHAKE_STEP: float = 0.03
const CRIT_SHAKE_SETTLE: float = 0.15

# --- Weapon particle colors ---
const WEAPON_COLORS: Dictionary = {
	"knife": Color(0.75, 0.75, 0.8),
	"holywater": Color(0.3, 0.5, 1.0),
	"lightning": Color(1.0, 1.0, 0.3),
	"bible": Color(0.9, 0.85, 0.7),
	"firestaff": Color(1.0, 0.4, 0.1),
	"frostaura": Color(0.5, 0.8, 1.0),
	"boomerang": Color(0.6, 0.4, 0.2),
	# Evolved -- gold placeholder per spec Section 6.3
	"fireknife": Color(1.0, 0.84, 0.0),
	"frostknife": Color(1.0, 0.84, 0.0),
	"thunderang": Color(1.0, 0.84, 0.0),
	"blazerang": Color(1.0, 0.84, 0.0),
	"thunderholywater": Color(1.0, 0.84, 0.0),
	"holydomain": Color(1.0, 0.84, 0.0),
	"blizzard": Color(1.0, 0.84, 0.0),
	"flamebible": Color(1.0, 0.84, 0.0),
	"sentineltotem": Color(1.0, 0.84, 0.0),
	"frostvortex": Color(0.3, 0.7, 1.0),
	"holyshockwave": Color(1.0, 0.85, 0.3),
	"thunderbeam": Color(1.0, 1.0, 0.4),
}

# --- Rate limiting ---
const RATE_LIMIT_DEFAULT: float = 0.1
const RATE_LIMIT_SLOW: float = 0.15
const RATE_LIMIT_WEAPON_TYPES: Dictionary = {
	"holywater": RATE_LIMIT_SLOW,
	"bible": RATE_LIMIT_SLOW,
	"frostaura": RATE_LIMIT_SLOW,
}

# --- Pools (lazy-created ColorRect / Label nodes) ---
var _particle_pool: Array = []
var _number_pool: Array = []
var _active_particles: int = 0
var _active_numbers: int = 0
var _last_feedback_time: Dictionary = {}  # weapon_id -> float


func spawn(enemy: CharacterBody2D, amount: float, source: String, was_crit: bool) -> void:
	## Main entry point: spawn hit particles and damage number for a hit.
	var arena: Node2D = _get_arena(enemy)
	if not arena:
		return

	var now: float = GameManager.elapsed_time if GameManager else 0.0
	# Rate limit per weapon
	var rate: float = RATE_LIMIT_WEAPON_TYPES.get(source, RATE_LIMIT_DEFAULT)
	if source == "lightning":
		rate = 0.0  # No rate limit for lightning
	var last_time: float = _last_feedback_time.get(source, -1.0)
	if now - last_time < rate:
		return
	_last_feedback_time[source] = now

	_spawn_particles(arena, enemy.global_position, source, was_crit)
	_spawn_damage_number(arena, enemy.global_position, amount, was_crit)


func _spawn_particles(arena: Node2D, pos: Vector2, source: String, was_crit: bool) -> void:
	## Spawn hit particle burst at the given position.
	var count: int = PARTICLE_COUNT_CRIT if was_crit else PARTICLE_COUNT_NORMAL
	var lifetime: float = PARTICLE_LIFETIME_CRIT if was_crit else PARTICLE_LIFETIME_NORMAL
	var color: Color = DMG_COLOR_CRIT if was_crit else WEAPON_COLORS.get(source, Color.WHITE)
	var speed_min: float = PARTICLE_SPEED_CRIT_MIN if was_crit else PARTICLE_SPEED_MIN
	var speed_max: float = PARTICLE_SPEED_CRIT_MAX if was_crit else PARTICLE_SPEED_MAX

	for i in range(count):
		if _active_particles >= MAX_PARTICLES:
			break
		var rect: ColorRect = _get_particle(arena)
		if not rect:
			break
		rect.visible = true
		rect.size = PARTICLE_SIZE
		rect.color = color
		rect.global_position = pos - PARTICLE_SIZE * 0.5
		_active_particles += 1

		var angle: float = randf() * TAU
		var speed: float = randf_range(speed_min, speed_max)
		var vel: Vector2 = Vector2(cos(angle), sin(angle)) * speed * lifetime
		var target_pos: Vector2 = rect.global_position + vel

		var tween: Tween = arena.create_tween()
		tween.tween_property(rect, "global_position", target_pos, lifetime)
		tween.parallel().tween_property(rect, "color:a", 0.0, lifetime)
		tween.tween_callback(_return_particle.bind(rect))


func _spawn_damage_number(arena: Node2D, pos: Vector2, amount: float, was_crit: bool) -> void:
	## Spawn a floating damage number at the given position.
	# Crit numbers have priority -- if pool exhausted and this is normal, skip
	if _active_numbers >= MAX_DAMAGE_NUMBERS:
		if not was_crit:
			return
		# For crit, still try (pool returns null if truly exhausted)
	var label: Label = _get_number(arena)
	if not label:
		return
	label.visible = true
	label.text = str(int(roundf(amount)))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font_size: int = DMG_FONT_SIZE_CRIT if was_crit else DMG_FONT_SIZE_NORMAL
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = DMG_COLOR_CRIT if was_crit else DMG_COLOR_NORMAL
	label.global_position = pos + Vector2(randf_range(-DMG_X_OFFSET, DMG_X_OFFSET), -DMG_Y_OFFSET)
	_active_numbers += 1

	if was_crit:
		_animate_crit_number(arena, label)
	else:
		_animate_normal_number(arena, label)


func _animate_normal_number(arena: Node2D, label: Label) -> void:
	## Animate a normal damage number: drift up and fade out.
	var start_pos: Vector2 = label.global_position
	var end_pos: Vector2 = start_pos + Vector2(0.0, -DMG_DRIFT_DISTANCE)
	var t: Tween = arena.create_tween()
	t.tween_property(label, "global_position", end_pos, DMG_DRIFT_DURATION)
	t.parallel().tween_method(_set_label_alpha.bind(label), 1.0, DMG_FADE_START, DMG_DRIFT_DURATION - DMG_FADE_DURATION)
	t.tween_property(label, "modulate:a", 0.0, DMG_FADE_DURATION)
	t.tween_callback(_return_number.bind(label))


func _animate_crit_number(arena: Node2D, label: Label) -> void:
	## Animate a crit damage number: shake then drift up and fade out.
	var base_x: float = label.global_position.x
	var settle_y: float = label.global_position.y

	# Shake phase (0.15s)
	var shake: Tween = arena.create_tween()
	for i in range(3):
		var offset: float = CRIT_SHAKE_PIXELS if i % 2 == 0 else -CRIT_SHAKE_PIXELS
		shake.tween_property(label, "global_position:x", base_x + offset, CRIT_SHAKE_STEP)
	shake.tween_property(label, "global_position:x", base_x, 0.03)

	# Drift + fade phase
	var end_pos: Vector2 = Vector2(base_x, settle_y - DMG_DRIFT_DISTANCE)
	var drift: Tween = arena.create_tween()
	drift.tween_property(label, "global_position", end_pos, DMG_DRIFT_DURATION).set_delay(CRIT_SHAKE_SETTLE)
	drift.parallel().tween_property(label, "modulate:a", 0.0, DMG_FADE_DURATION).set_delay(CRIT_SHAKE_SETTLE + DMG_DRIFT_DURATION - DMG_FADE_DURATION)
	drift.tween_callback(_return_number.bind(label))


func _set_label_alpha(value: float, label: Label) -> void:
	## Helper for Tween method callback to set label alpha.
	if is_instance_valid(label):
		var c: Color = label.modulate
		c.a = value
		label.modulate = c


# --- Pool management ---

func _get_particle(arena: Node2D) -> ColorRect:
	## Get a ColorRect from the particle pool (lazy create up to MAX_PARTICLES).
	for rect: ColorRect in _particle_pool:
		if not rect.visible:
			return rect
	if _particle_pool.size() < MAX_PARTICLES:
		var rect: ColorRect = ColorRect.new()
		rect.visible = false
		rect.z_index = 10
		arena.call_deferred("add_child", rect)
		_particle_pool.append(rect)
		return rect
	return null


func _get_number(arena: Node2D) -> Label:
	## Get a Label from the damage number pool (lazy create up to MAX_DAMAGE_NUMBERS).
	for label: Label in _number_pool:
		if not label.visible:
			return label
	if _number_pool.size() < MAX_DAMAGE_NUMBERS:
		var label: Label = Label.new()
		label.visible = false
		label.z_index = 11
		arena.call_deferred("add_child", label)
		_number_pool.append(label)
		return label
	return null


func _return_particle(rect: ColorRect) -> void:
	## Return a particle to the pool.
	if is_instance_valid(rect):
		rect.visible = false
	_active_particles = maxi(0, _active_particles - 1)


func _return_number(label: Label) -> void:
	## Return a damage number to the pool.
	if is_instance_valid(label):
		label.visible = false
	_active_numbers = maxi(0, _active_numbers - 1)


# --- Utility ---

func _get_arena(enemy: CharacterBody2D) -> Node2D:
	## Walk up from enemy to find the arena (parent Node2D).
	var parent: Node = enemy.get_parent()
	if parent and parent is Node2D:
		return parent as Node2D
	return null
