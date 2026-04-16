extends "res://addons/gut/test.gd"
## Unit tests for HUD skill button display
## Covers: _setup_skill_button creates visual elements, _update_skill_display
## updates cooldown overlay and border color
## Reference: HUD skill button implementation in hud.gd lines 392-479


var _hud: CanvasLayer
var _arena: Node2D
var _player: CharacterBody2D


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

	# Build arena tree with player so _get_player() works
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

	# Instantiate HUD scene
	_hud = load("res://scenes/hud.tscn").instantiate()
	_arena.add_child(_hud)


func after_each():
	# Clean up weapon instances from HUD-triggered upgrades
	if is_instance_valid(_player):
		var wc: Node = _player.get_node_or_null("WeaponController")
		if wc:
			for wid in _player.owned_weapons.keys():
				wc.remove_weapon_instances(wid)
			wc._boomerang_instances.clear()
			wc._orbit_instances.clear()
			wc._weapon_timers.clear()
	await get_tree().process_frame


# =====================================================================
# 1. SKILL BUTTON VARIABLES EXIST
# =====================================================================

func test_skill_button_bg_variable_exists():
	# _skill_bg is the outer ColorRect for the skill button
	# Without a character, _setup_skill_button does nothing
	# Test that the variable name exists in the script
	var hud_script := load("res://scripts/hud.gd")
	var source: String = hud_script.source_code
	assert_true(
		"_skill_bg" in source,
		"hud.gd should declare _skill_bg variable"
	)


func test_skill_button_icon_variable_exists():
	var hud_script := load("res://scripts/hud.gd")
	var source: String = hud_script.source_code
	assert_true(
		"_skill_icon" in source,
		"hud.gd should declare _skill_icon variable"
	)


func test_skill_button_cooldown_overlay_variable_exists():
	var hud_script := load("res://scripts/hud.gd")
	var source: String = hud_script.source_code
	assert_true(
		"_skill_cooldown_overlay" in source,
		"hud.gd should declare _skill_cooldown_overlay variable"
	)


func test_skill_button_key_label_variable_exists():
	var hud_script := load("res://scripts/hud.gd")
	var source: String = hud_script.source_code
	assert_true(
		"_skill_key_label" in source,
		"hud.gd should declare _skill_key_label variable"
	)


# =====================================================================
# 2. SKILL BUTTON SETUP
# =====================================================================

func test_skill_button_no_creation_without_character():
	# Without a character selected, skill button should not be created
	assert_eq(_hud._skill_bg, null, "Skill bg should be null without character")


func test_skill_button_setup_with_mage():
	# Set up mage character and re-trigger skill button setup
	_player._init_skill("elemental_burst", 20.0)
	_player.skill_id = "elemental_burst"
	_hud._setup_skill_button()
	assert_not_null(_hud._skill_bg, "Skill bg should be created for mage")
	assert_not_null(_hud._skill_icon, "Skill icon should be created for mage")
	assert_not_null(_hud._skill_cooldown_overlay, "Cooldown overlay should be created for mage")


func test_skill_button_setup_with_warrior():
	_player._init_skill("shield_charge", 15.0)
	_player.skill_id = "shield_charge"
	_hud._setup_skill_button()
	assert_not_null(_hud._skill_bg, "Skill bg should be created for warrior")


func test_skill_button_setup_with_ranger():
	_player._init_skill("arrow_rain", 18.0)
	_player.skill_id = "arrow_rain"
	_hud._setup_skill_button()
	assert_not_null(_hud._skill_bg, "Skill bg should be created for ranger")


func test_skill_button_bg_is_color_rect():
	_player._init_skill("elemental_burst", 20.0)
	_player.skill_id = "elemental_burst"
	_hud._setup_skill_button()
	assert_true(
		_hud._skill_bg is ColorRect,
		"Skill bg should be a ColorRect"
	)


func test_skill_button_icon_is_child_of_bg():
	_player._init_skill("elemental_burst", 20.0)
	_player.skill_id = "elemental_burst"
	_hud._setup_skill_button()
	assert_eq(
		_hud._skill_icon.get_parent(),
		_hud._skill_bg,
		"Skill icon should be child of skill bg"
	)


func test_skill_button_cooldown_overlay_is_child_of_icon():
	_player._init_skill("elemental_burst", 20.0)
	_player.skill_id = "elemental_burst"
	_hud._setup_skill_button()
	assert_eq(
		_hud._skill_cooldown_overlay.get_parent(),
		_hud._skill_icon,
		"Cooldown overlay should be child of skill icon"
	)


func test_skill_button_key_label_shows_e():
	_player._init_skill("elemental_burst", 20.0)
	_player.skill_id = "elemental_burst"
	_hud._setup_skill_button()
	assert_not_null(_hud._skill_key_label, "Key label should exist")
	assert_eq(_hud._skill_key_label.text, "E", "Key label should show 'E'")


func test_skill_button_size_constant():
	# Verify the button size constant matches the expected 48px
	assert_eq(_hud.SKILL_BUTTON_SIZE, 48.0, "SKILL_BUTTON_SIZE should be 48.0")


# =====================================================================
# 3. SKILL BUTTON UPDATE
# =====================================================================

func test_skill_button_ready_color():
	# When skill is ready, bg should be gold/yellow
	_player._init_skill("elemental_burst", 20.0)
	_player.skill_id = "elemental_burst"
	_player.is_skill_ready = true
	_hud._setup_skill_button()
	_hud._update_skill_display()
	assert_eq(
		_hud._skill_bg.color,
		_hud.SKILL_READY_COLOR,
		"Skill bg should be ready color when skill is ready"
	)


func test_skill_button_cooldown_color():
	# When skill is on cooldown, bg should be dark gray
	_player._init_skill("elemental_burst", 20.0)
	_player.skill_id = "elemental_burst"
	_player.is_skill_ready = false
	_player.skill_timer = 10.0
	_player.skill_cooldown_max = 20.0
	_hud._setup_skill_button()
	_hud._update_skill_display()
	assert_eq(
		_hud._skill_bg.color,
		Color(0.3, 0.3, 0.3),
		"Skill bg should be dark gray when on cooldown"
	)


func test_skill_button_cooldown_overlay_height():
	# At 50% cooldown (timer=10, max=20), overlay height should be ~50% of icon area
	_player._init_skill("elemental_burst", 20.0)
	_player.skill_id = "elemental_burst"
	_player.is_skill_ready = false
	_player.skill_timer = 10.0
	_player.skill_cooldown_max = 20.0
	_hud._setup_skill_button()
	_hud._update_skill_display()

	var border: float = 2.0
	var inner_size: float = _hud.SKILL_BUTTON_SIZE - border * 2.0
	var expected_height: float = inner_size * (1.0 - 10.0 / 20.0)
	assert_almost_eq(
		_hud._skill_cooldown_overlay.size.y,
		expected_height,
		0.5,
		"Cooldown overlay height should reflect 50% cooldown progress"
	)


func test_skill_button_full_cooldown_overlay():
	# At full cooldown (timer=20, max=20), overlay should be 0 height
	_player._init_skill("elemental_burst", 20.0)
	_player.skill_id = "elemental_burst"
	_player.is_skill_ready = false
	_player.skill_timer = 20.0
	_player.skill_cooldown_max = 20.0
	_hud._setup_skill_button()
	_hud._update_skill_display()
	assert_almost_eq(
		_hud._skill_cooldown_overlay.size.y,
		0.0,
		0.1,
		"Cooldown overlay should be 0 height at full cooldown"
	)


func test_skill_button_no_update_without_skill():
	# _update_skill_display should not crash when _skill_bg is null
	_hud._skill_bg = null
	_hud._update_skill_display()
	assert_true(true, "Should not crash when skill bg is null")


func test_skill_button_mage_icon_color():
	# Mage skill icon should load elemental_burst sprite or fallback to blue
	GameManager.selected_character = "mage"
	_player._init_skill("elemental_burst", 20.0)
	_player.skill_id = "elemental_burst"
	_hud._setup_skill_button()
	assert_true(
		_hud._skill_icon is TextureRect,
		"Skill icon should be TextureRect"
	)
	if _hud._skill_icon.texture != null:
		assert_true(true, "Mage skill icon loaded sprite texture")
	else:
		assert_eq(
			_hud._skill_icon.self_modulate,
			Color(0.2, 0.4, 0.9),
			"Mage skill icon fallback should be blue"
		)


func test_skill_button_warrior_icon_color():
	# Warrior skill icon should load shield_charge sprite or fallback to red
	GameManager.selected_character = "warrior"
	_player._init_skill("shield_charge", 15.0)
	_player.skill_id = "shield_charge"
	_hud._setup_skill_button()
	assert_true(
		_hud._skill_icon is TextureRect,
		"Skill icon should be TextureRect"
	)
	if _hud._skill_icon.texture != null:
		assert_true(true, "Warrior skill icon loaded sprite texture")
	else:
		assert_eq(
			_hud._skill_icon.self_modulate,
			Color(0.8, 0.2, 0.2),
			"Warrior skill icon fallback should be red"
		)


func test_skill_button_ranger_icon_color():
	# Ranger skill icon should load arrow_rain sprite or fallback to green
	GameManager.selected_character = "ranger"
	_player._init_skill("arrow_rain", 18.0)
	_player.skill_id = "arrow_rain"
	_hud._setup_skill_button()
	assert_true(
		_hud._skill_icon is TextureRect,
		"Skill icon should be TextureRect"
	)
	if _hud._skill_icon.texture != null:
		assert_true(true, "Ranger skill icon loaded sprite texture")
	else:
		assert_eq(
			_hud._skill_icon.self_modulate,
			Color(0.2, 0.7, 0.3),
			"Ranger skill icon fallback should be green"
		)


