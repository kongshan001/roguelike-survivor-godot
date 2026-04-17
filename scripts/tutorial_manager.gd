extends Node
## TutorialManager -- 8-step progressive tutorial system.
## Steps 1-5: core controls. Steps 6-8: mid-game discovery hints.
## Shows tooltip bubbles at specific gameplay moments.
## Persisted via SaveManager.tutorial_step / tutorial_completed.

# --- Constants (from tutorial-system.md Section 3) ---
const TUTORIAL_TOTAL_STEPS: int = 8
const TUTORIAL_LABEL_OFFSET: float = 40.0
const TUTORIAL_STEP_MOVE_TIMEOUT: float = 8.0
const TUTORIAL_STEP_DASH_TIMEOUT: float = 10.0
const TUTORIAL_STEP_WEAPON_TIMEOUT: float = 3.0
const TUTORIAL_STEP_SKILL_TIMEOUT: float = 10.0
const TUTORIAL_STEP_ENEMY_RANGE: float = 200.0
const TUTORIAL_STEP_MOVE_DELAY: float = 2.0
const TUTORIAL_FONT_SIZE: int = 14
const TUTORIAL_BG_COLOR: Color = Color(0, 0, 0, 0.7)
const TUTORIAL_TEXT_COLOR: Color = Color(1, 0.85, 0.3)
const TUTORIAL_BG_PADDING: Vector2 = Vector2(8, 4)
const FADE_IN_DURATION: float = 0.3
const FADE_OUT_DURATION: float = 0.2

# Steps 6-8 constants (from tutorial-extension.md Section 3)
const TUTORIAL_STEP6_TIMEOUT: float = 4.0
const TUTORIAL_STEP7_TIMEOUT: float = 3.5
const TUTORIAL_STEP8_TIMEOUT: float = 4.0
const TUTORIAL_STEP6_MIN_WEAPONS: int = 2
const TUTORIAL_STEP6_MIN_LEVEL: int = 2
const TUTORIAL_STEP7_COMBO_THRESHOLD: int = 5

# --- State ---
var _step: int = 0  # 0=not started, 1..8 = completed step
var _idle_timer: float = 0.0
var _tooltip_active: bool = false
var _current_tooltip: PanelContainer = null
var _tooltip_timer: float = 0.0
var _tooltip_timeout: float = 0.0
var _prev_kills: int = 0
var _step4_pending: bool = false
var _prev_skill_ready: bool = true
var _arena: Node2D = null
var _prev_synergy_count: int = 0  # For Step 8: track synergy count changes


func setup(arena: Node2D) -> void:
	_arena = arena
	if not SaveManager:
		return
	if SaveManager.tutorial_completed:
		_step = TUTORIAL_TOTAL_STEPS
		return
	_step = SaveManager.tutorial_step
	_prev_kills = GameManager.enemies_killed
	# When resuming at step 4 (processing step 5), initialize _prev_skill_ready
	# to false so the first "skill becomes ready" event triggers the tooltip.
	# Without this, _prev_skill_ready=true matches is_skill_ready=true and the
	# not-ready -> ready transition never fires.
	if _step == 4:
		_prev_skill_ready = false
	# Connect signals for tutorial triggers
	if not GameManager.level_up.is_connected(_on_level_up):
		GameManager.level_up.connect(_on_level_up)
	if not GameManager.health_changed.is_connected(_on_health_changed):
		GameManager.health_changed.connect(_on_health_changed)


func _physics_process(delta: float) -> void:
	if _step >= TUTORIAL_TOTAL_STEPS or not _arena:
		return
	if GameManager.is_game_over:
		return

	var player: Node2D = GameManager.find_player()
	if not player or not is_instance_valid(player):
		return

	match _step:
		0:
			_process_step_move(delta, player)
		1:
			_process_step_dash(delta, player)
		2:
			_process_step_weapon(delta, player)
		3:
			_process_step_upgrade(delta, player)
		4:
			_process_step_skill(delta, player)
		5:
			_process_step_evolution(delta, player)
		6:
			_process_step_combo(delta, player)
		7:
			_process_step_synergy(delta, player)

	# Update tooltip position if active
	if _tooltip_active and _current_tooltip and is_instance_valid(_current_tooltip):
		_update_tooltip_position(player)


# --- Step 0: Movement ---
func _process_step_move(delta: float, player: Node2D) -> void:
	var moving: bool = player.is_moving if player.get("is_moving") != null else false
	if not moving:
		_idle_timer += delta
		if _idle_timer >= TUTORIAL_STEP_MOVE_DELAY and not _tooltip_active:
			_show_tooltip("WASD 移动角色", TUTORIAL_STEP_MOVE_TIMEOUT, player)
	else:
		if _tooltip_active:
			_complete_step()
		else:
			# Player moved before tooltip appeared, complete directly
			_complete_step()


# --- Step 1: Dash ---
func _process_step_dash(delta: float, player: Node2D) -> void:
	if not _tooltip_active:
		# Check if enemy is within range
		if _has_enemy_in_range(player, TUTORIAL_STEP_ENEMY_RANGE):
			_show_tooltip("Space 冲刺闪避", TUTORIAL_STEP_DASH_TIMEOUT, player)
	else:
		_tooltip_timer += delta
		if Input.is_action_just_pressed("dash"):
			_complete_step()
		elif _tooltip_timer >= _tooltip_timeout:
			_complete_step()


# --- Step 2: Weapon auto-attack ---
func _process_step_weapon(delta: float, player: Node2D) -> void:
	if not _tooltip_active:
		var kills: int = GameManager.enemies_killed
		if kills > _prev_kills:
			_show_tooltip_top("武器自动攻击，拾取掉落的经验宝石升级", TUTORIAL_STEP_WEAPON_TIMEOUT)
			_prev_kills = kills
	else:
		_tooltip_timer += delta
		if _tooltip_timer >= _tooltip_timeout:
			_complete_step()


# --- Step 3: Upgrade selection (triggered by level_up signal) ---
func _process_step_upgrade(_delta: float, _player: Node2D) -> void:
	if _step4_pending:
		_show_tooltip_top("点击卡牌或按 1/2/3 选择升级", 0.0)
		_step4_pending = false
	if _tooltip_active and not get_tree().paused:
		# Upgrade was selected (game unpaused means panel closed)
		_complete_step()


# --- Step 4: Skill ---
func _process_step_skill(delta: float, player: Node2D) -> void:
	var skill_ready: bool = player.is_skill_ready if player.get("is_skill_ready") != null else false

	if not _tooltip_active:
		# Trigger when skill transitions from not-ready to ready
		if skill_ready and not _prev_skill_ready:
			_show_tooltip("按 E 使用角色技能", TUTORIAL_STEP_SKILL_TIMEOUT, player)
	else:
		_tooltip_timer += delta
		if Input.is_action_just_pressed("skill"):
			_complete_step()
		elif _tooltip_timer >= _tooltip_timeout:
			_complete_step()

	_prev_skill_ready = skill_ready


# --- Step 5: Evolution Hint ---
func _process_step_evolution(delta: float, player: Node2D) -> void:
	if not _tooltip_active:
		var owned_weapons: Dictionary = player.get("owned_weapons") if player.get("owned_weapons") != null else {}
		if _has_two_weapons_at_level(owned_weapons, TUTORIAL_STEP6_MIN_LEVEL):
			_show_tooltip_top("Weapons evolve at Lv3! Check combinations when both are maxed.", TUTORIAL_STEP6_TIMEOUT)
	else:
		_tooltip_timer += delta
		if _tooltip_timer >= _tooltip_timeout:
			_complete_step()


# --- Step 6: Combo Bonus ---
func _process_step_combo(delta: float, _player: Node2D) -> void:
	if not _tooltip_active:
		if GameManager.combo_count >= TUTORIAL_STEP7_COMBO_THRESHOLD:
			_show_tooltip_top("Combo kills give bonus XP! Keep killing to maintain your streak.", TUTORIAL_STEP7_TIMEOUT)
	else:
		_tooltip_timer += delta
		if _tooltip_timer >= _tooltip_timeout:
			_complete_step()


# --- Step 7: Synergy Activation ---
func _process_step_synergy(delta: float, _player: Node2D) -> void:
	if not _tooltip_active:
		var current_count: int = SynergyManager.get_active_count() if SynergyManager else 0
		if current_count > _prev_synergy_count:
			_show_tooltip_top("Synergy activated! Some weapon+passive combos create powerful effects.", TUTORIAL_STEP8_TIMEOUT)
		_prev_synergy_count = current_count
	else:
		_tooltip_timer += delta
		if _tooltip_timer >= _tooltip_timeout:
			_complete_step()


# --- Signal handlers ---

func _on_level_up(_new_level: int) -> void:
	if _step == 3 and not _tooltip_active:
		_step4_pending = true


func _on_health_changed(_cur: float, _max: float) -> void:
	# Step 1: also complete if player gets hit (negative feedback learning)
	if _step == 1 and _tooltip_active:
		_complete_step()


# --- Tooltip management ---

func _show_tooltip(text: String, timeout: float, player: Node2D) -> void:
	_dismiss_tooltip()
	_current_tooltip = _create_tooltip_bubble(text)
	_arena.add_child(_current_tooltip)
	_update_tooltip_position(player)
	_current_tooltip.modulate.a = 0.0
	var tween: Tween = _current_tooltip.create_tween()
	tween.tween_property(_current_tooltip, "modulate:a", 1.0, FADE_IN_DURATION)
	_tooltip_active = true
	_tooltip_timer = 0.0
	_tooltip_timeout = timeout


func _show_tooltip_top(text: String, timeout: float) -> void:
	_dismiss_tooltip()
	_current_tooltip = _create_tooltip_bubble(text)
	_arena.add_child(_current_tooltip)
	# Position at top center of viewport
	var camera: Camera2D = _arena.get_node_or_null("Camera2D")
	if camera:
		_current_tooltip.global_position = camera.global_position - Vector2(100, 280)
	else:
		_current_tooltip.global_position = Vector2(-100, -280)
	_current_tooltip.modulate.a = 0.0
	var tween: Tween = _current_tooltip.create_tween()
	tween.tween_property(_current_tooltip, "modulate:a", 1.0, FADE_IN_DURATION)
	_tooltip_active = true
	_tooltip_timer = 0.0
	_tooltip_timeout = timeout


func _create_tooltip_bubble(text: String) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = TUTORIAL_BG_COLOR
	style.set_corner_radius_all(4)
	style.set_content_margin_all(TUTORIAL_BG_PADDING.x)
	panel.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", TUTORIAL_FONT_SIZE)
	label.add_theme_color_override("font_color", TUTORIAL_TEXT_COLOR)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(label)
	panel.z_index = 100
	return panel


func _update_tooltip_position(player: Node2D) -> void:
	if _current_tooltip and is_instance_valid(_current_tooltip):
		_current_tooltip.global_position = player.global_position - Vector2(60, TUTORIAL_LABEL_OFFSET)


func _dismiss_tooltip() -> void:
	if _current_tooltip and is_instance_valid(_current_tooltip):
		_current_tooltip.queue_free()
		_current_tooltip = null
	_tooltip_active = false


func _complete_step() -> void:
	if _tooltip_active and _current_tooltip and is_instance_valid(_current_tooltip):
		var tween: Tween = _current_tooltip.create_tween()
		var tooltip: PanelContainer = _current_tooltip
		tween.tween_property(tooltip, "modulate:a", 0.0, FADE_OUT_DURATION)
		tween.tween_callback(tooltip.queue_free)
		_current_tooltip = null
	_tooltip_active = false
	_tooltip_timer = 0.0
	_step += 1
	if SaveManager:
		SaveManager.tutorial_step = _step
		if _step >= TUTORIAL_TOTAL_STEPS:
			SaveManager.tutorial_completed = true
		SaveManager.save()


# --- Helpers ---

func _has_enemy_in_range(player: Node2D, range_val: float) -> bool:
	var enemies: Array = []
	if _arena:
		enemies = _arena.get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			var dist: float = player.global_position.distance_to(enemy.global_position)
			if dist <= range_val:
				return true
	return false


func _has_two_weapons_at_level(owned_weapons: Dictionary, min_level: int) -> bool:
	var qualifying_count: int = 0
	for weapon_id: String in owned_weapons:
		if owned_weapons[weapon_id] >= min_level:
			qualifying_count += 1
			if qualifying_count >= TUTORIAL_STEP6_MIN_WEAPONS:
				return true
	return false


# --- Public API for testing ---

## Check if a given step should show based on save state.
func should_show_step(step: int, save_mgr) -> bool:
	if step < 1 or step > TUTORIAL_TOTAL_STEPS:
		return false
	if not save_mgr:
		return false
	if save_mgr.get("tutorial_completed") == true:
		return false
	var current: int = save_mgr.get("tutorial_step") if save_mgr.get("tutorial_step") != null else 0
	return current == step - 1


## Get the display text for a given step.
func get_step_text(step: int) -> String:
	match step:
		1:
			return "WASD \u79fb\u52a8\u89d2\u8272"
		2:
			return "Space \u51b2\u523a\u95ea\u907f"
		3:
			return "\u6b66\u5668\u81ea\u52a8\u653b\u51fb\uff0c\u62fe\u53d6\u6389\u843d\u7684\u7ecf\u9a8c\u5b9d\u77f3\u5347\u7ea7"
		4:
			return "\u70b9\u51fb\u5361\u724c\u6216\u6309 1/2/3 \u9009\u62e9\u5347\u7ea7"
		5:
			return "\u6309 E \u4f7f\u7528\u89d2\u8272\u6280\u80fd"
		6:
			return "Weapons evolve at Lv3! Check combinations when both are maxed."
		7:
			return "Combo kills give bonus XP! Keep killing to maintain your streak."
		8:
			return "Synergy activated! Some weapon+passive combos create powerful effects."
		_:
			return ""


## Get the timeout for a given step (-1 means no timeout).
func get_step_timeout(step: int) -> float:
	match step:
		1:
			return TUTORIAL_STEP_MOVE_TIMEOUT
		2:
			return TUTORIAL_STEP_DASH_TIMEOUT
		3:
			return TUTORIAL_STEP_WEAPON_TIMEOUT
		4:
			return -1.0
		5:
			return TUTORIAL_STEP_SKILL_TIMEOUT
		6:
			return TUTORIAL_STEP6_TIMEOUT
		7:
			return TUTORIAL_STEP7_TIMEOUT
		8:
			return TUTORIAL_STEP8_TIMEOUT
		_:
			return 0.0


## Get the dismiss action identifier for a given step.
func get_dismiss_action(step: int) -> String:
	match step:
		1:
			return "move"
		2:
			return "dash"
		3:
			return "timeout"
		4:
			return "upgrade_select"
		5:
			return "skill"
		6:
			return "timeout"
		7:
			return "timeout"
		8:
			return "timeout"
		_:
			return ""


## Complete a specific step and update save state (used by tests).
func complete_step(step: int, save_mgr) -> void:
	if step < 1 or step > TUTORIAL_TOTAL_STEPS:
		return
	if not save_mgr:
		return
	save_mgr.tutorial_step = step
	if step >= TUTORIAL_TOTAL_STEPS:
		save_mgr.tutorial_completed = true
