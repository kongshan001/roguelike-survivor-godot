extends "res://addons/gut/test.gd"
## Unit tests for Character Active Skills system
## Covers: Mage Elemental Burst, Warrior Shield Charge, Ranger Arrow Rain,
## passive traits (Mana Attunement, Iron Will, Keen Eye)
## Reference: docs/superpowers/specs/character-skills.md
##
## Implementation notes:
## - Cooldown constants: in player.gd (accessible via _player.CONST)
## - Damage/radius/effect constants: in skill_effects.gd (verified via code review)
## - Passive constants: in player.gd (accessible via _player.CONST)
## - Player skill state: skill_id, skill_timer, skill_cooldown_max, is_skill_ready
## - Passive state: _iron_will_active, _iron_will_timer, _iron_will_cooldown


var _player: CharacterBody2D
var _arena: Node2D


func before_each():
	GameManager.reset()
	GameManager.is_game_over = false
	GameManager.selected_difficulty = "normal"
	GameManager.selected_character = ""
	GameManager.elapsed_time = 0.0
	if SynergyManager:
		SynergyManager.active_synergies.clear()
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	UpgradePool.ensure_weapons_registered()

	_arena = Node2D.new()
	_arena.name = "Arena"
	add_child_autofree(_arena)

	var pm = Node.new()
	pm.name = "ProjectileManager"
	_arena.add_child(pm)

	var pkm = Node.new()
	pkm.name = "PickupManager"
	_arena.add_child(pkm)

	_player = load("res://scenes/player.tscn").instantiate()
	_player.global_position = Vector2(400, 300)
	_player.add_to_group("players")
	_arena.add_child(_player)

	# SaveManager state isolation
	if SaveManager:
		SaveManager.shop_upgrades = {}
		if "total_souls" in SaveManager:
			SaveManager.total_souls = 0
		if "endless_unlocked" in SaveManager:
			SaveManager.endless_unlocked = false

	await get_tree().process_frame


func after_each():
	await get_tree().process_frame


func _set_character(char_name: String) -> void:
	# Helper: set up player skill state for a specific character.
	# Uses _init_skill directly to avoid re-instantiation issues.
	GameManager.selected_character = char_name
	# Clean up existing skill effects node
	if _player.skill_effects_node and is_instance_valid(_player.skill_effects_node):
		_player.skill_effects_node.queue_free()
		_player.skill_effects_node = null
	# Reset Iron Will state from previous character
	if _player._iron_will_active:
		_player.armor -= _player.WARRIOR_PASSIVE_ARMOR_BONUS
	_player._iron_will_active = false
	_player._iron_will_timer = 0.0
	_player._iron_will_cooldown = 0.0
	# Initialize skill for the character
	match char_name:
		"mage":
			_player._init_skill("elemental_burst", _player.MAGE_SKILL_COOLDOWN)
		"warrior":
			_player._init_skill("shield_charge", _player.WARRIOR_SKILL_COOLDOWN)
		"ranger":
			_player._init_skill("arrow_rain", _player.RANGER_SKILL_COOLDOWN)
	await get_tree().process_frame


# =====================================================================
# SCRIPT LOADING
# =====================================================================

func test_skill_effects_script_loads():
	assert_not_null(load("res://scripts/skill_effects.gd"), "skill_effects.gd should load")


func test_player_script_has_skill_constants():
	assert_ne(_player.MAGE_SKILL_COOLDOWN, 0.0, "MAGE_SKILL_COOLDOWN should exist")
	assert_ne(_player.WARRIOR_SKILL_COOLDOWN, 0.0, "WARRIOR_SKILL_COOLDOWN should exist")
	assert_ne(_player.RANGER_SKILL_COOLDOWN, 0.0, "RANGER_SKILL_COOLDOWN should exist")


# =====================================================================
# COOLDOWN CONSTANTS (player.gd)
# =====================================================================

func test_mage_skill_cooldown():
	assert_eq(_player.MAGE_SKILL_COOLDOWN, 20.0, "Mage cooldown should be 20.0s")


func test_warrior_skill_cooldown():
	assert_eq(_player.WARRIOR_SKILL_COOLDOWN, 15.0, "Warrior cooldown should be 15.0s")


func test_ranger_skill_cooldown():
	assert_eq(_player.RANGER_SKILL_COOLDOWN, 18.0, "Ranger cooldown should be 18.0s")


# =====================================================================
# PASSIVE CONSTANTS (player.gd)
# =====================================================================

func test_mage_passive_damage_bonus():
	assert_eq(_player.MAGE_PASSIVE_DAMAGE_BONUS, 0.10, "Mana Attunement should be 0.10")


func test_warrior_passive_armor_bonus():
	assert_eq(_player.WARRIOR_PASSIVE_ARMOR_BONUS, 3, "Iron Will armor bonus should be 3")


func test_warrior_passive_hp_threshold():
	assert_eq(_player.WARRIOR_PASSIVE_HP_THRESHOLD, 0.30, "Iron Will threshold should be 0.30")


func test_warrior_passive_duration():
	assert_eq(_player.WARRIOR_PASSIVE_DURATION, 3.0, "Iron Will duration should be 3.0s")


func test_warrior_passive_cooldown():
	assert_eq(_player.WARRIOR_PASSIVE_COOLDOWN, 30.0, "Iron Will cooldown should be 30.0s")


func test_ranger_passive_hit_count():
	assert_eq(_player.RANGER_PASSIVE_HIT_COUNT, 5, "Keen Eye hit count should be 5")


# =====================================================================
# PLAYER SKILL STATE - Signals
# =====================================================================

func test_player_skill_signals_exist():
	assert_has_signal(_player, "skill_activated", "Player should have skill_activated signal")
	assert_has_signal(_player, "skill_cooldown_changed", "Player should have skill_cooldown_changed signal")
	assert_has_signal(_player, "skill_ready_signal", "Player should have skill_ready_signal signal")


# =====================================================================
# PLAYER SKILL STATE - Initialization per character
# =====================================================================

func test_mage_skill_id_set_on_ready():
	_set_character("mage")
	assert_eq(_player.skill_id, "elemental_burst", "Mage skill_id should be elemental_burst")


func test_warrior_skill_id_set_on_ready():
	_set_character("warrior")
	assert_eq(_player.skill_id, "shield_charge", "Warrior skill_id should be shield_charge")


func test_ranger_skill_id_set_on_ready():
	_set_character("ranger")
	assert_eq(_player.skill_id, "arrow_rain", "Ranger skill_id should be arrow_rain")


func test_mage_cooldown_max_set():
	_set_character("mage")
	assert_eq(_player.skill_cooldown_max, 20.0, "Mage skill_cooldown_max should be 20.0")


func test_warrior_cooldown_max_set():
	_set_character("warrior")
	assert_eq(_player.skill_cooldown_max, 15.0, "Warrior skill_cooldown_max should be 15.0")


func test_ranger_cooldown_max_set():
	_set_character("ranger")
	assert_eq(_player.skill_cooldown_max, 18.0, "Ranger skill_cooldown_max should be 18.0")


func test_skill_starts_ready():
	assert_eq(_player.skill_timer, 0.0, "Skill timer should start at 0")
	assert_true(_player.is_skill_ready, "Skill should start ready")


func test_skill_effects_node_created():
	assert_not_null(_player.skill_effects_node, "Skill effects node should be created")


# =====================================================================
# PLAYER SKILL STATE - Cooldown mechanics
# =====================================================================

func test_skill_cooldown_decreases():
	_player.is_skill_ready = false
	_player.skill_timer = 5.0
	_player._process_skill_input(1.0)
	assert_lt(_player.skill_timer, 5.0, "Cooldown should decrease over time")


func test_skill_ready_after_cooldown_expires():
	_player.is_skill_ready = false
	_player.skill_timer = 0.5
	_player._process_skill_input(1.0)
	assert_eq(_player.skill_timer, 0.0, "Timer should be 0 after cooldown")
	assert_true(_player.is_skill_ready, "Skill should be ready after cooldown")


func test_skill_cooldown_does_not_go_negative():
	_player.is_skill_ready = false
	_player.skill_timer = 0.1
	_player._process_skill_input(1.0)
	assert_eq(_player.skill_timer, 0.0, "Timer should clamp to 0")


func test_skill_cooldown_changes_emits_signal():
	watch_signals(_player)
	_player.is_skill_ready = false
	_player.skill_timer = 5.0
	_player._process_skill_input(1.0)
	assert_signal_emitted(_player, "skill_cooldown_changed")


func test_skill_ready_emits_signal():
	watch_signals(_player)
	_player.is_skill_ready = false
	_player.skill_timer = 0.5
	_player._process_skill_input(1.0)
	assert_signal_emitted(_player, "skill_ready_signal")


# =====================================================================
# WARRIOR - Iron Will Passive
# =====================================================================

func test_iron_will_triggers_at_low_hp():
	_set_character("warrior")
	_player.current_health = _player.max_health * 0.3
	_player._iron_will_cooldown = 0.0
	_player._iron_will_active = false
	_player._update_iron_will(0.016)
	assert_true(_player._iron_will_active, "Iron Will should activate at HP <= 30%")


func test_iron_will_gives_armor():
	_set_character("warrior")
	var armor_before: int = _player.armor
	_player.current_health = _player.max_health * 0.3
	_player._iron_will_cooldown = 0.0
	_player._iron_will_active = false
	_player._update_iron_will(0.016)
	assert_eq(_player.armor, armor_before + 3, "Iron Will should add +3 armor")


func test_iron_will_no_trigger_above_threshold():
	_set_character("warrior")
	_player.current_health = _player.max_health * 0.5
	_player._iron_will_cooldown = 0.0
	_player._iron_will_active = false
	var armor_before: int = _player.armor
	_player._update_iron_will(0.016)
	assert_eq(_player.armor, armor_before, "Iron Will should NOT trigger above 30% HP")
	assert_false(_player._iron_will_active, "Iron Will should NOT be active above 30% HP")


func test_iron_will_expires_after_duration():
	_set_character("warrior")
	_player.current_health = _player.max_health * 0.3
	_player._iron_will_cooldown = 0.0
	_player._iron_will_active = false
	_player._update_iron_will(0.016)
	assert_true(_player._iron_will_active, "Iron Will should be active")
	var armor_with_buff: int = _player.armor
	# Advance past duration (3.0s)
	_player._update_iron_will(3.1)
	assert_false(_player._iron_will_active, "Iron Will should expire after duration")
	assert_lt(_player.armor, armor_with_buff, "Armor should decrease when Iron Will expires")


func test_iron_will_cooldown_prevents_retrigger():
	_set_character("warrior")
	_player.current_health = _player.max_health * 0.3
	_player._iron_will_cooldown = 0.0
	_player._iron_will_active = false
	# First trigger
	_player._update_iron_will(0.016)
	assert_true(_player._iron_will_active, "First trigger should succeed")
	# Let it expire
	_player._update_iron_will(3.1)
	assert_false(_player._iron_will_active, "Should expire")
	# Cooldown is now 30s - should not re-trigger immediately
	_player._update_iron_will(0.016)
	assert_false(_player._iron_will_active, "Should NOT re-trigger during 30s cooldown")


func test_iron_will_does_not_affect_non_warrior():
	_set_character("mage")
	var armor_before: int = _player.armor
	_player.current_health = _player.max_health * 0.1
	_player._update_iron_will(0.016)
	assert_eq(_player.armor, armor_before, "Iron Will should not affect non-Warrior characters")


func test_iron_will_retriggers_after_full_cooldown():
	_set_character("warrior")
	_player.current_health = _player.max_health * 0.3
	_player._iron_will_cooldown = 0.0
	_player._iron_will_active = false
	# First trigger
	_player._update_iron_will(0.016)
	# Let it expire
	_player._update_iron_will(3.1)
	# Advance past 30s cooldown
	_player._update_iron_will(30.1)
	# Should be able to re-trigger
	_player._update_iron_will(0.016)
	assert_true(_player._iron_will_active, "Iron Will should re-trigger after cooldown")


# =====================================================================
# INPUT MAPPING
# =====================================================================

func test_skill_input_action_registered():
	var actions: PackedStringArray = InputMap.get_actions()
	assert_true("skill" in actions, "Input action 'skill' should be registered")


func test_skill_input_maps_to_e_key():
	var events: Array = InputMap.action_get_events("skill")
	assert_gt(events.size(), 0, "skill action should have at least one event")
	var has_e_key: bool = false
	for event in events:
		if event is InputEventKey and event.keycode == KEY_E:
			has_e_key = true
	assert_true(has_e_key, "Skill input should be mapped to E key")


# =====================================================================
# CROSS-CHARACTER VALIDATION
# =====================================================================

func test_all_cooldowns_distinct():
	assert_ne(_player.MAGE_SKILL_COOLDOWN, _player.WARRIOR_SKILL_COOLDOWN,
		"Mage and Warrior should have different cooldowns")
	assert_ne(_player.WARRIOR_SKILL_COOLDOWN, _player.RANGER_SKILL_COOLDOWN,
		"Warrior and Ranger should have different cooldowns")


func test_mage_cooldown_longest():
	assert_gt(_player.MAGE_SKILL_COOLDOWN, _player.WARRIOR_SKILL_COOLDOWN,
		"Mage cooldown (20s) > Warrior (15s)")
	assert_gt(_player.MAGE_SKILL_COOLDOWN, _player.RANGER_SKILL_COOLDOWN,
		"Mage cooldown (20s) > Ranger (18s)")


func test_warrior_cooldown_shortest():
	assert_lt(_player.WARRIOR_SKILL_COOLDOWN, _player.MAGE_SKILL_COOLDOWN,
		"Warrior cooldown (15s) < Mage (20s)")
	assert_lt(_player.WARRIOR_SKILL_COOLDOWN, _player.RANGER_SKILL_COOLDOWN,
		"Warrior cooldown (15s) < Ranger (18s)")


# =====================================================================
# R9: CONSTANT CONSISTENCY (SkillData <-> skill_effects.gd / player.gd)
# Uses load() to access skill_data.gd constants because class_name is
# not resolved at GUT script parse time.
# =====================================================================

func test_skill_effects_uses_skill_data_constants():
	# Verify skill_effects.gd damage/radius values match SkillData canonical source
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	assert_not_null(sd, "skill_data.gd should load")
	var se: Node = _player.skill_effects_node
	assert_not_null(se, "skill_effects_node should exist")

	# Mage constants
	assert_eq(se.MAGE_SKILL_DAMAGE, sd.MAGE_SKILL_DAMAGE,
		"skill_effects MAGE_SKILL_DAMAGE should match SkillData")
	assert_eq(se.MAGE_SKILL_RADIUS, sd.MAGE_SKILL_RADIUS,
		"skill_effects MAGE_SKILL_RADIUS should match SkillData")
	assert_eq(se.MAGE_SKILL_FREEZE_DURATION, sd.MAGE_SKILL_FREEZE_DURATION,
		"skill_effects MAGE_SKILL_FREEZE_DURATION should match SkillData")
	assert_eq(se.MAGE_SKILL_EXPAND_TIME, sd.MAGE_SKILL_EXPAND_TIME,
		"skill_effects MAGE_SKILL_EXPAND_TIME should match SkillData")

	# Warrior constants
	assert_eq(se.WARRIOR_SKILL_DAMAGE, sd.WARRIOR_SKILL_DAMAGE,
		"skill_effects WARRIOR_SKILL_DAMAGE should match SkillData")
	assert_eq(se.WARRIOR_SKILL_DISTANCE, sd.WARRIOR_SKILL_DISTANCE,
		"skill_effects WARRIOR_SKILL_DISTANCE should match SkillData")
	assert_eq(se.WARRIOR_SKILL_DURATION, sd.WARRIOR_SKILL_DURATION,
		"skill_effects WARRIOR_SKILL_DURATION should match SkillData")
	assert_eq(se.WARRIOR_SKILL_WIDTH, sd.WARRIOR_SKILL_WIDTH,
		"skill_effects WARRIOR_SKILL_WIDTH should match SkillData")
	assert_eq(se.WARRIOR_SKILL_STUN_DURATION, sd.WARRIOR_SKILL_STUN_DURATION,
		"skill_effects WARRIOR_SKILL_STUN_DURATION should match SkillData")

	# Ranger constants
	assert_eq(se.RANGER_SKILL_DAMAGE_PER_ARROW, sd.RANGER_SKILL_DAMAGE_PER_ARROW,
		"skill_effects RANGER_SKILL_DAMAGE_PER_ARROW should match SkillData")
	assert_eq(se.RANGER_SKILL_ARROW_COUNT, sd.RANGER_SKILL_ARROW_COUNT,
		"skill_effects RANGER_SKILL_ARROW_COUNT should match SkillData")
	assert_eq(se.RANGER_SKILL_RADIUS, sd.RANGER_SKILL_RADIUS,
		"skill_effects RANGER_SKILL_RADIUS should match SkillData")
	assert_eq(se.RANGER_SKILL_TARGET_RANGE, sd.RANGER_SKILL_TARGET_RANGE,
		"skill_effects RANGER_SKILL_TARGET_RANGE should match SkillData")

	# Passive constants
	assert_eq(se.MAGE_PASSIVE_DAMAGE_BONUS, sd.MAGE_PASSIVE_DAMAGE_BONUS,
		"skill_effects MAGE_PASSIVE_DAMAGE_BONUS should match SkillData")
	assert_eq(se.WARRIOR_PASSIVE_ARMOR_BONUS, sd.WARRIOR_PASSIVE_ARMOR_BONUS,
		"skill_effects WARRIOR_PASSIVE_ARMOR_BONUS should match SkillData")
	assert_eq(se.WARRIOR_PASSIVE_HP_THRESHOLD, sd.WARRIOR_PASSIVE_HP_THRESHOLD,
		"skill_effects WARRIOR_PASSIVE_HP_THRESHOLD should match SkillData")
	assert_eq(se.WARRIOR_PASSIVE_COOLDOWN, sd.WARRIOR_PASSIVE_COOLDOWN,
		"skill_effects WARRIOR_PASSIVE_COOLDOWN should match SkillData")
	assert_eq(se.RANGER_PASSIVE_HIT_COUNT, sd.RANGER_PASSIVE_HIT_COUNT,
		"skill_effects RANGER_PASSIVE_HIT_COUNT should match SkillData")


func test_player_uses_skill_data_cooldowns():
	# Verify player.gd cooldown constants match SkillData canonical source
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	assert_not_null(sd, "skill_data.gd should load")

	assert_eq(_player.MAGE_SKILL_COOLDOWN, sd.MAGE_SKILL_COOLDOWN,
		"player MAGE_SKILL_COOLDOWN should match SkillData")
	assert_eq(_player.WARRIOR_SKILL_COOLDOWN, sd.WARRIOR_SKILL_COOLDOWN,
		"player WARRIOR_SKILL_COOLDOWN should match SkillData")
	assert_eq(_player.RANGER_SKILL_COOLDOWN, sd.RANGER_SKILL_COOLDOWN,
		"player RANGER_SKILL_COOLDOWN should match SkillData")

	# Passive constants on player should also match SkillData
	assert_eq(_player.MAGE_PASSIVE_DAMAGE_BONUS, sd.MAGE_PASSIVE_DAMAGE_BONUS,
		"player MAGE_PASSIVE_DAMAGE_BONUS should match SkillData")
	assert_eq(_player.WARRIOR_PASSIVE_ARMOR_BONUS, sd.WARRIOR_PASSIVE_ARMOR_BONUS,
		"player WARRIOR_PASSIVE_ARMOR_BONUS should match SkillData")
	assert_eq(_player.WARRIOR_PASSIVE_HP_THRESHOLD, sd.WARRIOR_PASSIVE_HP_THRESHOLD,
		"player WARRIOR_PASSIVE_HP_THRESHOLD should match SkillData")
	assert_eq(_player.WARRIOR_PASSIVE_COOLDOWN, sd.WARRIOR_PASSIVE_COOLDOWN,
		"player WARRIOR_PASSIVE_COOLDOWN should match SkillData")
	assert_eq(_player.RANGER_PASSIVE_HIT_COUNT, sd.RANGER_PASSIVE_HIT_COUNT,
		"player RANGER_PASSIVE_HIT_COUNT should match SkillData")
