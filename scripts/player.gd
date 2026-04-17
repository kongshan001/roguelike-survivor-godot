extends CharacterBody2D

signal died
signal skill_activated(skill_id: String)
signal skill_cooldown_changed(current: float, max_val: float)
signal skill_ready_signal(skill_id: String)

# Combat constants
const HIT_INVINCIBILITY_TIME: float = 0.5
const MIN_DAMAGE: float = 1.0
const LOW_HP_THRESHOLD: float = 0.3
const LOW_HP_ARMOR_BONUS: int = 3
const FLASH_INTERVAL: float = 0.1
const FLASH_VISIBLE_THRESHOLD: float = 0.05
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

# Afterimage constants (delegated to player_skill.gd)
const AFTERIMAGE_ALPHA: float = 0.3
const AFTERIMAGE_DELAY: float = 0.03
const AFTERIMAGE_FADE_DURATION: float = 0.2

# Skill cooldown constants (canonical source: SkillData)
const MAGE_SKILL_COOLDOWN: float = SkillData.MAGE_SKILL_COOLDOWN
const WARRIOR_SKILL_COOLDOWN: float = SkillData.WARRIOR_SKILL_COOLDOWN
const RANGER_SKILL_COOLDOWN: float = SkillData.RANGER_SKILL_COOLDOWN

# Passive constants (canonical source: SkillData)
const MAGE_PASSIVE_DAMAGE_BONUS: float = SkillData.MAGE_PASSIVE_DAMAGE_BONUS
const WARRIOR_PASSIVE_ARMOR_BONUS: int = SkillData.WARRIOR_PASSIVE_ARMOR_BONUS
const WARRIOR_PASSIVE_HP_THRESHOLD: float = SkillData.WARRIOR_PASSIVE_HP_THRESHOLD
const WARRIOR_PASSIVE_DURATION: float = SkillData.WARRIOR_PASSIVE_DURATION
const WARRIOR_PASSIVE_COOLDOWN: float = SkillData.WARRIOR_PASSIVE_COOLDOWN
const RANGER_PASSIVE_HIT_COUNT: int = SkillData.RANGER_PASSIVE_HIT_COUNT

# Character exclusive passive constants (R12 TOP3 -- canonical source: SkillData)
const MAGE_DAMAGE_SCALE_BONUS: float = SkillData.MAGE_DAMAGE_SCALE_BONUS
const WARRIOR_ARMOR_MASTERY_BONUS: int = SkillData.WARRIOR_ARMOR_MASTERY_BONUS
const RANGER_CRIT_BOOST_BONUS: float = SkillData.RANGER_CRIT_BOOST_BONUS

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

# Skill system
var skill_id: String = ""
var skill_cooldown_max: float = 20.0
var skill_timer: float = 0.0
var is_skill_ready: bool = true
var skill_effects_node: Node = null

# Delegated state (iron_will managed by player_skill.gd)
var _keen_eye_counter: int = 0
var _iron_will_active: bool = false
var _iron_will_timer: float = 0.0
var _iron_will_cooldown: float = 0.0
var _burn_dps: float = 0.0
var _burn_timer: float = 0.0

const ANIM_INTERVAL: float = 1.0 / 4.0  # 4 FPS

@onready var hurtbox: Area2D = $Hurtbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite
var _char_color: Color = Color.WHITE

# Animation frame state
var _anim_time: float = 0.0
var _anim_frame: int = 0
var _idle_texture: Texture2D = null
var _action_texture: Texture2D = null

# Skill module (delegated from player_skill.gd)
var _skill_module: RefCounted = null


func _ready():
	# Apply shop bonuses (SaveManager may be null in GUT tests)
	if SaveManager:
		max_health += float(SaveManager.get_hp_bonus())
		move_speed += move_speed * SaveManager.get_speed_bonus()
		pickup_range += SaveManager.get_pickup_bonus()
		damage_bonus += SaveManager.get_weapon_dmg_bonus()

	current_health = max_health
	GameManager.health_changed.emit(current_health, max_health)

	# Always create skill effects node (even when no character selected)
	skill_effects_node = Node.new()
	skill_effects_node.set_script(load("res://scripts/skill_effects.gd"))
	add_child(skill_effects_node)

	# Initialize skill module
	_skill_module = load("res://scripts/player_skill.gd").new(self)

	# Apply character-specific bonuses and animation textures
	_setup_character_animation()


func _init_skill(sid: String, cooldown: float) -> void:
	_skill_module.init_skill(sid, cooldown)


func _setup_character_animation() -> void:
	match GameManager.selected_character:
		"warrior":
			armor += 1
			_char_color = Color(0.83, 0.18, 0.18)
			_idle_texture = preload("res://assets/sprites/characters/warrior.png")
			_action_texture = _load_texture_safe("res://assets/sprites/characters/warrior_block.png")
			_init_skill("shield_charge", WARRIOR_SKILL_COOLDOWN)
		"ranger":
			crit_chance += 0.1
			_char_color = Color(0.18, 0.45, 0.2)
			_idle_texture = preload("res://assets/sprites/characters/ranger.png")
			_action_texture = _load_texture_safe("res://assets/sprites/characters/ranger_draw.png")
			_init_skill("arrow_rain", RANGER_SKILL_COOLDOWN)
		"mage":
			damage_bonus += 0.2
			_char_color = Color(0.08, 0.4, 0.75)
			_idle_texture = preload("res://assets/sprites/characters/mage.png")
			_action_texture = _load_texture_safe("res://assets/sprites/characters/mage_cast.png")
			_init_skill("elemental_burst", MAGE_SKILL_COOLDOWN)
	if _idle_texture:
		sprite.texture = _idle_texture


func _load_texture_safe(path: String) -> Texture2D:
	# Try ResourceLoader first (works when .import file exists)
	# Use exists() to avoid printing error when file is not yet imported
	if ResourceLoader.exists(path):
		var tex: Texture2D = load(path)
		if tex:
			return tex
	# Fallback: load raw PNG via Image -> ImageTexture (works without .import)
	var global_path: String = ProjectSettings.globalize_path(path)
	if global_path == path or global_path == "":
		# globalize_path failed, construct from project data dir
		global_path = OS.get_data_dir().get_base_dir().get_base_dir() + "/" + path.replace("res://", "")
	if FileAccess.file_exists(global_path):
		var img: Image = Image.new()
		if img.load(global_path) == OK:
			var img_tex: ImageTexture = ImageTexture.create_from_image(img)
			img_tex.take_over_path(path)
			return img_tex
	return null


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

	# Skill input (E key)
	_process_skill_input(delta)

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed * speed_multiplier
	# Overcharge synergy: +5% move speed
	if SynergyManager:
		var oc_bonus: float = SynergyManager.get_speed_bonus("overcharge")
		if oc_bonus > 0.0:
			velocity *= (1.0 + oc_bonus)
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

	# Iron Will passive (Warrior)
	_update_iron_will(delta)

	# Burn DOT (from fire_slime burn aura)
	if _burn_timer > 0:
		_burn_timer -= delta
		var burn_dmg: float = _burn_dps * delta
		if burn_dmg > 0.0:
			current_health -= burn_dmg
			GameManager.damage_taken = true
			GameManager.health_changed.emit(current_health, max_health)
			if current_health <= 0:
				current_health = 0
				die()
		if _burn_timer <= 0:
			_burn_dps = 0.0

	GameManager.update_combo(delta)

	# Character walk animation
	if is_moving and _idle_texture:
		_anim_time += delta
		if _anim_time >= ANIM_INTERVAL:
			_anim_time -= ANIM_INTERVAL
			_anim_frame = 1 - _anim_frame
			sprite.texture = _action_texture if _anim_frame == 1 else _idle_texture
	else:
		_anim_time = 0.0
		_anim_frame = 0
		if _idle_texture:
			sprite.texture = _idle_texture

# --- Delegated to player_skill.gd ---
func _process_skill_input(delta: float) -> void:
	_skill_module.process_skill_input(delta)

func _activate_skill() -> void:
	_skill_module._activate_skill()

func _update_iron_will(delta: float) -> void:
	_skill_module.update_iron_will(delta)

# --- Combat ---
func take_damage(amount: float):
	if invincible_timer > 0 or not is_alive:
		return

	var effective_armor: int = armor
	# armor_maxhp synergy
	if SynergyManager and SynergyManager.has_synergy("armor_maxhp"):
		effective_armor *= 2
	# armor_regen synergy
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

func apply_burn(dps: float, duration: float) -> void:
	_burn_dps = maxf(_burn_dps, dps)
	_burn_timer = maxf(_burn_timer, duration)

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

# --- Weapon/Passive management ---
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
	elif UpgradePool._character_passives.has(passive_id):
		max_stack = UpgradePool._character_passives[passive_id].get("max_stack", 1)

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
		"mage_damage_scale":
			damage_bonus += MAGE_DAMAGE_SCALE_BONUS
		"warrior_armor_mastery":
			armor += WARRIOR_ARMOR_MASTERY_BONUS
		"ranger_crit_boost":
			crit_chance += RANGER_CRIT_BOOST_BONUS

	# Re-check synergies after passive change
	if SynergyManager:
		SynergyManager.check_synergies(owned_weapons, owned_passives)

func _spawn_afterimages() -> void:
	_skill_module.spawn_afterimages(sprite, _char_color)
