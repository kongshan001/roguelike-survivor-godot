extends RefCounted
## Enemy death/hit animation effects module.
## Provides Tween-based death animations per enemy_id and hit feedback.
## Extracted from enemy.gd to keep it under 500 lines.
## Reference: docs/superpowers/specs/enemy-animation-spec.md

# --- Hit feedback constants ---
const HIT_FLASH_COLOR: Color = Color(8, 8, 8)
const HIT_FLASH_DURATION: float = 0.1
const SHAKE_STRENGTH: float = 2.0
const SHAKE_STEP_DURATION: float = 0.03
const SHAKE_RETURN_DURATION: float = 0.02

# --- Elite hit feedback durations ---
const ELITE_SKELETON_RED_LINGER: float = 0.08
const ELITE_SKELETON_RECOVER: float = 0.07
const ELITE_KNIGHT_PURPLE_LINGER: float = 0.1
const ELITE_KNIGHT_RECOVER: float = 0.1


func play_hit_feedback(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Play the hit flash + knockback shake on the sprite.
	## Called from enemy.gd take_damage() after damage is applied.
	if not sprite or not is_instance_valid(sprite):
		return

	# HDR white flash
	sprite.modulate = HIT_FLASH_COLOR
	var flash_tween: Tween = enemy.create_tween()
	flash_tween.tween_property(sprite, "modulate", Color.WHITE, HIT_FLASH_DURATION)

	# Knockback shake on sprite position (local offset)
	# Use absolute values since PropertyTweener has no set_relative in Godot 4.x
	var base_pos: Vector2 = sprite.position
	var shake_str: float = SHAKE_STRENGTH
	# Elite enemies have 50% knockback resistance
	if enemy.enemy_data and enemy.enemy_data.is_elite:
		shake_str *= 0.5
	var shake_dir := Vector2(shake_str if randi() % 2 == 0 else -shake_str, 0.0)
	var shake_tween: Tween = enemy.create_tween()
	shake_tween.tween_property(sprite, "position", base_pos + shake_dir, SHAKE_STEP_DURATION)
	shake_tween.tween_property(sprite, "position", base_pos - shake_dir * 0.5, SHAKE_STEP_DURATION)
	shake_tween.tween_property(sprite, "position", base_pos, SHAKE_RETURN_DURATION)

	# Elite-specific lingering color
	if enemy.enemy_data:
		var eid: String = enemy.enemy_data.enemy_id
		if eid == "elite_skeleton":
			_play_elite_skeleton_hit(enemy, sprite)
		elif eid == "elite_knight":
			_play_elite_knight_hit(enemy, sprite)


func _play_elite_skeleton_hit(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	var t: Tween = enemy.create_tween()
	t.tween_property(sprite, "modulate", Color(1.5, 0.8, 0.7), ELITE_SKELETON_RED_LINGER)
	t.tween_property(sprite, "modulate", Color.WHITE, ELITE_SKELETON_RECOVER)


func _play_elite_knight_hit(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	var t: Tween = enemy.create_tween()
	t.tween_property(sprite, "modulate", Color(1.5, 0.6, 2.0), ELITE_KNIGHT_PURPLE_LINGER)
	t.tween_property(sprite, "modulate", Color.WHITE, ELITE_KNIGHT_RECOVER)


# --- Death animation dispatch ---

func play_death_animation(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Play the appropriate death animation based on enemy_id.
	## Called from enemy.gd die() before queue_free().
	if not sprite or not is_instance_valid(sprite):
		return
	if not enemy.enemy_data:
		_play_default_death(enemy, sprite)
		return

	var eid: String = enemy.enemy_data.enemy_id
	match eid:
		"zombie":
			_play_zombie_death(enemy, sprite)
		"bat":
			_play_bat_death(enemy, sprite)
		"skeleton":
			_play_skeleton_death(enemy, sprite)
		"elite_skeleton":
			_play_elite_skeleton_death(enemy, sprite)
		"ghost":
			_play_ghost_death(enemy, sprite)
		"splitter":
			_play_splitter_death(enemy, sprite)
		"splitter_small":
			_play_splitter_small_death(enemy, sprite)
		"fire_slime":
			_play_fire_slime_death(enemy, sprite)
		"elite_knight":
			_play_elite_knight_death(enemy, sprite)
		"boss":
			_play_boss_death(enemy, sprite)
		_:
			_play_default_death(enemy, sprite)


func get_death_duration(enemy_id: String) -> float:
	## Returns the maximum duration of the death animation for a given enemy_id.
	## Used by enemy.gd to schedule queue_free() after the animation completes.
	match enemy_id:
		"boss":
			return 0.85
		"elite_skeleton":
			return 0.45
		"elite_knight":
			return 0.55
		"ghost":
			return 0.4
		"zombie":
			return 0.45
		"bat":
			return 0.3
		"skeleton":
			return 0.45
		"splitter":
			return 0.25
		"fire_slime":
			return 0.4
		_:
			return 0.2


func _play_default_death(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	var t: Tween = enemy.create_tween()
	t.tween_property(sprite, "scale", Vector2.ZERO, 0.15).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "modulate:a", 0.0, 0.15).set_ease(Tween.EASE_IN)


# --- Individual death animations ---

func _play_zombie_death(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Zombie: darken -> flatten -> fade out
	var t: Tween = enemy.create_tween()
	# Darken to brown
	t.tween_property(sprite, "modulate", Color(0.3, 0.2, 0.1), 0.15)
	# Flatten + fade
	t.tween_property(sprite, "scale", Vector2(1.3, 0.3), 0.3).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN)


func _play_bat_death(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Bat: spin + shrink + fall down + fade
	var base_y: float = sprite.position.y
	var t: Tween = enemy.create_tween()
	t.tween_property(sprite, "scale", Vector2(0.3, 0.3), 0.25).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "rotation", TAU, 0.25)
	t.parallel().tween_property(sprite, "position:y", base_y + 8.0, 0.25).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN).set_delay(0.05)


func _play_skeleton_death(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Skeleton: compress + gray + drop + fade
	var base_y: float = sprite.position.y
	var t: Tween = enemy.create_tween()
	# Gray
	t.tween_property(sprite, "modulate", Color(0.5, 0.5, 0.5), 0.15)
	# Compress vertically + drop
	t.tween_property(sprite, "scale", Vector2(1.2, 0.5), 0.2).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "position:y", base_y + 5.0, 0.2).set_ease(Tween.EASE_IN)
	# Fade out (delayed)
	t.tween_property(sprite, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN).set_delay(0.1)


func _play_elite_skeleton_death(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Elite skeleton: expand -> shrink + rotate + dark red + fade
	var t: Tween = enemy.create_tween()
	# Brief expand
	t.tween_property(sprite, "scale", Vector2(1.4, 1.4), 0.15).set_ease(Tween.EASE_OUT)
	# Dark red tint
	t.parallel().tween_property(sprite, "modulate", Color(0.4, 0.1, 0.1), 0.15)
	# Shrink + rotate + fade
	t.tween_property(sprite, "scale", Vector2(0.1, 0.1), 0.2).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "rotation", 1.57, 0.35).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "modulate:a", 0.0, 0.25).set_ease(Tween.EASE_IN)


func _play_ghost_death(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Ghost: float up + shrink + fade (ghost starts at alpha 0.7)
	var base_y: float = sprite.position.y
	var t: Tween = enemy.create_tween()
	t.tween_property(sprite, "position:y", base_y - 15.0, 0.4).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(sprite, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "scale", Vector2(0.6, 0.6), 0.4).set_ease(Tween.EASE_IN)


func _play_splitter_death(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Splitter: expand -> flash -> pop
	var t: Tween = enemy.create_tween()
	# Expand
	t.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.1).set_ease(Tween.EASE_OUT)
	# Flash white
	t.tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5), 0.05)
	# Pop + fade
	t.tween_property(sprite, "scale", Vector2.ZERO, 0.1).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "modulate:a", 0.0, 0.15).set_ease(Tween.EASE_IN)


func _play_splitter_small_death(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Small splitter: quick shrink + fade
	var t: Tween = enemy.create_tween()
	t.tween_property(sprite, "scale", Vector2.ZERO, 0.15).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "modulate:a", 0.0, 0.15).set_ease(Tween.EASE_IN)


func _play_fire_slime_death(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Fire slime: darken (extinguish) + flatten + fade
	var t: Tween = enemy.create_tween()
	# Darken to charred color
	t.tween_property(sprite, "modulate", Color(0.3, 0.15, 0.05), 0.15)
	# Flatten + fade
	t.tween_property(sprite, "scale", Vector2(1.4, 0.4), 0.25).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN)


func _play_elite_knight_death(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Elite knight: tilt + sink + dark purple + fade
	var base_y: float = sprite.position.y
	var t: Tween = enemy.create_tween()
	# Dark purple tint
	t.tween_property(sprite, "modulate", Color(0.2, 0.1, 0.3), 0.2)
	# Tilt + sink
	t.tween_property(sprite, "rotation", 1.05, 0.35).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "position:y", base_y + 10.0, 0.35).set_ease(Tween.EASE_IN)
	# Fade out (delayed)
	t.tween_property(sprite, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN).set_delay(0.15)


func _play_boss_death(enemy: CharacterBody2D, sprite: Sprite2D) -> void:
	## Boss: multi-stage death: shock -> shake -> explode -> gold flash -> vanish
	var base_pos: Vector2 = sprite.position
	var t: Tween = enemy.create_tween()
	# Stage 1: shock expand
	t.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.1).set_ease(Tween.EASE_OUT)
	# Stage 2: shake (3 random offsets from current position)
	for _i in range(3):
		var offset := Vector2(randf_range(-4, 4), randf_range(-4, 4))
		base_pos += offset
		t.tween_property(sprite, "position", base_pos, 0.05)
		base_pos -= offset * 0.5
		t.tween_property(sprite, "position", base_pos, 0.03)
	# Stage 3: explode + flash
	t.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.15).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(sprite, "modulate", Color(5, 5, 5), 0.05)
	# Stage 4: gold flash -> shrink + fade
	t.tween_property(sprite, "modulate", Color(1.0, 0.9, 0.3), 0.05)
	t.tween_property(sprite, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(sprite, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN)
