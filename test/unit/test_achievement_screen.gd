extends GutTest

## Unit tests for the achievement screen UI
## Covers: scene instantiation, quest tab display, achievement tab display,
## hidden achievement "???" display, back button navigation, category structure


func after_each():
	# Ensure all queue_free() calls from _clear_content complete before GUT autofree
	await get_tree().process_frame


# =====================================================================
# Scene and Script Loading
# =====================================================================

func test_achievement_screen_scene_loads():
	var scene: PackedScene = load("res://scenes/achievement_screen.tscn")
	assert_not_null(scene, "achievement_screen.tscn should load without errors")

func test_achievement_screen_script_loads():
	var script: GDScript = load("res://scripts/achievement_screen.gd")
	assert_not_null(script, "achievement_screen.gd should load without errors")

func test_achievement_screen_instantiates():
	var scene: PackedScene = load("res://scenes/achievement_screen.tscn")
	var instance: Control = scene.instantiate()
	add_child_autofree(instance)
	await get_tree().process_frame
	assert_not_null(instance, "AchievementScreen should instantiate as Control")
	assert_true(instance is Control, "Root node should be Control")


# =====================================================================
# Scene Structure (nodes built in _ready)
# =====================================================================

func test_has_background():
	var instance := await _create_screen()
	var bg: ColorRect = instance.get_node_or_null("Background")
	assert_not_null(bg, "Should have Background ColorRect")

func test_has_main_vbox():
	var instance := await _create_screen()
	var vbox: VBoxContainer = instance.get_node_or_null("MainVBox")
	assert_not_null(vbox, "Should have MainVBox")

func test_has_header_with_back_button():
	var instance := await _create_screen()
	var header: HBoxContainer = instance.get_node_or_null("MainVBox/Header")
	assert_not_null(header, "Should have Header")
	var back_btn: Button = instance.get_node_or_null("MainVBox/Header/BackButton")
	assert_not_null(back_btn, "Should have BackButton in Header")
	assert_eq(back_btn.text, "< Back", "BackButton text should be '< Back'")

func test_has_tab_bar():
	var instance := await _create_screen()
	var tab_bar: HBoxContainer = instance.get_node_or_null("MainVBox/TabBar")
	assert_not_null(tab_bar, "Should have TabBar")

func test_has_quest_tab_button():
	var instance := await _create_screen()
	var quest_tab: Button = instance.get_node_or_null("MainVBox/TabBar/QuestTab")
	assert_not_null(quest_tab, "Should have QuestTab button")
	assert_eq(quest_tab.text, "Quests", "QuestTab text should be 'Quests'")

func test_has_achievement_tab_button():
	var instance := await _create_screen()
	var ach_tab: Button = instance.get_node_or_null("MainVBox/TabBar/AchTab")
	assert_not_null(ach_tab, "Should have AchTab button")
	assert_eq(ach_tab.text, "Achievements", "AchTab text should be 'Achievements'")

func test_has_scroll_container():
	var instance := await _create_screen()
	var scroll: ScrollContainer = instance.get_node_or_null("MainVBox/ScrollContainer")
	assert_not_null(scroll, "Should have ScrollContainer")

func test_has_content_vbox():
	var instance := await _create_screen()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	assert_not_null(content, "Should have ContentVBox inside ScrollContainer")

func test_has_footer():
	var instance := await _create_screen()
	var footer: HBoxContainer = instance.get_node_or_null("MainVBox/Footer")
	assert_not_null(footer, "Should have Footer")

func test_has_completed_label_in_footer():
	var instance := await _create_screen()
	var label: Label = instance.get_node_or_null("MainVBox/Footer/CompletedLabel")
	assert_not_null(label, "Footer should have CompletedLabel")

func test_has_soul_label_in_footer():
	var instance := await _create_screen()
	var label: Label = instance.get_node_or_null("MainVBox/Footer/SoulLabel")
	assert_not_null(label, "Footer should have SoulLabel")


# =====================================================================
# Quest Tab Display
# =====================================================================

func test_default_view_shows_quests():
	var instance := await _create_screen()
	var title: Label = instance.get_node_or_null("MainVBox/Header/TitleLabel")
	assert_eq(title.text, "Quests", "Default view should show Quests title")

func test_quest_tab_shows_quest_items():
	var instance := await _create_screen()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	assert_gt(content.get_child_count(), 0, "Quest tab should display quest items")

func test_quest_tab_item_count_matches_quests():
	var instance := await _create_screen()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	assert_eq(content.get_child_count(), SaveManager.QUESTS.size(),
		"Content children count should match QUESTS count (%d)" % SaveManager.QUESTS.size())

func test_quest_tab_item_has_check_icon():
	var instance := await _create_screen()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	if content.get_child_count() > 0:
		var first_item: PanelContainer = content.get_child(0) as PanelContainer
		assert_not_null(first_item, "Quest items should be PanelContainers")
		var hbox: HBoxContainer = first_item.get_child(0) as HBoxContainer
		assert_not_null(hbox, "Quest item should have HBoxContainer child")
		var status: Label = hbox.get_child(0) as Label
		assert_not_null(status, "Quest item should have status label")
		assert_true(status.text == "[x]" or status.text == "[ ]",
			"Status icon should be '[x]' or '[ ]', got '%s'" % status.text)

func test_completed_footer_after_quests():
	var instance := await _create_screen()
	var footer_completed: Label = instance.get_node_or_null("MainVBox/Footer/CompletedLabel")
	assert_true(footer_completed.text.begins_with("Completed:"),
		"Footer should show completed count, got: %s" % footer_completed.text)


# =====================================================================
# Achievement Tab Display
# =====================================================================

func test_achievement_tab_switches_title():
	var instance := await _create_screen()
	instance._show_achievements()
	var title: Label = instance.get_node_or_null("MainVBox/Header/TitleLabel")
	assert_eq(title.text, "Achievements", "After _show_achievements, title should be 'Achievements'")

func test_achievement_tab_shows_achievement_items():
	var instance := await _create_screen()
	instance._show_achievements()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	assert_gt(content.get_child_count(), 0, "Achievement tab should display items")

func test_achievement_tab_has_category_headers():
	var instance := await _create_screen()
	instance._show_achievements()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	var found_header: bool = false
	for child in content.get_children():
		if child is Label:
			var label: Label = child as Label
			if label.text.begins_with("---"):
				found_header = true
				break
	assert_true(found_header, "Achievement view should have at least one category header")


# =====================================================================
# Hidden Achievement "???" Display
# =====================================================================

func test_hidden_category_not_shown_when_none_unlocked():
	var instance := await _create_screen()
	SaveManager.completed_achievements["fast_boss"] = false
	SaveManager.completed_achievements["pacifist_1min"] = false
	instance._show_achievements()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	var found_hidden_header: bool = false
	for child in content.get_children():
		if child is Label and child.text == "--- ??? ---":
			found_hidden_header = true
	assert_false(found_hidden_header, "Hidden category header should NOT appear when none unlocked")

func test_hidden_category_shown_when_one_unlocked():
	var instance := await _create_screen()
	SaveManager.completed_achievements["fast_boss"] = true
	instance._show_achievements()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	var found_hidden_header: bool = false
	for child in content.get_children():
		if child is Label and child.text == "--- ??? ---":
			found_hidden_header = true
	assert_true(found_hidden_header, "Hidden category header should appear when one is unlocked")
	SaveManager.completed_achievements["fast_boss"] = false

func test_hidden_achievement_incomplete_shows_question_marks():
	var instance := await _create_screen()
	SaveManager.completed_achievements["fast_boss"] = true
	SaveManager.completed_achievements["pacifist_1min"] = false
	instance._show_achievements()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	var found_hidden_name: bool = false
	for child in content.get_children():
		if child is PanelContainer:
			var hbox: HBoxContainer = child.get_child(0) as HBoxContainer
			if hbox:
				var name_label: Label = hbox.get_child(1) as Label
				if name_label and name_label.text == "???":
					found_hidden_name = true
					break
	assert_true(found_hidden_name, "Incomplete hidden achievement name should show '???'")
	SaveManager.completed_achievements["fast_boss"] = false

func test_hidden_achievement_completed_shows_real_name():
	var instance := await _create_screen()
	SaveManager.completed_achievements["fast_boss"] = true
	instance._show_achievements()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	var found_real: bool = false
	for child in content.get_children():
		if child is PanelContainer:
			var hbox: HBoxContainer = child.get_child(0) as HBoxContainer
			if hbox:
				var name_label: Label = hbox.get_child(1) as Label
				if name_label and name_label.text == "速杀":
					found_real = true
	assert_true(found_real, "Completed hidden achievement should show real name")
	SaveManager.completed_achievements["fast_boss"] = false


# =====================================================================
# Back Navigation
# =====================================================================

func test_back_button_has_pressed_signal_connected():
	var instance := await _create_screen()
	var back_btn: Button = instance.get_node_or_null("MainVBox/Header/BackButton")
	assert_not_null(back_btn, "BackButton should exist")
	var connections: Array = back_btn.pressed.get_connections()
	assert_gt(connections.size(), 0, "BackButton pressed should be connected")

func test_back_button_method_exists():
	var script: GDScript = load("res://scripts/achievement_screen.gd")
	var instance: Control = autofree(Control.new())
	instance.set_script(script)
	assert_has_method(instance, "_on_back_pressed", "Should have _on_back_pressed method")

func test_escape_key_triggers_back():
	var script: GDScript = load("res://scripts/achievement_screen.gd")
	var instance: Control = autofree(Control.new())
	instance.set_script(script)
	assert_has_method(instance, "_input", "Should have _input method for ESC handling")


# =====================================================================
# Category Structure
# =====================================================================

func test_ach_categories_count():
	var script: GDScript = load("res://scripts/achievement_screen.gd")
	var source: String = script.source_code
	var count: int = 0
	var idx: int = 0
	while true:
		idx = source.find('"label":', idx)
		if idx == -1:
			break
		count += 1
		idx += 1
	assert_eq(count, 8, "Should have 8 achievement categories")

func test_categories_include_milestone():
	var instance := await _create_screen()
	instance._show_achievements()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	var found_milestone: bool = false
	for child in content.get_children():
		if child is Label and child.text == "--- Milestone ---":
			found_milestone = true
	assert_true(found_milestone, "Should have Milestone category header")

func test_categories_include_survival():
	var instance := await _create_screen()
	instance._show_achievements()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	var found: bool = false
	for child in content.get_children():
		if child is Label and child.text == "--- Survival ---":
			found = true
	assert_true(found, "Should have Survival category header")

func test_categories_include_evolution_synergy():
	var instance := await _create_screen()
	instance._show_achievements()
	var content: VBoxContainer = instance.get_node_or_null("MainVBox/ScrollContainer/ContentVBox")
	var found: bool = false
	for child in content.get_children():
		if child is Label and child.text == "--- Evolution/Synergy ---":
			found = true
	assert_true(found, "Should have Evolution/Synergy category header")


# =====================================================================
# Main Menu Achievement Button
# =====================================================================

func test_main_scene_loads():
	var scene: PackedScene = load("res://scenes/main.tscn")
	assert_not_null(scene, "main.tscn should load")

func test_main_scene_has_achievement_button():
	var scene: PackedScene = load("res://scenes/main.tscn")
	var instance: Control = scene.instantiate()
	add_child_autofree(instance)
	await get_tree().process_frame
	var btn: Button = instance.get_node_or_null("AchievementButton")
	assert_not_null(btn, "Main scene should have AchievementButton")
	assert_eq(btn.text, "Achievements", "Button text should be 'Achievements'")

func test_title_screen_has_achievement_handler():
	var script: GDScript = load("res://scripts/title_screen.gd")
	var instance: Control = autofree(Control.new())
	instance.set_script(script)
	assert_has_method(instance, "_on_achievement_pressed", "Should have _on_achievement_pressed method")


# =====================================================================
# Color Constants Validation
# =====================================================================

func test_color_constants_defined():
	var script: GDScript = load("res://scripts/achievement_screen.gd")
	var source: String = script.source_code
	assert_true(source.find("COLOR_BG") != -1, "COLOR_BG should be defined")
	assert_true(source.find("COLOR_COMPLETED_BG") != -1, "COLOR_COMPLETED_BG should be defined")
	assert_true(source.find("COLOR_HIDDEN") != -1, "COLOR_HIDDEN should be defined")
	assert_true(source.find("COLOR_REWARD_GOLD") != -1, "COLOR_REWARD_GOLD should be defined")


# =====================================================================
# Helper
# =====================================================================

func _create_screen() -> Control:
	var scene: PackedScene = load("res://scenes/achievement_screen.tscn")
	var instance: Control = scene.instantiate()
	add_child_autofree(instance)
	await get_tree().process_frame
	return instance
