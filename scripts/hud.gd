extends CanvasLayer

signal retreat_pressed

var _upgrade_options: Array[Dictionary] = []
var _pending_level_ups: int = 0
var _rerolls_used: int = 0
const MAX_REROLLS: int = 1

# --- Toast subsystem ---
var _toast: RefCounted = null

# --- Run completion tracking ---
var _run_quests: Array[String] = []
var _run_achievements: Array[String] = []


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	GameManager.health_changed.connect(_on_health_changed)
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.level_up.connect(_on_level_up)
	GameManager.player_died.connect(_on_player_died)
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.combo_changed.connect(_on_combo_changed)
	GameManager.combo_milestone.connect(_on_combo_milestone)
	GameManager.boss_warning.connect(_on_boss_warning)
	GameManager.wave_started.connect(_on_wave_started)
	GameManager.wave_completed.connect(_on_wave_completed)
	GameManager.victory_achieved.connect(_on_victory_achieved)

	# Build wave progress bar
	_setup_wave_bar()

	# Quest/Achievement toast signals (guard against reconnect in tests)
	if SaveManager:
		if not SaveManager.quest_completed.is_connected(_on_quest_completed):
			SaveManager.quest_completed.connect(_on_quest_completed)
		if not SaveManager.achievement_unlocked.is_connected(_on_achievement_unlocked):
			SaveManager.achievement_unlocked.connect(_on_achievement_unlocked)

	# Show difficulty indicator
	var diff_names: Dictionary = {"easy": "休闲", "normal": "标准", "hard": "噩梦", "endless": "无尽"}
	$DifficultyLabel.text = diff_names.get(GameManager.selected_difficulty, "")

	$UpgradePanel.visible = false
	$UpgradePanel/Panel/Card1.gui_input.connect(_on_card_input.bind(0))
	$UpgradePanel/Panel/Card2.gui_input.connect(_on_card_input.bind(1))
	$UpgradePanel/Panel/Card3.gui_input.connect(_on_card_input.bind(2))
	$UpgradePanel/RerollButton.pressed.connect(_reroll_upgrades)

	# Card children consume mouse events by default, prevent that
	for card in [$UpgradePanel/Panel/Card1, $UpgradePanel/Panel/Card2, $UpgradePanel/Panel/Card3]:
		for child in card.get_children():
			if child is Control:
				child.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Build toast container in top-right corner
	_toast = load("res://scripts/hud_toast.gd").new(self)
	_toast.setup_container()

	# Retreat button (endless mode only)
	if GameManager.selected_difficulty == "endless":
		_setup_retreat_button()

	# Skill button (HUD skill display)
	_setup_skill_button()


func _process(delta: float):
	$TimerLabel.text = GameManager.format_time(GameManager.elapsed_time)
	_update_wave_display()
	if _toast:
		_toast.process_queue(delta)
	_update_skill_display()


func _on_gold_changed(amount: int):
	$GoldLabel.text = "Gold: %d" % amount


func _on_combo_changed(count: int):
	if count > 1:
		$ComboLabel.text = "Combo: %d" % count
	else:
		$ComboLabel.text = ""


func _on_combo_milestone(count: int):
	var labels: Dictionary = {5: "5 连击！", 10: "10 连击！！", 20: "20 连击！！！", 50: "50 连击！！！" }
	$ComboLabel.text = labels.get(count, "%d 连击！" % count)
	# Flash combo label color
	match count:
		5: $ComboLabel.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
		10: $ComboLabel.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
		20: $ComboLabel.add_theme_color_override("font_color", Color(1.0, 0.2, 0.0))
		50: $ComboLabel.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1))
	# Show combo toast
	_toast.show_toast("%d 连击!" % count, Color(1.0, 0.85, 0.0))


func _on_boss_warning():
	$BossWarningLabel.text = "💀 Boss 即将来袭！"
	$BossWarningLabel.visible = true
	$BossWarningLabel.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1))
	# Auto-hide after 2.5s
	get_tree().create_timer(2.5).timeout.connect(func():
		$BossWarningLabel.visible = false
	)


func _on_health_changed(current: float, max_hp: float):
	$HealthBar.value = (current / max_hp) * 100.0
	$HealthLabel.text = "%d/%d" % [int(current), int(max_hp)]


func _on_xp_changed(current: float, needed: float):
	$XPBar.value = (current / needed) * 100.0
	$LevelLabel.text = "Lv %d" % GameManager.player_level


func _on_level_up(_new_level: int):
	_pending_level_ups += 1
	_show_upgrade_panel()


func _on_player_died():
	# Store run-specific completion data for game_over_screen
	GameManager.set_meta("run_quests", _run_quests)
	GameManager.set_meta("run_achievements", _run_achievements)


func _show_upgrade_panel():
	get_tree().paused = true
	_pending_level_ups -= 1

	var player = _get_player()
	if not player:
		return

	_upgrade_options = UpgradePool.get_random_upgrades(player.owned_weapons, player.owned_passives, 3)

	for i in range(3):
		var card = $UpgradePanel/Panel.get_child(i) as Control
		if i < _upgrade_options.size():
			card.visible = true
			var option = _upgrade_options[i]
			card.get_node("VBox/NameLabel").text = option.name
			card.get_node("VBox/DescLabel").text = option.description
			card.get_node("VBox/Icon").color = option.icon_color
			card.get_node("VBox/KeyLabel").text = "[%d]" % (i + 1)
		else:
			card.visible = false

	$UpgradePanel.visible = true
	$UpgradePanel/RerollButton.visible = _rerolls_used < MAX_REROLLS


func _on_card_input(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed:
		_select_upgrade(index)


func _input(event: InputEvent):
	if $UpgradePanel.visible and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _select_upgrade(0)
			KEY_2: _select_upgrade(1)
			KEY_3: _select_upgrade(2)
			KEY_R: _reroll_upgrades()
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		_on_retreat_pressed()


func _select_upgrade(index: int):
	if index >= _upgrade_options.size():
		return

	var option = _upgrade_options[index]
	var player = _get_player()
	if not player:
		return

	match option.type:
		"new_weapon":
			player.add_weapon(option.id)
		"weapon_upgrade":
			player.upgrade_weapon(option.id)
		"passive":
			player.apply_passive(option.id)
		"evolution":
			_perform_evolution(player, option)

	$UpgradePanel.visible = false

	if _pending_level_ups > 0:
		_show_upgrade_panel()
	else:
		get_tree().paused = false


func _reroll_upgrades() -> void:
	if _rerolls_used >= MAX_REROLLS:
		return
	_rerolls_used += 1
	_show_upgrade_panel()


func _get_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]
	return null


func _perform_evolution(player: Node2D, option: Dictionary) -> void:
	# Remove the two base weapons
	var weapon_a: String = option.recipe_a
	var weapon_b: String = option.recipe_b

	# Clean up weapon instances (orbits, boomerangs)
	var wc: Node = player.get_node_or_null("WeaponController")
	if wc and wc.has_method("remove_weapon_instances"):
		wc.remove_weapon_instances(weapon_a)
		wc.remove_weapon_instances(weapon_b)

	player.owned_weapons.erase(weapon_a)
	player.owned_weapons.erase(weapon_b)

	# Add evolved weapon at level 1
	player.owned_weapons[option.id] = 1

	# Write evolution tracking meta for save_manager achievement checks
	var evolutions: Dictionary = GameManager.get_meta("evolutions") if GameManager.has_meta("evolutions") else {}
	evolutions[option.id] = true
	GameManager.set_meta("evolutions", evolutions)

	# Evolution flash effect
	var arena := player.get_parent()
	if arena:
		var effects: RefCounted = load("res://scripts/weapons/weapon_effects.gd").new()
		effects.create_evolution_flash(arena)


func _setup_retreat_button() -> void:
	var btn: Button = Button.new()
	btn.name = "RetreatButton"
	btn.text = "Retreat [Q]"
	btn.position = Vector2(1100.0, 68.0)
	btn.size = Vector2(160.0, 30.0)
	add_child(btn)
	btn.pressed.connect(_on_retreat_pressed)


func _on_retreat_pressed() -> void:
	if GameManager.selected_difficulty != "endless":
		return
	if GameManager.is_game_over:
		return
	retreat_pressed.emit()
	GameManager.retreat_requested.emit()


# --- Quest/Achievement signal handlers ---

func _on_quest_completed(quest_id: String) -> void:
	_run_quests.append(quest_id)
	var quest_name: String = _find_quest_name(quest_id)
	_toast.show_toast("Quest: %s" % quest_name, Color(1.0, 0.84, 0.31))


func _on_achievement_unlocked(achievement_id: String) -> void:
	_run_achievements.append(achievement_id)
	var ach_name: String = _find_achievement_name(achievement_id)
	_toast.show_toast("Achievement: %s" % ach_name, Color(0.81, 0.58, 0.85))


func _find_quest_name(quest_id: String) -> String:
	if not SaveManager:
		return quest_id
	for q: Dictionary in SaveManager.QUESTS:
		if q["id"] == quest_id:
			return q["name"]
	return quest_id


func _find_achievement_name(achievement_id: String) -> String:
	if not SaveManager:
		return achievement_id
	for a: Dictionary in SaveManager.ACHIEVEMENTS:
		if a["id"] == achievement_id:
			return a["name"]
	return achievement_id


# =====================================================================
# Wave Display System
# =====================================================================

var _last_displayed_wave: int = -1
var _wave_bar_bg: ColorRect = null
var _wave_bar_fill: ColorRect = null
var _victory_label: Label = null


func _setup_wave_bar() -> void:
	# Background bar (dark)
	_wave_bar_bg = ColorRect.new()
	_wave_bar_bg.name = "WaveBarBG"
	_wave_bar_bg.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_wave_bar_bg.offset_top = 0.0
	_wave_bar_bg.offset_bottom = 4.0
	_wave_bar_bg.offset_left = 0.0
	_wave_bar_bg.offset_right = 0.0
	_wave_bar_bg.color = Color(0.15, 0.15, 0.2)
	add_child(_wave_bar_bg)

	# Fill bar (wave color)
	_wave_bar_fill = ColorRect.new()
	_wave_bar_fill.name = "WaveBarFill"
	_wave_bar_fill.color = Color(0.3, 0.69, 0.31)
	_wave_bar_fill.set_position(Vector2(0, 0))
	_wave_bar_fill.set_size(Vector2(0, 4))
	add_child(_wave_bar_fill)


func _update_wave_display() -> void:
	var wave_node: Label = get_node_or_null("WaveLabel")
	if wave_node == null:
		return

	# Update wave label based on state
	match GameManager.wave_state:
		GameManager.WaveState.INTERMISSION:
			var cd: float = GameManager.get_intermission_countdown()
			wave_node.text = "Next wave in %d..." % ceili(cd)
		GameManager.WaveState.VICTORY:
			wave_node.text = "Victory!"
		_:
			if GameManager.current_wave != _last_displayed_wave:
				_last_displayed_wave = GameManager.current_wave
				var def: Dictionary = GameManager._get_current_wave_def()
				var total_waves: int = GameManager.WAVE_DEFS.size()
				if GameManager.selected_difficulty == "endless":
					wave_node.text = "C%d Wave %d/%d: %s" % [
						GameManager.current_cycle,
						((GameManager.current_wave - 1) % total_waves) + 1,
						total_waves, def["name"]]
				else:
					wave_node.text = "Wave %d/%d: %s" % [
						GameManager.current_wave, total_waves, def["name"]]

	# Update wave progress bar
	if _wave_bar_fill != null and _wave_bar_bg != null:
		var progress: float = GameManager.get_wave_progress()
		var bg_width: float = _wave_bar_bg.size.x
		_wave_bar_fill.set_size(Vector2(bg_width * progress, 4))
		_wave_bar_fill.color = GameManager.get_wave_color()


func _on_wave_started(wave: int, wave_name: String) -> void:
	_toast.show_toast("Wave %d: %s" % [wave, wave_name], GameManager.get_wave_color())


func _on_wave_completed(wave: int) -> void:
	_toast.show_toast("Wave %d Complete!" % wave, Color(0.3, 0.69, 0.31))


func _on_victory_achieved(gold_bonus: int) -> void:
	# Show victory banner
	if _victory_label == null:
		_victory_label = Label.new()
		_victory_label.name = "VictoryLabel"
		_victory_label.set_anchors_preset(Control.PRESET_CENTER)
		_victory_label.offset_left = -200.0
		_victory_label.offset_top = -50.0
		_victory_label.offset_right = 200.0
		_victory_label.offset_bottom = 50.0
		_victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_victory_label.add_theme_font_size_override("font_size", 36)
		add_child(_victory_label)
	_victory_label.text = "VICTORY! +%d gold" % gold_bonus
	_victory_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	_victory_label.visible = true
	_toast.show_toast("Victory! +%d gold bonus" % gold_bonus, Color(1.0, 0.84, 0.0))


# =====================================================================
# Skill Button Display
# =====================================================================

const SKILL_BUTTON_SIZE: float = 48.0
const SKILL_COOLDOWN_COLOR: Color = Color(0, 0, 0, 0.6)
const SKILL_READY_COLOR: Color = Color(1, 0.85, 0.3)

var _skill_bg: ColorRect = null
var _skill_icon: ColorRect = null
var _skill_cooldown_overlay: ColorRect = null
var _skill_key_label: Label = null


func _setup_skill_button() -> void:
	var player: Node2D = _get_player()
	if not player:
		return
	# Only show if player has a skill
	if not player.get("skill_id") or player.skill_id == "":
		return

	var icon_color: Color = Color.WHITE
	match GameManager.selected_character:
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
	add_child(_skill_bg)

	# Icon area
	_skill_icon = ColorRect.new()
	_skill_icon.name = "SkillIcon"
	var border: float = 2.0
	_skill_icon.set_position(_skill_bg.position + Vector2(border, border))
	_skill_icon.set_size(Vector2(SKILL_BUTTON_SIZE - border * 2.0, SKILL_BUTTON_SIZE - border * 2.0))
	_skill_icon.color = icon_color
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
	add_child(_skill_key_label)


func _update_skill_display() -> void:
	if _skill_bg == null:
		return
	var player: Node2D = _get_player()
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
