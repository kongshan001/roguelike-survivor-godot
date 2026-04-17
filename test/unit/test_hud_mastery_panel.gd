extends GutTest
## R25: hud_mastery_panel.gd extracted module tests
## Validates the mastery badge/flash subsystem extracted from hud.gd.

var _hud: CanvasLayer
var _arena: Node2D
var _player: CharacterBody2D
var _panel: RefCounted


func before_each():
	GameManager.reset()
	SaveManager.reset_save()
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

	_hud = load("res://scenes/hud.tscn").instantiate()
	_arena.add_child(_hud)
	_panel = _hud._mastery_panel


func after_each():
	await get_tree().process_frame


# =====================================================================
# Section A: Panel Initialization
# =====================================================================

func test_panel_exists():
	assert_true(_panel != null, "_mastery_panel should be initialized in _ready")


func test_panel_script_is_correct():
	var script_path: String = _panel.get_script().resource_path
	assert_eq(script_path, "res://scripts/hud_mastery_panel.gd",
		"Panel should use hud_mastery_panel.gd script")


func test_panel_has_badges_dict():
	assert_true("_mastery_badges" in _panel,
		"Panel should have _mastery_badges dictionary")
	assert_eq(_panel._mastery_badges.size(), 0,
		"Badges dict should be empty initially")


func test_panel_has_flash_var():
	assert_true("_mastery_flash" in _panel,
		"Panel should have _mastery_flash variable")
	assert_eq(_panel._mastery_flash, null,
		"Flash should be null initially")


# =====================================================================
# Section B: Constants
# =====================================================================

func test_mastery_badge_size():
	assert_eq(_panel.MASTERY_BADGE_SIZE, 6.0,
		"MASTERY_BADGE_SIZE should be 6.0")


func test_mastery_fill_size():
	assert_eq(_panel.MASTERY_FILL_SIZE, 4.0,
		"MASTERY_FILL_SIZE should be 4.0")


func test_mastery_fill_offset():
	assert_eq(_panel.MASTERY_FILL_OFFSET, 1.0,
		"MASTERY_FILL_OFFSET should be 1.0")


func test_tier_colors_count():
	assert_eq(_panel.MASTERY_TIER_COLORS.size(), 5,
		"Should have 5 tier colors (Tier 0-4)")


func test_tier_borders_count():
	assert_eq(_panel.MASTERY_TIER_BORDERS.size(), 5,
		"Should have 5 tier borders (Tier 0-4)")


func test_tier_names_count():
	assert_eq(_panel.MASTERY_TIER_NAMES.size(), 5,
		"Should have 5 tier names (Tier 0-4)")


func test_tier_names_values():
	assert_eq(_panel.MASTERY_TIER_NAMES[0], "Novice", "Tier 0 = Novice")
	assert_eq(_panel.MASTERY_TIER_NAMES[1], "Apprentice", "Tier 1 = Apprentice")
	assert_eq(_panel.MASTERY_TIER_NAMES[2], "Adept", "Tier 2 = Adept")
	assert_eq(_panel.MASTERY_TIER_NAMES[3], "Expert", "Tier 3 = Expert")
	assert_eq(_panel.MASTERY_TIER_NAMES[4], "Master", "Tier 4 = Master")


func test_tier_color_tier0_transparent():
	assert_eq(_panel.MASTERY_TIER_COLORS[0], Color.TRANSPARENT,
		"Tier 0 color should be transparent")


func test_tier_color_tier1_bronze():
	var c: Color = _panel.MASTERY_TIER_COLORS[1]
	assert_almost_eq(c.r, 0.80, 0.01, "Tier 1 R should be bronze")
	assert_almost_eq(c.g, 0.55, 0.01, "Tier 1 G should be bronze")
	assert_almost_eq(c.b, 0.35, 0.01, "Tier 1 B should be bronze")


func test_tier_color_tier2_silver():
	var c: Color = _panel.MASTERY_TIER_COLORS[2]
	assert_almost_eq(c.r, 0.78, 0.01, "Tier 2 R should be silver")
	assert_almost_eq(c.g, 0.78, 0.01, "Tier 2 G should be silver")


func test_tier_color_tier3_gold():
	var c: Color = _panel.MASTERY_TIER_COLORS[3]
	assert_almost_eq(c.r, 0.95, 0.01, "Tier 3 R should be gold")
	assert_almost_eq(c.g, 0.82, 0.01, "Tier 3 G should be gold")


func test_tier_color_tier4_diamond():
	var c: Color = _panel.MASTERY_TIER_COLORS[4]
	assert_almost_eq(c.r, 1.0, 0.01, "Tier 4 R should be diamond")
	assert_almost_eq(c.g, 0.85, 0.01, "Tier 4 G should be diamond")


# =====================================================================
# Section C: Method Existence
# =====================================================================

func test_has_ensure_badge():
	assert_true(_panel.has_method("ensure_badge"),
		"Panel should have ensure_badge method")


func test_has_on_tier_up():
	assert_true(_panel.has_method("on_tier_up"),
		"Panel should have on_tier_up method")


func test_has_get_weapon_display_name():
	assert_true(_panel.has_method("get_weapon_display_name"),
		"Panel should have get_weapon_display_name method")


func test_has_show_mastery_flash():
	assert_true(_panel.has_method("_show_mastery_flash"),
		"Panel should have _show_mastery_flash method")


func test_has_update_badge_tier():
	assert_true(_panel.has_method("_update_badge_tier"),
		"Panel should have _update_badge_tier method")


func test_has_start_badge_pulse():
	assert_true(_panel.has_method("_start_badge_pulse"),
		"Panel should have _start_badge_pulse method")


# =====================================================================
# Section D: Badge Creation
# =====================================================================

func test_ensure_badge_creates_entry():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_panel.ensure_badge("knife", slot)
	assert_true(_panel._mastery_badges.has("knife"),
		"Badge should be created for knife")
	var badge_data: Dictionary = _panel._mastery_badges["knife"]
	assert_true(badge_data.has("border"), "Should have border")
	assert_true(badge_data.has("fill"), "Should have fill")


func test_ensure_badge_no_duplicate():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_panel.ensure_badge("knife", slot)
	_panel.ensure_badge("knife", slot)
	assert_eq(_panel._mastery_badges.size(), 1,
		"Should not create duplicate badge")


func test_badge_border_is_color_rect():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_panel.ensure_badge("knife", slot)
	var border: ColorRect = _panel._mastery_badges["knife"]["border"]
	assert_true(border is ColorRect, "Border should be ColorRect")
	assert_eq(border.size, Vector2(6.0, 6.0), "Border size should be 6x6")


func test_badge_fill_is_color_rect():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_panel.ensure_badge("knife", slot)
	var fill: ColorRect = _panel._mastery_badges["knife"]["fill"]
	assert_true(fill is ColorRect, "Fill should be ColorRect")
	assert_eq(fill.size, Vector2(4.0, 4.0), "Fill size should be 4x4")


func test_badge_hidden_at_tier_0():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	_panel.ensure_badge("knife", slot)
	var border: ColorRect = _panel._mastery_badges["knife"]["border"]
	assert_false(border.visible, "Badge should be hidden at Tier 0")


func test_badge_visible_at_tier_1():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_panel.ensure_badge("knife", slot)
	var border: ColorRect = _panel._mastery_badges["knife"]["border"]
	assert_true(border.visible, "Badge should be visible at Tier 1")


func test_badge_border_color_matches_tier():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 200  # Tier 2
	_panel.ensure_badge("knife", slot)
	var border: ColorRect = _panel._mastery_badges["knife"]["border"]
	assert_eq(border.color, _panel.MASTERY_TIER_BORDERS[2],
		"Border color should match Tier 2 border color")


func test_badge_fill_color_matches_tier():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 200  # Tier 2
	_panel.ensure_badge("knife", slot)
	var fill: ColorRect = _panel._mastery_badges["knife"]["fill"]
	assert_eq(fill.color, _panel.MASTERY_TIER_COLORS[2],
		"Fill color should match Tier 2 fill color")


func test_badge_position_bottom_right():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_panel.ensure_badge("knife", slot)
	var border: ColorRect = _panel._mastery_badges["knife"]["border"]
	var expected_pos: Vector2 = Vector2(32.0 - 6.0 - 1.0, 32.0 - 6.0 - 1.0)
	assert_eq(border.position, expected_pos,
		"Badge should be positioned at bottom-right of slot")


# =====================================================================
# Section E: Weapon Display Names
# =====================================================================

func test_display_name_knife():
	assert_eq(_panel.get_weapon_display_name("knife"), "Knife")


func test_display_name_holywater():
	assert_eq(_panel.get_weapon_display_name("holywater"), "Holy Water")


func test_display_name_lightning():
	assert_eq(_panel.get_weapon_display_name("lightning"), "Lightning")


func test_display_name_bible():
	assert_eq(_panel.get_weapon_display_name("bible"), "Bible")


func test_display_name_firestaff():
	assert_eq(_panel.get_weapon_display_name("firestaff"), "Fire Staff")


func test_display_name_frostaura():
	assert_eq(_panel.get_weapon_display_name("frostaura"), "Frost Aura")


func test_display_name_boomerang():
	assert_eq(_panel.get_weapon_display_name("boomerang"), "Boomerang")


func test_display_name_unknown():
	assert_eq(_panel.get_weapon_display_name("unknown_weapon"), "unknown_weapon",
		"Unknown weapon returns weapon_id as fallback")


# =====================================================================
# Section F: HUD Delegation (backward compat)
# =====================================================================

func test_hud_delegates_ensure_badge():
	assert_true(_hud.has_method("_ensure_mastery_badge"),
		"HUD should still have _ensure_mastery_badge for backward compat")


func test_hud_delegates_on_tier_up():
	assert_true(_hud.has_method("_on_mastery_tier_up"),
		"HUD should still have _on_mastery_tier_up for signal connection")


func test_hud_delegates_show_mastery_flash():
	assert_true(_hud.has_method("_show_mastery_flash"),
		"HUD should still have _show_mastery_flash for backward compat")


func test_hud_pass_through_tier_colors():
	assert_eq(_hud.MASTERY_TIER_COLORS.size(), 5,
		"HUD pass-through should have 5 tier colors")


func test_hud_pass_through_tier_names():
	assert_eq(_hud.MASTERY_TIER_NAMES.size(), 5,
		"HUD pass-through should have 5 tier names")


func test_hud_pass_through_badge_size():
	assert_eq(_hud.MASTERY_BADGE_SIZE, 6.0,
		"HUD pass-through should have correct badge size")


func test_hud_pass_through_badges_dict():
	assert_eq(_hud._mastery_badges.size(), 0,
		"HUD pass-through badges dict should delegate to panel")


func test_hud_get_weapon_display_name_delegates():
	assert_eq(_hud._get_weapon_display_name("knife"), "Knife",
		"HUD _get_weapon_display_name should delegate to panel")
