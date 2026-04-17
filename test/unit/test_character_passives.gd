extends "res://addons/gut/test.gd"
## Unit tests for R12 character exclusive passives (TOP3)
## Covers: mage_damage_scale, warrior_armor_mastery, ranger_crit_boost
## Registration in upgrade_pool.gd, application in player.gd


func before_each():
	GameManager.reset()
	GameManager.is_game_over = false
	GameManager.selected_character = ""
	GameManager.elapsed_time = 0.0
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	UpgradePool.ensure_weapons_registered()


# =====================================================================
# 1. REGISTRATION IN UPGRADE_POOL
# =====================================================================

func test_character_passives_dict_exists():
	assert_true(
		"mage_damage_scale" in UpgradePool._character_passives,
		"mage_damage_scale should be registered"
	)
	assert_true(
		"warrior_armor_mastery" in UpgradePool._character_passives,
		"warrior_armor_mastery should be registered"
	)
	assert_true(
		"ranger_crit_boost" in UpgradePool._character_passives,
		"ranger_crit_boost should be registered"
	)


func test_character_passive_max_stack_is_one():
	assert_eq(
		UpgradePool._character_passives["mage_damage_scale"].get("max_stack", 0),
		1,
		"mage_damage_scale should have max_stack 1"
	)
	assert_eq(
		UpgradePool._character_passives["warrior_armor_mastery"].get("max_stack", 0),
		1,
		"warrior_armor_mastery should have max_stack 1"
	)
	assert_eq(
		UpgradePool._character_passives["ranger_crit_boost"].get("max_stack", 0),
		1,
		"ranger_crit_boost should have max_stack 1"
	)


func test_character_passive_has_character_field():
	assert_eq(
		UpgradePool._character_passives["mage_damage_scale"]["character"],
		"mage",
		"mage_damage_scale should belong to mage"
	)
	assert_eq(
		UpgradePool._character_passives["warrior_armor_mastery"]["character"],
		"warrior",
		"warrior_armor_mastery should belong to warrior"
	)
	assert_eq(
		UpgradePool._character_passives["ranger_crit_boost"]["character"],
		"ranger",
		"ranger_crit_boost should belong to ranger"
	)


func test_character_passive_has_name_and_description():
	for passive_id in ["mage_damage_scale", "warrior_armor_mastery", "ranger_crit_boost"]:
		var p: Dictionary = UpgradePool._character_passives[passive_id]
		assert_true(p.has("name"), "%s should have name" % passive_id)
		assert_true(p.has("description"), "%s should have description" % passive_id)
		assert_true(p.has("icon_color"), "%s should have icon_color" % passive_id)


# =====================================================================
# 2. SKILL DATA CONSTANTS
# =====================================================================

func test_skill_data_constants():
	assert_eq(SkillData.MAGE_DAMAGE_SCALE_BONUS, 0.08, "MAGE_DAMAGE_SCALE_BONUS should be 0.08")
	assert_eq(SkillData.WARRIOR_ARMOR_MASTERY_BONUS, 2, "WARRIOR_ARMOR_MASTERY_BONUS should be 2")
	assert_eq(SkillData.RANGER_CRIT_BOOST_BONUS, 0.12, "RANGER_CRIT_BOOST_BONUS should be 0.12")


func test_player_constants_reference_skill_data():
	var p_script := load("res://scripts/player.gd")
	var source: String = p_script.source_code
	assert_true(
		"MAGE_DAMAGE_SCALE_BONUS" in source,
		"player.gd should define MAGE_DAMAGE_SCALE_BONUS"
	)
	assert_true(
		"WARRIOR_ARMOR_MASTERY_BONUS" in source,
		"player.gd should define WARRIOR_ARMOR_MASTERY_BONUS"
	)
	assert_true(
		"RANGER_CRIT_BOOST_BONUS" in source,
		"player.gd should define RANGER_CRIT_BOOST_BONUS"
	)


# =====================================================================
# 3. UPGRADE POOL FILTERING
# =====================================================================

func test_mage_sees_mage_passive():
	var options := UpgradePool.get_random_upgrades({}, {}, 20, "mage")
	var found := false
	for opt in options:
		if opt.get("id") == "mage_damage_scale":
			found = true
			assert_eq(opt["type"], "character_passive", "Should be character_passive type")
	assert_true(found, "Mage should see mage_damage_scale in options")


func test_mage_does_not_see_warrior_passive():
	var options := UpgradePool.get_random_upgrades({}, {}, 20, "mage")
	for opt in options:
		assert_ne(opt.get("id"), "warrior_armor_mastery", "Mage should NOT see warrior passive")


func test_warrior_sees_warrior_passive():
	var options := UpgradePool.get_random_upgrades({}, {}, 20, "warrior")
	var found := false
	for opt in options:
		if opt.get("id") == "warrior_armor_mastery":
			found = true
	assert_true(found, "Warrior should see warrior_armor_mastery in options")


func test_ranger_sees_ranger_passive():
	var options := UpgradePool.get_random_upgrades({}, {}, 20, "ranger")
	var found := false
	for opt in options:
		if opt.get("id") == "ranger_crit_boost":
			found = true
	assert_true(found, "Ranger should see ranger_crit_boost in options")


func test_no_character_sees_no_character_passives():
	var options := UpgradePool.get_random_upgrades({}, {}, 20, "")
	for opt in options:
		assert_ne(opt.get("type"), "character_passive", "No character passives without character")


func test_character_passive_not_offered_at_max_stack():
	var owned_passives := {"mage_damage_scale": 1}
	var options := UpgradePool.get_random_upgrades({}, owned_passives, 20, "mage")
	for opt in options:
		assert_ne(opt.get("id"), "mage_damage_scale", "Should not offer maxed character passive")


# =====================================================================
# 4. PLAYER APPLY PASSIVE
# =====================================================================

func test_mage_damage_scale_increases_damage_bonus():
	var player := _create_player()
	player.damage_bonus = 0.2  # mage base
	player.apply_passive("mage_damage_scale")
	assert_almost_eq(
		player.damage_bonus,
		0.28,
		0.001,
		"mage_damage_scale should add 0.08 to damage_bonus"
	)


func test_warrior_armor_mastery_increases_armor():
	var player := _create_player()
	var initial_armor: int = player.armor
	player.apply_passive("warrior_armor_mastery")
	assert_eq(
		player.armor,
		initial_armor + 2,
		"warrior_armor_mastery should add 2 armor"
	)


func test_ranger_crit_boost_increases_crit_chance():
	var player := _create_player()
	player.crit_chance = 0.1  # ranger base
	player.apply_passive("ranger_crit_boost")
	assert_almost_eq(
		player.crit_chance,
		0.22,
		0.001,
		"ranger_crit_boost should add 0.12 to crit_chance"
	)


func test_character_passive_max_stack_enforced():
	var player := _create_player()
	player.apply_passive("mage_damage_scale")
	var bonus_after_first: float = player.damage_bonus
	player.apply_passive("mage_damage_scale")  # should not apply again
	assert_eq(
		player.damage_bonus,
		bonus_after_first,
		"mage_damage_scale should not stack beyond 1"
	)


func test_character_passive_tracked_in_owned_passives():
	var player := _create_player()
	player.apply_passive("mage_damage_scale")
	assert_eq(player.owned_passives.get("mage_damage_scale", 0), 1, "Should track 1 stack")


# =====================================================================
# 5. HUD SKILL ICON TextureRect
# =====================================================================

func test_skill_icon_is_texture_rect():
	var hud_script := load("res://scripts/hud_skill_button.gd")
	var source: String = hud_script.source_code
	assert_true(
		"TextureRect" in source,
		"hud_skill_button.gd should use TextureRect"
	)
	assert_true(
		"_skill_icon: TextureRect" in source,
		"_skill_icon should be declared as TextureRect"
	)


func test_skill_icon_loads_sprite_path():
	var hud_script := load("res://scripts/hud_skill_button.gd")
	var source: String = hud_script.source_code
	assert_true(
		"assets/sprites/skills/" in source,
		"Should reference skills sprite path"
	)
	assert_true(
		"skill_tex_path" in source,
		"Should construct skill texture path from skill_id"
	)


# =====================================================================
# Helpers
# =====================================================================

func _create_player() -> CharacterBody2D:
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(player)
	return player
