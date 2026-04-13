extends Area2D

var xp_value: int = 5
var magnet_speed: float = 300.0
var is_moving_to_player: bool = false
var _player: Node2D = null


func _ready():
	var sprite = $Sprite as Sprite2D
	if sprite:
		if xp_value >= 15:
			sprite.texture = preload("res://assets/sprites/pickups/xp_gem_large.png")
		elif xp_value >= 10:
			sprite.texture = preload("res://assets/sprites/pickups/xp_gem_medium.png")
		else:
			sprite.texture = preload("res://assets/sprites/pickups/xp_gem_small.png")


func _physics_process(delta):
	if not _player or not is_instance_valid(_player):
		_player = _find_player()
		if not _player:
			return

	var dist = global_position.distance_to(_player.global_position)
	if dist <= _player.pickup_range:
		is_moving_to_player = true
	_check_frostaura_luckycoin()

	if is_moving_to_player:
		var direction = global_position.direction_to(_player.global_position)
		global_position += direction * magnet_speed * delta
		magnet_speed += 200.0 * delta
		if dist < 10.0:
			_collect()


func _find_player() -> Node2D:
	return GameManager.find_player()


func _collect():
	var xp: float = float(xp_value)
	if SaveManager:
		xp *= (1.0 + SaveManager.get_exp_bonus())
	xp *= GameManager.get_difficulty_mul("exp_mul")
	# Combo exp bonus: combo × 5%, max 50%
	var combo_bonus: float = minf(float(GameManager.combo_count) * GameManager.COMBO_EXP_RATE, GameManager.COMBO_MAX_BONUS)
	xp *= (1.0 + combo_bonus)
	GameManager.add_xp(xp)
	# magnet_maxhp synergy: 拾取宝石2%回复1HP
	if SynergyManager and SynergyManager.has_synergy("magnet_maxhp"):
		var heal_chance: float = SynergyManager.get_synergy_value("magnet_maxhp", "value", 0.02)
		if randf() < heal_chance:
			if _player and is_instance_valid(_player) and _player.is_alive:
				_player.heal(1.0)
	queue_free()


func _check_frostaura_luckycoin() -> void:
	if not SynergyManager or not SynergyManager.has_synergy("frostaura_luckycoin"):
		return
	if not _player or not is_instance_valid(_player):
		return
	# Expand pickup range if any nearby enemy is frozen
	var bonus: float = SynergyManager.get_synergy_value("frostaura_luckycoin", "value", 30.0)
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has("_freeze_timer") and enemy._freeze_timer > 0:
			var dist = global_position.distance_to(enemy.global_position)
			if dist < 100.0:
				# Expand effective range toward player
				var dist_to_player = global_position.distance_to(_player.global_position)
				if dist_to_player <= _player.pickup_range + bonus:
					is_moving_to_player = true
				break
