extends GutTest
## Unit tests for HUD toast notification system
## Covers: toast creation, max visible limit, auto-removal, combo milestone toast,
## quest/achievement handlers, toast queue stagger, run tracking.

var _hud: CanvasLayer
var _arena: Node2D
var _player: CharacterBody2D


func before_each():
	GameManager.reset()
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

	# Instantiate HUD scene
	_hud = load("res://scenes/hud.tscn").instantiate()
	_arena.add_child(_hud)


# Helper to access the toast subsystem
func _toast() -> RefCounted:
	return _hud._toast


# =====================================================================
# 1. TOAST CONTAINER SETUP
# =====================================================================

func test_toast_container_exists_after_ready():
	var container: VBoxContainer = _hud.get_node_or_null("ToastContainer")
	assert_not_null(container, "ToastContainer should exist as child of HUD")


func test_toast_container_is_vbox():
	var container: VBoxContainer = _hud.get_node_or_null("ToastContainer")
	assert_true(container is VBoxContainer, "ToastContainer should be VBoxContainer")


func test_toast_container_anchored_top_right():
	var container: VBoxContainer = _hud.get_node_or_null("ToastContainer")
	assert_ne(container, null, "Container should exist")
	# Check it's positioned at top-right via anchor
	assert_eq(container.anchor_left, 1.0, "Anchor left should be 1.0 (right)")
	assert_eq(container.anchor_right, 1.0, "Anchor right should be 1.0 (right)")
	assert_eq(container.offset_top, _toast().TOAST_MARGIN, "Top offset should be TOAST_MARGIN")


# =====================================================================
# 2. TOAST CREATION
# =====================================================================

func test_show_toast_creates_panel():
	_toast().show_toast("Test Toast", Color.YELLOW)
	assert_eq(_toast()._active_toasts.size(), 1, "One active toast after show_toast")
	var panel: PanelContainer = _toast()._active_toasts[0]
	assert_true(panel is PanelContainer, "Active toast should be PanelContainer")


func test_show_toast_displays_text():
	_toast().show_toast("Hello World", Color.WHITE)
	var panel: PanelContainer = _toast()._active_toasts[0]
	var vbox: VBoxContainer = panel.get_child(0)
	var label: Label = vbox.get_child(0)
	assert_eq(label.text, "Hello World", "Toast label should show the given text")


func test_show_toast_applies_color_to_border():
	var toast_color: Color = Color(1.0, 0.5, 0.0)
	_toast().show_toast("Colored Toast", toast_color)
	var panel: PanelContainer = _toast()._active_toasts[0]
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
	assert_eq(style.border_color, toast_color, "Border color should match toast color")


func test_show_toast_applies_color_to_label():
	var toast_color: Color = Color(0.5, 1.0, 0.0)
	_toast().show_toast("Green Toast", toast_color)
	var panel: PanelContainer = _toast()._active_toasts[0]
	var vbox: VBoxContainer = panel.get_child(0)
	var label: Label = vbox.get_child(0)
	assert_eq(label.get_theme_color("font_color"), toast_color, "Label font color should match")


# =====================================================================
# 3. MAX VISIBLE TOAST LIMIT
# =====================================================================

func test_max_two_toasts_visible():
	_toast().show_toast("Toast 1", Color.WHITE)
	_toast().show_toast("Toast 2", Color.WHITE)
	assert_eq(_toast()._active_toasts.size(), 2, "Two active toasts allowed")
	_toast().show_toast("Toast 3", Color.WHITE)
	assert_eq(_toast()._active_toasts.size(), 2, "Third toast should not be active immediately")


func test_excess_toast_goes_to_queue():
	_toast().show_toast("A", Color.WHITE)
	_toast().show_toast("B", Color.WHITE)
	_toast().show_toast("C", Color.WHITE)
	assert_eq(_toast()._toast_queue.size(), 1, "Excess toast should be queued")


func test_queue_processes_after_stagger():
	_toast().show_toast("A", Color.WHITE)
	_toast().show_toast("B", Color.WHITE)
	_toast().show_toast("C", Color.WHITE)
	assert_eq(_toast()._toast_queue.size(), 1, "Toast C should be in queue")
	assert_eq(_toast()._active_toasts.size(), 2, "Only 2 active toasts")
	# Simulate one toast being removed, opening a slot
	_toast()._remove_toast(_toast()._active_toasts[0])
	assert_eq(_toast()._active_toasts.size(), 1, "One slot now open")
	# Stagger timer kicks in, processes queue
	_toast().process_queue(_toast().TOAST_QUEUE_STAGGER + 0.1)
	assert_eq(_toast()._active_toasts.size(), 2, "Queued toast fills open slot")
	assert_eq(_toast()._toast_queue.size(), 0, "Queue should be empty after processing")


# =====================================================================
# 4. AUTO-REMOVAL AFTER TIMEOUT
# =====================================================================

func test_remove_toast_clears_from_active():
	_toast().show_toast("Removable", Color.WHITE)
	var panel: PanelContainer = _toast()._active_toasts[0]
	_toast()._remove_toast(panel)
	assert_eq(_toast()._active_toasts.size(), 0, "Active toasts should be empty after removal")


func test_remove_toast_invalid_panel_no_crash():
	var fake_panel: PanelContainer = PanelContainer.new()
	autofree(fake_panel)
	_toast()._remove_toast(fake_panel)
	assert_eq(_toast()._active_toasts.size(), 0, "Removing non-active panel should not crash")


func test_remove_toast_marks_panel_for_deletion():
	_toast().show_toast("To Free", Color.WHITE)
	var panel: PanelContainer = _toast()._active_toasts[0]
	_toast()._remove_toast(panel)
	# queue_free() is deferred; the panel is still valid this frame but
	# has been removed from the active list
	assert_eq(_toast()._active_toasts.size(), 0, "Active list should be empty")
	assert_true(panel.is_queued_for_deletion(), "Panel should be queued for deletion")


# =====================================================================
# 5. COMBO MILESTONE TOAST
# =====================================================================

func test_combo_milestone_triggers_toast():
	GameManager.combo_milestone.emit(5)
	assert_eq(_toast()._active_toasts.size(), 1, "Combo milestone should trigger a toast")


func test_combo_milestone_toast_text():
	GameManager.combo_milestone.emit(10)
	var panel: PanelContainer = _toast()._active_toasts[0]
	var vbox: VBoxContainer = panel.get_child(0)
	var label: Label = vbox.get_child(0)
	assert_eq(label.text, "10 连击!", "Combo toast should show milestone count")


func test_combo_milestone_toast_color():
	GameManager.combo_milestone.emit(20)
	var panel: PanelContainer = _toast()._active_toasts[0]
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
	assert_eq(style.border_color, Color(1.0, 0.85, 0.0), "Combo toast should use gold color")


# =====================================================================
# 6. QUEST COMPLETION HANDLER
# =====================================================================

func test_quest_completed_tracks_run_data():
	# Simulate quest_completed signal (SaveManager may be null in tests)
	_hud._on_quest_completed("kill_50")
	assert_eq(_hud._run_quests.size(), 1, "Quest should be tracked in run_quests")
	assert_eq(_hud._run_quests[0], "kill_50", "Quest ID should match")


func test_quest_completed_shows_toast():
	_hud._on_quest_completed("kill_boss")
	assert_eq(_toast()._active_toasts.size(), 1, "Quest completion should show toast")


# =====================================================================
# 7. ACHIEVEMENT UNLOCKED HANDLER
# =====================================================================

func test_achievement_unlocked_tracks_run_data():
	_hud._on_achievement_unlocked("boss_kill")
	assert_eq(_hud._run_achievements.size(), 1, "Achievement should be tracked")
	assert_eq(_hud._run_achievements[0], "boss_kill", "Achievement ID should match")


func test_achievement_unlocked_shows_toast():
	_hud._on_achievement_unlocked("total_kills_100")
	assert_eq(_toast()._active_toasts.size(), 1, "Achievement unlock should show toast")


# =====================================================================
# 8. RUN DATA STORED ON PLAYER DEATH
# =====================================================================

func test_player_died_stores_run_quests_in_meta():
	_hud._run_quests.append("kill_50")
	_hud._run_quests.append("combo_20")
	GameManager.player_died.emit()
	assert_true(GameManager.has_meta("run_quests"), "run_quests should be stored in GameManager meta")
	var stored: Array = GameManager.get_meta("run_quests")
	assert_eq(stored.size(), 2, "Two quests should be stored")


func test_player_died_stores_run_achievements_in_meta():
	_hud._run_achievements.append("boss_kill")
	GameManager.player_died.emit()
	assert_true(GameManager.has_meta("run_achievements"), "run_achievements should be stored")
	var stored: Array = GameManager.get_meta("run_achievements")
	assert_eq(stored.size(), 1, "One achievement should be stored")


# =====================================================================
# 9. TOAST CONSTANTS (now on HudToast module)
# =====================================================================

func test_toast_max_visible_constant():
	assert_eq(_toast().TOAST_MAX_VISIBLE, 2, "TOAST_MAX_VISIBLE should be 2")


func test_toast_display_duration_constant():
	assert_eq(_toast().TOAST_DISPLAY_DURATION, 2.0, "TOAST_DISPLAY_DURATION should be 2.0s")


func test_toast_width_constant():
	assert_eq(_toast().TOAST_WIDTH, 220.0, "TOAST_WIDTH should be 220.0")


# =====================================================================
# 10. TOAST BACKGROUND STYLE
# =====================================================================

func test_toast_background_semi_transparent():
	_toast().show_toast("Style Test", Color.WHITE)
	var panel: PanelContainer = _toast()._active_toasts[0]
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
	assert_almost_eq(style.bg_color.a, 0.7, 0.01, "Background alpha should be 0.7")


func test_toast_has_rounded_corners():
	_toast().show_toast("Corner Test", Color.WHITE)
	var panel: PanelContainer = _toast()._active_toasts[0]
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
	# Check all four corners individually (get_corner_radius_all may not exist)
	assert_eq(style.get_corner_radius(CORNER_TOP_LEFT), 4, "Top-left corner radius should be 4")
	assert_eq(style.get_corner_radius(CORNER_TOP_RIGHT), 4, "Top-right corner radius should be 4")
	assert_eq(style.get_corner_radius(CORNER_BOTTOM_RIGHT), 4, "Bottom-right corner radius should be 4")
	assert_eq(style.get_corner_radius(CORNER_BOTTOM_LEFT), 4, "Bottom-left corner radius should be 4")
