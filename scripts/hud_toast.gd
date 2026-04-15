extends RefCounted
# HudToast -- Toast notification subsystem extracted from hud.gd
# Manages creation, queueing, display, and removal of toast popups.

# --- Toast notification constants ---
const TOAST_MAX_VISIBLE: int = 2
const TOAST_DISPLAY_DURATION: float = 2.0
const TOAST_SLIDE_IN_DURATION: float = 0.2
const TOAST_FADE_OUT_DURATION: float = 0.3
const TOAST_WIDTH: float = 220.0
const TOAST_MARGIN: float = 10.0
const TOAST_QUEUE_STAGGER: float = 0.5

# --- Toast state ---
var _toast_container: VBoxContainer = null
var _toast_queue: Array[Dictionary] = []
var _active_toasts: Array[PanelContainer] = []
var _toast_stagger_timer: float = 0.0
var _is_showing_queued_toast: bool = false

# Weak reference to the CanvasLayer (hud.gd)
var _canvas_layer: CanvasLayer = null


func _init(canvas: CanvasLayer) -> void:
	_canvas_layer = canvas


## Build the toast container in the top-right corner of the viewport.
func setup_container() -> void:
	_toast_container = VBoxContainer.new()
	_toast_container.name = "ToastContainer"
	_toast_container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_toast_container.offset_left = -TOAST_WIDTH - TOAST_MARGIN
	_toast_container.offset_right = -TOAST_MARGIN
	_toast_container.offset_top = TOAST_MARGIN
	_toast_container.size_flags_horizontal = Control.SIZE_SHRINK_END
	_toast_container.add_theme_constant_override("separation", 6)
	_canvas_layer.add_child(_toast_container)


## Public API: show a toast notification with the given text and border color.
func show_toast(text: String, color: Color) -> void:
	var toast_data: Dictionary = {"text": text, "color": color}
	if _active_toasts.size() >= TOAST_MAX_VISIBLE:
		_toast_queue.append(toast_data)
		if not _is_showing_queued_toast:
			_is_showing_queued_toast = true
			_toast_stagger_timer = TOAST_QUEUE_STAGGER
		return
	_instantiate_toast(toast_data)


## Call from _process to handle toast queue staggering.
func process_queue(delta: float) -> void:
	if not _is_showing_queued_toast:
		return
	_toast_stagger_timer -= delta
	if _toast_stagger_timer <= 0.0:
		_is_showing_queued_toast = false
		if _toast_queue.size() > 0 and _active_toasts.size() < TOAST_MAX_VISIBLE:
			var next: Dictionary = _toast_queue.pop_front()
			_instantiate_toast(next)


func _instantiate_toast(toast_data: Dictionary) -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(TOAST_WIDTH, 0)

	# Style: semi-transparent dark background with colored border
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.set_corner_radius_all(4)
	style.set_border_width_all(2)
	style.border_color = toast_data["color"]
	panel.add_theme_stylebox_override("panel", style)

	# Content
	var vbox := VBoxContainer.new()
	var title_label := Label.new()
	title_label.text = toast_data["text"]
	title_label.add_theme_color_override("font_color", toast_data["color"])
	title_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(title_label)
	panel.add_child(vbox)

	# Position off-screen right for slide-in animation
	panel.position.x += TOAST_WIDTH

	_toast_container.add_child(panel)
	_active_toasts.append(panel)

	# Slide-in tween
	var tween: Tween = _canvas_layer.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "position:x", 0.0, TOAST_SLIDE_IN_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_interval(TOAST_DISPLAY_DURATION)
	tween.tween_callback(_schedule_toast_removal.bind(panel))


func _schedule_toast_removal(panel: PanelContainer) -> void:
	if not is_instance_valid(panel):
		return
	var tween: Tween = _canvas_layer.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "modulate:a", 0.0, TOAST_FADE_OUT_DURATION).set_ease(Tween.EASE_IN)
	tween.tween_callback(_remove_toast.bind(panel))


func _remove_toast(panel: PanelContainer) -> void:
	var idx: int = _active_toasts.find(panel)
	if idx >= 0:
		_active_toasts.remove_at(idx)
	if is_instance_valid(panel):
		panel.queue_free()
