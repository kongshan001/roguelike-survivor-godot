extends GutTest

# Test Food Pickup: creation, properties, healing

var _player: CharacterBody2D


func before_each():
	GameManager.reset()
	if SaveManager:
		for id in SaveManager.SHOP_UPGRADES:
			SaveManager.shop_upgrades[id] = 0
	GameManager.selected_character = ""
	var player_scene = load("res://scenes/player.tscn")
	_player = player_scene.instantiate()
	_player.add_to_group("players")
	add_child_autofree(_player)


func test_food_script_loads():
	var script = load("res://scripts/food_pickup.gd")
	assert_not_null(script, "food_pickup.gd should load")


func test_food_creation():
	var food: Area2D = Area2D.new()
	food.set_script(load("res://scripts/food_pickup.gd"))
	food.collision_mask = 1
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	food.add_child(shape)
	add_child_autofree(food)
	assert_eq(food.heal_amount, 1, "Default heal amount is 1")
	assert_false(food.is_moving_to_player, "Not magnetized initially")
	assert_eq(food.magnet_speed, 200.0, "Default magnet speed")


func test_food_magnet_speed():
	var food: Area2D = Area2D.new()
	food.set_script(load("res://scripts/food_pickup.gd"))
	assert_eq(food.magnet_speed, 200.0, "Base magnet speed is 200")
	food.free()


func test_food_heals_player():
	# Damage player first
	_player.take_damage(2.0)
	var hp_after_damage: float = _player.current_health
	assert_lt(hp_after_damage, _player.max_health)
	# Simulate food collection
	var food: Area2D = Area2D.new()
	food.set_script(load("res://scripts/food_pickup.gd"))
	food.collision_mask = 1
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	food.add_child(shape)
	add_child_autofree(food)
	food._player = _player
	food._collect()
	assert_eq(_player.current_health, hp_after_damage + 1.0, "HP should increase by 1")


func test_food_heal_capped():
	# Player at full health
	assert_eq(_player.current_health, _player.max_health)
	var food: Area2D = Area2D.new()
	food.set_script(load("res://scripts/food_pickup.gd"))
	food.collision_mask = 1
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	food.add_child(shape)
	add_child_autofree(food)
	food._player = _player
	food._collect()
	assert_eq(_player.current_health, _player.max_health, "HP should not exceed max")


func test_food_no_heal_if_player_dead():
	_player.take_damage(100.0)  # Kill player
	assert_false(_player.is_alive)
	var hp_before: float = _player.current_health
	var food: Area2D = Area2D.new()
	food.set_script(load("res://scripts/food_pickup.gd"))
	food.collision_mask = 1
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	food.add_child(shape)
	add_child_autofree(food)
	food._player = _player
	food._collect()
	assert_eq(_player.current_health, hp_before, "Dead player should not be healed")
