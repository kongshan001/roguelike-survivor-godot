extends Node2D

var _shake_amount: float = 0.0
var _shake_decay: float = 5.0
var _shake_cooldown: float = 0.0
var _prev_health: float = -1.0
var _chest_spawner: Node = null
var _gold_income_timer: float = 0.0

# Endless mode constants
const ENDLESS_GOLD_INCOME_INTERVAL: float = 60.0
const ENDLESS_GOLD_INCOME_AMOUNT: int = 1


func _ready():
	GameManager.reset()

	# Add ChestSpawner
	_chest_spawner = Node.new()
	_chest_spawner.set_script(load("res://scripts/chest_spawner.gd"))
	_chest_spawner.name = "ChestSpawner"
	add_child(_chest_spawner)

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
	# Apply difficulty multipliers to player
	player.max_health *= GameManager.get_difficulty_mul("player_hp_mul")
	player.move_speed *= GameManager.get_difficulty_mul("player_speed_mul")
	player.current_health = player.max_health
	player.add_to_group("players")
	player.hurtbox.body_entered.connect(_on_player_hurtbox_entered.bind(player))

	# Connect screen shake triggers
	GameManager.health_changed.connect(_on_health_changed_shake)
	GameManager.combo_changed.connect(_on_combo_changed_shake)

	# Connect retreat signal for endless mode
	GameManager.retreat_requested.connect(_on_retreat_requested)

	# Connect victory signal for normal/hard mode
	GameManager.victory_achieved.connect(_on_victory_achieved)

	_draw_grid()


func _process(delta):
	var player = $Player
	if player and is_instance_valid(player):
		$Camera2D.global_position = player.global_position

	# Screen shake cooldown (prevent continuous shake from burn DOT)
	if _shake_cooldown > 0:
		_shake_cooldown -= delta

	# Screen shake
	if _shake_amount > 0:
		_shake_amount = maxf(0, _shake_amount - _shake_decay * delta)
		$Camera2D.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake_amount
	else:
		$Camera2D.offset = Vector2.ZERO

	# Endless mode passive gold income
	if GameManager.selected_difficulty == "endless" and not GameManager.is_game_over:
		_gold_income_timer += delta
		if _gold_income_timer >= ENDLESS_GOLD_INCOME_INTERVAL:
			_gold_income_timer -= ENDLESS_GOLD_INCOME_INTERVAL
			GameManager.add_gold(ENDLESS_GOLD_INCOME_AMOUNT)
			var minutes: int = int(GameManager.elapsed_time / 60.0)
			GameManager.milestone_reached.emit(minutes, ENDLESS_GOLD_INCOME_AMOUNT)


func screen_shake(amount: float) -> void:
	_shake_amount = amount


func _on_health_changed_shake(cur: float, _max: float) -> void:
	# Only shake on damage, not healing, with cooldown to prevent burn DOT spam
	if _prev_health >= 0.0 and cur < _prev_health and _shake_cooldown <= 0:
		screen_shake(3.0)
		_shake_cooldown = 0.5
	_prev_health = cur


func _on_combo_changed_shake(count: int) -> void:
	# Only shake on milestone increases, not on combo reset to 0
	if count <= 0:
		return
	# Tiered shake based on combo count
	if count >= 50:
		screen_shake(10.0)
	elif count >= 20:
		screen_shake(7.0)
	elif count >= 10:
		screen_shake(5.0)
	elif count >= 5:
		screen_shake(3.0)


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
		var dmg: float = body.enemy_data.damage * GameManager.get_difficulty_mul("enemy_dmg_mul")
		player.take_damage(dmg)


func _on_retreat_requested() -> void:
	if GameManager.is_game_over:
		return
	GameManager.is_game_over = true
	GameManager.player_died.emit()
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/game_over_screen.tscn")
	)


func _on_victory_achieved(_gold_bonus: int) -> void:
	var tween = create_tween()
	tween.tween_interval(GameManager.VICTORY_TRANSITION_DELAY)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/game_over_screen.tscn")
	)
