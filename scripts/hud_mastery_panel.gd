extends RefCounted
# HudMasteryPanel -- Mastery badge & flash subsystem extracted from hud.gd
# Manages weapon mastery badge creation, tier-up flash, and display name lookup.

# --- Mastery Badge Constants ---
const MASTERY_BADGE_SIZE: float = 6.0
const MASTERY_FILL_SIZE: float = 4.0
const MASTERY_FILL_OFFSET: float = 1.0
const MASTERY_TIER_COLORS: Array[Color] = [
	Color.TRANSPARENT,  # Tier 0: hidden
	Color(0.80, 0.55, 0.35),  # Tier 1: Bronze
	Color(0.78, 0.78, 0.82),  # Tier 2: Silver
	Color(0.95, 0.82, 0.30),  # Tier 3: Gold
	Color(1.0, 0.85, 0.30),   # Tier 4: Diamond
]
const MASTERY_TIER_BORDERS: Array[Color] = [
	Color.TRANSPARENT,
	Color(0.50, 0.35, 0.20),  # Deep bronze
	Color(0.50, 0.50, 0.55),  # Deep silver
	Color(0.65, 0.55, 0.15),  # Deep gold
	Color(0.75, 0.60, 0.10),  # Deep diamond
]
const MASTERY_TIER_NAMES: Array[String] = ["Novice", "Apprentice", "Adept", "Expert", "Master"]

# --- State ---
var _mastery_badges: Dictionary = {}  # weapon_id -> {border: ColorRect, fill: ColorRect}
var _mastery_flash: ColorRect = null
var _toast: RefCounted = null          # Reference to hud_toast subsystem
var _canvas_layer: CanvasLayer = null  # Reference to hud.gd


func _init(canvas: CanvasLayer, toast: RefCounted) -> void:
	_canvas_layer = canvas
	_toast = toast


## Handle mastery tier-up: show toast, flash, update badge.
func on_tier_up(weapon_id: String, new_tier: int) -> void:
	var weapon_name: String = get_weapon_display_name(weapon_id)
	var tier_color: Color = MASTERY_TIER_COLORS[new_tier]
	var text: String = "%s Mastery: %s" % [weapon_name, MASTERY_TIER_NAMES[new_tier]]
	if new_tier == 4:
		text += " +8% DMG"
	_toast.show_toast(text, tier_color)
	if new_tier >= 3:
		_show_mastery_flash(tier_color)
	# Update badge if one exists for this weapon
	if _mastery_badges.has(weapon_id):
		_update_badge_tier(weapon_id, new_tier)


## Create mastery badge on weapon slot if not exists.
func ensure_badge(weapon_id: String, slot: Control) -> void:
	if _mastery_badges.has(weapon_id):
		return
	var tier: int = SaveManager.get_weapon_mastery_tier(weapon_id) if SaveManager else 0
	var border: ColorRect = ColorRect.new()
	border.name = "MasteryBadge"
	border.size = Vector2(MASTERY_BADGE_SIZE, MASTERY_BADGE_SIZE)
	border.position = slot.size - Vector2(MASTERY_BADGE_SIZE + 1.0, MASTERY_BADGE_SIZE + 1.0)
	border.color = MASTERY_TIER_BORDERS[tier]
	border.visible = tier > 0
	var fill: ColorRect = ColorRect.new()
	fill.size = Vector2(MASTERY_FILL_SIZE, MASTERY_FILL_SIZE)
	fill.position = Vector2(MASTERY_FILL_OFFSET, MASTERY_FILL_OFFSET)
	fill.color = MASTERY_TIER_COLORS[tier]
	border.add_child(fill)
	if tier == 4:
		_start_badge_pulse(border)
	slot.add_child(border)
	_mastery_badges[weapon_id] = {"border": border, "fill": fill}


## Lookup weapon display name for toasts.
func get_weapon_display_name(weapon_id: String) -> String:
	var names: Dictionary = {
		"knife": "Knife", "holywater": "Holy Water", "lightning": "Lightning",
		"bible": "Bible", "firestaff": "Fire Staff", "frostaura": "Frost Aura",
		"boomerang": "Boomerang",
	}
	return names.get(weapon_id, weapon_id)


## Create/show full-screen tier-up flash overlay.
func _show_mastery_flash(flash_color: Color) -> void:
	if _mastery_flash == null:
		_mastery_flash = ColorRect.new()
		_mastery_flash.name = "MasteryFlash"
		_mastery_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
		_mastery_flash.color = Color(flash_color.r, flash_color.g, flash_color.b, 0.15)
		_canvas_layer.add_child(_mastery_flash)
	_mastery_flash.color = Color(flash_color.r, flash_color.g, flash_color.b, 0.15)
	_mastery_flash.visible = true
	var tween: Tween = _canvas_layer.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_mastery_flash, "color:a", 0.0, 0.4)
	tween.tween_callback(func() -> void:
		if is_instance_valid(_mastery_flash):
			_mastery_flash.visible = false
	)


## Update badge border/fill colors on tier change.
func _update_badge_tier(weapon_id: String, new_tier: int) -> void:
	if not _mastery_badges.has(weapon_id):
		return
	var badge_data: Dictionary = _mastery_badges[weapon_id]
	var border: ColorRect = badge_data["border"]
	var fill: ColorRect = badge_data["fill"]
	border.color = MASTERY_TIER_BORDERS[new_tier]
	fill.color = MASTERY_TIER_COLORS[new_tier]
	border.visible = new_tier > 0
	if new_tier == 4:
		_start_badge_pulse(border)


## Start diamond-tier pulsing animation.
func _start_badge_pulse(badge: ColorRect) -> void:
	var pulse: Tween = _canvas_layer.create_tween().set_loops()
	pulse.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	pulse.tween_property(badge, "modulate:a", 0.70, 0.75).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(badge, "modulate:a", 1.00, 0.75).set_ease(Tween.EASE_IN_OUT)


# --- Pause Mastery Panel ---

const PAUSE_PANEL_WIDTH: float = 300.0
const PAUSE_PANEL_ROW_HEIGHT: float = 24.0
const PAUSE_PANEL_PADDING: float = 8.0
const PAUSE_BG_COLOR: Color = Color(0.08, 0.08, 0.10, 0.92)


## Build the pause mastery info panel showing all base weapon tiers/progress.
## Returns a Control (PanelContainer) with weapon mastery rows.
func build_pause_panel() -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "PauseMasteryPanel"
	panel.custom_minimum_size = Vector2(PAUSE_PANEL_WIDTH, 0.0)

	# Dark semi-transparent background
	var bg: ColorRect = ColorRect.new()
	bg.color = PAUSE_BG_COLOR
	bg.size = Vector2(PAUSE_PANEL_WIDTH, 0.0)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.name = "MasteryVBox"
	vbox.add_theme_constant_override("separation", 2)

	# Title
	var title: Label = Label.new()
	title.text = "-- Mastery --"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	vbox.add_child(title)

	# One row per base weapon
	var base_weapons: Array = SaveManager.BASE_WEAPONS if SaveManager else []
	for weapon_id: String in base_weapons:
		var row: HBoxContainer = HBoxContainer.new()
		row.name = "MasteryRow_%s" % weapon_id

		var tier: int = SaveManager.get_weapon_mastery_tier(weapon_id) if SaveManager else 0
		var kills: int = SaveManager.get_weapon_kill_count(weapon_id) if SaveManager else 0
		var tier_color: Color = MASTERY_TIER_COLORS[tier] if tier < MASTERY_TIER_COLORS.size() else Color.WHITE

		# Tier badge (small colored square)
		var badge: ColorRect = ColorRect.new()
		badge.custom_minimum_size = Vector2(12.0, 12.0)
		badge.size = Vector2(12.0, 12.0)
		badge.color = tier_color
		row.add_child(badge)

		# Weapon name
		var name_label: Label = Label.new()
		name_label.text = get_weapon_display_name(weapon_id)
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.add_theme_color_override("font_color", tier_color)
		name_label.custom_minimum_size = Vector2(100.0, 0.0)
		row.add_child(name_label)

		# Tier name + kills progress
		var progress_label: Label = Label.new()
		progress_label.text = "%s (%d)" % [MASTERY_TIER_NAMES[tier], kills]
		progress_label.add_theme_font_size_override("font_size", 11)
		progress_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		row.add_child(progress_label)

		vbox.add_child(row)

	panel.add_child(vbox)
	return panel
