extends GutTest
## Tests for boomerang.gd: setup, state transitions, tracking parameters

var _bm: Area2D


func before_each():
	_bm = _create_boomerang()


func _create_boomerang() -> Area2D:
	var scene: PackedScene = load("res://scenes/projectile.tscn")
	var bm: Area2D = scene.instantiate()
	bm.set_script(load("res://scripts/weapons/boomerang.gd"))
	bm.global_position = Vector2(100, 100)
	bm.direction = Vector2.RIGHT
	bm.speed = 280.0
	bm.damage = 3.0
	bm.pierce = 0
	bm.color = Color.WHITE
	bm.size = 8.0
	bm.setup_boomerang(Vector2(100, 100), Vector2.RIGHT, 250.0, 320.0, 0.52)
	var arena := Node2D.new()
	arena.add_child(bm)
	add_child_autofree(arena)
	return bm


# --- Default values ---

func test_default_speed():
	assert_eq(_bm.speed, 280.0, "Speed = 280")


func test_default_damage():
	assert_eq(_bm.damage, 3.0, "Damage = 3")


func test_default_pierce():
	assert_eq(_bm.pierce, 0, "Pierce = 0")


func test_default_direction():
	assert_eq(_bm.direction, Vector2.RIGHT, "Direction = RIGHT")


func test_default_lifetime():
	assert_eq(_bm.lifetime, 5.0, "Lifetime = 5s")


func test_default_not_returning():
	assert_false(_bm._returning, "Not returning initially")


func test_default_dist_traveled():
	assert_eq(_bm._dist_traveled, 0.0, "Distance traveled = 0")


func test_default_hit_enemies_empty():
	assert_eq(_bm._hit_enemies.size(), 0, "No hit enemies initially")


# --- setup_boomerang parameters ---

func test_max_dist_set():
	assert_eq(_bm._max_dist, 250.0, "Max dist = 250")


func test_return_speed_set():
	assert_eq(_bm._return_speed, 320.0, "Return speed = 320")


func test_track_angle_set():
	assert_almost_eq(_bm._track_angle, 0.52, 0.01, "Track angle = 0.52")


func test_start_pos_set():
	assert_eq(_bm._start_pos, Vector2(100, 100), "Start pos = (100,100)")


# --- update_player_pos ---

func test_update_player_pos():
	_bm.update_player_pos(Vector2(200, 200))
	assert_eq(_bm._player_pos, Vector2(200, 200), "Player pos updated")


# --- Custom values ---

func test_custom_damage():
	_bm.damage = 5.0
	assert_eq(_bm.damage, 5.0, "Damage can be set")


func test_custom_pierce():
	_bm.pierce = 2
	assert_eq(_bm.pierce, 2, "Pierce can be set")


func test_custom_color():
	_bm.color = Color.RED
	assert_eq(_bm.color, Color.RED, "Color can be set")


# --- Re-setup ---

func test_re_setup_boomerang():
	_bm.setup_boomerang(Vector2(0, 0), Vector2.UP, 350.0, 400.0, 0.78)
	assert_eq(_bm._max_dist, 350.0, "Re-setup: max dist = 350")
	assert_eq(_bm._return_speed, 400.0, "Re-setup: return speed = 400")
	assert_almost_eq(_bm._track_angle, 0.78, 0.01, "Re-setup: track angle = 0.78")


# --- Distance calculation ---

func test_distance_from_start():
	_bm.global_position = Vector2(150, 100)
	var dist: float = _bm.global_position.distance_to(_bm._start_pos)
	assert_eq(dist, 50.0, "Distance from start = 50")
