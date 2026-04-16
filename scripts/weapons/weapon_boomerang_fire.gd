extends RefCounted
## Boomerang firing logic extracted from weapon_fire.gd

# Boomerang
const BOOMERANG_SPEED: float = 280.0
const BOOMERANG_MAX_COUNT: int = 8

var _controller: Node = null


func _init(controller: Node) -> void:
	_controller = controller


func _get_pm(player: CharacterBody2D) -> Node:
	var parent: Node = player.get_parent()
	if parent and parent.has_node("ProjectileManager"):
		return parent.get_node("ProjectileManager")
	return null


func _get_enemies(player: Node2D, range_val: float) -> Array:
	return _controller._get_enemies_in_range(player, range_val)


func fire_boomerang(data: WeaponData, level: int, player: CharacterBody2D, dmg_bonus: float, weapon_timers: Dictionary, boomerang_instances: Array) -> Array:
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
		if SynergyManager and SynergyManager.has_synergy("boomerang_crit"):
			pierce += int(SynergyManager.get_synergy_value("boomerang_crit", "pierce_bonus", 1))
		cooldown = data.cooldown - (level - 1) * 0.4
		track_angle = data.boomerang_track_angle + (level - 1) * 0.26
		# Boomerang Lv3: Homing Tweak -- 50% more tracking at level >= 3
		if level >= 3:
			track_angle *= 1.5

	weapon_timers[data.weapon_id] = maxf(cooldown, 0.5)

	var valid_boomerangs := boomerang_instances.filter(func(b): return is_instance_valid(b))

	for i in range(count):
		if valid_boomerangs.size() >= BOOMERANG_MAX_COUNT:
			break

		var enemies := _get_enemies(player, 400.0)
		var target_dir: Vector2 = Vector2.RIGHT.rotated(randf() * TAU)
		if not enemies.is_empty():
			target_dir = player.global_position.direction_to(enemies[i % enemies.size()].global_position)

		var bm: Area2D = _create_boomerang(player.global_position, target_dir, damage, pierce, max_dist, data.boomerang_return_speed, track_angle, data.color, data.projectile_size, data.weapon_id)
		# Boomerang crit: keen eye (Ranger) then synergy check
		var is_keen_crit: bool = _controller.notify_weapon_hit(player) if _controller.has_method("notify_weapon_hit") else false
		if is_keen_crit:
			bm.damage *= player.crit_damage_mul
			bm.is_crit = true
		elif data.weapon_id == "boomerang" and SynergyManager and SynergyManager.has_synergy("boomerang_crit"):
			if randf() < player.crit_chance:
				bm.damage *= player.crit_damage_mul
				bm.is_crit = true
		bm.weapon_id = data.weapon_id
		var pm: Node = _get_pm(player)
		if pm:
			pm.call_deferred("add_child", bm)
			valid_boomerangs.append(bm)

	return valid_boomerangs


func _create_boomerang(pos: Vector2, dir: Vector2, dmg: float, prc: int, max_dist: float, return_spd: float, track_angle: float, col: Color, sz: float, wpn_id: String = "boomerang") -> Area2D:
	var bm_scene: PackedScene = preload("res://scenes/projectile.tscn")
	var bm: Area2D = bm_scene.instantiate()
	bm.global_position = pos
	bm.set_script(load("res://scripts/weapons/boomerang.gd"))
	bm.direction = dir
	bm.speed = BOOMERANG_SPEED
	bm.damage = dmg
	bm.pierce = prc
	bm.color = col
	bm.size = sz
	bm.weapon_id = wpn_id
	bm.setup_boomerang(pos, dir, max_dist, return_spd, track_angle)
	return bm
