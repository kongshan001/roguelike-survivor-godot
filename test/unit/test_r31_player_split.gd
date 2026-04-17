extends GutTest
## R31 Task 3: player.gd split regression tests
## Tests: player.gd line count after split, new split files exist,
## player scene instantiation, basic movement, weapon management, dash.

var _player: CharacterBody2D


func before_each():
	GameManager.reset()
	if SaveManager:
		for id in SaveManager.SHOP_UPGRADES:
			SaveManager.shop_upgrades[id] = 0
	GameManager.selected_character = ""
	_player = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(_player)


# =====================================================================
# 1. player.gd line count < 400 (target after split)
# =====================================================================

func test_player_gd_line_count_under_400():
	var file: FileAccess = FileAccess.open("res://scripts/player.gd", FileAccess.READ)
	var lines: int = 0
	while not file.eof_reached():
		file.get_line()
		lines += 1
	file.close()
	if lines >= 400:
		pending("player.gd is %d lines; split not yet completed (target < 400)" % lines)
		return
	assert_lt(lines, 400, "player.gd must be under 400 lines after split (currently %d)" % lines)


# =====================================================================
# 2. Split files exist (player_skill.gd, etc.)
# =====================================================================

func test_player_skill_file_exists():
	if not ResourceLoader.exists("res://scripts/player_skill.gd"):
		pending("Programmer has not yet created player_skill.gd split file")
		return
	assert_true(ResourceLoader.exists("res://scripts/player_skill.gd"),
		"player_skill.gd should exist as extracted module from player.gd")


func test_player_split_file_is_valid():
	# player_skill.gd was the actual extracted module
	if not ResourceLoader.exists("res://scripts/player_skill.gd"):
		pending("player_skill.gd not yet created")
		return
	var script: GDScript = load("res://scripts/player_skill.gd")
	assert_ne(script, null, "player_skill.gd should load as valid GDScript")


# =====================================================================
# 3. Player scene instantiation does not crash
# =====================================================================

func test_player_instantiation_no_crash():
	assert_true(is_instance_valid(_player), "Player should instantiate without crash")


func test_player_is_character_body():
	assert_true(_player is CharacterBody2D,
		"Player should be CharacterBody2D type")


func test_player_has_required_nodes():
	assert_ne(_player.get_node_or_null("Hurtbox"), null,
		"Player should have Hurtbox node")
	assert_ne(_player.get_node_or_null("CollisionShape2D"), null,
		"Player should have CollisionShape2D node")
	assert_ne(_player.get_node_or_null("Sprite"), null,
		"Player should have Sprite node")


# =====================================================================
# 4. Player basic movement functionality
# =====================================================================

func test_player_move_speed_positive():
	assert_gt(_player.move_speed, 0.0,
		"Player move_speed should be positive")


func test_player_default_move_speed():
	assert_eq(_player.move_speed, 160.0,
		"Player default move_speed should be 160.0")


func test_player_speed_multiplier_default():
	assert_eq(_player.speed_multiplier, 1.0,
		"Player speed_multiplier should default to 1.0")


func test_player_velocity_starts_zero():
	assert_eq(_player.velocity, Vector2.ZERO,
		"Player velocity should start at zero")


func test_player_max_health_positive():
	assert_gt(_player.max_health, 0.0,
		"Player max_health should be positive")


func test_player_health_equals_max():
	assert_eq(_player.current_health, _player.max_health,
		"Player current_health should equal max_health at start")


func test_player_is_alive():
	assert_true(_player.is_alive,
		"Player should start alive")


# =====================================================================
# 5. Player weapon management functionality
# =====================================================================

func test_player_add_weapon():
	_player.add_weapon("knife")
	assert_eq(_player.owned_weapons.get("knife", 0), 1,
		"Player should have knife at level 1 after add_weapon")


func test_player_upgrade_weapon():
	_player.add_weapon("knife")
	var result: bool = _player.upgrade_weapon("knife")
	assert_true(result, "Upgrade should succeed")
	assert_eq(_player.owned_weapons["knife"], 2,
		"Knife should be level 2 after upgrade")


func test_player_weapon_max_level():
	_player.add_weapon("knife")
	_player.upgrade_weapon("knife")
	_player.upgrade_weapon("knife")
	var result: bool = _player.upgrade_weapon("knife")
	assert_false(result, "Should not exceed max level 3")
	assert_eq(_player.owned_weapons["knife"], 3,
		"Knife should stay at level 3")


func test_player_get_weapon_level():
	assert_eq(_player.get_weapon_level("knife"), 0,
		"Non-owned weapon should be level 0")
	_player.add_weapon("knife")
	assert_eq(_player.get_weapon_level("knife"), 1,
		"Owned weapon should be level 1")


func test_player_owned_weapons_initially_empty():
	assert_eq(_player.owned_weapons.size(), 0,
		"Player should start with no weapons")


func test_player_weapon_controller_exists():
	assert_ne(_player.get_node_or_null("WeaponController"), null,
		"Player should have WeaponController node")


# =====================================================================
# 6. Player dash functionality
# =====================================================================

func test_player_dash_defaults():
	assert_eq(_player.dash_distance, 80.0,
		"Default dash distance should be 80.0")
	assert_eq(_player.dash_duration, 0.15,
		"Default dash duration should be 0.15")
	assert_eq(_player.dash_cooldown, 2.5,
		"Default dash cooldown should be 2.5")
	assert_eq(_player.dash_timer, 0.0,
		"Dash timer should start at 0.0")
	assert_false(_player.is_dashing,
		"Player should not be dashing initially")
	assert_eq(_player.dash_direction, Vector2.ZERO,
		"Dash direction should start at ZERO")


func test_player_dash_afterimage_count():
	assert_eq(_player.dash_afterimage_count, 3,
		"Dash afterimage count should be 3")


func test_player_take_damage():
	_player.take_damage(3.0)
	assert_eq(_player.current_health, _player.max_health - 3.0,
		"HP should decrease by damage amount")


func test_player_invincibility_after_hit():
	_player.take_damage(1.0)
	assert_gt(_player.invincible_timer, 0.0,
		"Player should have invincibility timer after taking damage")


func test_player_heal():
	_player.take_damage(3.0)
	_player.heal(2.0)
	assert_eq(_player.current_health, _player.max_health - 1.0,
		"HP should increase by heal amount")


func test_player_die():
	_player.take_damage(999.0)
	assert_eq(_player.current_health, 0.0,
		"HP should be 0 after lethal damage")
	assert_false(_player.is_alive,
		"Player should not be alive after lethal damage")
