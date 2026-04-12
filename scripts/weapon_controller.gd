extends Node

var _weapon_timers: Dictionary = {}
var _registered: bool = false
var _orbit_instances: Dictionary = {}
var _boomerang_instances: Array = []
var _effects: RefCounted = null


func _get_effects() -> RefCounted:
	if not _effects:
		_effects = load("res://scripts/weapons/weapon_effects.gd").new()
	return _effects


func _physics_process(delta):
	if not _registered:
		UpgradePool.ensure_weapons_registered()
		_registered = true

	if GameManager.is_game_over:
		return

	var player: CharacterBody2D = get_parent()
	if not player.is_alive:
		return

	for weapon_id in player.owned_weapons:
		if not _weapon_timers.has(weapon_id):
			_weapon_timers[weapon_id] = 0.0

		_weapon_timers[weapon_id] -= delta
		if _weapon_timers[weapon_id] <= 0.0:
			var data: WeaponData = UpgradePool._weapons.get(weapon_id)
			if data:
				_fire_weapon(weapon_id, data, player)
				_weapon_timers[weapon_id] = data.cooldown

	_update_boomerangs(delta)


func _fire_weapon(weapon_id: String, data: WeaponData, player: CharacterBody2D):
	var level: int = player.owned_weapons[weapon_id]
	var dmg_bonus: float = 1.0 + player.damage_bonus
	match data.weapon_type:
		"projectile":
			_fire_projectile(data, level, player, dmg_bonus)
		"orbit":
			_update_orbit(weapon_id, data, level, player, dmg_bonus)
		"lightning":
			_fire_lightning(data, level, player, dmg_bonus)
		"cone":
			_fire_cone(data, level, player, dmg_bonus)
		"aura":
			_update_aura(weapon_id, data, level, player, dmg_bonus)
		"boomerang":
			_fire_boomerang(data, level, player, dmg_bonus)


# --- Projectile ---

func _fire_projectile(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var count: int = data.projectile_count + (level - 1)
	var damage: float = data.damage + (level - 1) * 0.6
	var pierce: int = data.projectile_pierce + (level - 1)

	# Evolved weapons have fixed stats
	if data.is_evolved:
		count = data.projectile_count
		damage = data.damage
		pierce = data.projectile_pierce

	var enemies := _get_enemies_in_range(player, 600.0)
	if enemies.is_empty():
		return

	for i in range(count):
		var target: Node2D = enemies[i % enemies.size()]
		var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")
		var proj: Area2D = projectile_scene.instantiate()
		proj.setup(
			player.global_position,
			target.global_position,
			data.projectile_speed,
			damage * dmg_bonus,
			pierce,
			data.color,
			data.projectile_size
		)
		# Apply status effects for evolved weapons
		if data.burn_dps > 0 or data.slow_pct > 0:
			proj.set_status_effects(data.burn_dps, data.burn_duration, data.slow_pct)
		player.get_parent().get_node("ProjectileManager").add_child(proj)


# --- Orbit ---

func _update_orbit(weapon_id: String, data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var orbit_count: int
	var radius: float
	var damage: float

	if data.is_evolved:
		orbit_count = data.orbit_count
		radius = data.orbit_radius
		damage = data.damage * dmg_bonus
	elif weapon_id == "holywater":
		orbit_count = level
		radius = 50.0 + (level - 1) * 5.0
		damage = (1.5 if level < 3 else 2.0) * dmg_bonus
		if SynergyManager and SynergyManager.has_synergy("holywater_maxhp"):
			radius *= SynergyManager.get_synergy_value("holywater_maxhp", "value", 1.3)
	elif weapon_id == "bible":
		orbit_count = 1
		radius = 80.0 + (level - 1) * 20.0
		if SynergyManager and SynergyManager.has_synergy("bible_boots"):
			radius += SynergyManager.get_synergy_value("bible_boots", "radius_bonus", 20.0)
		damage = (1.0 if level < 3 else 2.0) * dmg_bonus
	else:
		return

	var key: String = weapon_id
	if _orbit_instances.has(key) and is_instance_valid(_orbit_instances[key]):
		var existing: Node2D = _orbit_instances[key]
		if existing.orbit_count != orbit_count or existing.orbit_radius != radius:
			existing.queue_free()
			_orbit_instances.erase(key)
		else:
			existing.damage = damage
			existing.global_position = player.global_position
			return

	var instance := Node2D.new()
	instance.set_script(load("res://scripts/spin_blade.gd"))
	instance.setup(orbit_count, damage, radius, data.color, data.projectile_size)
	var rot_speed: float = data.orbit_speed + (0 if data.is_evolved else (level - 1) * 0.6)
	if weapon_id == "bible" and SynergyManager and SynergyManager.has_synergy("bible_boots"):
		rot_speed *= SynergyManager.get_synergy_value("bible_boots", "value", 1.5)
	instance.rotation_speed = rot_speed
	player.get_parent().get_node("ProjectileManager").add_child(instance)
	instance.global_position = player.global_position
	_orbit_instances[key] = instance


# --- Lightning ---

func _fire_lightning(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var damage: float
	var chains: int
	var bolt_count: int
	var range_val: float = data.projectile_range

	if data.is_evolved:
		damage = data.damage * dmg_bonus
		chains = data.chain_count
		bolt_count = data.projectile_count
	else:
		damage = (5.0 + (level - 1)) * dmg_bonus
		chains = level - 1
		bolt_count = 1 if level < 3 else 2

	var enemies := _get_enemies_in_range(player, range_val)
	if enemies.is_empty():
		return

	var hit_count := mini(bolt_count + chains, enemies.size())
	for i in range(hit_count):
		var target: Node2D = enemies[i]
		if target.has_method("take_damage"):
			target.take_damage(damage)
		_get_effects().create_lightning_effect(player.global_position, target.global_position, data.color, player.get_parent().get_node("ProjectileManager"))


# --- Cone ---

func _fire_cone(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var angle: float = data.cone_angle + (level - 1) * 20.0
	var range_val: float = data.cone_range + (level - 1) * 30.0
	var damage: float = (data.damage + (level - 1) * 2.0) * dmg_bonus
	var burn: float = 0.0
	var burn_dur: float = 0.0
	if level >= 3:
		burn = 2.0
		burn_dur = 2.0

	var player_dir: Vector2 = Vector2.RIGHT
	var velocity := player.velocity
	if velocity.length_squared() > 1.0:
		player_dir = velocity.normalized()

	var half_angle := deg_to_rad(angle / 2.0)
	var dir_angle: float = player_dir.angle()

	var enemies := _get_enemies_in_range(player, range_val)
	for enemy in enemies:
		var to_enemy: Vector2 = enemy.global_position - player.global_position
		var enemy_angle: float = to_enemy.angle()
		var angle_diff := absf(wrapf(enemy_angle - dir_angle, -PI, PI))
		if angle_diff <= half_angle:
			enemy.take_damage(damage)
			if burn > 0.0 and enemy.has_method("apply_burn"):
				enemy.apply_burn(burn, burn_dur)

	_get_effects().create_cone_effect(player.global_position, dir_angle, half_angle, range_val, data.color, player.get_parent().get_node("ProjectileManager"))


# --- Aura ---

func _update_aura(weapon_id: String, data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var radius: float
	var slow: float
	var damage: float
	var freeze_pct: float

	if data.is_evolved:
		radius = data.aoe_radius
		slow = data.slow_pct
		damage = data.damage * dmg_bonus
		freeze_pct = data.freeze_pct
	else:
		radius = 80.0 + (level - 1) * 25.0
		slow = 0.3 + (level - 1) * 0.15
		damage = (1.0 + (level - 1) * 0.5) * dmg_bonus
		freeze_pct = 0.08 if level >= 3 else 0.0

	var enemies := _get_enemies_in_range(player, radius)
	for enemy in enemies:
		enemy.take_damage(damage * get_process_delta_time())
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(slow)
		if freeze_pct > 0.0 and enemy.has_method("apply_freeze"):
			enemy.apply_freeze(freeze_pct * get_process_delta_time())

	# Evolved blizzard: also fire lightning periodically
	if weapon_id == "blizzard":
		if not _weapon_timers.has("_blizzard_lightning"):
			_weapon_timers["_blizzard_lightning"] = 2.0
		_weapon_timers["_blizzard_lightning"] -= get_process_delta_time()
		if _weapon_timers["_blizzard_lightning"] <= 0:
			_weapon_timers["_blizzard_lightning"] = 2.0
			var bolt_enemies := _get_enemies_in_range(player, 300.0)
			var hit := mini(3, bolt_enemies.size())
			for i in range(hit):
				bolt_enemies[i].take_damage(8.0 * dmg_bonus)
				_get_effects().create_lightning_effect(player.global_position, bolt_enemies[i].global_position, Color(0.5, 0.8, 1.0), player.get_parent().get_node("ProjectileManager"))


# --- Boomerang ---

func _fire_boomerang(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float):
	var count: int
	var damage: float
	var pierce: int
	var max_dist: float
	var cooldown: float
	var track_angle: float

	if data.is_evolved:
		count = data.projectile_count
		damage = data.damage * dmg_bonus
		pierce = data.projectile_pierce
		max_dist = data.boomerang_max_dist
		cooldown = data.cooldown
		track_angle = data.boomerang_track_angle
	else:
		count = data.projectile_count + (level - 1)
		damage = (data.damage + (level - 1)) * dmg_bonus
		pierce = data.projectile_pierce + (level - 1)
		max_dist = data.boomerang_max_dist + (level - 1) * 50.0
		cooldown = data.cooldown - (level - 1) * 0.4
		track_angle = data.boomerang_track_angle + (level - 1) * 0.26

	_weapon_timers[data.weapon_id] = maxf(cooldown, 0.5)

	_boomerang_instances = _boomerang_instances.filter(func(b): return is_instance_valid(b))

	for i in range(count):
		if _boomerang_instances.size() >= 8:
			break

		var enemies := _get_enemies_in_range(player, 400.0)
		var target_dir: Vector2 = Vector2.RIGHT.rotated(randf() * TAU)
		if not enemies.is_empty():
			target_dir = player.global_position.direction_to(enemies[i % enemies.size()].global_position)

		var bm: Area2D = _create_boomerang(player.global_position, target_dir, damage, pierce, max_dist, data.boomerang_return_speed, track_angle, data.color, data.projectile_size)
		player.get_parent().get_node("ProjectileManager").add_child(bm)
		_boomerang_instances.append(bm)


func _create_boomerang(pos: Vector2, dir: Vector2, dmg: float, prc: int, max_dist: float, return_spd: float, track_angle: float, col: Color, sz: float) -> Area2D:
	var bm_scene: PackedScene = preload("res://scenes/projectile.tscn")
	var bm: Area2D = bm_scene.instantiate()
	bm.global_position = pos
	bm.direction = dir
	bm.speed = 280.0
	bm.damage = dmg
	bm.pierce = prc
	bm.color = col
	bm.size = sz
	bm.set_script(load("res://scripts/weapons/boomerang.gd"))
	bm.setup_boomerang(pos, dir, max_dist, return_spd, track_angle)
	return bm


func _update_boomerangs(_delta: float):
	var player: CharacterBody2D = get_parent()
	if not player or not is_instance_valid(player):
		return
	for bm in _boomerang_instances:
		if is_instance_valid(bm) and bm.has_method("update_player_pos"):
			bm.update_player_pos(player.global_position)


# --- Helpers ---

func _get_enemies_in_range(player: Node2D, range_val: float) -> Array:
	var enemies: Array = []
	var all_enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			var dist := player.global_position.distance_to(enemy.global_position)
			if dist <= range_val:
				enemies.append(enemy)
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	return enemies


func remove_weapon_instances(weapon_id: String) -> void:
	# Clean up orbit instances
	if _orbit_instances.has(weapon_id):
		var inst: Node2D = _orbit_instances[weapon_id]
		if is_instance_valid(inst):
			inst.queue_free()
		_orbit_instances.erase(weapon_id)
	# Clean up boomerang instances for this weapon type
	_boomerang_instances = _boomerang_instances.filter(func(b): return not is_instance_valid(b) or b.get("weapon_id") != weapon_id)
	# Remove timer
	_weapon_timers.erase(weapon_id)


func _process(_delta):
	for key in _orbit_instances:
		var inst: Node2D = _orbit_instances[key]
		if is_instance_valid(inst):
			var player: CharacterBody2D = get_parent()
			if player and is_instance_valid(player):
				inst.global_position = player.global_position
