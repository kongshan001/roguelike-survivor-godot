extends Control

var _weapons: Array[Dictionary] = [
	{"id": "holywater", "name": "圣水", "desc": "环绕旋转", "color": Color(0.3, 0.5, 1.0), "sprite": "res://assets/sprites/weapons/holy_water.png"},
	{"id": "knife", "name": "飞刀", "desc": "自动投掷", "color": Color(0.75, 0.75, 0.8), "sprite": "res://assets/sprites/weapons/knife.png"},
	{"id": "lightning", "name": "闪电", "desc": "随机电击", "color": Color(1.0, 1.0, 0.3), "sprite": "res://assets/sprites/weapons/lightning.png"},
	{"id": "boomerang", "name": "回旋镖", "desc": "追踪回旋", "color": Color(0.6, 0.4, 0.2), "sprite": "res://assets/sprites/weapons/boomerang.png"},
]


func _ready():
	var title = Label.new()
	title.text = "选择初始武器"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	$VBoxContainer.add_child(title)

	var cards = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 20)
	$VBoxContainer.add_child(cards)

	for wpn in _weapons:
		cards.add_child(_create_card(wpn))

	var back = Button.new()
	back.text = "返回"
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/difficulty_select.tscn"))
	$VBoxContainer.add_child(back)


func _create_card(data: Dictionary) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(160, 200)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(40, 40)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tex_path: String = data.get("sprite", "")
	if tex_path != "" and ResourceLoader.exists(tex_path):
		icon.texture = load(tex_path)
	icon.modulate = data.color
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(icon)

	var name_label = Label.new()
	name_label.text = data.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)

	var desc = Label.new()
	desc.text = data.desc
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc)

	var btn = Button.new()
	btn.text = "选择"
	btn.pressed.connect(_on_weapon_selected.bind(data.id))
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(btn)

	return panel


func _on_weapon_selected(weapon_id: String):
	# Store mage's chosen weapon in GameManager
	GameManager.set_meta("mage_start_weapon", weapon_id)
	get_tree().change_scene_to_file("res://scenes/arena.tscn")
