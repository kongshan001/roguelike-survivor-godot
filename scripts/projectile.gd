extends Area2D

var speed: float = 300.0
var damage: float = 10.0
var pierce: int = 1
var direction: Vector2 = Vector2.RIGHT
var color: Color = Color.WHITE
var size: float = 8.0
var lifetime: float = 5.0
var _hit_enemies: Array = []

# Status effect support
var burn_dps: float = 0.0
var burn_duration: float = 0.0
var slow_pct: float = 0.0

# Kill attribution
var weapon_id: String = ""
var is_crit: bool = false
var weapon_level: int = 1

# Knife Lv3 Ricochet constants
const KNIFE_LV3_RICOCHET_RANGE: float = 100.0
const KNIFE_LV3_RICOCHET_DAMAGE_MUL: float = 0.5
const KNIFE_LV3_RICOCHET_SPEED: float = 300.0
const KNIFE_LV3_RICOCHET_SIZE: float = 4.0
const KNIFE_LV3_RICOCHET_LIFETIME: float = 0.5


func setup(pos: Vector2, target_pos: Vector2, spd: float, dmg: float, prc: int, col: Color, sz: float):
	global_position = pos
	direction = pos.direction_to(target_pos)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	speed = spd
	damage = dmg
	pierce = prc
	color = col
	size = sz
	var sprite = $Sprite as Sprite2D
	if sprite:
		sprite.modulate = color
		var tex_path := "res://assets/sprites/weapons/%s.png" % weapon_id
		if weapon_id != "" and ResourceLoader.exists(tex_path):
			sprite.texture = load(tex_path)
		else:
			sprite.texture = preload("res://assets/sprites/weapons/enemy_bullet.png")
		var base_size: float = 16.0
		var scale_factor: float = (size * 2.0) / base_size
		sprite.scale = Vector2(scale_factor, scale_factor)
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = size


func set_status_effects(burn: float = 0.0, burn_dur: float = 0.0, slow: float = 0.0):
	burn_dps = burn
	burn_duration = burn_dur
	slow_pct = slow


func _physics_process(delta):
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	rotation = direction.angle()


func _on_body_entered(body: Node2D):
	if body.is_in_group("enemies") and body.has_method("take_damage") and not body in _hit_enemies:
		body.take_damage(damage, weapon_id, is_crit)
		# Apply status effects
		if burn_dps > 0.0 and burn_duration > 0.0 and body.has_method("apply_burn"):
			body.apply_burn(burn_dps, burn_duration)
		if slow_pct > 0.0 and body.has_method("apply_slow"):
			body.apply_slow(slow_pct)
		_hit_enemies.append(body)

		# Knife Lv3 Ricochet: bounce to a nearby enemy
		if weapon_id == "knife" and weapon_level >= 3:
			_spawn_ricochet(body)

		pierce -= 1
		if pierce <= 0:
			queue_free()


func _spawn_ricochet(primary_target: Node2D) -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var best_enemy: Node2D = null
	var best_dist: float = KNIFE_LV3_RICOCHET_RANGE
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.is_alive and enemy != primary_target and not enemy in _hit_enemies:
			var dist := global_position.distance_to(enemy.global_position)
			if dist < best_dist:
				best_dist = dist
				best_enemy = enemy
	if best_enemy == null:
		return
	var ricochet: Area2D = preload("res://scenes/projectile.tscn").instantiate()
	ricochet.global_position = primary_target.global_position
	ricochet.direction = primary_target.global_position.direction_to(best_enemy.global_position)
	ricochet.speed = KNIFE_LV3_RICOCHET_SPEED
	ricochet.damage = damage * KNIFE_LV3_RICOCHET_DAMAGE_MUL
	ricochet.pierce = 0
	ricochet.color = Color(1.0, 0.9, 0.5)  # Golden tint
	ricochet.size = KNIFE_LV3_RICOCHET_SIZE
	ricochet.weapon_id = "knife"
	ricochet.weapon_level = weapon_level
	ricochet.lifetime = KNIFE_LV3_RICOCHET_LIFETIME
	get_parent().call_deferred("add_child", ricochet)
