extends GutTest

# Test Projectile setup and direction logic

var _projectile: Area2D


func before_each():
	var proj_scene = load("res://scenes/projectile.tscn")
	_projectile = proj_scene.instantiate()
	add_child_autofree(_projectile)


func test_setup_sets_position():
	var from = Vector2(100, 200)
	var to = Vector2(300, 200)
	_projectile.setup(from, to, 300.0, 10.0, 1, Color.WHITE, 8.0)
	assert_eq(_projectile.global_position, from, "Position should be set to origin")


func test_setup_sets_direction_right():
	_projectile.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 1, Color.WHITE, 8.0)
	assert_almost_eq(_projectile.direction.x, 1.0, 0.01, "Direction should point right")
	assert_almost_eq(_projectile.direction.y, 0.0, 0.01)


func test_setup_sets_direction_diagonal():
	_projectile.setup(Vector2.ZERO, Vector2(100, 100), 300.0, 10.0, 1, Color.WHITE, 8.0)
	assert_almost_eq(_projectile.direction.x, _projectile.direction.y, 0.01, "Diagonal should be equal")


func test_setup_same_position_defaults_to_right():
	_projectile.setup(Vector2(50, 50), Vector2(50, 50), 300.0, 10.0, 1, Color.WHITE, 8.0)
	assert_eq(_projectile.direction, Vector2.RIGHT, "Zero direction should default to RIGHT")


func test_setup_sets_damage():
	_projectile.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 25.0, 3, Color.WHITE, 8.0)
	assert_eq(_projectile.damage, 25.0, "Damage should be 25")


func test_setup_sets_pierce():
	_projectile.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 5, Color.WHITE, 8.0)
	assert_eq(_projectile.pierce, 5, "Pierce should be 5")


func test_setup_sets_speed():
	_projectile.setup(Vector2.ZERO, Vector2(100, 0), 500.0, 10.0, 1, Color.WHITE, 8.0)
	assert_eq(_projectile.speed, 500.0, "Speed should be 500")


func test_setup_sets_color():
	_projectile.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 1, Color.RED, 8.0)
	assert_eq(_projectile.color, Color.RED, "Color should be red")


func test_direction_is_normalized():
	_projectile.setup(Vector2.ZERO, Vector2(300, 400), 300.0, 10.0, 1, Color.WHITE, 8.0)
	assert_almost_eq(_projectile.direction.length(), 1.0, 0.01, "Direction should be normalized")
