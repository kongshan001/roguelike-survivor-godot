extends Node

var _weapon_timers: Dictionary = {}
var _registered: bool = false
var _orbit_instances: Dictionary = {}
var _boomerang_instances: Array = []
var _effects: RefCounted = null
var _weapon_fire: RefCounted = null


func _get_effects() -> RefCounted:
	if not _effects:
		_effects = load("res://scripts/weapons/weapon_effects.gd").new()
	return _effects


func _get_projectile_manager(player: CharacterBody2D) -> Node:
	var parent: Node = player.get_parent()
	if parent and parent.has_node("ProjectileManager"):
		return parent.get_node("ProjectileManager")
	return null


func _get_weapon_fire() -> RefCounted:
	if not _weapon_fire:
		_weapon_fire = load("res://scripts/weapons/weapon_fire.gd").new(self)
	return _weapon_fire


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

	# Mage passive: Mana Attunement -- +10% weapon damage while skill is on cooldown
	if player.skill_id == "elemental_burst" and not player.is_skill_ready:
		dmg_bonus *= (1.0 + 0.10)

	var wf: RefCounted = _get_weapon_fire()
	match data.weapon_type:
		"projectile":
			wf.fire_projectile(data, level, player, dmg_bonus)
		"orbit":
			_orbit_instances = wf.update_orbit(weapon_id, data, level, player, dmg_bonus, _orbit_instances, _weapon_timers)
		"lightning":
			wf.fire_lightning(data, level, player, dmg_bonus)
		"cone":
			wf.fire_cone(data, level, player, dmg_bonus)
		"aura":
			wf.update_aura(weapon_id, data, level, player, dmg_bonus, _weapon_timers)
		"boomerang":
			_boomerang_instances = wf.fire_boomerang(data, level, player, dmg_bonus, _weapon_timers, _boomerang_instances)


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
	if _orbit_instances.has(weapon_id):
		var inst: Node2D = _orbit_instances[weapon_id]
		if is_instance_valid(inst):
			inst.queue_free()
		_orbit_instances.erase(weapon_id)
	_boomerang_instances = _boomerang_instances.filter(func(b): return not is_instance_valid(b) or b.get("weapon_id") != weapon_id)
	_weapon_timers.erase(weapon_id)


## Increment keen_eye counter and return true if this hit should be a guaranteed crit (Ranger passive)
func notify_weapon_hit(player: CharacterBody2D) -> bool:
	if player.skill_id != "arrow_rain":
		return false
	player._keen_eye_counter += 1
	if player._keen_eye_counter >= 5:
		player._keen_eye_counter = 0
		return true
	return false


func _process(_delta):
	for key in _orbit_instances:
		var inst: Node2D = _orbit_instances[key]
		if is_instance_valid(inst):
			var player: CharacterBody2D = get_parent()
			if player and is_instance_valid(player):
				inst.global_position = player.global_position
