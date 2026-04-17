extends CanvasLayer

signal retreat_pressed

var _upgrade_options: Array[Dictionary] = []
var _pending_level_ups: int = 0
var _rerolls_used: int = 0
const MAX_REROLLS: int = 1

# Card hover effect constants
const CARD_HOVER_SCALE: float = 1.08
const CARD_HOVER_Y_OFFSET: float = -4.0  # Reserved for future Y-axis hover offset
const CARD_HOVER_DURATION: float = 0.12
const CARD_UNHOVER_DURATION: float = 0.1
const CARD_HOVER_GLOW: Color = Color(1.1, 1.05, 0.95)

# --- Subsystems ---
var _toast: RefCounted = null
var _skill_btn: RefCounted = null
var _mastery_panel: RefCounted = null
var _run_quests: Array[String] = []
var _run_achievements: Array[String] = []
var _pause_panel: Control = null

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

	_setup_wave_bar()

	# Quest/Achievement toast signals (guard against reconnect in tests)
	if SaveManager:
		if not SaveManager.quest_completed.is_connected(_on_quest_completed):
			SaveManager.quest_completed.connect(_on_quest_completed)
		if not SaveManager.achievement_unlocked.is_connected(_on_achievement_unlocked):
			SaveManager.achievement_unlocked.connect(_on_achievement_unlocked)
		if not SaveManager.mastery_tier_up.is_connected(_on_mastery_tier_up):
			SaveManager.mastery_tier_up.connect(_on_mastery_tier_up)

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
		# Card hover/unhover signals for visual feedback
		card.mouse_entered.connect(_on_card_hover.bind(card))
		card.mouse_exited.connect(_on_card_unhover.bind(card))

	_toast = load("res://scripts/hud_toast.gd").new(self)
	_toast.setup_container()

	_mastery_panel = load("res://scripts/hud_mastery_panel.gd").new(self, _toast)

	if GameManager.selected_difficulty == "endless":
		_setup_retreat_button()

	_skill_btn = load("res://scripts/hud_skill_button.gd").new(self)
	_skill_btn.setup(_get_player(), GameManager.selected_character)

func _process(delta: float) -> void:
	$TimerLabel.text = GameManager.format_time(GameManager.elapsed_time)
	_update_wave_display()
	if _toast:
		_toast.process_queue(delta)
	_skill_btn.update_display(_get_player())

func _on_gold_changed(amount: int) -> void:
	$GoldLabel.text = "Gold: %d" % amount

func _on_combo_changed(count: int) -> void:
	$ComboLabel.text = "Combo: %d" % count if count > 1 else ""

func _on_combo_milestone(count: int) -> void:
	var labels: Dictionary = {5: "5 连击！", 10: "10 连击！！", 20: "20 连击！！！", 50: "50 连击！！！" }
	$ComboLabel.text = labels.get(count, "%d 连击！" % count)
	match count:
		5: $ComboLabel.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
		10: $ComboLabel.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
		20: $ComboLabel.add_theme_color_override("font_color", Color(1.0, 0.2, 0.0))
		50: $ComboLabel.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1))
	_toast.show_toast("%d 连击!" % count, Color(1.0, 0.85, 0.0))

func _on_boss_warning() -> void:
	$BossWarningLabel.text = "💀 Boss 即将来袭！"
	$BossWarningLabel.visible = true
	$BossWarningLabel.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1))
	get_tree().create_timer(2.5).timeout.connect(func():
		$BossWarningLabel.visible = false
	)

func _on_health_changed(current: float, max_hp: float) -> void:
	$HealthBar.value = (current / max_hp) * 100.0
	$HealthLabel.text = "%d/%d" % [int(current), int(max_hp)]

func _on_xp_changed(current: float, needed: float) -> void:
	$XPBar.value = (current / needed) * 100.0
	$LevelLabel.text = "Lv %d" % GameManager.player_level

func _on_level_up(_new_level: int) -> void:
	_pending_level_ups += 1
	if AudioManager: AudioManager.play_sfx_by_id("player_levelup")

	_show_upgrade_panel()
func _on_player_died() -> void:
	GameManager.set_meta("run_quests", _run_quests)
	GameManager.set_meta("run_achievements", _run_achievements)

func _show_upgrade_panel() -> void:
	get_tree().paused = true
	_pending_level_ups -= 1

	var player: Node2D = _get_player()
	if not player:
		return

	_upgrade_options = UpgradePool.get_random_upgrades(player.owned_weapons, player.owned_passives, 3, GameManager.selected_character)

	for i in range(3):
		var card = $UpgradePanel/Panel.get_child(i) as Control
		if i < _upgrade_options.size():
			card.visible = true
			_reset_card_state(card)
			var option = _upgrade_options[i]
			card.get_node("VBox/NameLabel").text = option.name
			card.get_node("VBox/DescLabel").text = option.description
			card.get_node("VBox/Icon").color = option.icon_color
			card.get_node("VBox/KeyLabel").text = "[%d]" % (i + 1)
		else:
			card.visible = false

	$UpgradePanel.visible = true
	$UpgradePanel/RerollButton.visible = _rerolls_used < MAX_REROLLS

func _on_card_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		_select_upgrade(index)

func _input(event: InputEvent) -> void:
	if $UpgradePanel.visible and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _select_upgrade(0)
			KEY_2: _select_upgrade(1)
			KEY_3: _select_upgrade(2)
			KEY_R: _reroll_upgrades()
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		_on_retreat_pressed()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if not $UpgradePanel.visible:
			_on_pause_toggled()

func _select_upgrade(index: int) -> void:
	if index >= _upgrade_options.size():
		return

	var option: Dictionary = _upgrade_options[index]
	var player: Node2D = _get_player()
	if not player:
		return

	match option.type:
		"new_weapon": player.add_weapon(option.id)
		"weapon_upgrade": player.upgrade_weapon(option.id)
		"passive": player.apply_passive(option.id)
		"evolution": _perform_evolution(player, option)

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
	var weapon_a: String = option.recipe_a
	var weapon_b: String = option.recipe_b

	var wc: Node = player.get_node_or_null("WeaponController")
	if wc and wc.has_method("remove_weapon_instances"):
		wc.remove_weapon_instances(weapon_a)
		wc.remove_weapon_instances(weapon_b)

	player.owned_weapons.erase(weapon_a)
	player.owned_weapons.erase(weapon_b)
	player.owned_weapons[option.id] = 1

	var evolutions: Dictionary = GameManager.get_meta("evolutions") if GameManager.has_meta("evolutions") else {}
	evolutions[option.id] = true
	GameManager.set_meta("evolutions", evolutions)

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

# --- Pause Menu (Esc) ---

func _on_pause_toggled() -> void:
	if get_tree().paused and _pause_panel != null:
		# Already paused with panel showing -- unpause
		if is_instance_valid(_pause_panel):
			_pause_panel.queue_free()
		_pause_panel = null
		get_tree().paused = false
		return
	# Pause and show mastery panel
	get_tree().paused = true
	if _mastery_panel and _mastery_panel.has_method("build_pause_panel"):
		_pause_panel = _mastery_panel.build_pause_panel()
		_pause_panel.set_anchors_preset(Control.PRESET_CENTER)
		_pause_panel.position = Vector2(
			(1280.0 - _pause_panel.custom_minimum_size.x) * 0.5,
			(720.0 - 200.0) * 0.5)
		add_child(_pause_panel)

func _on_quest_completed(quest_id: String) -> void:
	_run_quests.append(quest_id)
	_toast.show_toast("Quest: %s" % _find_quest_name(quest_id), Color(1.0, 0.84, 0.31))

func _on_achievement_unlocked(achievement_id: String) -> void:
	_run_achievements.append(achievement_id)
	_toast.show_toast("Achievement: %s" % _find_achievement_name(achievement_id), Color(0.81, 0.58, 0.85))

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

# --- Wave Display System ---
var _last_displayed_wave: int = -1
var _wave_bar_bg: ColorRect = null
var _wave_bar_fill: ColorRect = null
var _victory_label: Label = null

func _setup_wave_bar() -> void:
	_wave_bar_bg = ColorRect.new()
	_wave_bar_bg.name = "WaveBarBG"
	_wave_bar_bg.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_wave_bar_bg.offset_top = 0.0
	_wave_bar_bg.offset_bottom = 4.0
	_wave_bar_bg.offset_left = 0.0
	_wave_bar_bg.offset_right = 0.0
	_wave_bar_bg.color = Color(0.15, 0.15, 0.2)
	add_child(_wave_bar_bg)

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

# --- Skill Button Display (delegates to hud_skill_button.gd) ---
const SKILL_BUTTON_SIZE: float = 48.0
const SKILL_READY_COLOR: Color = Color(1, 0.85, 0.3)

var _skill_bg: ColorRect:
	get: return _skill_btn._skill_bg if _skill_btn else null
var _skill_icon: TextureRect:
	get: return _skill_btn._skill_icon if _skill_btn else null
var _skill_cooldown_overlay: ColorRect:
	get: return _skill_btn._skill_cooldown_overlay if _skill_btn else null
var _skill_key_label: Label:
	get: return _skill_btn._skill_key_label if _skill_btn else null

func _setup_skill_button() -> void:
	_skill_btn.setup(_get_player(), GameManager.selected_character)

func _update_skill_display() -> void:
	_skill_btn.update_display(_get_player())

# --- Card Hover Effects ---

func _on_card_hover(card: Control) -> void:
	if not $UpgradePanel.visible:
		return
	var t: Tween = create_tween()
	t.tween_property(card, "scale", Vector2(CARD_HOVER_SCALE, CARD_HOVER_SCALE), CARD_HOVER_DURATION)\
		.set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(card, "modulate", CARD_HOVER_GLOW, CARD_HOVER_DURATION)

func _on_card_unhover(card: Control) -> void:
	if not $UpgradePanel.visible:
		return
	var t: Tween = create_tween()
	t.tween_property(card, "scale", Vector2.ONE, CARD_UNHOVER_DURATION)\
		.set_ease(Tween.EASE_IN)
	t.parallel().tween_property(card, "modulate", Color.WHITE, CARD_UNHOVER_DURATION)

func _reset_card_state(card: Control) -> void:
	card.scale = Vector2.ONE
	card.modulate = Color.WHITE

# --- Mastery pass-through constants (for test backward compatibility) ---
# These delegate to hud_mastery_panel.gd so existing tests still pass.
var MASTERY_TIER_COLORS: Array[Color]:
	get: return _mastery_panel.MASTERY_TIER_COLORS if _mastery_panel else []
var MASTERY_TIER_BORDERS: Array[Color]:
	get: return _mastery_panel.MASTERY_TIER_BORDERS if _mastery_panel else []
var MASTERY_TIER_NAMES: Array[String]:
	get: return _mastery_panel.MASTERY_TIER_NAMES if _mastery_panel else []
var MASTERY_BADGE_SIZE: float:
	get: return _mastery_panel.MASTERY_BADGE_SIZE if _mastery_panel else 0.0
var _mastery_badges: Dictionary:
	get: return _mastery_panel._mastery_badges if _mastery_panel else {}

# --- Mastery (delegates to hud_mastery_panel.gd) ---

func _get_weapon_display_name(weapon_id: String) -> String:
	if _mastery_panel:
		return _mastery_panel.get_weapon_display_name(weapon_id)
	return weapon_id

func _on_mastery_tier_up(weapon_id: String, new_tier: int) -> void:
	if _mastery_panel:
		_mastery_panel.on_tier_up(weapon_id, new_tier)

func _show_mastery_flash(flash_color: Color) -> void:
	if _mastery_panel:
		_mastery_panel._show_mastery_flash(flash_color)

func _ensure_mastery_badge(weapon_id: String, slot: Control) -> void:
	if _mastery_panel:
		_mastery_panel.ensure_badge(weapon_id, slot)
