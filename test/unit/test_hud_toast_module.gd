extends "res://addons/gut/test.gd"
## Unit tests for HUD Toast module (hud_toast.gd RefCounted)
## Tests the extracted Toast notification subsystem independently.
## Reference: docs/superpowers/specs/achievement-ui.md Section 3


var _canvas: CanvasLayer
var _toast: RefCounted


func before_each():
	_canvas = CanvasLayer.new()
	add_child_autofree(_canvas)

	var toast_script: GDScript = load("res://scripts/hud_toast.gd") as GDScript
	if toast_script == null:
		return
	_toast = toast_script.new(_canvas)


func after_each():
	await get_tree().process_frame


func _has_toast_module() -> bool:
	return _toast != null


# =====================================================================
# TOAST MODULE CONSTANTS
# =====================================================================

func test_toast_module_loads():
	assert_not_null(load("res://scripts/hud_toast.gd"), "hud_toast.gd should load successfully")


func test_toast_max_visible():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	assert_eq(_toast.TOAST_MAX_VISIBLE, 2, "Max visible toasts should be 2")


func test_toast_display_duration():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	assert_eq(_toast.TOAST_DISPLAY_DURATION, 2.0, "Display duration should be 2.0s")


func test_toast_slide_in_duration():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	assert_eq(_toast.TOAST_SLIDE_IN_DURATION, 0.2, "Slide-in duration should be 0.2s")


func test_toast_fade_out_duration():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	assert_eq(_toast.TOAST_FADE_OUT_DURATION, 0.3, "Fade-out duration should be 0.3s")


func test_toast_width():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	assert_eq(_toast.TOAST_WIDTH, 220.0, "Toast width should be 220.0")


func test_toast_margin():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	assert_eq(_toast.TOAST_MARGIN, 10.0, "Toast margin should be 10.0")


func test_toast_queue_stagger():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	assert_eq(_toast.TOAST_QUEUE_STAGGER, 0.5, "Queue stagger should be 0.5s")


# =====================================================================
# CONTAINER SETUP
# =====================================================================

func test_setup_container_creates_vbox():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	var container: VBoxContainer = _canvas.get_node_or_null("ToastContainer")
	assert_not_null(container, "ToastContainer should be created as child of canvas")
	assert_true(container is VBoxContainer, "Container should be VBoxContainer")


func test_container_anchored_top_right():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	var container: VBoxContainer = _canvas.get_node_or_null("ToastContainer")
	if container == null:
		fail_test("ToastContainer should exist")
		return
	assert_eq(container.anchor_left, 1.0, "Anchor left should be 1.0 (right)")
	assert_eq(container.anchor_right, 1.0, "Anchor right should be 1.0 (right)")
	assert_eq(container.offset_top, _toast.TOAST_MARGIN, "Top offset should be TOAST_MARGIN")


# =====================================================================
# TOAST CREATION (show_toast)
# =====================================================================

func test_show_toast_creates_panel():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	_toast.show_toast("Test Toast", Color.YELLOW)
	assert_eq(_toast._active_toasts.size(), 1, "One active toast after show_toast")
	var panel: PanelContainer = _toast._active_toasts[0]
	assert_true(panel is PanelContainer, "Active toast should be PanelContainer")


func test_show_toast_displays_text():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	_toast.show_toast("Hello World", Color.WHITE)
	var panel: PanelContainer = _toast._active_toasts[0]
	var vbox: VBoxContainer = panel.get_child(0)
	var label: Label = vbox.get_child(0)
	assert_eq(label.text, "Hello World", "Toast label should show the given text")


func test_show_toast_applies_color_to_border():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	var toast_color: Color = Color(1.0, 0.5, 0.0)
	_toast.show_toast("Colored Toast", toast_color)
	var panel: PanelContainer = _toast._active_toasts[0]
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
	assert_eq(style.border_color, toast_color, "Border color should match toast color")


func test_show_toast_applies_color_to_label():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	var toast_color: Color = Color(0.5, 1.0, 0.0)
	_toast.show_toast("Green Toast", toast_color)
	var panel: PanelContainer = _toast._active_toasts[0]
	var vbox: VBoxContainer = panel.get_child(0)
	var label: Label = vbox.get_child(0)
	assert_eq(label.get_theme_color("font_color"), toast_color, "Label font color should match")


# =====================================================================
# MAX VISIBLE TOAST LIMIT
# =====================================================================

func test_max_two_toasts_visible():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	_toast.show_toast("Toast 1", Color.WHITE)
	_toast.show_toast("Toast 2", Color.WHITE)
	assert_eq(_toast._active_toasts.size(), 2, "Two active toasts allowed")
	_toast.show_toast("Toast 3", Color.WHITE)
	assert_eq(_toast._active_toasts.size(), 2, "Third toast should not be active immediately")


func test_excess_toast_goes_to_queue():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	_toast.show_toast("A", Color.WHITE)
	_toast.show_toast("B", Color.WHITE)
	_toast.show_toast("C", Color.WHITE)
	assert_eq(_toast._toast_queue.size(), 1, "Excess toast should be queued")


func test_queue_processes_after_stagger():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	_toast.show_toast("A", Color.WHITE)
	_toast.show_toast("B", Color.WHITE)
	_toast.show_toast("C", Color.WHITE)
	assert_eq(_toast._toast_queue.size(), 1, "Toast C should be in queue")

	# Simulate one toast being removed
	_toast._remove_toast(_toast._active_toasts[0])
	assert_eq(_toast._active_toasts.size(), 1, "One slot now open")

	# Stagger timer processes queue
	_toast.process_queue(_toast.TOAST_QUEUE_STAGGER + 0.1)
	assert_eq(_toast._active_toasts.size(), 2, "Queued toast fills open slot")
	assert_eq(_toast._toast_queue.size(), 0, "Queue should be empty after processing")


# =====================================================================
# AUTO-REMOVAL
# =====================================================================

func test_remove_toast_clears_from_active():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	_toast.show_toast("Removable", Color.WHITE)
	var panel: PanelContainer = _toast._active_toasts[0]
	_toast._remove_toast(panel)
	assert_eq(_toast._active_toasts.size(), 0, "Active toasts should be empty after removal")


func test_remove_toast_invalid_panel_no_crash():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	var fake_panel: PanelContainer = PanelContainer.new()
	autofree(fake_panel)
	_toast._remove_toast(fake_panel)
	assert_eq(_toast._active_toasts.size(), 0, "Removing non-active panel should not crash")


func test_remove_toast_marks_panel_for_deletion():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	_toast.show_toast("To Free", Color.WHITE)
	var panel: PanelContainer = _toast._active_toasts[0]
	_toast._remove_toast(panel)
	assert_eq(_toast._active_toasts.size(), 0, "Active list should be empty")
	assert_true(panel.is_queued_for_deletion(), "Panel should be queued for deletion")


# =====================================================================
# BACKGROUND STYLE
# =====================================================================

func test_toast_background_semi_transparent():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	_toast.show_toast("Style Test", Color.WHITE)
	var panel: PanelContainer = _toast._active_toasts[0]
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
	assert_almost_eq(style.bg_color.a, 0.7, 0.01, "Background alpha should be 0.7")


func test_toast_has_rounded_corners():
	if not _has_toast_module():
		pending("hud_toast.gd not yet available")
		return
	_toast.setup_container()
	await get_tree().process_frame
	_toast.show_toast("Corner Test", Color.WHITE)
	var panel: PanelContainer = _toast._active_toasts[0]
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
	assert_eq(style.get_corner_radius(CORNER_TOP_LEFT), 4, "Top-left corner radius should be 4")
	assert_eq(style.get_corner_radius(CORNER_TOP_RIGHT), 4, "Top-right corner radius should be 4")
	assert_eq(style.get_corner_radius(CORNER_BOTTOM_RIGHT), 4, "Bottom-right corner radius should be 4")
	assert_eq(style.get_corner_radius(CORNER_BOTTOM_LEFT), 4, "Bottom-left corner radius should be 4")
