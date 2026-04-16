extends GutTest
## Regression tests for SkillData constant unification.
## Verifies that the canonical constants in skill_data.gd match the values
## used in skill_effects.gd and player.gd.
## Purpose: catch drift if Programmer partially migrates constants to SkillData.


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

	await get_tree().process_frame


func after_each():
	await get_tree().process_frame


# =====================================================================
# 1. SKILL DATA CLASS LOADS AND HAS EXPECTED CONSTANTS
# =====================================================================

func test_skill_data_script_loads():
	assert_not_null(load("res://scripts/data/skill_data.gd"), "skill_data.gd should load as a GDScript")


func test_skill_data_has_mage_cooldown():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	assert_eq(sd.MAGE_SKILL_COOLDOWN, 20.0, "SkillData.MAGE_SKILL_COOLDOWN should be 20.0")


func test_skill_data_has_warrior_cooldown():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	assert_eq(sd.WARRIOR_SKILL_COOLDOWN, 15.0, "SkillData.WARRIOR_SKILL_COOLDOWN should be 15.0")


func test_skill_data_has_ranger_cooldown():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	assert_eq(sd.RANGER_SKILL_COOLDOWN, 18.0, "SkillData.RANGER_SKILL_COOLDOWN should be 18.0")


# =====================================================================
# 2. PLAYER.GD COOLDOWNS MATCH SKILLDATA
# =====================================================================

func test_player_mage_cooldown_matches_skill_data():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	assert_eq(_player.MAGE_SKILL_COOLDOWN, sd.MAGE_SKILL_COOLDOWN,
		"player.gd MAGE_SKILL_COOLDOWN should match SkillData canonical value")


func test_player_warrior_cooldown_matches_skill_data():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	assert_eq(_player.WARRIOR_SKILL_COOLDOWN, sd.WARRIOR_SKILL_COOLDOWN,
		"player.gd WARRIOR_SKILL_COOLDOWN should match SkillData canonical value")


func test_player_ranger_cooldown_matches_skill_data():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	assert_eq(_player.RANGER_SKILL_COOLDOWN, sd.RANGER_SKILL_COOLDOWN,
		"player.gd RANGER_SKILL_COOLDOWN should match SkillData canonical value")


# =====================================================================
# 3. SKILL_EFFECTS.GD DAMAGE/RADIUS CONSTANTS MATCH SKILLDATA
# =====================================================================

func test_skill_effects_mage_damage_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.MAGE_SKILL_DAMAGE, sd.MAGE_SKILL_DAMAGE,
		"skill_effects MAGE_SKILL_DAMAGE should match SkillData")


func test_skill_effects_mage_radius_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.MAGE_SKILL_RADIUS, sd.MAGE_SKILL_RADIUS,
		"skill_effects MAGE_SKILL_RADIUS should match SkillData")


func test_skill_effects_mage_freeze_duration_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.MAGE_SKILL_FREEZE_DURATION, sd.MAGE_SKILL_FREEZE_DURATION,
		"skill_effects MAGE_SKILL_FREEZE_DURATION should match SkillData")


func test_skill_effects_mage_expand_time_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.MAGE_SKILL_EXPAND_TIME, sd.MAGE_SKILL_EXPAND_TIME,
		"skill_effects MAGE_SKILL_EXPAND_TIME should match SkillData")


func test_skill_effects_mage_screenshake_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.MAGE_SKILL_SCREENSHAKE, sd.MAGE_SKILL_SCREENSHAKE,
		"skill_effects MAGE_SKILL_SCREENSHAKE should match SkillData")


func test_skill_effects_mage_screenshake_dur_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.MAGE_SKILL_SCREENSHAKE_DUR, sd.MAGE_SKILL_SCREENSHAKE_DUR,
		"skill_effects MAGE_SKILL_SCREENSHAKE_DUR should match SkillData")


# =====================================================================
# 4. SKILL_EFFECTS.GD WARRIOR CONSTANTS MATCH SKILLDATA
# =====================================================================

func test_skill_effects_warrior_damage_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.WARRIOR_SKILL_DAMAGE, sd.WARRIOR_SKILL_DAMAGE,
		"skill_effects WARRIOR_SKILL_DAMAGE should match SkillData")


func test_skill_effects_warrior_distance_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.WARRIOR_SKILL_DISTANCE, sd.WARRIOR_SKILL_DISTANCE,
		"skill_effects WARRIOR_SKILL_DISTANCE should match SkillData")


func test_skill_effects_warrior_duration_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.WARRIOR_SKILL_DURATION, sd.WARRIOR_SKILL_DURATION,
		"skill_effects WARRIOR_SKILL_DURATION should match SkillData")


func test_skill_effects_warrior_width_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.WARRIOR_SKILL_WIDTH, sd.WARRIOR_SKILL_WIDTH,
		"skill_effects WARRIOR_SKILL_WIDTH should match SkillData")


func test_skill_effects_warrior_stun_duration_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.WARRIOR_SKILL_STUN_DURATION, sd.WARRIOR_SKILL_STUN_DURATION,
		"skill_effects WARRIOR_SKILL_STUN_DURATION should match SkillData")


func test_skill_effects_warrior_screenshake_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.WARRIOR_SKILL_SCREENSHAKE, sd.WARRIOR_SKILL_SCREENSHAKE,
		"skill_effects WARRIOR_SKILL_SCREENSHAKE should match SkillData")


# =====================================================================
# 5. SKILL_EFFECTS.GD RANGER CONSTANTS MATCH SKILLDATA
# =====================================================================

func test_skill_effects_ranger_damage_per_arrow_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.RANGER_SKILL_DAMAGE_PER_ARROW, sd.RANGER_SKILL_DAMAGE_PER_ARROW,
		"skill_effects RANGER_SKILL_DAMAGE_PER_ARROW should match SkillData")


func test_skill_effects_ranger_arrow_count_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.RANGER_SKILL_ARROW_COUNT, sd.RANGER_SKILL_ARROW_COUNT,
		"skill_effects RANGER_SKILL_ARROW_COUNT should match SkillData")


func test_skill_effects_ranger_radius_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.RANGER_SKILL_RADIUS, sd.RANGER_SKILL_RADIUS,
		"skill_effects RANGER_SKILL_RADIUS should match SkillData")


func test_skill_effects_ranger_target_range_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.RANGER_SKILL_TARGET_RANGE, sd.RANGER_SKILL_TARGET_RANGE,
		"skill_effects RANGER_SKILL_TARGET_RANGE should match SkillData")


func test_skill_effects_ranger_fall_duration_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.RANGER_SKILL_FALL_DURATION, sd.RANGER_SKILL_FALL_DURATION,
		"skill_effects RANGER_SKILL_FALL_DURATION should match SkillData")


func test_skill_effects_ranger_warning_time_matches():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(se.RANGER_SKILL_WARNING_TIME, sd.RANGER_SKILL_WARNING_TIME,
		"skill_effects RANGER_SKILL_WARNING_TIME should match SkillData")


# =====================================================================
# 6. PASSIVE CONSTANTS MATCH ACROSS ALL THREE SOURCES
# =====================================================================

func test_mage_passive_bonus_triple_consistency():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	# SkillData, player.gd, skill_effects.gd should all agree
	assert_eq(sd.MAGE_PASSIVE_DAMAGE_BONUS, _player.MAGE_PASSIVE_DAMAGE_BONUS,
		"SkillData and player.gd MAGE_PASSIVE_DAMAGE_BONUS should match")
	assert_eq(sd.MAGE_PASSIVE_DAMAGE_BONUS, se.MAGE_PASSIVE_DAMAGE_BONUS,
		"SkillData and skill_effects MAGE_PASSIVE_DAMAGE_BONUS should match")


func test_warrior_passive_armor_bonus_triple_consistency():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(sd.WARRIOR_PASSIVE_ARMOR_BONUS, _player.WARRIOR_PASSIVE_ARMOR_BONUS,
		"SkillData and player.gd WARRIOR_PASSIVE_ARMOR_BONUS should match")
	assert_eq(sd.WARRIOR_PASSIVE_ARMOR_BONUS, se.WARRIOR_PASSIVE_ARMOR_BONUS,
		"SkillData and skill_effects WARRIOR_PASSIVE_ARMOR_BONUS should match")


func test_warrior_passive_hp_threshold_triple_consistency():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(sd.WARRIOR_PASSIVE_HP_THRESHOLD, _player.WARRIOR_PASSIVE_HP_THRESHOLD,
		"SkillData and player.gd WARRIOR_PASSIVE_HP_THRESHOLD should match")
	assert_eq(sd.WARRIOR_PASSIVE_HP_THRESHOLD, se.WARRIOR_PASSIVE_HP_THRESHOLD,
		"SkillData and skill_effects WARRIOR_PASSIVE_HP_THRESHOLD should match")


func test_warrior_passive_cooldown_triple_consistency():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(sd.WARRIOR_PASSIVE_COOLDOWN, _player.WARRIOR_PASSIVE_COOLDOWN,
		"SkillData and player.gd WARRIOR_PASSIVE_COOLDOWN should match")
	assert_eq(sd.WARRIOR_PASSIVE_COOLDOWN, se.WARRIOR_PASSIVE_COOLDOWN,
		"SkillData and skill_effects WARRIOR_PASSIVE_COOLDOWN should match")


func test_ranger_passive_hit_count_triple_consistency():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var se: Node = _player.skill_effects_node
	assert_eq(sd.RANGER_PASSIVE_HIT_COUNT, _player.RANGER_PASSIVE_HIT_COUNT,
		"SkillData and player.gd RANGER_PASSIVE_HIT_COUNT should match")
	assert_eq(sd.RANGER_PASSIVE_HIT_COUNT, se.RANGER_PASSIVE_HIT_COUNT,
		"SkillData and skill_effects RANGER_PASSIVE_HIT_COUNT should match")


# =====================================================================
# 7. SKILL ID CONSTANTS
# =====================================================================

func test_skill_data_mage_skill_id():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	assert_eq(sd.MAGE_SKILL_ID, "elemental_burst", "SkillData.MAGE_SKILL_ID should be elemental_burst")


func test_skill_data_warrior_skill_id():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	assert_eq(sd.WARRIOR_SKILL_ID, "shield_charge", "SkillData.WARRIOR_SKILL_ID should be shield_charge")


func test_skill_data_ranger_skill_id():
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	assert_eq(sd.RANGER_SKILL_ID, "arrow_rain", "SkillData.RANGER_SKILL_ID should be arrow_rain")


# =====================================================================
# 8. COMPLETE CONSTANT COUNT (regression: no constants accidentally removed)
# =====================================================================

func test_skill_data_constant_count():
	# Verify that SkillData has the expected number of named constants.
	# This catches accidental removal during refactoring.
	var sd: GDScript = load("res://scripts/data/skill_data.gd")
	var expected_constants: Array = [
		"MAGE_SKILL_ID", "MAGE_SKILL_COOLDOWN", "MAGE_SKILL_DAMAGE",
		"MAGE_SKILL_RADIUS", "MAGE_SKILL_FREEZE_DURATION", "MAGE_SKILL_EXPAND_TIME",
		"MAGE_SKILL_SCREENSHAKE", "MAGE_SKILL_SCREENSHAKE_DUR",
		"WARRIOR_SKILL_ID", "WARRIOR_SKILL_COOLDOWN", "WARRIOR_SKILL_DAMAGE",
		"WARRIOR_SKILL_DISTANCE", "WARRIOR_SKILL_DURATION", "WARRIOR_SKILL_WIDTH",
		"WARRIOR_SKILL_STUN_DURATION", "WARRIOR_SKILL_SCREENSHAKE", "WARRIOR_SKILL_SCREENSHAKE_DUR",
		"RANGER_SKILL_ID", "RANGER_SKILL_COOLDOWN", "RANGER_SKILL_DAMAGE_PER_ARROW",
		"RANGER_SKILL_ARROW_COUNT", "RANGER_SKILL_RADIUS", "RANGER_SKILL_TARGET_RANGE",
		"RANGER_SKILL_FALL_DURATION", "RANGER_SKILL_ARROW_WIDTH", "RANGER_SKILL_ARROW_HEIGHT",
		"RANGER_SKILL_WARNING_TIME", "RANGER_SKILL_SCREENSHAKE", "RANGER_SKILL_SCREENSHAKE_DUR",
		"MAGE_PASSIVE_DAMAGE_BONUS", "WARRIOR_PASSIVE_ARMOR_BONUS",
		"WARRIOR_PASSIVE_HP_THRESHOLD", "WARRIOR_PASSIVE_COOLDOWN",
		"RANGER_PASSIVE_HIT_COUNT",
	]
	assert_eq(expected_constants.size(), 34, "Should verify 34 constants in SkillData")
	for const_name in expected_constants:
		assert_true(const_name in sd, "SkillData should have constant: %s" % const_name)
