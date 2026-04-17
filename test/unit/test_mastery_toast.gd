extends GutTest
## R22 Task 2: Mastery Toast Notification Tests
## Validates mastery tier-up toast notifications and screen flash.

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
# Section A: SaveManager Mastery Signal
# =====================================================================

func test_save_manager_has_mastery_tier_up_signal():
	assert_true(SaveManager.has_signal("mastery_tier_up"),
		"SaveManager should have mastery_tier_up signal")


func test_save_manager_detects_tier_up():
	SaveManager.weapon_kills.clear()
	var old_tier: int = SaveManager.get_weapon_mastery_tier("knife")
	assert_eq(old_tier, 0, "Knife starts at tier 0")
	for i in range(50):
		SaveManager.add_weapon_kill("knife")
	var new_tier: int = SaveManager.get_weapon_mastery_tier("knife")
	assert_eq(new_tier, 1, "Knife should be tier 1 after 50 kills")


# =====================================================================
# Section B: Toast Method Existence
# =====================================================================

func test_hud_has_on_mastery_tier_up():
	assert_true(_hud.has_method("_on_mastery_tier_up"),
		"HUD should have _on_mastery_tier_up handler")


func test_hud_has_show_mastery_flash():
	assert_true(_hud.has_method("_show_mastery_flash"),
		"HUD should have _show_mastery_flash method")


func test_hud_has_get_weapon_display_name():
	assert_true(_hud.has_method("_get_weapon_display_name"),
		"HUD should have _get_weapon_display_name helper")


# =====================================================================
# Section C: Weapon Display Names
# =====================================================================

func test_display_name_knife():
	assert_eq(_hud._get_weapon_display_name("knife"), "Knife",
		"Knife display name")


func test_display_name_holywater():
	assert_eq(_hud._get_weapon_display_name("holywater"), "Holy Water",
		"Holy Water display name")


func test_display_name_frostaura():
	assert_eq(_hud._get_weapon_display_name("frostaura"), "Frost Aura",
		"Frost Aura display name")


func test_display_name_unknown():
	assert_eq(_hud._get_weapon_display_name("unknown_weapon"), "unknown_weapon",
		"Unknown weapon returns weapon_id")


# =====================================================================
# Section D: Tier Colors Match Implementation
# =====================================================================

func test_tier_1_color_bronze():
	var c: Color = _hud.MASTERY_TIER_COLORS[1]
	assert_almost_eq(c.r, 0.80, 0.01, "Tier 1 R")
	assert_almost_eq(c.g, 0.55, 0.01, "Tier 1 G")
	assert_almost_eq(c.b, 0.35, 0.01, "Tier 1 B")


func test_tier_2_color_silver():
	var c: Color = _hud.MASTERY_TIER_COLORS[2]
	assert_almost_eq(c.r, 0.78, 0.01, "Tier 2 R")
	assert_almost_eq(c.g, 0.78, 0.01, "Tier 2 G")
	assert_almost_eq(c.b, 0.82, 0.01, "Tier 2 B")


func test_tier_3_color_gold():
	var c: Color = _hud.MASTERY_TIER_COLORS[3]
	assert_almost_eq(c.r, 0.95, 0.01, "Tier 3 R")
	assert_almost_eq(c.g, 0.82, 0.01, "Tier 3 G")
	assert_almost_eq(c.b, 0.30, 0.01, "Tier 3 B")


func test_tier_4_color_diamond():
	var c: Color = _hud.MASTERY_TIER_COLORS[4]
	assert_almost_eq(c.r, 1.00, 0.01, "Tier 4 R")
	assert_almost_eq(c.g, 0.85, 0.01, "Tier 4 G")
	assert_almost_eq(c.b, 0.30, 0.01, "Tier 4 B")


# =====================================================================
# Section E: Tier Names
# =====================================================================

func test_tier_names_complete():
	var names = _hud.MASTERY_TIER_NAMES
	assert_eq(names[0], "Novice")
	assert_eq(names[1], "Apprentice")
	assert_eq(names[2], "Adept")
	assert_eq(names[3], "Expert")
	assert_eq(names[4], "Master")


# =====================================================================
# Section F: Mastery Flash
# =====================================================================

func test_mastery_flash_node_name():
	# After R25 split, MasteryFlash lives in hud_mastery_panel.gd
	var panel: RefCounted = _hud._mastery_panel
	assert_true(panel != null, "HUD should have _mastery_panel subsystem")
	var source: String = panel.get_script().source_code
	assert_true(source.find("MasteryFlash") != -1,
		"hud_mastery_panel source should create MasteryFlash node")


func test_mastery_flash_for_tier_3():
	# After R25 split, tier threshold check lives in hud_mastery_panel.gd
	var panel: RefCounted = _hud._mastery_panel
	assert_true(panel != null, "HUD should have _mastery_panel subsystem")
	var source: String = panel.get_script().source_code
	assert_true(source.find("new_tier >= 3") != -1 or source.find(">= 3") != -1,
		"hud_mastery_panel flash should trigger for tier >= 3")


# =====================================================================
# Section G: Source Code Integration
# =====================================================================

func test_signal_connected_in_ready():
	# After R25 split, hud.gd still connects the signal in _ready, delegates to panel
	var source: String = _hud.get_script().source_code
	assert_true(source.find("mastery_tier_up") != -1,
		"HUD should reference mastery_tier_up signal in _ready")


func test_toast_called_on_tier_up():
	var source: String = _hud.get_script().source_code
	assert_true(source.find("show_toast") != -1,
		"Tier up should call show_toast")
