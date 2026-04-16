extends CharacterBody2D

@export var enemy_data: EnemyData

var current_hp: float
var is_alive: bool = true
var _player: Node2D = null

# Death effects module (loaded lazily)
var _death_effects: RefCounted = null

# Loot module (loaded lazily)
var _loot: RefCounted = null

# Status effects
var _burn_dps: float = 0.0
var _burn_timer: float = 0.0
var _slow_pct: float = 0.0
var _slow_timer: float = 0.0
var _freeze_timer: float = 0.0

# Ranged attack
var _shoot_timer: float = 0.0

# Ghost teleport
var _phase_timer: float = 0.0
var _phase_duration: float = 2.0
var _is_phased: bool = false

# Boss AI
var _boss_ai = null  # BossAI instance

# Splitter death tracking (prevents double-spawn)
var _has_split: bool = false

# Kill attribution (for synergy tracking)
var _last_hit_by: String = ""
var _was_crit: bool = false


func _ready():
	if enemy_data:
		current_hp = enemy_data.max_hp
		add_to_group("enemies")
		if GameManager:
			GameManager.register_enemy(self)
		_setup_visual()
		_setup_collision()

		var time_bonus: float = 1.0 + (GameManager.elapsed_time / 60.0) * 0.1
		current_hp *= time_bonus

		# Initialize boss AI
		if enemy_data.is_boss:
			_boss_ai = load("res://scripts/enemies/boss_ai.gd").new()

		# Initialize shoot timer with random offset
		if enemy_data.is_ranged:
			_shoot_timer = enemy_data.shoot_cd * randf_range(0.5, 1.0)


func _setup_visual() -> void:
	var sprite: Sprite2D = $Sprite as Sprite2D
	if sprite:
		var tex_path := "res://assets/sprites/enemies/%s.png" % enemy_data.enemy_id
		if ResourceLoader.exists(tex_path):
			sprite.texture = load(tex_path)
	var base_size: float = 32.0
	var scale_factor: float = (enemy_data.size * 2.0) / base_size
	sprite.scale = Vector2(scale_factor, scale_factor)


func _setup_collision() -> void:
	var shape: CircleShape2D = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = enemy_data.size
	var hitbox_shape: CircleShape2D = $Hitbox/CollisionShape2D.shape as CircleShape2D
	if hitbox_shape:
		hitbox_shape.radius = enemy_data.size


func _physics_process(delta: float):
	if not is_alive:
		return

	if not _player or not is_instance_valid(_player):
		_player = _find_player()
		if not _player:
			return

	# Boss phase logic
	if _boss_ai:
		_boss_ai.update_phase(current_hp, enemy_data.max_hp)

	var speed_mult: float = 1.0

	# Status effects
	if _freeze_timer > 0:
		_freeze_timer -= delta
		speed_mult = 0.0
	elif _slow_timer > 0:
		_slow_timer -= delta
		speed_mult = 1.0 - _slow_pct
	else:
		_slow_pct = 0.0

	# Ghost phase shift
	if enemy_data.can_phase_shift:
		_process_ghost_phase(delta, speed_mult)

	# Boss AI speed override
	if _boss_ai:
		var boss_mult: float = _boss_ai.process(delta, self, _player)
		speed_mult *= boss_mult

	# Movement (skip if phased or frozen)
	if not _is_phased and speed_mult > 0.0:
		var direction: Vector2 = global_position.direction_to(_player.global_position)
		velocity = direction * enemy_data.speed * speed_mult
		move_and_slide()

	# Burn DOT
	if _burn_timer > 0:
		_burn_timer -= delta
		current_hp -= _burn_dps * delta
		if current_hp <= 0:
			die()

	# Ranged attack
	if enemy_data.is_ranged and not _is_phased:
		_process_ranged_attack(delta)

	# Fire Slime burn aura (passive contact burn)
	if enemy_data.has_burn_aura and _player and is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)
		if dist < enemy_data.size + 16.0:
			_player.apply_burn(enemy_data.burn_aura_dps, enemy_data.burn_aura_duration)



# --- Ghost behavior ---

func _process_ghost_phase(delta: float, speed_mult: float) -> void:
	if _is_phased:
		_phase_timer -= delta
		if _phase_timer <= 0:
			_is_phased = false
			# Teleport near player
			if enemy_data.can_teleport and _player:
				var offset: Vector2 = Vector2(randf_range(-60, 60), randf_range(-60, 60))
				global_position = _player.global_position + offset
			modulate.a = 1.0
	else:
		# Random chance to phase
		if randf() < 0.005:
			_is_phased = true
			_phase_timer = _phase_duration
			modulate.a = 0.3


# --- Ranged attack ---

func _process_ranged_attack(delta: float) -> void:
	_shoot_timer -= delta
	if _shoot_timer <= 0:
		_shoot_timer = enemy_data.shoot_cd
		if enemy_data.is_elite:
			_fire_elite_shot()
		else:
			_fire_single_shot()


func _fire_single_shot() -> void:
	if not _player or not is_instance_valid(_player):
		return
	var dir: Vector2 = global_position.direction_to(_player.global_position)
	_spawn_bullet(dir)


func _fire_elite_shot() -> void:
	if not _player or not is_instance_valid(_player):
		return
	var base_dir: Vector2 = global_position.direction_to(_player.global_position)
	var base_angle: float = base_dir.angle()
	for i in range(3):
		var angle: float = base_angle + (i - 1) * deg_to_rad(25.0)
		_spawn_bullet(Vector2(cos(angle), sin(angle)))


func _spawn_bullet(dir: Vector2) -> void:
	var bullet_scene: PackedScene = preload("res://scenes/enemy_bullet.tscn")
	var bullet: Area2D = bullet_scene.instantiate()
	bullet.direction = dir
	bullet.speed = 200.0
	bullet.damage = enemy_data.damage * GameManager.get_difficulty_mul("enemy_dmg_mul")
	bullet.color = Color(0.9, 0.9, 0.9)
	bullet.size = 4.0
	bullet.global_position = global_position
	get_parent().call_deferred("add_child", bullet)


# --- Combat ---

func take_damage(amount: float, source: String = "", was_crit: bool = false):
	if not is_alive:
		return
	if source != "":
		_last_hit_by = source
	_was_crit = was_crit
	current_hp -= amount
	# Play hit feedback (flash + shake) via death effects module
	var sprite_node: Sprite2D = $Sprite as Sprite2D
	if sprite_node and is_instance_valid(sprite_node):
		_get_death_effects().play_hit_feedback(self, sprite_node)
	# Hit particles + damage number via feedback module
	_spawn_hit_feedback(amount, source, was_crit)
	if current_hp <= 0:
		die()


func apply_burn(dps: float, duration: float):
	_burn_dps = maxf(_burn_dps, dps)
	_burn_timer = maxf(_burn_timer, duration)


func apply_slow(pct: float):
	_slow_pct = maxf(_slow_pct, pct)
	_slow_timer = 1.0


func apply_freeze(duration: float):
	_freeze_timer = maxf(_freeze_timer, duration)


func apply_stun(duration: float) -> void:
	_freeze_timer = maxf(_freeze_timer, duration)


func die() -> void:
	if not is_alive:
		return
	is_alive = false
	remove_from_group("enemies")
	if GameManager:
		GameManager.unregister_enemy(self)

	var loot: RefCounted = _get_loot()
	var pm: Node = get_parent().get_node_or_null("PickupManager") if get_parent() else null

	loot.handle_kill_rewards(enemy_data, _last_hit_by, _was_crit)
	_handle_shatter()
	loot.spawn_xp_gems(enemy_data, global_position, _last_hit_by, _was_crit, _burn_timer, pm)
	loot.spawn_food_drop(enemy_data, global_position, get_parent())
	loot.spawn_crate_drop(enemy_data, global_position, pm)
	_handle_boss_death(loot, pm)
	_handle_splitter_death(loot)

	# Play death animation then free
	_play_death_animation_and_free()


# --- Frost Aura Lv3 Shatter ---

const FROSTAURA_LV3_SHATTER_RADIUS: float = 50.0
const FROSTAURA_LV3_SHATTER_DAMAGE: float = 2.0


func _handle_shatter() -> void:
	if _freeze_timer <= 0.0:
		return  # Not frozen, no shatter
	var player: Node2D = _find_player()
	if not player or not is_instance_valid(player):
		return
	if not player.owned_weapons.has("frostaura"):
		return
	if player.owned_weapons["frostaura"] < 3:
		return  # Not Lv3 yet
	var all_enemies: Array = GameManager.get_cached_enemies() if GameManager else get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.is_alive and enemy != self:
			var dist := global_position.distance_to(enemy.global_position)
			if dist <= FROSTAURA_LV3_SHATTER_RADIUS:
				enemy.take_damage(FROSTAURA_LV3_SHATTER_DAMAGE, "frostaura")
	_spawn_shatter_effect()


func _spawn_shatter_effect() -> void:
	var circle: Node2D = Node2D.new()
	circle.global_position = global_position
	var script := GDScript.new()
	script.source_code = "extends Node2D\nvar alpha: float = 0.6\nfunc _process(delta):\n\talpha -= delta * 3.0\n\tif alpha <= 0.0:\n\t\tqueue_free()\n\tqueue_redraw()\nfunc _draw():\n\tdraw_circle(Vector2.ZERO, 50.0, Color(0.5, 0.8, 1.0, alpha))\n"
	script.reload()
	circle.set_script(script)
	get_parent().call_deferred("add_child", circle)


func _handle_boss_death(loot: RefCounted, pm: Node) -> void:
	if not enemy_data.is_boss:
		return
	loot.handle_boss_death(enemy_data, global_position, get_parent(), pm)


func _handle_splitter_death(loot: RefCounted) -> void:
	if enemy_data.is_splitter and not _has_split:
		_has_split = true
		loot.spawn_split_children(enemy_data, global_position, get_parent())


# --- Hit feedback (particles + damage numbers) ---

var _hit_feedback: RefCounted = null


func _spawn_hit_feedback(amount: float, source: String, was_crit: bool) -> void:
	## Delegate hit particle and damage number spawning to feedback module.
	if _hit_feedback == null:
		var script: GDScript = load("res://scripts/effects/hit_feedback.gd") as GDScript
		if script:
			_hit_feedback = script.new()
	if _hit_feedback:
		_hit_feedback.spawn(self, amount, source, was_crit)


func _find_player() -> Node2D:
	return GameManager.find_player()


# --- Death animation helpers ---

func _get_death_effects() -> RefCounted:
	if _death_effects == null:
		_death_effects = load("res://scripts/enemies/enemy_death_effects.gd").new()
	return _death_effects


func _get_loot() -> RefCounted:
	if _loot == null:
		_loot = load("res://scripts/enemies/enemy_loot.gd").new()
	return _loot


func _play_death_animation_and_free() -> void:
	var sprite_node: Sprite2D = $Sprite as Sprite2D
	if sprite_node and is_instance_valid(sprite_node):
		# Stop physics processing during death animation
		set_physics_process(false)
		_get_death_effects().play_death_animation(self, sprite_node)
		# Wait for animation to finish before freeing
		var max_duration: float = _get_death_max_duration()
		var t: Tween = create_tween()
		t.tween_interval(max_duration)
		t.tween_callback(queue_free)
	else:
		queue_free()


func _get_death_max_duration() -> float:
	var eid: String = enemy_data.enemy_id if enemy_data else ""
	return _get_death_effects().get_death_duration(eid)
