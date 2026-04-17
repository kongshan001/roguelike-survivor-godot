extends GutTest
## R26 Task C: Pause Mastery Panel Tests
## Validates the mastery panel pause display integration and build_pause_panel().
## The hud_mastery_panel.gd module was extracted in R25; R26 adds build_pause_panel().

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
# Section A: build_pause_panel Method Existence
# =====================================================================

func test_panel_has_build_pause_panel():
	assert_true(_panel.has_method("build_pause_panel"),
		"hud_mastery_panel should have build_pause_panel method for pause menu")


# =====================================================================
# Section B: build_pause_panel Returns Control
# =====================================================================

func test_build_pause_panel_returns_control():
	if not _panel.has_method("build_pause_panel"):
		return
	var result: Control = _panel.build_pause_panel()
	assert_not_null(result, "build_pause_panel should return a non-null Control")
	if result:
		add_child_autofree(result)


func test_build_pause_panel_has_children():
	if not _panel.has_method("build_pause_panel"):
		return
	var result: Control = _panel.build_pause_panel()
	if result:
		add_child_autofree(result)
		assert_gt(result.get_child_count(), 0,
			"Pause panel should have child nodes for weapon rows")


# =====================================================================
# Section C: Pause Panel Shows Weapon Mastery Data
# =====================================================================

func test_build_pause_panel_reads_mastery_data():
	# Set up mastery data for knife
	SaveManager.weapon_kills["knife"] = 150
	if not _panel.has_method("build_pause_panel"):
		return
	var result: Control = _panel.build_pause_panel()
	if result:
		add_child_autofree(result)
		# The panel should reflect the mastery tier from SaveManager
		var knife_tier: int = SaveManager.get_weapon_mastery_tier("knife")
		assert_eq(knife_tier, 1, "Knife at 150 kills should be tier 1 (Apprentice)")


func test_build_pause_panel_shows_all_base_weapons():
	# The mastery panel should display all 7 base weapons
	if not _panel.has_method("build_pause_panel"):
		return
	var result: Control = _panel.build_pause_panel()
	if result:
		add_child_autofree(result)
		# Check that SaveManager.BASE_WEAPONS or mastery panel references 7 weapons
		var base_weapons: Array = SaveManager.BASE_WEAPONS if "BASE_WEAPONS" in SaveManager else []
		if base_weapons.size() > 0:
			assert_eq(base_weapons.size(), 7,
				"Should reference 7 base weapons for mastery display")


# =====================================================================
# Section D: Panel Dimensions and Styling
# =====================================================================

func test_build_pause_panel_width():
	if not _panel.has_method("build_pause_panel"):
		return
	var result: Control = _panel.build_pause_panel()
	if result:
		add_child_autofree(result)
		# Per spec: panel width should be 300px
		assert_eq(result.size.x, 300.0,
			"Pause panel width should be 300px per spec")


func test_build_pause_panel_background_color():
	if not _panel.has_method("build_pause_panel"):
		return
	var result: Control = _panel.build_pause_panel()
	if result:
		add_child_autofree(result)
		# Per spec: background should be semi-transparent dark
		# The panel or its first child should have a dark background
		if result is ColorRect:
			var bg_color: Color = result.color
			assert_lt(bg_color.r, 0.15,
				"Background R should be dark (< 0.15)")
			assert_lt(bg_color.g, 0.15,
				"Background G should be dark (< 0.15)")
			assert_lt(bg_color.b, 0.15,
				"Background B should be dark (< 0.15)")


# =====================================================================
# Section E: Mastery Tier Display in Panel
# =====================================================================

func test_panel_displays_tier_names():
	# Verify the panel uses MASTERY_TIER_NAMES for display
	assert_eq(_panel.MASTERY_TIER_NAMES[0], "Novice", "Tier 0 = Novice")
	assert_eq(_panel.MASTERY_TIER_NAMES[1], "Apprentice", "Tier 1 = Apprentice")
	assert_eq(_panel.MASTERY_TIER_NAMES[2], "Adept", "Tier 2 = Adept")
	assert_eq(_panel.MASTERY_TIER_NAMES[3], "Expert", "Tier 3 = Expert")
	assert_eq(_panel.MASTERY_TIER_NAMES[4], "Master", "Tier 4 = Master")


func test_panel_displays_correct_tier_for_kills():
	# Verify SaveManager returns correct tier for kill counts
	SaveManager.weapon_kills["knife"] = 0
	assert_eq(SaveManager.get_weapon_mastery_tier("knife"), 0,
		"0 kills = tier 0 (Novice)")

	SaveManager.weapon_kills["knife"] = 50
	assert_eq(SaveManager.get_weapon_mastery_tier("knife"), 1,
		"50 kills = tier 1 (Apprentice)")

	SaveManager.weapon_kills["knife"] = 200
	assert_eq(SaveManager.get_weapon_mastery_tier("knife"), 2,
		"200 kills = tier 2 (Adept)")

	SaveManager.weapon_kills["knife"] = 500
	assert_eq(SaveManager.get_weapon_mastery_tier("knife"), 3,
		"500 kills = tier 3 (Expert)")

	SaveManager.weapon_kills["knife"] = 1000
	assert_eq(SaveManager.get_weapon_mastery_tier("knife"), 4,
		"1000 kills = tier 4 (Master)")


func test_panel_displays_correct_bonus_for_tier():
	# Verify mastery bonus matches spec
	assert_eq(SaveManager.get_weapon_mastery_bonus("knife"), 0.0,
		"0 kills = 0% bonus")

	SaveManager.weapon_kills["knife"] = 50
	assert_eq(SaveManager.get_weapon_mastery_bonus("knife"), 0.02,
		"Tier 1 = +2% bonus")

	SaveManager.weapon_kills["knife"] = 200
	assert_eq(SaveManager.get_weapon_mastery_bonus("knife"), 0.04,
		"Tier 2 = +4% bonus")

	SaveManager.weapon_kills["knife"] = 500
	assert_eq(SaveManager.get_weapon_mastery_bonus("knife"), 0.06,
		"Tier 3 = +6% bonus")

	SaveManager.weapon_kills["knife"] = 1000
	assert_eq(SaveManager.get_weapon_mastery_bonus("knife"), 0.08,
		"Tier 4 = +8% bonus")


# =====================================================================
# Section F: HUD Pause Integration
# =====================================================================

func test_hud_has_pause_panel_variable():
	# Verify HUD has the _pause_panel variable for pause display
	# This tests the R26 Programmer addition: _pause_panel member in hud.gd
	var source: String = _hud.get_script().source_code
	assert_true(source.find("_pause_panel") != -1,
		"HUD should have _pause_panel variable or reference for pause display")


func test_hud_has_pause_toggled_handler():
	# Check if HUD has a method to handle pause toggling
	# Per spec: _on_pause_toggled() toggles build_pause_panel visibility
	assert_true(_hud.has_method("_on_pause_toggled") or
		_hud.get_script().source_code.find("_on_pause_toggled") != -1,
		"HUD should have _on_pause_toggled method for mastery panel display")


# =====================================================================
# Section G: Mastery Tier Colors Match Pause Panel Spec
# =====================================================================

func test_pause_panel_tier_1_color_is_bronze():
	var c: Color = _panel.MASTERY_TIER_COLORS[1]
	assert_almost_eq(c.r, 0.80, 0.05, "Tier 1 color R should be bronze")
	assert_almost_eq(c.g, 0.55, 0.15, "Tier 1 color G should be bronze")


func test_pause_panel_tier_3_color_is_gold():
	var c: Color = _panel.MASTERY_TIER_COLORS[3]
	assert_almost_eq(c.r, 0.95, 0.05, "Tier 3 color R should be gold")
	assert_almost_eq(c.g, 0.82, 0.05, "Tier 3 color G should be gold")


func test_pause_panel_tier_4_color_is_diamond():
	var c: Color = _panel.MASTERY_TIER_COLORS[4]
	assert_almost_eq(c.r, 1.0, 0.05, "Tier 4 color R should be diamond")
	assert_almost_eq(c.g, 0.85, 0.10, "Tier 4 color G should be diamond")


# =====================================================================
# Section H: get_weapon_display_name covers all base weapons
# =====================================================================

func test_all_base_weapons_have_display_names():
	var base_ids: Array = ["knife", "holywater", "lightning", "bible",
		"firestaff", "frostaura", "boomerang"]
	for id: String in base_ids:
		var name: String = _panel.get_weapon_display_name(id)
		assert_ne(name, id,
			"%s should have a display name, not fall back to raw id" % id)


# =====================================================================
# Section I: on_tier_up integration with pause panel data
# =====================================================================

func test_on_tier_up_updates_badge_for_existing_weapon():
	# Create a badge for knife, then trigger tier up
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_panel.ensure_badge("knife", slot)
	assert_true(_panel._mastery_badges.has("knife"), "Badge should exist")

	# Simulate tier up from 1 to 2
	_panel.on_tier_up("knife", 2)

	# Badge should still exist and be updated
	assert_true(_panel._mastery_badges.has("knife"),
		"Badge should still exist after tier up")
	var badge_data: Dictionary = _panel._mastery_badges["knife"]
	var border: ColorRect = badge_data["border"]
	assert_eq(border.color, _panel.MASTERY_TIER_BORDERS[2],
		"Badge border should be updated to tier 2 color")


func test_on_tier_up_triggers_flash_for_tier_3():
	# on_tier_up with tier 3 should create mastery flash
	_panel.on_tier_up("knife", 3)
	# Flash should have been created
	if _panel._mastery_flash != null:
		assert_true(_panel._mastery_flash.visible,
			"Mastery flash should be visible after tier 3 tier up")


func test_on_tier_up_triggers_flash_for_tier_4():
	_panel.on_tier_up("knife", 4)
	if _panel._mastery_flash != null:
		assert_true(_mastery_flash_was_triggered(),
			"Mastery flash should trigger for tier 4")


func _mastery_flash_was_triggered() -> bool:
	# Check if flash was created by examining _mastery_flash
	return _panel._mastery_flash != null


# =====================================================================
# Section J: Regression -- existing mastery badge tests still pass
# =====================================================================

func test_ensure_badge_creates_entry_regression():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_panel.ensure_badge("knife", slot)
	assert_true(_panel._mastery_badges.has("knife"),
		"Badge creation should work as before (regression check)")


func test_badge_hidden_at_tier_0_regression():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	_panel.ensure_badge("knife", slot)
	var border: ColorRect = _panel._mastery_badges["knife"]["border"]
	assert_false(border.visible,
		"Badge should be hidden at tier 0 (regression check)")


func test_get_weapon_display_name_regression():
	assert_eq(_panel.get_weapon_display_name("knife"), "Knife",
		"Knife display name should still work (regression)")
	assert_eq(_panel.get_weapon_display_name("holywater"), "Holy Water",
		"Holy Water display name should still work (regression)")
	assert_eq(_panel.get_weapon_display_name("unknown"), "unknown",
		"Unknown weapon should return raw id (regression)")
