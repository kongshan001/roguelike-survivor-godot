extends Node2D


func _ready():
	GameManager.reset()
	var player = $Player
	# Set player stats based on selected character
	match GameManager.selected_character:
		"mage":
			player.max_health = 8.0
			player.move_speed = 160.0
			var start_wpn = "holywater"
			if GameManager.has_meta("mage_start_weapon"):
				start_wpn = GameManager.get_meta("mage_start_weapon")
			player.add_weapon(start_wpn)
		"warrior":
			player.max_health = 12.0
			player.move_speed = 140.0
			player.add_weapon("knife")
		"ranger":
			player.max_health = 6.0
			player.move_speed = 190.0
			player.add_weapon("holywater")
		_:
			# Default for testing
			player.add_weapon("holywater")
	player.current_health = player.max_health
	player.add_to_group("players")
	player.hurtbox.body_entered.connect(_on_player_hurtbox_entered.bind(player))

	_draw_grid()


func _process(_delta):
	var player = $Player
	if player and is_instance_valid(player):
		$Camera2D.global_position = player.global_position


func _draw_grid():
	var grid_step = 80
	var half = 1500
	var line_color = Color(0.2, 0.2, 0.28, 1)

	for x in range(-half, half + 1, grid_step):
		var line = Line2D.new()
		line.width = 1.0
		line.default_color = line_color
		line.add_point(Vector2(x, -half))
		line.add_point(Vector2(x, half))
		line.z_index = -1
		add_child(line)

	for y in range(-half, half + 1, grid_step):
		var line = Line2D.new()
		line.width = 1.0
		line.default_color = line_color
		line.add_point(Vector2(-half, y))
		line.add_point(Vector2(half, y))
		line.z_index = -1
		add_child(line)


func _on_player_hurtbox_entered(body: Node2D, player: CharacterBody2D):
	if body.is_in_group("enemies") and body.is_alive and player.is_alive:
		player.take_damage(body.enemy_data.damage)
