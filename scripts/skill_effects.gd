extends Node
# SkillEffects -- Visual and gameplay effects for character active skills.
# Each method creates Area2D-based effects, deals damage, and applies status.

# --- Mage: Elemental Burst ---
const MAGE_SKILL_DAMAGE: float = 15.0
const MAGE_SKILL_RADIUS: float = 150.0
const MAGE_SKILL_FREEZE_DURATION: float = 1.5
const MAGE_SKILL_EXPAND_TIME: float = 0.2
const MAGE_SKILL_SCREENSHAKE: float = 4.0
const MAGE_SKILL_SCREENSHAKE_DUR: float = 0.15

# --- Warrior: Shield Charge ---
const WARRIOR_SKILL_DAMAGE: float = 10.0
const WARRIOR_SKILL_DISTANCE: float = 160.0
const WARRIOR_SKILL_DURATION: float = 0.25
const WARRIOR_SKILL_WIDTH: float = 40.0
const WARRIOR_SKILL_STUN_DURATION: float = 2.0
const WARRIOR_SKILL_SCREENSHAKE: float = 3.0
const WARRIOR_SKILL_SCREENSHAKE_DUR: float = 0.1

# --- Ranger: Arrow Rain ---
const RANGER_SKILL_DAMAGE_PER_ARROW: float = 5.0
const RANGER_SKILL_ARROW_COUNT: int = 12
const RANGER_SKILL_RADIUS: float = 100.0
const RANGER_SKILL_TARGET_RANGE: float = 300.0
const RANGER_SKILL_FALL_DURATION: float = 0.5
const RANGER_SKILL_ARROW_WIDTH: float = 4.0
const RANGER_SKILL_ARROW_HEIGHT: float = 12.0
const RANGER_SKILL_WARNING_TIME: float = 0.3
const RANGER_SKILL_SCREENSHAKE: float = 2.0
const RANGER_SKILL_SCREENSHAKE_DUR: float = 0.08

# --- Passive constants ---
const MAGE_PASSIVE_DAMAGE_BONUS: float = 0.10
const WARRIOR_PASSIVE_ARMOR_BONUS: int = 3
const WARRIOR_PASSIVE_HP_THRESHOLD: float = 0.30
const WARRIOR_PASSIVE_DURATION: float = 3.0
const WARRIOR_PASSIVE_COOLDOWN: float = 30.0
const RANGER_PASSIVE_HIT_COUNT: int = 5

# --- Visual constants ---
const WARRIOR_AFTERIMAGE_COUNT: int = 3
const WARRIOR_AFTERIMAGE_ALPHA: float = 0.4


## Mage: Elemental Burst -- expanding ring, freeze enemies in radius
func elemental_burst(player: CharacterBody2D, damage_bonus: float = 0.0) -> void:
	var pos: Vector2 = player.global_position
	var dmg: float = MAGE_SKILL_DAMAGE * (1.0 + damage_bonus)
	var arena: Node = player.get_parent()
	if not arena:
		return

	# Create expanding ring visual
	var ring: ColorRect = ColorRect.new()
	ring.size = Vector2(0, 0)
	ring.position = pos - Vector2(0, 0)
	ring.color = Color(0.3, 0.5, 1.0, 0.8)
	ring.z_index = 10
	arena.call_deferred("add_child", ring)

	var tween: Tween = arena.create_tween()
	tween.tween_property(ring, "size", Vector2(MAGE_SKILL_RADIUS * 2.0, MAGE_SKILL_RADIUS * 2.0), MAGE_SKILL_EXPAND_TIME)
	tween.parallel().tween_property(ring, "position", pos - Vector2(MAGE_SKILL_RADIUS, MAGE_SKILL_RADIUS), MAGE_SKILL_EXPAND_TIME)
	tween.parallel().tween_property(ring, "color:a", 0.0, MAGE_SKILL_EXPAND_TIME)
	tween.tween_callback(ring.queue_free)

	# Damage and freeze enemies in range
	var enemies: Array = _get_enemies_in_radius(arena, pos, MAGE_SKILL_RADIUS)
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			enemy.take_damage(dmg, "elemental_burst")
			if enemy.has_method("apply_freeze"):
				enemy.apply_freeze(MAGE_SKILL_FREEZE_DURATION)

	# Screen shake
	_screen_shake(arena, MAGE_SKILL_SCREENSHAKE)


## Warrior: Shield Charge -- dash forward, damage and stun enemies in path
func shield_charge(player: CharacterBody2D, direction: Vector2, damage_bonus: float = 0.0) -> void:
	var dmg: float = WARRIOR_SKILL_DAMAGE * (1.0 + damage_bonus)
	var arena: Node = player.get_parent()
	if not arena:
		return

	var start_pos: Vector2 = player.global_position
	var end_pos: Vector2 = start_pos + direction * WARRIOR_SKILL_DISTANCE

	# Create afterimages
	for i in range(WARRIOR_AFTERIMAGE_COUNT):
		var afterimage: ColorRect = ColorRect.new()
		afterimage.size = Vector2(32, 32)
		var t: float = float(i + 1) / float(WARRIOR_AFTERIMAGE_COUNT)
		var img_pos: Vector2 = start_pos.lerp(end_pos, t) - Vector2(16, 16)
		afterimage.position = img_pos
		afterimage.color = Color(0.9, 0.2, 0.1, WARRIOR_AFTERIMAGE_ALPHA)
		afterimage.z_index = -1
		arena.call_deferred("add_child", afterimage)
		var img_tween: Tween = arena.create_tween()
		img_tween.tween_property(afterimage, "color:a", 0.0, 0.3)
		img_tween.tween_callback(afterimage.queue_free)

	# Move player to end position
	var move_tween: Tween = player.create_tween()
	move_tween.tween_property(player, "global_position", end_pos, WARRIOR_SKILL_DURATION)

	# Check enemies along the charge path
	var enemies: Array = _get_enemies_in_path(arena, start_pos, end_pos, WARRIOR_SKILL_WIDTH)
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			enemy.take_damage(dmg, "shield_charge")
			if enemy.has_method("apply_freeze"):
				enemy.apply_freeze(WARRIOR_SKILL_STUN_DURATION)

	# Screen shake
	_screen_shake(arena, WARRIOR_SKILL_SCREENSHAKE)


## Ranger: Arrow Rain -- arrows fall on target area
func arrow_rain(player: CharacterBody2D, damage_bonus: float = 0.0) -> void:
	var dmg: float = RANGER_SKILL_DAMAGE_PER_ARROW * (1.0 + damage_bonus)
	var arena: Node = player.get_parent()
	if not arena:
		return

	# Find target position: center of mass of 5 closest enemies, or 200px ahead
	var target_pos: Vector2 = _find_arrow_rain_target(player)

	# Show warning circle
	var warning: ColorRect = ColorRect.new()
	warning.size = Vector2(RANGER_SKILL_RADIUS * 2.0, RANGER_SKILL_RADIUS * 2.0)
	warning.position = target_pos - Vector2(RANGER_SKILL_RADIUS, RANGER_SKILL_RADIUS)
	warning.color = Color(1, 0.85, 0, 0.3)
	warning.z_index = 10
	arena.call_deferred("add_child", warning)

	var warn_tween: Tween = arena.create_tween()
	warn_tween.tween_interval(RANGER_SKILL_WARNING_TIME)
	warn_tween.tween_callback(warning.queue_free)
	warn_tween.tween_callback(_spawn_arrows.bind(arena, target_pos, dmg))

	# Screen shake on first impact
	warn_tween.tween_callback(_screen_shake.bind(arena, RANGER_SKILL_SCREENSHAKE))


## Spawn the actual arrow projectiles for arrow rain
func _spawn_arrows(arena: Node, center: Vector2, damage: float) -> void:
	for i in range(RANGER_SKILL_ARROW_COUNT):
		var offset: Vector2 = Vector2(
			randf_range(-RANGER_SKILL_RADIUS, RANGER_SKILL_RADIUS),
			randf_range(-RANGER_SKILL_RADIUS, RANGER_SKILL_RADIUS)
		)
		var target: Vector2 = center + offset
		var start: Vector2 = Vector2(target.x, target.y - 200.0)

		var arrow: ColorRect = ColorRect.new()
		arrow.size = Vector2(RANGER_SKILL_ARROW_WIDTH, RANGER_SKILL_ARROW_HEIGHT)
		arrow.position = start
		arrow.color = Color(0.9, 0.9, 0.8)
		arrow.z_index = 10
		arena.call_deferred("add_child", arrow)

		var fall_delay: float = randf() * RANGER_SKILL_FALL_DURATION * 0.5
		var arrow_tween: Tween = arena.create_tween()
		arrow_tween.tween_interval(fall_delay)
		arrow_tween.tween_property(arrow, "position:y", target.y, RANGER_SKILL_FALL_DURATION * 0.5)
		arrow_tween.tween_callback(_arrow_impact.bind(arrow, target, damage, arena))


## Handle single arrow impact -- damage enemies near impact
func _arrow_impact(arrow: ColorRect, pos: Vector2, damage: float, arena: Node) -> void:
	if is_instance_valid(arrow):
		arrow.queue_free()

	# Small flash at impact
	var flash: ColorRect = ColorRect.new()
	flash.size = Vector2(8, 8)
	flash.position = pos - Vector2(4, 4)
	flash.color = Color(1, 1, 1, 0.8)
	flash.z_index = 10
	arena.call_deferred("add_child", flash)
	var flash_tween: Tween = arena.create_tween()
	flash_tween.tween_property(flash, "color:a", 0.0, 0.1)
	flash_tween.tween_callback(flash.queue_free)

	# Damage enemies near impact
	var enemies: Array = _get_enemies_in_radius(arena, pos, 15.0)
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			enemy.take_damage(damage, "arrow_rain")


# --- Helpers ---

func _get_enemies_in_radius(arena: Node, center: Vector2, radius: float) -> Array:
	var result: Array = []
	var all_enemies := arena.get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			var dist: float = center.distance_to(enemy.global_position)
			if dist <= radius:
				result.append(enemy)
	return result


func _get_enemies_in_path(arena: Node, start: Vector2, end: Vector2, width: float) -> Array:
	var result: Array = []
	var all_enemies := arena.get_tree().get_nodes_in_group("enemies")
	var path_dir: Vector2 = end - start
	var path_len: float = path_dir.length()
	if path_len < 1.0:
		return result
	path_dir = path_dir.normalized()
	var perp: Vector2 = Vector2(-path_dir.y, path_dir.x)

	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			var to_enemy: Vector2 = enemy.global_position - start
			var along: float = to_enemy.dot(path_dir)
			if along >= 0.0 and along <= path_len:
				var across: float = absf(to_enemy.dot(perp))
				if across <= width * 0.5:
					result.append(enemy)
	return result


func _find_arrow_rain_target(player: CharacterBody2D) -> Vector2:
	var arena: Node = player.get_parent()
	if not arena:
		return player.global_position + Vector2(0, -200.0)

	# Find closest enemies and compute center of mass of up to 5
	var enemies: Array = []
	var all_enemies := arena.get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			var dist: float = player.global_position.distance_to(enemy.global_position)
			if dist <= RANGER_SKILL_TARGET_RANGE:
				enemies.append({"enemy": enemy, "dist": dist})

	enemies.sort_custom(func(a, b): return a["dist"] < b["dist"])

	if enemies.size() == 0:
		var dir: Vector2 = player.velocity.normalized() if player.velocity.length_squared() > 1.0 else Vector2.DOWN
		return player.global_position + dir * 200.0

	var count: int = mini(5, enemies.size())
	var center: Vector2 = Vector2.ZERO
	for i in range(count):
		center += enemies[i]["enemy"].global_position
	center /= float(count)
	return center


func _screen_shake(arena: Node, intensity: float) -> void:
	if arena.has_method("screen_shake"):
		arena.screen_shake(intensity)
