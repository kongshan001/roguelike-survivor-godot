extends Control

var _difficulties: Array[Dictionary] = [
	{
		"id": "easy",
		"name": "休闲",
		"desc": "敌人更弱，适合新手",
		"color": Color(0.4, 0.73, 0.42),
	},
	{
		"id": "normal",
		"name": "标准",
		"desc": "标准难度，平衡体验",
		"color": Color(1.0, 0.84, 0.31),
	},
	{
		"id": "hard",
		"name": "噩梦",
		"desc": "极限挑战，真正的考验",
		"color": Color(0.94, 0.33, 0.31),
	},
	{
		"id": "endless",
		"name": "无尽",
		"desc": "击败Boss后解锁，永无止境",
		"color": Color(0.81, 0.58, 0.85),
	},
]


func _ready():
	var title = Label.new()
	title.text = "选择难度"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	$VBoxContainer.add_child(title)

	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	$VBoxContainer.add_child(grid)

	for diff in _difficulties:
		var card = _create_card(diff)
		grid.add_child(card)

	var back = Button.new()
	back.text = "返回"
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/character_select.tscn"))
	$VBoxContainer.add_child(back)


func _create_card(data: Dictionary) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(240, 120)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var name_label = Label.new()
	name_label.text = data.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", data.color)
	vbox.add_child(name_label)

	var desc = Label.new()
	desc.text = data.desc
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc)

	var btn = Button.new()
	btn.text = "选择"
	btn.pressed.connect(_on_difficulty_selected.bind(data.id))
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	# Endless mode: check unlock status
	if data.id == "endless":
		if SaveManager and not SaveManager.endless_unlocked:
			btn.text = "🔒 击败Boss解锁"
			btn.disabled = true
		else:
			btn.text = "选择 (无尽)"

	vbox.add_child(btn)

	return panel


func _on_difficulty_selected(diff_id: String):
	GameManager.selected_difficulty = diff_id

	if GameManager.selected_character == "mage":
		get_tree().change_scene_to_file("res://scenes/weapon_select.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/arena.tscn")
