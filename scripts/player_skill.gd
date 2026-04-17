extends RefCounted
## PlayerSkill -- Skill, dash, and character passive subsystem extracted from player.gd.
## RefCounted helper: created by player.gd, delegates skill/dash/iron_will logic.
## All state remains on the player node; this module operates on it via reference.

# --- Dash constants ---
const DASH_INVINCIBILITY_TIME: float = 0.15

# --- Skill cooldown constants (canonical source: SkillData) ---
const MAGE_SKILL_COOLDOWN: float = SkillData.MAGE_SKILL_COOLDOWN
const WARRIOR_SKILL_COOLDOWN: float = SkillData.WARRIOR_SKILL_COOLDOWN
const RANGER_SKILL_COOLDOWN: float = SkillData.RANGER_SKILL_COOLDOWN

# --- Passive constants (canonical source: SkillData) ---
const MAGE_PASSIVE_DAMAGE_BONUS: float = SkillData.MAGE_PASSIVE_DAMAGE_BONUS
const WARRIOR_PASSIVE_ARMOR_BONUS: int = SkillData.WARRIOR_PASSIVE_ARMOR_BONUS
const WARRIOR_PASSIVE_HP_THRESHOLD: float = SkillData.WARRIOR_PASSIVE_HP_THRESHOLD
const WARRIOR_PASSIVE_DURATION: float = SkillData.WARRIOR_PASSIVE_DURATION
const WARRIOR_PASSIVE_COOLDOWN: float = SkillData.WARRIOR_PASSIVE_COOLDOWN
const RANGER_PASSIVE_HIT_COUNT: int = SkillData.RANGER_PASSIVE_HIT_COUNT

# --- Character exclusive passive constants (R12 TOP3 -- canonical source: SkillData) ---
const MAGE_DAMAGE_SCALE_BONUS: float = SkillData.MAGE_DAMAGE_SCALE_BONUS
const WARRIOR_ARMOR_MASTERY_BONUS: int = SkillData.WARRIOR_ARMOR_MASTERY_BONUS
const RANGER_CRIT_BOOST_BONUS: float = SkillData.RANGER_CRIT_BOOST_BONUS

# --- Afterimage constants ---
const AFTERIMAGE_ALPHA: float = 0.3
const AFTERIMAGE_DELAY: float = 0.03
const AFTERIMAGE_FADE_DURATION: float = 0.2

# --- Reference to the player node ---
var _player: CharacterBody2D = null


func _init(player: CharacterBody2D) -> void:
	_player = player


## Initialize skill state for the given character.
func init_skill(sid: String, cooldown: float) -> void:
	_player.skill_id = sid
	_player.skill_cooldown_max = cooldown
	_player.skill_timer = 0.0
	_player.is_skill_ready = true


## Process skill input -- cooldown ticking and activation check.
func process_skill_input(delta: float) -> void:
	# Update skill cooldown
	if not _player.is_skill_ready:
		_player.skill_timer -= delta
		_player.skill_cooldown_changed.emit(_player.skill_timer, _player.skill_cooldown_max)
		if _player.skill_timer <= 0.0:
			_player.skill_timer = 0.0
			_player.is_skill_ready = true
			_player.skill_ready_signal.emit(_player.skill_id)

	# Check for skill activation
	if Input.is_action_just_pressed("skill") and _player.is_skill_ready and _player.skill_id != "":
		_activate_skill()


func _activate_skill() -> void:
	_player.is_skill_ready = false
	_player.skill_timer = _player.skill_cooldown_max
	_player.skill_activated.emit(_player.skill_id)

	if not _player.skill_effects_node:
		return

	match _player.skill_id:
		"elemental_burst":
			_player.skill_effects_node.elemental_burst(_player, _player.damage_bonus)
		"shield_charge":
			var dir: Vector2 = _player.velocity.normalized() if _player.velocity.length_squared() > 1.0 else Vector2.DOWN
			_player.skill_effects_node.shield_charge(_player, dir, _player.damage_bonus)
		"arrow_rain":
			_player.skill_effects_node.arrow_rain(_player, _player.damage_bonus)


## Update Iron Will passive (Warrior only).
func update_iron_will(delta: float) -> void:
	if _player.skill_id != "shield_charge":
		return

	# Decrease internal cooldown
	if _player._iron_will_cooldown > 0:
		_player._iron_will_cooldown -= delta
		if _player._iron_will_cooldown <= 0:
			_player._iron_will_cooldown = 0.0

	# Decrease active duration
	if _player._iron_will_active:
		_player._iron_will_timer -= delta
		if _player._iron_will_timer <= 0:
			_player._iron_will_active = false
			_player._iron_will_timer = 0.0
			_player.armor -= WARRIOR_PASSIVE_ARMOR_BONUS

	# Check trigger condition
	if not _player._iron_will_active and _player._iron_will_cooldown <= 0:
		if _player.current_health > 0 and _player.current_health <= _player.max_health * WARRIOR_PASSIVE_HP_THRESHOLD:
			_player._iron_will_active = true
			_player._iron_will_timer = WARRIOR_PASSIVE_DURATION
			_player._iron_will_cooldown = WARRIOR_PASSIVE_COOLDOWN
			_player.armor += WARRIOR_PASSIVE_ARMOR_BONUS


## Spawn afterimages during dash.
func spawn_afterimages(sprite: Sprite2D, char_color: Color) -> void:
	for i in range(_player.dash_afterimage_count):
		var afterimage: Sprite2D = Sprite2D.new()
		afterimage.texture = sprite.texture
		afterimage.centered = true
		afterimage.modulate = Color(char_color.r, char_color.g, char_color.b, AFTERIMAGE_ALPHA)
		afterimage.z_index = -1
		_player.get_parent().call_deferred("add_child", afterimage)
		var tween: Tween = afterimage.create_tween()
		tween.tween_interval(i * AFTERIMAGE_DELAY)
		tween.tween_property(afterimage, "modulate:a", 0.0, AFTERIMAGE_FADE_DURATION)
		tween.tween_callback(afterimage.queue_free)
