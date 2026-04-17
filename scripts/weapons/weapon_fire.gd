extends RefCounted
## Weapon firing logic extracted from weapon_controller.gd

# --- Named constants (extracted from magic numbers) ---

# Projectile
const PROJECTILE_RANGE: float = 600.0

# Cone
const CONE_ANGLE_PER_LEVEL: float = 20.0
const CONE_RANGE_PER_LEVEL: float = 30.0
const CONE_DAMAGE_PER_LEVEL: float = 2.0

# Aura
const AURA_BASE_RADIUS: float = 80.0
const AURA_RADIUS_PER_LEVEL: float = 25.0
const AURA_DAMAGE_PER_LEVEL: float = 0.5

# Crit knife (synergy)
const CRIT_KNIFE_SPEED: float = 250.0
const CRIT_KNIFE_LIFETIME: float = 1.0

# --- Weapon Lv3 Quality-Change Constants ---

# Bible Lv3: Expanding Radius
const BIBLE_LV3_RADIUS_MUL: float = 1.5

# Fire Staff Lv3: Burst Burn
const FIRESTAFF_LV3_BURN_DPS: float = 3.0
const FIRESTAFF_LV3_BURN_DURATION: float = 2.0

var _controller: Node = null
var _boomerang_fire: RefCounted = null


func _init(controller: Node) -> void:
	_controller = controller


func _get_pm(player: CharacterBody2D) -> Node:
	var parent: Node = player.get_parent()
	if parent and parent.has_node("ProjectileManager"):
		return parent.get_node("ProjectileManager")
	return null


func _get_effects() -> RefCounted:
	return _controller._get_effects()


func _get_enemies(player: Node2D, range_val: float) -> Array:
	return _controller._get_enemies_in_range(player, range_val)


# --- Projectile ---

func fire_projectile(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float) -> void:
	var count: int = data.projectile_count + (level - 1)
	var damage: float = data.damage + (level - 1) * 0.6
	var pierce: int = data.projectile_pierce + (level - 1)

	if data.is_evolved:
		count = data.projectile_count
		damage = data.damage
		pierce = data.projectile_pierce

	var enemies := _get_enemies(player, PROJECTILE_RANGE)
	if enemies.is_empty():
		return

	for i in range(count):
		var target: Node2D = enemies[i % enemies.size()]
		var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")
		var proj: Area2D = projectile_scene.instantiate()
		proj.weapon_id = data.weapon_id
		proj.setup(
			player.global_position,
			target.global_position,
			data.projectile_speed,
			damage * dmg_bonus,
			pierce,
			data.color,
			data.projectile_size
		)
		var proj_damage: float = damage * dmg_bonus
		var is_keen_eye_crit: bool = _controller.notify_weapon_hit(player) if _controller.has_method("notify_weapon_hit") else false
		if is_keen_eye_crit:
			proj_damage *= player.crit_damage_mul
			proj.color = Color(1.0, 0.85, 0.0)
			proj.is_crit = true
		elif data.weapon_id == "knife" and SynergyManager and SynergyManager.has_synergy("knife_crit"):
			if randf() < player.crit_chance:
				proj_damage *= player.crit_damage_mul
				proj.color = Color(1.0, 0.85, 0.0)
				proj.is_crit = true
		proj.damage = proj_damage

		if data.weapon_id == "knife":
			proj.weapon_level = level

		if data.burn_dps > 0 or data.slow_pct > 0:
			proj.set_status_effects(data.burn_dps, data.burn_duration, data.slow_pct)
		var pm: Node = _get_pm(player)
		if pm:
			pm.call_deferred("add_child", proj)
		if SynergyManager and SynergyManager.has_synergy("crit_boots") and proj.is_crit:
			_spawn_crit_knife(player, proj.damage * 0.5)


func _spawn_crit_knife(player: CharacterBody2D, dmg: float) -> void:
	var enemies := _get_enemies(player, 400.0)
	if enemies.is_empty():
		return
	var target: Node2D = enemies[0]
	var proj_scene: PackedScene = preload("res://scenes/projectile.tscn")
	var knife: Area2D = proj_scene.instantiate()
	knife.setup(player.global_position, target.global_position, CRIT_KNIFE_SPEED, dmg, 0, Color(1.0, 0.85, 0.0), 4.0)
	knife.weapon_id = "crit_boots"
	knife.is_crit = true
	knife.lifetime = CRIT_KNIFE_LIFETIME
	var pm: Node = _get_pm(player)
	if pm:
		pm.call_deferred("add_child", knife)


# --- Orbit ---

func update_orbit(weapon_id: String, data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float, orbit_instances: Dictionary, weapon_timers: Dictionary = {}) -> Dictionary:
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
		if level >= 3:
			radius = radius * BIBLE_LV3_RADIUS_MUL
		if SynergyManager and SynergyManager.has_synergy("bible_boots"):
			radius += SynergyManager.get_synergy_value("bible_boots", "radius_bonus", 20.0)
		damage = (1.0 if level < 3 else 2.0) * dmg_bonus
	else:
		return orbit_instances

	var key: String = weapon_id
	if orbit_instances.has(key) and is_instance_valid(orbit_instances[key]):
		var existing: Node2D = orbit_instances[key]
		if existing.orbit_count != orbit_count or existing.orbit_radius != radius:
			existing.queue_free()
			orbit_instances.erase(key)
		else:
			existing.damage = damage
			existing.global_position = player.global_position
			_fire_orbit_projectiles(weapon_id, data, level, player, dmg_bonus, orbit_instances, weapon_timers)
			return orbit_instances

	var instance := Node2D.new()
	instance.set_script(load("res://scripts/spin_blade.gd"))
	instance.setup(orbit_count, damage, radius, data.color, data.projectile_size)
	var rot_speed: float = data.orbit_speed + (0 if data.is_evolved else (level - 1) * 0.6)
	if weapon_id == "bible" and SynergyManager and SynergyManager.has_synergy("bible_boots"):
		rot_speed *= SynergyManager.get_synergy_value("bible_boots", "value", 1.5)
	instance.rotation_speed = rot_speed
	instance.weapon_id = weapon_id
	var pm: Node = _get_pm(player)
	if pm:
		pm.call_deferred("add_child", instance)
	instance.global_position = player.global_position
	orbit_instances[key] = instance
	_fire_orbit_projectiles(weapon_id, data, level, player, dmg_bonus, orbit_instances, weapon_timers)
	return orbit_instances


func _fire_orbit_projectiles(weapon_id: String, data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float, orbit_instances: Dictionary, weapon_timers: Dictionary) -> void:
	if data.orbit_fire_rate <= 0.0 or not orbit_instances.has(weapon_id):
		return
	var delta: float = _controller.get_process_delta_time()
	var fire_timer_key: String = "_%s_fire" % weapon_id
	if not weapon_timers.has(fire_timer_key):
		weapon_timers[fire_timer_key] = data.orbit_fire_rate
	weapon_timers[fire_timer_key] -= delta
	if weapon_timers[fire_timer_key] > 0.0:
		return
	weapon_timers[fire_timer_key] = data.orbit_fire_rate
	var orbit_node: Node2D = orbit_instances[weapon_id]
	if not is_instance_valid(orbit_node):
		return
	var fire_enemies := _get_enemies(player, 250.0)
	if fire_enemies.is_empty():
		return
	for i in range(data.orbit_count):
		var blade_angle: float = orbit_node._angle + (TAU * i / data.orbit_count)
		var fire_pos: Vector2 = orbit_node.global_position + Vector2(cos(blade_angle), sin(blade_angle)) * data.orbit_radius
		var target: Node2D = fire_enemies[i % fire_enemies.size()]
		var proj_scene: PackedScene = preload("res://scenes/projectile.tscn")
		var proj: Area2D = proj_scene.instantiate()
		proj.weapon_id = data.weapon_id
		if weapon_id == "holywater":
			proj.weapon_level = level
		proj.setup(fire_pos, target.global_position, data.projectile_speed, data.damage * dmg_bonus, 0, Color(0.9, 0.85, 0.5), data.projectile_size)
		var pm: Node = _get_pm(player)
		if pm:
			pm.call_deferred("add_child", proj)


# --- Lightning ---

func fire_lightning(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float) -> void:
	var damage: float
	var chains: int
	var bolt_count: int
	var range_val: float = data.projectile_range

	if SynergyManager and SynergyManager.has_synergy("lightning_magnet"):
		range_val += SynergyManager.get_synergy_value("lightning_magnet", "range_bonus", 50.0)

	if data.is_evolved:
		damage = data.damage * dmg_bonus
		chains = data.chain_count
		bolt_count = data.projectile_count
	else:
		damage = (5.0 + (level - 1)) * dmg_bonus
		chains = level - 1
		bolt_count = 1 if level < 3 else 2
		if SynergyManager and SynergyManager.has_synergy("lightning_magnet"):
			chains += int(SynergyManager.get_synergy_value("lightning_magnet", "chains", 1))

	var enemies := _get_enemies(player, range_val)
	if enemies.is_empty():
		return

	var hit_count := mini(bolt_count + chains, enemies.size())
	for i in range(hit_count):
		var target: Node2D = enemies[i]
		if target.has_method("take_damage"):
			var keen_crit: bool = _controller.notify_weapon_hit(player) if _controller.has_method("notify_weapon_hit") else false
			var lightning_damage: float = damage
			if keen_crit:
				lightning_damage *= player.crit_damage_mul
			target.take_damage(lightning_damage, data.weapon_id, keen_crit)
		var pm: Node = _get_pm(player)
		if pm:
			_get_effects().create_lightning_effect(player.global_position, target.global_position, data.color, pm)


# --- Cone ---

func fire_cone(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float) -> void:
	var angle: float = data.cone_angle + (level - 1) * CONE_ANGLE_PER_LEVEL
	var range_val: float = data.cone_range + (level - 1) * CONE_RANGE_PER_LEVEL
	var damage: float = (data.damage + (level - 1) * CONE_DAMAGE_PER_LEVEL) * dmg_bonus
	var burn: float = 0.0
	var burn_dur: float = 0.0
	if level >= 3:
		burn = FIRESTAFF_LV3_BURN_DPS
		burn_dur = FIRESTAFF_LV3_BURN_DURATION

	if SynergyManager and SynergyManager.has_synergy("firestaff_armor"):
		angle += SynergyManager.get_synergy_value("firestaff_armor", "angle", 40.0)
		if burn_dur > 0.0:
			burn_dur += SynergyManager.get_synergy_value("firestaff_armor", "burn_dur_bonus", 1.0)

	var player_dir: Vector2 = Vector2.RIGHT
	var velocity := player.velocity
	if velocity.length_squared() > 1.0:
		player_dir = velocity.normalized()

	var half_angle := deg_to_rad(angle / 2.0)
	var dir_angle: float = player_dir.angle()

	var enemies := _get_enemies(player, range_val)
	for enemy in enemies:
		var to_enemy: Vector2 = enemy.global_position - player.global_position
		var enemy_angle: float = to_enemy.angle()
		var angle_diff := absf(wrapf(enemy_angle - dir_angle, -PI, PI))
		if angle_diff <= half_angle:
			var keen_crit: bool = _controller.notify_weapon_hit(player) if _controller.has_method("notify_weapon_hit") else false
			var cone_damage: float = damage
			if keen_crit:
				cone_damage *= player.crit_damage_mul
			enemy.take_damage(cone_damage, data.weapon_id, keen_crit)
			if burn > 0.0 and enemy.has_method("apply_burn"):
				enemy.apply_burn(burn, burn_dur)

	var pm: Node = _get_pm(player)
	if pm:
		_get_effects().create_cone_effect(player.global_position, dir_angle, half_angle, range_val, data.color, pm)


# --- Aura ---

func update_aura(weapon_id: String, data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float, weapon_timers: Dictionary) -> void:
	var radius: float
	var slow: float
	var damage: float
	var freeze_pct: float
	var freeze_dur_bonus: float = 0.0

	if data.is_evolved:
		radius = data.aoe_radius
		slow = data.slow_pct
		damage = data.damage * dmg_bonus
		freeze_pct = data.freeze_pct
	else:
		radius = AURA_BASE_RADIUS + (level - 1) * AURA_RADIUS_PER_LEVEL
		slow = 0.3 + (level - 1) * 0.15
		damage = (1.0 + (level - 1) * AURA_DAMAGE_PER_LEVEL) * dmg_bonus
		freeze_pct = 0.08 if level >= 3 else 0.0

	if SynergyManager and SynergyManager.has_synergy("frost_regen"):
		freeze_pct += SynergyManager.get_synergy_value("frost_regen", "chance", 0.05)
		freeze_dur_bonus = SynergyManager.get_synergy_value("frost_regen", "dur_bonus", 0.5)

	var delta: float = _controller.get_process_delta_time()
	var enemies := _get_enemies(player, radius)
	for enemy in enemies:
		var keen_crit: bool = _controller.notify_weapon_hit(player) if _controller.has_method("notify_weapon_hit") else false
		var aura_damage: float = damage * delta
		if keen_crit:
			aura_damage *= player.crit_damage_mul
		enemy.take_damage(aura_damage, weapon_id, keen_crit)
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(slow)
		if freeze_pct > 0.0 and enemy.has_method("apply_freeze"):
			enemy.apply_freeze(freeze_pct * delta + freeze_dur_bonus)

	# Evolved blizzard: also fire lightning periodically
	if weapon_id == "blizzard":
		if not weapon_timers.has("_blizzard_lightning"):
			weapon_timers["_blizzard_lightning"] = 2.0
		weapon_timers["_blizzard_lightning"] -= delta
		if weapon_timers["_blizzard_lightning"] <= 0:
			weapon_timers["_blizzard_lightning"] = 2.0
			var bolt_enemies := _get_enemies(player, 300.0)
			var hit := mini(3, bolt_enemies.size())
			for i in range(hit):
				bolt_enemies[i].take_damage(8.0 * dmg_bonus, "blizzard")
				var pm: Node = _get_pm(player)
				if pm:
					_get_effects().create_lightning_effect(player.global_position, bolt_enemies[i].global_position, Color(0.5, 0.8, 1.0), pm)


# --- Boomerang (delegated to weapon_boomerang_fire.gd) ---

func _get_boomerang_fire() -> RefCounted:
	if not _boomerang_fire:
		_boomerang_fire = load("res://scripts/weapons/weapon_boomerang_fire.gd").new(_controller)
	return _boomerang_fire


func fire_boomerang(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float, weapon_timers: Dictionary, boomerang_instances: Array) -> Array:
	return _get_boomerang_fire().fire_boomerang(data, level, player, dmg_bonus, weapon_timers, boomerang_instances)


func _create_boomerang(pos: Vector2, dir: Vector2, dmg: float, prc: int, max_dist: float, return_spd: float, track_angle: float, col: Color, sz: float, wpn_id: String = "boomerang") -> Area2D:
	return _get_boomerang_fire()._create_boomerang(pos, dir, dmg, prc, max_dist, return_spd, track_angle, col, sz, wpn_id)


# --- Spiral (frostvortex) ---

func update_spiral(weapon_id: String, data: WeaponData, player: CharacterBody2D, dmg_bonus: float, spiral_instance: Node2D) -> Node2D:
	# If instance exists and is valid, just update damage
	if spiral_instance and is_instance_valid(spiral_instance):
		spiral_instance.damage = data.damage * dmg_bonus
		return spiral_instance
	# Create new spiral blade instance
	var instance := Node2D.new()
	instance.set_script(load("res://scripts/weapons/spiral_blade.gd"))
	instance.setup(
		data.spiral_blade_count,
		data.damage * dmg_bonus,
		data.spiral_min_radius,
		data.spiral_max_radius,
		data.spiral_expand_speed,
		data.color,
		data.slow_pct,
		data.freeze_pct
	)
	instance.weapon_id = weapon_id
	instance.global_position = player.global_position
	var pm: Node = _get_pm(player)
	if pm:
		pm.call_deferred("add_child", instance)
	return instance


# --- Pulse (holyshockwave) ---

func fire_pulse(data: WeaponData, player: CharacterBody2D, dmg_bonus: float) -> void:
	var ring: Node2D = Node2D.new()
	ring.set_script(load("res://scripts/weapons/pulse_ring.gd"))
	ring.setup(
		data.damage * dmg_bonus,
		data.pulse_max_radius,
		data.pulse_expand_time,
		data.pulse_ring_width,
		data.color,
		data.burn_dps,
		data.burn_duration
	)
	ring.weapon_id = data.weapon_id
	ring.global_position = player.global_position
	var pm: Node = _get_pm(player)
	if pm:
		pm.call_deferred("add_child", ring)


# --- Beam (thunderbeam) ---

const THUNDERBEAM_CHAIN_DAMAGE: float = 6.0
const THUNDERBEAM_CHAIN_RANGE: float = 120.0

func fire_beam(data: WeaponData, player: CharacterBody2D, dmg_bonus: float) -> void:
	var enemies := _get_enemies(player, data.projectile_range)
	if enemies.is_empty():
		return
	var target: Node2D = enemies[0]
	var direction: Vector2 = (target.global_position - player.global_position).normalized()

	var beam: Node2D = Node2D.new()
	beam.set_script(load("res://scripts/weapons/beam_line.gd"))
	beam.setup(
		data.damage * dmg_bonus,
		data.projectile_range,
		data.beam_width,
		data.beam_tick_interval,
		data.beam_active_duration,
		data.chain_count,
		THUNDERBEAM_CHAIN_DAMAGE * dmg_bonus,
		data.color,
		direction,
		player
	)
	beam.weapon_id = data.weapon_id
	beam.global_position = player.global_position
	var pm: Node = _get_pm(player)
	if pm:
		pm.call_deferred("add_child", beam)
