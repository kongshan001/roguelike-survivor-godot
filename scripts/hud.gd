extends CanvasLayer

var _upgrade_options: Array[Dictionary] = []
var _pending_level_ups: int = 0


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	GameManager.health_changed.connect(_on_health_changed)
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.level_up.connect(_on_level_up)
	GameManager.player_died.connect(_on_player_died)

	$UpgradePanel.visible = false
	$UpgradePanel/Panel/Card1.gui_input.connect(_on_card_input.bind(0))
	$UpgradePanel/Panel/Card2.gui_input.connect(_on_card_input.bind(1))
	$UpgradePanel/Panel/Card3.gui_input.connect(_on_card_input.bind(2))

	# Card children consume mouse events by default, prevent that
	for card in [$UpgradePanel/Panel/Card1, $UpgradePanel/Panel/Card2, $UpgradePanel/Panel/Card3]:
		for child in card.get_children():
			if child is Control:
				child.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta):
	$TimerLabel.text = GameManager.format_time(GameManager.elapsed_time)


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
	pass


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
			card.get_node("NameLabel").text = option.name
			card.get_node("DescLabel").text = option.description
			card.get_node("Icon").color = option.icon_color
			card.get_node("KeyLabel").text = "[%d]" % (i + 1)
		else:
			card.visible = false

	$UpgradePanel.visible = true


func _on_card_input(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed:
		_select_upgrade(index)


func _input(event: InputEvent):
	if $UpgradePanel.visible and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _select_upgrade(0)
			KEY_2: _select_upgrade(1)
			KEY_3: _select_upgrade(2)


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

	$UpgradePanel.visible = false

	if _pending_level_ups > 0:
		_show_upgrade_panel()
	else:
		get_tree().paused = false


func _get_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]
	return null
