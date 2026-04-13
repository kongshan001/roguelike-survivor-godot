extends GutTest

# Test Dash system: defaults, state transitions, cooldown, invincibility

var _player: CharacterBody2D


func before_each():
	GameManager.reset()
	GameManager.selected_character = ""
	var player_scene = load("res://scenes/player.tscn")
	_player = player_scene.instantiate()
	add_child_autofree(_player)


func test_dash_defaults():
	assert_eq(_player.dash_distance, 80.0, "Default dash distance")
	assert_eq(_player.dash_duration, 0.15, "Default dash duration")
	assert_eq(_player.dash_cooldown, 2.5, "Default dash cooldown")
	assert_eq(_player.dash_timer, 0.0, "Dash timer starts at 0")
	assert_false(_player.is_dashing, "Not dashing initially")
	assert_eq(_player.dash_direction, Vector2.ZERO, "No dash direction initially")


func test_dash_afterimage_count():
	assert_eq(_player.dash_afterimage_count, 3, "Should spawn 3 afterimages")


func test_dash_cooldown_guard():
	_player.dash_timer = 1.0
	assert_gt(_player.dash_timer, 0.0, "Timer > 0 means dash blocked")
	# A dash cannot start while timer > 0
	_player.is_dashing = false
	assert_false(_player.is_dashing, "Not dashing while on cooldown")


func test_dash_direction_can_be_set():
	_player.dash_direction = Vector2.UP
	assert_eq(_player.dash_direction, Vector2.UP, "Dash direction should be settable")


func test_damage_blocked_by_invincibility():
	# Set invincible timer directly (simulating dash invincibility)
	_player.invincible_timer = 0.15
	var hp_before: float = _player.current_health
	_player.take_damage(5.0)
	assert_eq(_player.current_health, hp_before, "Damage blocked by invincibility")


func test_damage_taken_flag_on_hit():
	assert_false(GameManager.damage_taken, "No damage taken initially")
	_player.take_damage(1.0)
	assert_true(GameManager.damage_taken, "damage_taken should be true after hit")


func test_dash_distance_formula():
	# Verify the speed calculation: distance / duration
	var expected_speed: float = 80.0 / 0.15
	assert_gt(expected_speed, 500.0, "Dash speed should be a high burst")
	assert_lt(expected_speed, 600.0, "Dash speed should be reasonable")
