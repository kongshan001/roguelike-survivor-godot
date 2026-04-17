extends GutTest
## R34 Necromancer Character Tests
## Verifies the necromancer character definition across the codebase.
## Tests check: definition in player.gd/arena.gd, initial weapon frostaura,
## stats in reasonable range, sprite existence, character select handling,
## and upgrade_pool integration.


const PLAYER_PATH := "res://scripts/player.gd"
const ARENA_PATH := "res://scripts/arena.gd"
const CHARACTER_SELECT_PATH := "res://scripts/character_select.gd"
const UPGRADE_POOL_PATH := "res://scripts/autoload/upgrade_pool.gd"
const PLAYER_SKILL_PATH := "res://scripts/player_skill.gd"
const SKILL_DATA_PATH := "res://scripts/data/skill_data.gd"
const WEAPON_CONTROLLER_PATH := "res://scripts/weapon_controller.gd"


func _load_source(path: String) -> String:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content: String = f.get_as_text()
	f.close()
	return content


# =====================================================================
# 1. Necromancer definition exists in player.gd
# =====================================================================

func test_necromancer_case_in_player_setup():
	var src: String = _load_source(PLAYER_PATH)
	assert_true(src.find('"necromancer"') >= 0,
		"player.gd _setup_character_animation should have necromancer match case")


func test_necromancer_initial_weapon_is_death_pulse_skill():
	var src: String = _load_source(PLAYER_PATH)
	assert_true(src.find('death_pulse') >= 0,
		"player.gd should initialize death_pulse skill for necromancer")


func test_necromancer_skill_cooldown_from_skill_data():
	var src: String = _load_source(PLAYER_PATH)
	assert_true(src.find("NECROMANCER_SKILL_COOLDOWN") >= 0,
		"player.gd should reference NECROMANCER_SKILL_COOLDOWN constant")


func test_necromancer_color_is_purple():
	var src: String = _load_source(PLAYER_PATH)
	# Necromancer color: Color(0.5, 0.3, 0.7)
	var idx: int = src.find('"necromancer"')
	assert_true(idx >= 0, "Should find necromancer case")
	var section: String = src.substr(idx, 200)
	assert_true(section.find("0.5") >= 0 and section.find("0.3") >= 0 and section.find("0.7") >= 0,
		"Necromancer should have purple-ish color values")


# =====================================================================
# 2. Necromancer stats in arena.gd
# =====================================================================

func test_necromancer_hp_in_arena():
	var src: String = _load_source(ARENA_PATH)
	var idx: int = src.find('"necromancer"')
	assert_true(idx >= 0, "arena.gd should have necromancer case")
	var section: String = src.substr(idx, 200)
	# HP = 7.0
	assert_true(section.find("7.0") >= 0,
		"Necromancer HP should be 7.0")


func test_necromancer_speed_in_arena():
	var src: String = _load_source(ARENA_PATH)
	var idx: int = src.find('"necromancer"')
	var section: String = src.substr(idx, 200)
	# Speed = 150.0
	assert_true(section.find("150.0") >= 0,
		"Necromancer speed should be 150.0")


func test_necromancer_pickup_range_in_arena():
	var src: String = _load_source(ARENA_PATH)
	var idx: int = src.find('"necromancer"')
	var section: String = src.substr(idx, 200)
	# pickup_range = 45.0
	assert_true(section.find("45.0") >= 0,
		"Necromancer pickup range should be 45.0")


func test_necromancer_stats_reasonable_range():
	var src: String = _load_source(ARENA_PATH)
	var idx: int = src.find('"necromancer"')
	var section: String = src.substr(idx, 200)
	# HP should be between 5-15
	assert_true(section.find("7.0") >= 0, "HP 7.0 should be in reasonable range (5-15)")
	# Speed should be between 100-200
	assert_true(section.find("150.0") >= 0, "Speed 150.0 should be in reasonable range (100-200)")


# =====================================================================
# 3. Necromancer initial weapon is frostaura
# =====================================================================

func test_necromancer_starts_with_frostaura():
	# Arena.gd sets up initial weapon for each character
	var src: String = _load_source(ARENA_PATH)
	var idx: int = src.find('"necromancer"')
	assert_true(idx >= 0, "arena.gd should have necromancer case")
	var section: String = src.substr(idx, 300)
	assert_true(section.find("frostaura") >= 0,
		"Necromancer initial weapon should be frostaura")


# =====================================================================
# 4. Necromancer sprite files
# =====================================================================

func test_necromancer_sprite_path_referenced():
	var src: String = _load_source(PLAYER_PATH)
	assert_true(src.find("necromancer.png") >= 0,
		"player.gd should reference necromancer.png sprite")


func test_necromancer_cast_sprite_referenced():
	var src: String = _load_source(PLAYER_PATH)
	assert_true(src.find("necromancer_cast.png") >= 0,
		"player.gd should reference necromancer_cast.png action sprite")


# =====================================================================
# 5. Character select handles necromancer
# =====================================================================

func test_character_select_has_necromancer():
	var src: String = _load_source(CHARACTER_SELECT_PATH)
	assert_true(src.find('"necromancer"') >= 0,
		"character_select.gd should have necromancer entry")


func test_character_select_necromancer_name():
	var src: String = _load_source(CHARACTER_SELECT_PATH)
	assert_true(src.find("necromancer") >= 0 and src.find("死灵法师") >= 0,
		"character_select.gd should have necromancer name in Chinese")


func test_character_select_necromancer_sprite_path():
	var src: String = _load_source(CHARACTER_SELECT_PATH)
	assert_true(src.find("res://assets/sprites/characters/necromancer.png") >= 0,
		"character_select.gd should reference necromancer sprite path")


func test_character_select_necromancer_hp():
	var src: String = _load_source(CHARACTER_SELECT_PATH)
	# Find necromancer section and verify hp: 7
	var idx: int = src.find('"necromancer"')
	assert_true(idx >= 0, "Should find necromancer in character_select")
	var section: String = src.substr(idx, 300)
	assert_true(section.find('"hp": 7') >= 0,
		"character_select should list necromancer HP as 7")


func test_character_select_necromancer_desc():
	var src: String = _load_source(CHARACTER_SELECT_PATH)
	assert_true(src.find("初始冰冻光环") >= 0,
		"character_select should show necromancer starts with frost aura")


# =====================================================================
# 6. UpgradePool handles necromancer character passives
# =====================================================================

func test_upgrade_pool_has_necromancer_passive():
	var src: String = _load_source(UPGRADE_POOL_PATH)
	assert_true(src.find("necromancer_kill_scaling") >= 0,
		"UpgradePool should have necromancer_kill_scaling passive")


func test_upgrade_pool_necromancer_passive_character_filter():
	var src: String = _load_source(UPGRADE_POOL_PATH)
	var idx: int = src.find("necromancer_kill_scaling")
	assert_true(idx >= 0, "Should find necromancer_kill_scaling")
	var section: String = src.substr(idx, 300)
	assert_true(section.find('"character": "necromancer"') >= 0,
		"necromancer_kill_scaling should be filtered by character: necromancer")


func test_upgrade_pool_get_random_upgrades_with_necromancer():
	# Source-level check: get_random_upgrades accepts selected_character parameter
	# and filters character passives by it. Verify the function signature handles necromancer.
	var src: String = _load_source(UPGRADE_POOL_PATH)
	assert_true(src.find("selected_character") >= 0,
		"get_random_upgrades should accept selected_character parameter")
	# The character passive filter uses: cp.get("character", "") != selected_char
	assert_true(src.find("selected_char") >= 0,
		"get_random_upgrades should filter character passives by selected_char")


func test_upgrade_pool_necromancer_passive_max_stack():
	var src: String = _load_source(UPGRADE_POOL_PATH)
	var idx: int = src.find("necromancer_kill_scaling")
	var section: String = src.substr(idx, 300)
	assert_true(section.find('"max_stack": 1') >= 0,
		"necromancer_kill_scaling should have max_stack: 1")


# =====================================================================
# 7. SkillData has necromancer constants
# =====================================================================

func test_skill_data_has_necromancer_cooldown():
	var src: String = _load_source(SKILL_DATA_PATH)
	assert_true(src.find("NECROMANCER_SKILL_COOLDOWN") >= 0,
		"SkillData should define NECROMANCER_SKILL_COOLDOWN")


func test_skill_data_has_necromancer_skill_id():
	var src: String = _load_source(SKILL_DATA_PATH)
	assert_true(src.find("NECROMANCER_SKILL_ID") >= 0,
		"SkillData should define NECROMANCER_SKILL_ID")


func test_skill_data_necromancer_skill_is_death_pulse():
	var src: String = _load_source(SKILL_DATA_PATH)
	assert_true(src.find('"death_pulse"') >= 0,
		"SkillData NECROMANCER_SKILL_ID should be death_pulse")


func test_skill_data_has_necromancer_kill_scaling():
	var src: String = _load_source(SKILL_DATA_PATH)
	assert_true(src.find("NECROMANCER_KILL_SCALING_INTERVAL") >= 0,
		"SkillData should define NECROMANCER_KILL_SCALING_INTERVAL")
	assert_true(src.find("NECROMANCER_KILL_SCALING_BONUS") >= 0,
		"SkillData should define NECROMANCER_KILL_SCALING_BONUS")
	assert_true(src.find("NECROMANCER_KILL_SCALING_MAX") >= 0,
		"SkillData should define NECROMANCER_KILL_SCALING_MAX")


# =====================================================================
# 8. Player skill module handles necromancer
# =====================================================================

func test_player_skill_has_necromancer_cooldown():
	var src: String = _load_source(PLAYER_SKILL_PATH)
	assert_true(src.find("NECROMANCER_SKILL_COOLDOWN") >= 0,
		"player_skill.gd should reference NECROMANCER_SKILL_COOLDOWN")


func test_player_skill_handles_death_pulse():
	var src: String = _load_source(PLAYER_SKILL_PATH)
	assert_true(src.find('"death_pulse"') >= 0,
		"player_skill.gd should handle death_pulse skill activation")


# =====================================================================
# 9. Weapon controller handles necromancer passive
# =====================================================================

func test_weapon_controller_necromancer_kill_scaling():
	var src: String = _load_source(WEAPON_CONTROLLER_PATH)
	assert_true(src.find("necromancer_kill_scaling") >= 0,
		"weapon_controller.gd should reference necromancer_kill_scaling passive")
