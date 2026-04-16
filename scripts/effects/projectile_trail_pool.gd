extends Node
## Projectile trail afterimage pool.
## Manages a pool of ColorRect nodes used as projectile trail segments.
## Reference: docs/superpowers/specs/projectile-trail-vfx.md

const MAX_TRAIL_SEGMENTS: int = 80
const TRAIL_LIFETIME: float = 0.15

# Trail colors per weapon_id (from projectile-trail-vfx.md Section 5.1)
const TRAIL_COLORS: Dictionary = {
	"knife": Color(0.75, 0.75, 0.8, 0.3),
	"boomerang": Color(0.6, 0.4, 0.2, 0.25),
	"fireknife": Color(1.0, 0.4, 0.1, 0.35),
	"frostknife": Color(0.53, 0.87, 1.0, 0.3),
	"thunderang": Color(1.0, 0.84, 0.0, 0.25),
	"blazerang": Color(1.0, 0.27, 0.0, 0.35),
}

# Trail sizes per weapon_id (from projectile-trail-vfx.md Section 5.2)
const TRAIL_SIZES: Dictionary = {
	"knife": Vector2(5.0, 7.0),
	"boomerang": Vector2(8.0, 8.0),
	"fireknife": Vector2(7.0, 9.0),
	"frostknife": Vector2(7.0, 9.0),
	"thunderang": Vector2(9.0, 9.0),
	"blazerang": Vector2(9.0, 9.0),
}

var _pool: Array[ColorRect] = []
var _active_count: int = 0
var _trails_enabled: bool = true


func _ready() -> void:
	## Pre-warm the pool with hidden ColorRect nodes.
	for i in range(MAX_TRAIL_SEGMENTS):
		var rect: ColorRect = ColorRect.new()
		rect.visible = false
		rect.z_index = 5
		add_child(rect)
		_pool.append(rect)


func spawn(global_pos: Vector2, weapon_id: String, rotation: float) -> void:
	## Spawn a trail segment at the given position for the given weapon.
	if not _trails_enabled:
		return
	var color: Color = TRAIL_COLORS.get(weapon_id, Color(1.0, 1.0, 1.0, 0.2))
	var size: Vector2 = TRAIL_SIZES.get(weapon_id, Vector2(6.0, 6.0))
	var rect: ColorRect = _get_available()
	if not rect:
		return
	rect.visible = true
	rect.size = size
	rect.color = color
	rect.global_position = global_pos - size * 0.5
	rect.rotation = rotation
	_active_count += 1

	# Fade out and return to pool
	var tween: Tween = create_tween()
	tween.tween_property(rect, "color:a", 0.0, TRAIL_LIFETIME)
	# Thunderang: alpha flicker
	if weapon_id == "thunderang":
		_add_thunderang_flicker(tween, rect)
	# Blazerang: scale expansion
	if weapon_id == "blazerang":
		tween.parallel().tween_property(rect, "scale", Vector2(1.2, 1.2), TRAIL_LIFETIME)
	tween.tween_callback(_return_to_pool.bind(rect))


func get_trail_color(weapon_id: String) -> Color:
	## Get the trail color for a weapon. Returns white transparent if unknown.
	return TRAIL_COLORS.get(weapon_id, Color(1.0, 1.0, 1.0, 0.2))


func has_trail(weapon_id: String) -> bool:
	## Check if a weapon should have trail effects.
	return TRAIL_COLORS.has(weapon_id)


func set_trails_enabled(enabled: bool) -> void:
	_trails_enabled = enabled


func get_active_count() -> int:
	return _active_count


func _get_available() -> ColorRect:
	## Find the first invisible ColorRect in the pool.
	for rect: ColorRect in _pool:
		if not rect.visible:
			return rect
	# Pool exhausted -- cull oldest (first visible)
	for rect: ColorRect in _pool:
		if rect.visible:
			_force_return(rect)
			return rect
	return null


func _return_to_pool(rect: ColorRect) -> void:
	## Return a trail segment to the pool after its animation completes.
	if is_instance_valid(rect):
		rect.visible = false
		rect.scale = Vector2.ONE
	_active_count = maxi(0, _active_count - 1)


func _force_return(rect: ColorRect) -> void:
	## Forcefully return a segment to the pool (culling oldest).
	if is_instance_valid(rect):
		rect.visible = false
		rect.scale = Vector2.ONE
	_active_count = maxi(0, _active_count - 1)


func _add_thunderang_flicker(tween: Tween, rect: ColorRect) -> void:
	## Add random alpha flicker for thunderang trail segments.
	var base_alpha: float = rect.color.a
	for i in range(3):
		var flicker: float = base_alpha + randf_range(-0.1, 0.1)
		flicker = clampf(flicker, 0.0, 1.0)
		tween.parallel().tween_property(rect, "color:a", flicker, TRAIL_LIFETIME / 3.0)
