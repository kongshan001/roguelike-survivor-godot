extends Control

var _characters: Array[Dictionary] = [
	{
		"id": "mage",
		"name": "魔法师",
		"icon": "M",
		"hp": 8,
		"speed": 160,
		"desc": "均衡型，自选初始武器",
		"ability": "武器伤害+20%",
		"color": Color(0.1, 0.14, 0.49),
	},
	{
		"id": "warrior",
		"name": "战士",
		"icon": "W",
		"hp": 12,
		"speed": 140,
		"desc": "高血量坦克，初始飞刀",
		"ability": "护甲+1",
		"color": Color(0.72, 0.11, 0.11),
	},
	{
		"id": "ranger",
		"name": "游侠",
		"icon": "R",
		"hp": 6,
		"speed": 190,
		"desc": "高速低血，初始圣水",
		"ability": "暴击+10%",
		"color": Color(0.11, 0.37, 0.13),
	},
]


func _ready():
	# Title
	var title = Label.new()
	title.text = "选择角色"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	$VBoxContainer.add_child(title)

	# Character cards
	var cards = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 20)
	$VBoxContainer.add_child(cards)

	for char_data in _characters:
		var card = _create_card(char_data)
		cards.add_child(card)

	# Back button
	var back = Button.new()
	back.text = "返回"
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main.tscn"))
	$VBoxContainer.add_child(back)


func _create_card(data: Dictionary) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(200, 280)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# Icon
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(60, 60)
	icon.color = data.color
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(icon)

	# Name
	var name_label = Label.new()
	name_label.text = data.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(name_label)

	# Stats
	var stats = Label.new()
	stats.text = "HP: %d  速度: %d" % [data.hp, data.speed]
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(stats)

	# Description
	var desc = Label.new()
	desc.text = data.desc
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc)

	# Ability
	var ability = Label.new()
	ability.text = data.ability
	ability.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ability.add_theme_font_size_override("font_size", 14)
	ability.add_theme_color_override("font_color", Color.YELLOW)
	vbox.add_child(ability)

	# Select button
	var btn = Button.new()
	btn.text = "选择"
	btn.pressed.connect(_on_character_selected.bind(data.id))
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(btn)

	return panel


func _on_character_selected(char_id: String):
	GameManager.selected_character = char_id
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/difficulty_select.tscn")
