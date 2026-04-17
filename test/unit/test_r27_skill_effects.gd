extends GutTest
## R27: Unit tests for skill_effects.gd constants and helpers
## Covers: skill damage/radius/duration constants, passive constants,
## helper method existence, and visual constants.

var _effects: Node


func before_each():
	_effects = Node.new()
	_effects.set_script(load("res://scripts/skill_effects.gd"))
	add_child_autofree(_effects)


# =====================================================================
# Section A: Mage Skill Constants
# =====================================================================

func test_mage_skill_damage():
	assert_gt(_effects.MAGE_SKILL_DAMAGE, 0.0, "Mage skill damage should be positive")


func test_mage_skill_radius():
	assert_gt(_effects.MAGE_SKILL_RADIUS, 0.0, "Mage skill radius should be positive")


func test_mage_skill_freeze_duration():
	assert_gt(_effects.MAGE_SKILL_FREEZE_DURATION, 0.0, "Mage freeze duration should be positive")


func test_mage_skill_expand_time():
	assert_gt(_effects.MAGE_SKILL_EXPAND_TIME, 0.0, "Mage expand time should be positive")


func test_mage_skill_screenshake():
	assert_gt(_effects.MAGE_SKILL_SCREENSHAKE, 0.0, "Mage screenshake should be positive")


func test_mage_skill_screenshake_dur():
	assert_gt(_effects.MAGE_SKILL_SCREENSHAKE_DUR, 0.0, "Mage screenshake duration should be positive")


# =====================================================================
# Section B: Warrior Skill Constants
# =====================================================================

func test_warrior_skill_damage():
	assert_gt(_effects.WARRIOR_SKILL_DAMAGE, 0.0, "Warrior skill damage should be positive")


func test_warrior_skill_distance():
	assert_gt(_effects.WARRIOR_SKILL_DISTANCE, 0.0, "Warrior charge distance should be positive")


func test_warrior_skill_duration():
	assert_gt(_effects.WARRIOR_SKILL_DURATION, 0.0, "Warrior charge duration should be positive")


func test_warrior_skill_width():
	assert_gt(_effects.WARRIOR_SKILL_WIDTH, 0.0, "Warrior charge width should be positive")


func test_warrior_skill_stun_duration():
	assert_gt(_effects.WARRIOR_SKILL_STUN_DURATION, 0.0, "Warrior stun duration should be positive")


func test_warrior_skill_screenshake():
	assert_gt(_effects.WARRIOR_SKILL_SCREENSHAKE, 0.0, "Warrior screenshake should be positive")


# =====================================================================
# Section C: Ranger Skill Constants
# =====================================================================

func test_ranger_skill_damage_per_arrow():
	assert_gt(_effects.RANGER_SKILL_DAMAGE_PER_ARROW, 0.0, "Ranger arrow damage should be positive")


func test_ranger_skill_arrow_count():
	assert_gt(_effects.RANGER_SKILL_ARROW_COUNT, 0, "Ranger arrow count should be positive")


func test_ranger_skill_radius():
	assert_gt(_effects.RANGER_SKILL_RADIUS, 0.0, "Ranger skill radius should be positive")


func test_ranger_skill_target_range():
	assert_gt(_effects.RANGER_SKILL_TARGET_RANGE, 0.0, "Ranger target range should be positive")


func test_ranger_skill_fall_duration():
	assert_gt(_effects.RANGER_SKILL_FALL_DURATION, 0.0, "Ranger fall duration should be positive")


func test_ranger_skill_arrow_width():
	assert_gt(_effects.RANGER_SKILL_ARROW_WIDTH, 0.0, "Ranger arrow width should be positive")


func test_ranger_skill_arrow_height():
	assert_gt(_effects.RANGER_SKILL_ARROW_HEIGHT, 0.0, "Ranger arrow height should be positive")


func test_ranger_skill_warning_time():
	assert_gt(_effects.RANGER_SKILL_WARNING_TIME, 0.0, "Ranger warning time should be positive")


# =====================================================================
# Section D: Passive Constants
# =====================================================================

func test_mage_passive_damage_bonus():
	assert_gt(_effects.MAGE_PASSIVE_DAMAGE_BONUS, 0.0, "Mage passive bonus should be positive")


func test_warrior_passive_armor_bonus():
	assert_gt(_effects.WARRIOR_PASSIVE_ARMOR_BONUS, 0, "Warrior armor bonus should be positive")


func test_warrior_passive_hp_threshold():
	assert_gt(_effects.WARRIOR_PASSIVE_HP_THRESHOLD, 0.0, "Warrior HP threshold should be positive")


func test_warrior_passive_duration():
	assert_gt(_effects.WARRIOR_PASSIVE_DURATION, 0.0, "Warrior passive duration should be positive")


func test_warrior_passive_cooldown():
	assert_gt(_effects.WARRIOR_PASSIVE_COOLDOWN, 0.0, "Warrior passive cooldown should be positive")


func test_ranger_passive_hit_count():
	assert_gt(_effects.RANGER_PASSIVE_HIT_COUNT, 0, "Ranger hit count should be positive")


# =====================================================================
# Section E: Visual Constants
# =====================================================================

func test_warrior_afterimage_count():
	assert_gt(_effects.WARRIOR_AFTERIMAGE_COUNT, 0, "Afterimage count should be positive")


func test_warrior_afterimage_alpha_range():
	assert_gt(_effects.WARRIOR_AFTERIMAGE_ALPHA, 0.0, "Afterimage alpha should be positive")
	assert_lt(_effects.WARRIOR_AFTERIMAGE_ALPHA, 1.0, "Afterimage alpha should be less than 1")


# =====================================================================
# Section F: Method Existence
# =====================================================================

func test_has_elemental_burst_method():
	assert_true(_effects.has_method("elemental_burst"),
		"skill_effects should have elemental_burst method")


func test_has_shield_charge_method():
	assert_true(_effects.has_method("shield_charge"),
		"skill_effects should have shield_charge method")


func test_has_arrow_rain_method():
	assert_true(_effects.has_method("arrow_rain"),
		"skill_effects should have arrow_rain method")


func test_has_get_enemies_in_radius():
	assert_true(_effects.has_method("_get_enemies_in_radius"),
		"skill_effects should have _get_enemies_in_radius helper")


func test_has_get_enemies_in_path():
	assert_true(_effects.has_method("_get_enemies_in_path"),
		"skill_effects should have _get_enemies_in_path helper")


func test_has_find_arrow_rain_target():
	assert_true(_effects.has_method("_find_arrow_rain_target"),
		"skill_effects should have _find_arrow_rain_target helper")


func test_has_screen_shake():
	assert_true(_effects.has_method("_screen_shake"),
		"skill_effects should have _screen_shake helper")


# =====================================================================
# Section G: Skill Constants Consistency with SkillData
# =====================================================================

func test_mage_damage_matches_skill_data():
	var sd_damage: float = SkillData.MAGE_SKILL_DAMAGE
	assert_eq(_effects.MAGE_SKILL_DAMAGE, sd_damage,
		"skill_effects MAGE_SKILL_DAMAGE should match SkillData")


func test_warrior_damage_matches_skill_data():
	var sd_damage: float = SkillData.WARRIOR_SKILL_DAMAGE
	assert_eq(_effects.WARRIOR_SKILL_DAMAGE, sd_damage,
		"skill_effects WARRIOR_SKILL_DAMAGE should match SkillData")


func test_ranger_damage_matches_skill_data():
	var sd_damage: float = SkillData.RANGER_SKILL_DAMAGE_PER_ARROW
	assert_eq(_effects.RANGER_SKILL_DAMAGE_PER_ARROW, sd_damage,
		"skill_effects RANGER_SKILL_DAMAGE_PER_ARROW should match SkillData")


# =====================================================================
# Section H: _get_enemies_in_radius helper
# =====================================================================

func test_get_enemies_in_radius_empty():
	var result: Array = _effects._get_enemies_in_radius(_effects, Vector2(100, 100), 50.0)
	assert_eq(result.size(), 0, "Should find no enemies in empty scene")


func test_get_enemies_in_radius_finds_enemy():
	var enemy: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = 10.0; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	enemy.enemy_data = data
	enemy.global_position = Vector2(110, 100)
	enemy.add_to_group("enemies")
	add_child_autofree(enemy)
	var result: Array = _effects._get_enemies_in_radius(_effects, Vector2(100, 100), 50.0)
	assert_eq(result.size(), 1, "Should find 1 enemy within radius")


func test_get_enemies_in_radius_excludes_dead():
	var enemy: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = 10.0; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	enemy.enemy_data = data
	enemy.global_position = Vector2(110, 100)
	enemy.is_alive = false
	enemy.add_to_group("enemies")
	add_child_autofree(enemy)
	var result: Array = _effects._get_enemies_in_radius(_effects, Vector2(100, 100), 50.0)
	assert_eq(result.size(), 0, "Should not find dead enemies")


func test_get_enemies_in_radius_excludes_distant():
	var enemy: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = 10.0; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	enemy.enemy_data = data
	enemy.global_position = Vector2(500, 500)
	enemy.add_to_group("enemies")
	add_child_autofree(enemy)
	var result: Array = _effects._get_enemies_in_radius(_effects, Vector2(100, 100), 50.0)
	assert_eq(result.size(), 0, "Should not find enemies outside radius")
