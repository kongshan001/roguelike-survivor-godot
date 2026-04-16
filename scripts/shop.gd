extends Control
## 商店界面 — 使用灵魂碎片购买永久升级

var _upgrade_buttons: Array[Button] = []


func _ready():
	$BackButton.pressed.connect(_on_back)
	_build_shop_ui()
	_refresh()


func _build_shop_ui() -> void:
	var container: VBoxContainer = $ScrollContainer/VBox
	var upgrades: Dictionary = SaveManager.SHOP_UPGRADES

	var idx: int = 0
	for id in upgrades:
		var def: Dictionary = upgrades[id]
		var level: int = SaveManager.get_upgrade_level(id)

		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)

		# Icon
		var icon: Label = Label.new()
		icon.text = def["icon"]
		icon.custom_minimum_size = Vector2(40, 40)
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(icon)

		# Info
		var info: VBoxContainer = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label: Label = Label.new()
		name_label.text = "%s  Lv.%d/%d" % [def["name"], level, def["max_level"]]
		name_label.name = "NameLabel"
		info.add_child(name_label)

		var desc_label: Label = Label.new()
		desc_label.text = _get_effect_text(id)
		desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		info.add_child(desc_label)

		row.add_child(info)

		# Buy button
		var btn: Button = Button.new()
		btn.name = "BuyBtn"
		btn.custom_minimum_size = Vector2(120, 40)
		var cost: int = SaveManager.get_upgrade_cost(id)
		if cost < 0:
			btn.text = "MAX"
			btn.disabled = true
		else:
			btn.text = "%d 💎" % cost
		btn.pressed.connect(_on_buy.bind(id))
		row.add_child(btn)

		container.add_child(row)
		_upgrade_buttons.append(btn)
		idx += 1


func _refresh() -> void:
	$SoulLabel.text = "Soul Fragments: %d" % SaveManager.soul_fragments
	_rebuild_buttons()


func _rebuild_buttons() -> void:
	var container: VBoxContainer = $ScrollContainer/VBox
	var upgrades: Dictionary = SaveManager.SHOP_UPGRADES
	var idx: int = 0

	for id in upgrades:
		if idx >= _upgrade_buttons.size():
			break
		var btn: Button = _upgrade_buttons[idx]
		var cost: int = SaveManager.get_upgrade_cost(id)
		if cost < 0:
			btn.text = "MAX"
			btn.disabled = true
		else:
			btn.text = "%d 💎" % cost
			btn.disabled = SaveManager.soul_fragments < cost
		idx += 1

	# Update name labels
	var def_id: int = 0
	for id in upgrades:
		var def: Dictionary = upgrades[id]
		var level: int = SaveManager.get_upgrade_level(id)
		var row: HBoxContainer = container.get_child(def_id) as HBoxContainer
		if row:
			var info: VBoxContainer = row.get_child(1) as VBoxContainer
			if info:
				var name_label: Label = info.get_node_or_null("NameLabel")
				if name_label:
					name_label.text = "%s  Lv.%d/%d" % [def["name"], level, def["max_level"]]
		def_id += 1


func _on_buy(upgrade_id: String) -> void:
	if SaveManager.purchase_upgrade(upgrade_id):
		_refresh()


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _get_effect_text(id: String) -> String:
	match id:
		"maxhp": return "+1/+2/+3/+5 HP"
		"speed": return "+5%/+10%/+15%/+20% Speed"
		"pickup": return "+5/+10/+15/+20 Pickup Range"
		"expbonus": return "+5%/+10%/+15%/+20% EXP"
		"weapondmg": return "+3%/+6%/+10%/+15% Weapon DMG"
		"gold": return "+10%/+20%/+30%/+40% Gold"
		_: return ""
