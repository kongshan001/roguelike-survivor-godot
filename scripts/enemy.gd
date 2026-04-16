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

# Kill attribution (for synergy tracking)
var _last_hit_by: String = ""
var _was_crit: bool = false


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

	# Flash effect
	if _flash_timer > 0:
		_flash_timer -= delta
		var sprite: Sprite2D = $Sprite as Sprite2D
		if sprite:
			sprite.modulate = Color(8, 8, 8) if fmod(_flash_timer, 0.1) > 0.05 else Color.WHITE


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


func apply_stun(duration: float) -> void:
	_freeze_timer = maxf(_freeze_timer, duration)


func die() -> void:
	if not is_alive:
		return
	is_alive = false

	_handle_kill_rewards()
	_handle_shatter()
	_spawn_xp_gems()
	_spawn_food_drop()
	_spawn_crate_drop()
	_handle_boss_death()
	_handle_splitter_death()

	queue_free()


func _handle_kill_rewards() -> void:
	GameManager.register_kill()
	GameManager.score += enemy_data.xp_value
	GameManager.enemy_count -= 1

	var gold_amount: int = _calculate_gold_drop()
	GameManager.add_gold(gold_amount)

	# holywater_luckycoin synergy: 圣水击杀+1金币
	if SynergyManager and SynergyManager.has_synergy("holywater_luckycoin"):
		if _last_hit_by == "holywater":
			GameManager.add_gold(1)


# Frost Aura Lv3: Shatter -- frozen enemy explodes on death
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
	var all_enemies := get_tree().get_nodes_in_group("enemies")
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
	script.source_code = (
		"extends Node2D\n"
		+ "var alpha: float = 0.6\n"
		+ "func _process(delta):\n"
		+ "\talpha -= delta * 3.0\n"
		+ "\tif alpha <= 0.0:\n"
		+ "\t\tqueue_free()\n"
		+ "\tqueue_redraw()\n"
		+ "func _draw():\n"
		+ "\tdraw_circle(Vector2.ZERO, 50.0, Color(0.5, 0.8, 1.0, alpha))\n"
	)
	script.reload()
	circle.set_script(script)
	get_parent().call_deferred("add_child", circle)


func _calculate_gold_drop() -> int:
	var gold_amount: int = 3
	if SaveManager:
		gold_amount = int(float(gold_amount) * (1.0 + SaveManager.get_gold_bonus()))

	# Lucky coin passive: +15% gold per stack
	var player_ref: Node2D = _find_player()
	if player_ref and player_ref.has_passive("luckycoin"):
		var lucky_stacks: int = player_ref.owned_passives.get("luckycoin", 0)
		gold_amount = int(float(gold_amount) * (1.0 + 0.15 * lucky_stacks))

	# crit_luckycoin synergy: 暴击时双倍金币
	if SynergyManager and SynergyManager.has_synergy("crit_luckycoin"):
		gold_amount *= 2

	# Combo gold bonus: 连击≥5时+1金币/击杀
	if GameManager.combo_count >= 5:
		gold_amount += 1

	return gold_amount


func _spawn_xp_gems() -> void:
	_spawn_xp_gem()

	# magnet_crit synergy: 暴击额外掉落价值+2宝石
	if SynergyManager and SynergyManager.has_synergy("magnet_crit") and _was_crit:
		_spawn_bonus_gem(2)

	# firestaff_luckycoin synergy: 燃烧击杀+1宝石
	if SynergyManager and SynergyManager.has_synergy("firestaff_luckycoin"):
		if _last_hit_by == "firestaff" and _burn_timer > 0:
			_spawn_bonus_gem(1)


func _spawn_food_drop() -> void:
	if randf() < 0.1 * GameManager.get_difficulty_mul("food_drop_mul", 1.0):
		_spawn_food()


func _spawn_crate_drop() -> void:
	if randf() < enemy_data.drop_chance:
		_spawn_item_crate()


func _handle_boss_death() -> void:
	if not enemy_data.is_boss:
		return

	GameManager.boss_killed = true
	GameManager.boss_kill_count += 1

	# Boss bonus gems (all modes)
	for i in range(5):
		_spawn_xp_gem()

	# Endless mode boss kill rewards
	if GameManager.selected_difficulty == "endless":
		_apply_endless_boss_reward()


func _apply_endless_boss_reward() -> void:
	GameManager.add_gold(50)
	GameManager.add_xp(30.0)
	for i in range(5):
		_spawn_food_at(global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30)))
	GameManager.boss_kill_reward.emit(50, 30)


func _handle_splitter_death() -> void:
	if enemy_data.is_splitter and not _has_split:
		_has_split = true
		_spawn_split_children()


# --- Spawning helpers ---

func _spawn_xp_gem():
	var gem_scene: PackedScene = preload("res://scenes/xp_gem.tscn")
	var gem: Area2D = gem_scene.instantiate()
	gem.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	gem.xp_value = enemy_data.xp_value
	var pm: Node = get_parent().get_node_or_null("PickupManager")
	if pm:
		pm.call_deferred("add_child", gem)


func _spawn_item_crate():
	var crate_scene: PackedScene = preload("res://scenes/item_crate.tscn")
	var crate: Area2D = crate_scene.instantiate()
	crate.global_position = global_position
	var pm: Node = get_parent().get_node_or_null("PickupManager")
	if pm:
		pm.call_deferred("add_child", crate)


func _spawn_food():
	_spawn_food_at(global_position + Vector2(randf_range(-15, 15), randf_range(-15, 15)))


func _spawn_food_at(pos: Vector2) -> void:
	var food: Area2D = Area2D.new()
	food.collision_mask = 1  # Player layer
	food.set_script(preload("res://scripts/food_pickup.gd"))
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	food.add_child(shape)
	var sprite: ColorRect = ColorRect.new()
	sprite.size = Vector2(8, 8)
	sprite.position = Vector2(-4, -4)
	sprite.color = Color(0.4, 0.9, 0.3)
	food.add_child(sprite)
	food.global_position = pos
	get_parent().call_deferred("add_child", food)


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
		get_parent().call_deferred("add_child", child)
		GameManager.enemy_count += 1


func _spawn_bonus_gem(value: int) -> void:
	var gem_scene: PackedScene = preload("res://scenes/xp_gem.tscn")
	var gem: Area2D = gem_scene.instantiate()
	gem.global_position = global_position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
	gem.xp_value = value
	var pm: Node = get_parent().get_node_or_null("PickupManager")
	if pm:
		pm.call_deferred("add_child", gem)


func _find_player() -> Node2D:
	return GameManager.find_player()
