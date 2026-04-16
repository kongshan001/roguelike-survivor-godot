extends RefCounted
# HudSkillButton -- Skill button UI subsystem extracted from hud.gd
# Manages the skill cooldown display button in the bottom-right corner.

# --- Skill button constants ---
const SKILL_BUTTON_SIZE: float = 48.0
const SKILL_COOLDOWN_COLOR: Color = Color(0, 0, 0, 0.6)
const SKILL_READY_COLOR: Color = Color(1, 0.85, 0.3)

# --- Skill button nodes ---
var _skill_bg: ColorRect = null
var _skill_icon: TextureRect = null
var _skill_cooldown_overlay: ColorRect = null
var _skill_key_label: Label = null

# Weak reference to the CanvasLayer (hud.gd)
var _canvas_layer: CanvasLayer = null


func _init(canvas: CanvasLayer) -> void:
	_canvas_layer = canvas


## Build the skill button UI elements. Call once from hud._ready().
func setup(player: Node2D, character: String) -> void:
	if not player:
		return
	# Only show if player has a skill
	if not player.get("skill_id") or player.skill_id == "":
		return

	var icon_color: Color = Color.WHITE
	match character:
		"mage":
			icon_color = Color(0.2, 0.4, 0.9)
		"warrior":
			icon_color = Color(0.8, 0.2, 0.2)
		"ranger":
			icon_color = Color(0.2, 0.7, 0.3)

	# Background (acts as gold border when ready)
	_skill_bg = ColorRect.new()
	_skill_bg.name = "SkillBg"
	_skill_bg.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_skill_bg.offset_left = -60.0 - SKILL_BUTTON_SIZE
	_skill_bg.offset_top = -80.0 - SKILL_BUTTON_SIZE
	_skill_bg.offset_right = -60.0
	_skill_bg.offset_bottom = -80.0
	_skill_bg.color = SKILL_READY_COLOR
	_canvas_layer.add_child(_skill_bg)

	# Icon area (TextureRect with sprite)
	_skill_icon = TextureRect.new()
	_skill_icon.name = "SkillIcon"
	var border: float = 2.0
	_skill_icon.set_position(_skill_bg.position + Vector2(border, border))
	_skill_icon.set_size(Vector2(SKILL_BUTTON_SIZE - border * 2.0, SKILL_BUTTON_SIZE - border * 2.0))
	_skill_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_skill_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	# Load skill sprite texture based on skill_id
	var skill_tex_path: String = "res://assets/sprites/skills/%s.png" % player.skill_id
	if ResourceLoader.exists(skill_tex_path):
		_skill_icon.texture = load(skill_tex_path)
	else:
		# Fallback: use flat color if sprite missing
		_skill_icon.texture = null
		_skill_icon.self_modulate = icon_color
	_skill_bg.add_child(_skill_icon)

	# Cooldown overlay (black semi-transparent)
	_skill_cooldown_overlay = ColorRect.new()
	_skill_cooldown_overlay.name = "CooldownOverlay"
	_skill_cooldown_overlay.set_position(Vector2.ZERO)
	_skill_cooldown_overlay.set_size(Vector2(SKILL_BUTTON_SIZE - border * 2.0, 0.0))
	_skill_cooldown_overlay.color = SKILL_COOLDOWN_COLOR
	_skill_icon.add_child(_skill_cooldown_overlay)

	# Key label
	_skill_key_label = Label.new()
	_skill_key_label.name = "SkillKeyLabel"
	_skill_key_label.text = "E"
	_skill_key_label.set_position(_skill_bg.position + Vector2(SKILL_BUTTON_SIZE * 0.3, SKILL_BUTTON_SIZE * 0.2))
	_skill_key_label.add_theme_font_size_override("font_size", 16)
	_skill_key_label.add_theme_color_override("font_color", Color.WHITE)
	_canvas_layer.add_child(_skill_key_label)


## Update the skill button display state. Call from hud._process().
func update_display(player: Node2D) -> void:
	if _skill_bg == null:
		return
	if not player or not player.get("skill_id"):
		return

	var is_ready: bool = player.is_skill_ready if player.get("is_skill_ready") != null else true
	var skill_timer: float = player.skill_timer if player.get("skill_timer") != null else 0.0
	var skill_max: float = player.skill_cooldown_max if player.get("skill_cooldown_max") != null else 1.0

	# Update gold border
	if is_ready:
		_skill_bg.color = SKILL_READY_COLOR
	else:
		_skill_bg.color = Color(0.3, 0.3, 0.3)

	# Update cooldown overlay height (fills from top to bottom)
	var border: float = 2.0
	var fill_height: float = (SKILL_BUTTON_SIZE - border * 2.0) * (1.0 - skill_timer / maxf(skill_max, 0.01))
	_skill_cooldown_overlay.set_size(Vector2(SKILL_BUTTON_SIZE - border * 2.0, fill_height))
