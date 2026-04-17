extends GutTest
## R22 Task 1: Mastery HUD Badge Tests
## Validates mastery badge constants, structure, and integration.
## Tests match actual hud.gd implementation (_ensure_mastery_badge pattern).

var _hud: CanvasLayer
var _arena: Node2D
var _player: CharacterBody2D


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


func after_each():
	await get_tree().process_frame


# =====================================================================
# Section A: Badge Constants
# =====================================================================

func test_mastery_tier_colors_defined():
	assert_true(_hud.MASTERY_TIER_COLORS.size() >= 5,
		"MASTERY_TIER_COLORS should have 5 entries (Tier 0-4)")


func test_mastery_tier_colors_match_spec():
	# Match actual hud.gd values
	assert_eq(_hud.MASTERY_TIER_COLORS[0], Color.TRANSPARENT,
		"Tier 0 should be transparent")
	# Tier 1: Bronze
	assert_almost_eq(_hud.MASTERY_TIER_COLORS[1].r, 0.80, 0.01,
		"Tier 1 R should be bronze")
	assert_almost_eq(_hud.MASTERY_TIER_COLORS[1].g, 0.55, 0.01,
		"Tier 1 G should be bronze")
	# Tier 2: Silver
	assert_almost_eq(_hud.MASTERY_TIER_COLORS[2].r, 0.78, 0.01,
		"Tier 2 R should be silver")
	# Tier 3: Gold
	assert_almost_eq(_hud.MASTERY_TIER_COLORS[3].r, 0.95, 0.01,
		"Tier 3 R should be gold")
	assert_almost_eq(_hud.MASTERY_TIER_COLORS[3].g, 0.82, 0.01,
		"Tier 3 G should be gold")
	# Tier 4: Diamond
	assert_almost_eq(_hud.MASTERY_TIER_COLORS[4].r, 1.0, 0.01,
		"Tier 4 R should be diamond")
	assert_almost_eq(_hud.MASTERY_TIER_COLORS[4].g, 0.85, 0.01,
		"Tier 4 G should be diamond")


func test_mastery_tier_borders_defined():
	assert_true(_hud.MASTERY_TIER_BORDERS.size() >= 5,
		"MASTERY_TIER_BORDERS should have 5 entries")


func test_mastery_tier_names_defined():
	assert_eq(_hud.MASTERY_TIER_NAMES.size(), 5,
		"Should have 5 tier names")
	assert_eq(_hud.MASTERY_TIER_NAMES[0], "Novice",
		"Tier 0 name")
	assert_eq(_hud.MASTERY_TIER_NAMES[1], "Apprentice",
		"Tier 1 name")
	assert_eq(_hud.MASTERY_TIER_NAMES[4], "Master",
		"Tier 4 name")


func test_badge_size_constant():
	assert_eq(_hud.MASTERY_BADGE_SIZE, 6.0,
		"Badge size should be 6x6 per spec")


# =====================================================================
# Section B: Badge Method Existence
# =====================================================================

func test_hud_has_ensure_mastery_badge():
	assert_true(_hud.has_method("_ensure_mastery_badge"),
		"HUD should have _ensure_mastery_badge method")


func test_hud_has_mastery_badges_dict():
	assert_true("_mastery_badges" in _hud,
		"HUD should have _mastery_badges dictionary")


func test_hud_has_on_mastery_tier_up():
	assert_true(_hud.has_method("_on_mastery_tier_up"),
		"HUD should have _on_mastery_tier_up signal handler")


# =====================================================================
# Section C: Mastery Signal in SaveManager
# =====================================================================

func test_save_manager_has_mastery_tier_up_signal():
	assert_true(SaveManager.has_signal("mastery_tier_up"),
		"SaveManager should have mastery_tier_up signal")


func test_mastery_thresholds_constant():
	assert_eq(SaveManager.MASTERY_THRESHOLDS, [0, 50, 200, 500, 1000],
		"Mastery thresholds should match spec")


func test_mastery_bonuses_constant():
	assert_eq(SaveManager.MASTERY_BONUSES, [0.0, 0.02, 0.04, 0.06, 0.08],
		"Mastery bonuses should match spec")


# =====================================================================
# Section D: Badge Creation via _mastery_badges
# =====================================================================

func test_badge_dict_empty_initially():
	assert_eq(_hud._mastery_badges.size(), 0,
		"Badge dict should be empty before any weapon is displayed")


func test_ensure_badge_creates_entry():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_hud._ensure_mastery_badge("knife", slot)
	assert_true(_hud._mastery_badges.has("knife"),
		"Badge should be created for knife")
	var badge_data: Dictionary = _hud._mastery_badges["knife"]
	assert_true(badge_data.has("border"), "Should have border")
	assert_true(badge_data.has("fill"), "Should have fill")


func test_badge_border_is_color_rect():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_hud._ensure_mastery_badge("knife", slot)
	var border: ColorRect = _hud._mastery_badges["knife"]["border"]
	assert_true(border is ColorRect, "Border should be ColorRect")
	assert_eq(border.size, Vector2(6.0, 6.0), "Border size should be 6x6")


func test_badge_fill_is_color_rect():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_hud._ensure_mastery_badge("knife", slot)
	var fill: ColorRect = _hud._mastery_badges["knife"]["fill"]
	assert_true(fill is ColorRect, "Fill should be ColorRect")
	assert_lt(fill.size.x, 6.0, "Fill should be smaller than border")


func test_badge_hidden_at_tier_0():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	# Tier 0 (default, 0 kills)
	_hud._ensure_mastery_badge("knife", slot)
	var border: ColorRect = _hud._mastery_badges["knife"]["border"]
	assert_false(border.visible, "Badge should be hidden at Tier 0")


func test_badge_visible_at_tier_1():
	var slot = ColorRect.new()
	slot.size = Vector2(32, 32)
	add_child_autofree(slot)
	SaveManager.weapon_kills["knife"] = 50
	_hud._ensure_mastery_badge("knife", slot)
	var border: ColorRect = _hud._mastery_badges["knife"]["border"]
	assert_true(border.visible, "Badge should be visible at Tier 1")


# =====================================================================
# Section E: Source Code Verification
# =====================================================================

func test_source_references_mastery_badge():
	var source: String = _hud.get_script().source_code
	assert_true(source.find("_ensure_mastery_badge") != -1,
		"HUD source should have _ensure_mastery_badge method")
	assert_true(source.find("_mastery_badges") != -1,
		"HUD source should have _mastery_badges dict")


func test_source_references_pulse():
	var source: String = _hud.get_script().source_code
	assert_true(source.find("_start_badge_pulse") != -1,
		"HUD source should have _start_badge_pulse for Tier 4")


func test_source_references_flash():
	var source: String = _hud.get_script().source_code
	assert_true(source.find("_show_mastery_flash") != -1,
		"HUD source should have _show_mastery_flash for Tier 3+")


func test_source_references_tier_up_handler():
	var source: String = _hud.get_script().source_code
	assert_true(source.find("_on_mastery_tier_up") != -1,
		"HUD source should handle mastery_tier_up signal")
