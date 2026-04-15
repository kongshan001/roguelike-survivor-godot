extends CharacterBody2D


signal died

# Combat constants
const HIT_INVINCIBILITY_TIME: float = 0.5
const MIN_DAMAGE: float = 1.0
const LOW_HP_THRESHOLD: float = 0.3
const LOW_HP_ARMOR_BONUS: int = 3
const FLASH_INTERVAL: float = 0.1
const FLASH_VISIBLE_THRESHOLD: float = 0.05

# Dash constants
const DASH_INVINCIBILITY_TIME: float = 0.15

# Regen constants
const BASE_REGEN_INTERVAL: float = 5.0
const MOVING_REGEN_INTERVAL: float = 2.5

# Passive bonus constants
const SPEED_BOOTS_BONUS: float = 0.15
const MAGNET_RANGE_BONUS: float = 0.3
const CRIT_CHANCE_BONUS: float = 0.08
const MAX_HP_BONUS: float = 2.0
const REGEN_AMOUNT_BONUS: float = 1.0
const CRIT_DAMAGE_BONUS: float = 0.5
const DEFAULT_PASSIVE_MAX_STACK: int = 3

# Afterimage constants
const AFTERIMAGE_ALPHA: float = 0.3
const AFTERIMAGE_DELAY: float = 0.03
const AFTERIMAGE_FADE_DURATION: float = 0.2

@export var move_speed: float = 160.0
@export var max_health: float = 8.0
@export var pickup_range: float = 35.0
@export var armor: int = 0

var current_health: float
var invincible_timer: float = 0.0
var is_alive: bool = true
var regen_timer: float = 0.0
var regen_amount: float = 0.0
var speed_multiplier: float = 1.0
var owned_weapons: Dictionary = {}
var owned_passives: Dictionary = {}

# Character-specific stats
var crit_chance: float = 0.0
var crit_damage_mul: float = 2.0
var damage_bonus: float = 0.0  # mage: +20%
var is_moving: bool = false

# Dash system (H5 DASH config)
var dash_distance: float = 80.0
var dash_duration: float = 0.15
var dash_cooldown: float = 2.5
var dash_timer: float = 0.0
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_afterimage_count: int = 3

@onready var hurtbox: Area2D = $Hurtbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite
var _char_color: Color = Color.WHITE


func _ready():
	# Apply shop bonuses (SaveManager may be null in GUT tests)
	if SaveManager:
		max_health += float(SaveManager.get_hp_bonus())
		move_speed += move_speed * SaveManager.get_speed_bonus()
		pickup_range += SaveManager.get_pickup_bonus()
		damage_bonus += SaveManager.get_weapon_dmg_bonus()

	current_health = max_health
	GameManager.health_changed.emit(current_health, max_health)

	# Apply character-specific bonuses
	match GameManager.selected_character:
		"warrior":
			armor += 1
			sprite.texture = preload("res://assets/sprites/characters/warrior.png")
			_char_color = Color(0.83, 0.18, 0.18)
		"ranger":
			crit_chance += 0.1
			sprite.texture = preload("res://assets/sprites/characters/ranger.png")
			_char_color = Color(0.18, 0.45, 0.2)
		"mage":
			damage_bonus += 0.2
			sprite.texture = preload("res://assets/sprites/characters/mage.png")
			_char_color = Color(0.08, 0.4, 0.75)


func _physics_process(delta):
	if not is_alive:
		return

	# Dash cooldown
	if dash_timer > 0:
		dash_timer -= delta

	# Dash input
	if is_dashing:
		velocity = dash_direction * (dash_distance / dash_duration)
		move_and_slide()
		is_dashing = false
		invincible_timer = maxf(invincible_timer, DASH_INVINCIBILITY_TIME)
		dash_timer = dash_cooldown
		return

	if Input.is_action_just_pressed("dash") and dash_timer <= 0:
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if direction.length_squared() > 0.01:
			dash_direction = direction.normalized()
			is_dashing = true
			_spawn_afterimages()
			return

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed * speed_multiplier
	is_moving = velocity.length_squared() > 1.0
	move_and_slide()

	if invincible_timer > 0:
		invincible_timer -= delta
		sprite.visible = fmod(invincible_timer, FLASH_INTERVAL) > FLASH_VISIBLE_THRESHOLD
	else:
		sprite.visible = true

	if regen_amount > 0:
		regen_timer += delta
		var regen_interval: float = BASE_REGEN_INTERVAL
		# Synergy: boots_regen - moving regens 2x faster
		if is_moving and has_passive("speedboots") and has_passive("regen"):
			regen_interval = MOVING_REGEN_INTERVAL
		if regen_timer >= regen_interval:
			regen_timer -= regen_interval
			heal(regen_amount)

	GameManager.update_combo(delta)


func take_damage(amount: float):
	if invincible_timer > 0 or not is_alive:
		return

	var effective_armor: int = armor
	# armor_maxhp synergy: 护甲效果翻倍
	if SynergyManager and SynergyManager.has_synergy("armor_maxhp"):
		effective_armor *= 2
	# armor_regen synergy: 低HP时临时+3护甲
	if SynergyManager and SynergyManager.has_synergy("armor_regen"):
		if current_health <= max_health * LOW_HP_THRESHOLD:
			effective_armor += LOW_HP_ARMOR_BONUS
	var actual_damage = maxf(MIN_DAMAGE, amount - effective_armor)
	current_health -= actual_damage
	GameManager.damage_taken = true
	GameManager.health_changed.emit(current_health, max_health)

	if current_health <= 0:
		current_health = 0
		die()
	else:
		invincible_timer = HIT_INVINCIBILITY_TIME


func heal(amount: float):
	current_health = minf(current_health + amount, max_health)
	GameManager.health_changed.emit(current_health, max_health)


func die():
	is_alive = false
	died.emit()
	GameManager.is_game_over = true
	GameManager.player_died.emit()
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/game_over_screen.tscn")
	)


func add_weapon(weapon_id: String):
	owned_weapons[weapon_id] = 1
	if SynergyManager:
		SynergyManager.check_synergies(owned_weapons, owned_passives)


func upgrade_weapon(weapon_id: String) -> bool:
	if owned_weapons.has(weapon_id) and owned_weapons[weapon_id] < 3:
		owned_weapons[weapon_id] += 1
		return true
	return false


func get_weapon_level(weapon_id: String) -> int:
	return owned_weapons.get(weapon_id, 0)


func has_passive(passive_id: String) -> bool:
	return owned_passives.get(passive_id, 0) > 0


func apply_passive(passive_id: String):
	if not owned_passives.has(passive_id):
		owned_passives[passive_id] = 0

	var max_stack: int = DEFAULT_PASSIVE_MAX_STACK
	if UpgradePool._passives.has(passive_id):
		max_stack = UpgradePool._passives[passive_id].get("max_stack", DEFAULT_PASSIVE_MAX_STACK)

	if owned_passives[passive_id] >= max_stack:
		return
	owned_passives[passive_id] += 1

	match passive_id:
		"speedboots":
			speed_multiplier += SPEED_BOOTS_BONUS
		"armor":
			armor += 1
		"magnet":
			pickup_range += pickup_range * MAGNET_RANGE_BONUS
		"crit":
			crit_chance += CRIT_CHANCE_BONUS
		"maxhp":
			max_health += 2.0
			heal(2.0)
		"regen":
			regen_amount += REGEN_AMOUNT_BONUS
		"luckycoin":
			crit_damage_mul += CRIT_DAMAGE_BONUS

	# Re-check synergies after passive change
	if SynergyManager:
		SynergyManager.check_synergies(owned_weapons, owned_passives)


func _spawn_afterimages() -> void:
	for i in range(dash_afterimage_count):
		var afterimage: ColorRect = ColorRect.new()
		afterimage.size = Vector2(32, 32)
		afterimage.position = Vector2(-16, -16)
		afterimage.color = Color(_char_color.r, _char_color.g, _char_color.b, AFTERIMAGE_ALPHA)
		afterimage.z_index = -1
		get_parent().call_deferred("add_child", afterimage)
		var tween: Tween = afterimage.create_tween()
		tween.tween_interval(i * AFTERIMAGE_DELAY)
		tween.tween_property(afterimage, "color:a", 0.0, AFTERIMAGE_FADE_DURATION)
		tween.tween_callback(afterimage.queue_free)
