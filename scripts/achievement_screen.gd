extends Control

## Achievement/Quest menu screen
## Reads data from SaveManager.QUESTS and SaveManager.ACHIEVEMENTS
## Displays completion status with categories

# Color constants (from achievement-ui.md palette)
const COLOR_BG: Color = Color(0.1, 0.1, 0.18, 1.0)
const COLOR_COMPLETED_BG: Color = Color(0.15, 0.25, 0.15, 0.8)
const COLOR_INCOMPLETE_BG: Color = Color(0.2, 0.2, 0.2, 0.5)
const COLOR_COMPLETED_ACH_BG: Color = Color(0.15, 0.15, 0.25, 0.8)
const COLOR_CHECK_GREEN: Color = Color(0.4, 0.73, 0.42)
const COLOR_EMPTY_GRAY: Color = Color(0.46, 0.46, 0.46)
const COLOR_REWARD_GOLD: Color = Color(1.0, 0.84, 0.31)
const COLOR_SECTION_HEADER: Color = Color(1.0, 0.84, 0.31)
const COLOR_HIDDEN: Color = Color(0.5, 0.5, 0.5)
const COLOR_QUEST_BORDER: Color = Color(1.0, 0.84, 0.31)
const COLOR_ACHIEVEMENT_BORDER: Color = Color(0.81, 0.58, 0.85)

const ITEM_HEIGHT: float = 40.0

# Achievement category definitions for section headers
const ACH_CATEGORIES: Array = [
	{"label": "--- Milestone ---", "ids": ["total_kills_100", "total_kills_500", "total_kills_2000", "games_10", "games_50"]},
	{"label": "--- Survival ---", "ids": ["survive_3min", "survive_5min", "survive_hard_5min"]},
	{"label": "--- Character ---", "ids": ["all_chars"]},
	{"label": "--- Challenge ---", "ids": ["boss_kill", "hard_boss_kill", "no_damage_survive", "kill_100_single", "survive_10min", "combo_30", "combo_50", "hard_survive_ach"]},
	{"label": "--- Evolution/Synergy ---", "ids": ["evolve_weapon", "synergy_first", "all_evolved", "all_synergies"]},
	{"label": "--- Shop ---", "ids": ["shop_first", "shop_single_max", "shop_max_all"]},
	{"label": "--- Quest ---", "ids": ["quests_half", "quests_all"]},
	{"label": "--- ??? ---", "ids": ["fast_boss", "pacifist_1min"]},
]


func _ready() -> void:
	# Build background
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = COLOR_BG
	add_child(bg)

	# Build main layout VBox
	var main_vbox := VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.offset_left = 40.0
	main_vbox.offset_top = 30.0
	main_vbox.offset_right = -40.0
	main_vbox.offset_bottom = -30.0
	main_vbox.add_theme_constant_override("separation", 8)
	add_child(main_vbox)

	# Header: Back button + title
	var header := HBoxContainer.new()
	header.name = "Header"
	header.add_theme_constant_override("separation", 20)
	main_vbox.add_child(header)

	var back_btn := Button.new()
	back_btn.name = "BackButton"
	back_btn.text = "< Back"
	back_btn.pressed.connect(_on_back_pressed)
	header.add_child(back_btn)

	var title_label := Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Achievements"
	title_label.add_theme_font_size_override("font_size", 20)
	header.add_child(title_label)

	# Tab buttons for switching between quests/achievements
	var tab_bar := HBoxContainer.new()
	tab_bar.name = "TabBar"
	tab_bar.add_theme_constant_override("separation", 10)
	main_vbox.add_child(tab_bar)

	var quest_tab := Button.new()
	quest_tab.name = "QuestTab"
	quest_tab.text = "Quests"
	quest_tab.pressed.connect(_show_quests)
	tab_bar.add_child(quest_tab)

	var ach_tab := Button.new()
	ach_tab.name = "AchTab"
	ach_tab.text = "Achievements"
	ach_tab.pressed.connect(_show_achievements)
	tab_bar.add_child(ach_tab)

	# ScrollContainer for content
	var scroll := ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	var content_vbox := VBoxContainer.new()
	content_vbox.name = "ContentVBox"
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(content_vbox)

	# Footer
	var footer := HBoxContainer.new()
	footer.name = "Footer"
	footer.add_theme_constant_override("separation", 30)
	main_vbox.add_child(footer)

	var completed_label := Label.new()
	completed_label.name = "CompletedLabel"
	footer.add_child(completed_label)

	var soul_label := Label.new()
	soul_label.name = "SoulLabel"
	soul_label.add_theme_color_override("font_color", COLOR_REWARD_GOLD)
	footer.add_child(soul_label)

	# Show quests by default
	_show_quests()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_BACKSPACE:
			_on_back_pressed()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _show_quests() -> void:
	var content: VBoxContainer = $MainVBox/ScrollContainer/ContentVBox
	_clear_content(content)
	$MainVBox/Header/TitleLabel.text = "Quests"

	if not SaveManager:
		_add_empty_label(content, "SaveManager not available")
		_update_footer(0, 0, 0)
		return

	var completed_count: int = 0
	var total_soul: int = 0
	var quests: Array = SaveManager.QUESTS

	# Sort: completed first
	var sorted_quests: Array = quests.duplicate()
	sorted_quests.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_done: bool = SaveManager.completed_quests.get(a["id"], false)
		var b_done: bool = SaveManager.completed_quests.get(b["id"], false)
		if a_done != b_done:
			return a_done
		return false
	)

	for quest: Dictionary in sorted_quests:
		var is_done: bool = SaveManager.completed_quests.get(quest["id"], false)
		if is_done:
			completed_count += 1
			total_soul += int(quest.get("reward", 0))
		_create_list_item(content, quest, is_done, false, COLOR_COMPLETED_BG, COLOR_INCOMPLETE_BG)

	_update_footer(completed_count, quests.size(), total_soul)


func _show_achievements() -> void:
	var content: VBoxContainer = $MainVBox/ScrollContainer/ContentVBox
	_clear_content(content)
	$MainVBox/Header/TitleLabel.text = "Achievements"

	if not SaveManager:
		_add_empty_label(content, "SaveManager not available")
		_update_footer(0, 0, 0)
		return

	var completed_count: int = 0
	var total_soul: int = 0
	var achievements: Array = SaveManager.ACHIEVEMENTS

	# Build a lookup dict for fast access
	var ach_by_id: Dictionary = {}
	for ach: Dictionary in achievements:
		ach_by_id[ach["id"]] = ach

	# Render by category
	for cat: Dictionary in ACH_CATEGORIES:
		# For hidden category, only show header if at least one is unlocked
		var is_hidden_cat: bool = cat["label"] == "--- ??? ---"
		var any_hidden_unlocked: bool = false

		if is_hidden_cat:
			for hid: String in cat["ids"]:
				if SaveManager.completed_achievements.get(hid, false):
					any_hidden_unlocked = true
					break
			if not any_hidden_unlocked:
				continue

		# Section header
		var header_label := Label.new()
		header_label.text = cat["label"]
		header_label.add_theme_color_override("font_color", COLOR_SECTION_HEADER)
		header_label.add_theme_font_size_override("font_size", 14)
		header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(header_label)

		for ach_id: String in cat["ids"]:
			var ach: Dictionary = ach_by_id.get(ach_id, {})
			if ach.is_empty():
				continue
			var is_done: bool = SaveManager.completed_achievements.get(ach_id, false)
			if is_done:
				completed_count += 1
				total_soul += int(ach.get("reward", 0))
			_create_list_item(content, ach, is_done, is_hidden_cat and not is_done, COLOR_COMPLETED_ACH_BG, COLOR_INCOMPLETE_BG)

	_update_footer(completed_count, achievements.size(), total_soul)


func _create_list_item(parent: VBoxContainer, data: Dictionary, is_done: bool, is_hidden: bool, done_bg: Color, incomplete_bg: Color) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, ITEM_HEIGHT)

	# Style
	var style := StyleBoxFlat.new()
	style.bg_color = done_bg if is_done else incomplete_bg
	style.set_corner_radius_all(3)
	style.set_border_width_all(1)
	if is_done:
		style.border_color = COLOR_QUEST_BORDER if not _is_achievement(data) else COLOR_ACHIEVEMENT_BORDER
	else:
		style.border_color = Color(0.3, 0.3, 0.3, 0.5)
	panel.add_theme_stylebox_override("panel", style)

	# HBox for content
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)

	# Status icon
	var status_label := Label.new()
	status_label.text = "[x]" if is_done else "[ ]"
	status_label.add_theme_color_override("font_color", COLOR_CHECK_GREEN if is_done else COLOR_EMPTY_GRAY)
	status_label.custom_minimum_size = Vector2(30, 0)
	hbox.add_child(status_label)

	# Name
	var name_label := Label.new()
	if is_hidden:
		name_label.text = "???"
		name_label.add_theme_color_override("font_color", COLOR_HIDDEN)
	else:
		name_label.text = str(data.get("name", ""))
	hbox.add_child(name_label)

	# Description
	var desc_label := Label.new()
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if is_hidden:
		desc_label.text = "???"
		desc_label.add_theme_color_override("font_color", COLOR_HIDDEN)
	else:
		desc_label.text = str(data.get("desc", ""))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(desc_label)

	# Reward
	var reward_label := Label.new()
	if is_hidden:
		reward_label.text = "???"
		reward_label.add_theme_color_override("font_color", COLOR_HIDDEN)
	else:
		reward_label.text = str(data.get("reward", 0))
		reward_label.add_theme_color_override("font_color", COLOR_REWARD_GOLD)
	reward_label.custom_minimum_size = Vector2(40, 0)
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(reward_label)

	parent.add_child(panel)


## Check if data item belongs to ACHIEVEMENTS (vs QUESTS).
func _is_achievement(data: Dictionary) -> bool:
	if not SaveManager:
		return false
	for ach: Dictionary in SaveManager.ACHIEVEMENTS:
		if ach["id"] == data.get("id", ""):
			return true
	return false


func _clear_content(content: VBoxContainer) -> void:
	while content.get_child_count() > 0:
		var child: Node = content.get_child(0)
		content.remove_child(child)
		child.queue_free()


func _add_empty_label(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)


func _update_footer(completed: int, total: int, soul: int) -> void:
	var footer: HBoxContainer = $MainVBox/Footer
	var footer_completed: Label = footer.get_node("CompletedLabel")
	var footer_soul: Label = footer.get_node("SoulLabel")
	footer_completed.text = "Completed: %d/%d" % [completed, total]
	footer_soul.text = "Soul Earned: %d" % soul
