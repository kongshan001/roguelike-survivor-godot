extends CharacterBody2D

@export var enemy_data: EnemyData

var current_hp: float
var is_alive: bool = true
var _flash_timer: float = 0.0
var _player: Node2D = null

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


func _ready():
	if enemy_data:
		current_hp = enemy_data.max_hp
		add_to_group("enemies")
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
	var sprite: ColorRect = $Sprite as ColorRect
	if sprite:
		sprite.color = enemy_data.color
		sprite.size = Vector2(enemy_data.size * 2, enemy_data.size * 2)
		sprite.position = -sprite.size / 2.0


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

	# Flash effect
	if _flash_timer > 0:
		_flash_timer -= delta
		var sprite: ColorRect = $Sprite as ColorRect
		if sprite:
			sprite.color = Color.WHITE if fmod(_flash_timer, 0.1) > 0.05 else enemy_data.color


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
	get_parent().add_child(bullet)


# --- Combat ---

func take_damage(amount: float):
	if not is_alive:
		return
	current_hp -= amount
	_flash_timer = 0.2
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


func die():
	if not is_alive:
		return
	is_alive = false
	GameManager.register_kill()
	GameManager.score += enemy_data.xp_value
	GameManager.enemy_count -= 1
	var gold_amount: int = 3
	if SaveManager:
		gold_amount = int(float(gold_amount) * (1.0 + SaveManager.get_gold_bonus()))
	GameManager.add_gold(gold_amount)
	_spawn_xp_gem()

	if randf() < enemy_data.drop_chance:
		_spawn_item_crate()

	# Boss death
	if enemy_data.is_boss:
		GameManager.boss_killed = true
		GameManager.boss_kill_count += 1
		for i in range(5):
			_spawn_xp_gem()

	# Splitter death
	if enemy_data.is_splitter and not _has_split:
		_has_split = true
		_spawn_split_children()

	queue_free()


# --- Spawning helpers ---

func _spawn_xp_gem():
	var gem_scene: PackedScene = preload("res://scenes/xp_gem.tscn")
	var gem: Area2D = gem_scene.instantiate()
	gem.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	gem.xp_value = enemy_data.xp_value
	get_parent().get_node("PickupManager").add_child(gem)


func _spawn_item_crate():
	var crate_scene: PackedScene = preload("res://scenes/item_crate.tscn")
	var crate: Area2D = crate_scene.instantiate()
	crate.global_position = global_position
	get_parent().get_node("PickupManager").add_child(crate)


func _spawn_split_children():
	var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
	for i in range(enemy_data.split_count):
		var child_data: EnemyData = EnemyData.new()
		child_data.enemy_id = "splitter_small"
		child_data.enemy_name = "小分裂者"
		child_data.max_hp = 1.0
		child_data.speed = 70.0
		child_data.damage = 1.0
		child_data.xp_value = 1
		child_data.color = Color(0.3, 0.71, 0.67)
		child_data.size = 8.0
		child_data.is_child = true
		# Apply difficulty multipliers to children
		child_data.max_hp *= GameManager.get_difficulty_mul("enemy_hp_mul")
		child_data.speed *= GameManager.get_difficulty_mul("enemy_speed_mul")
		child_data.damage *= GameManager.get_difficulty_mul("enemy_dmg_mul")

		var child: CharacterBody2D = enemy_scene.instantiate()
		child.enemy_data = child_data
		var offset: Vector2 = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		child.global_position = global_position + offset
		get_parent().add_child(child)
		GameManager.enemy_count += 1


func _find_player() -> Node2D:
	var players: Array = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]
	return null
