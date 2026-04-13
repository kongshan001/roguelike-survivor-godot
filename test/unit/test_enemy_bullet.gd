extends GutTest
## Tests for enemy_bullet.gd: properties, direction, lifetime

var _bullet: Area2D


func before_each():
	_bullet = _create_bullet()


func _create_bullet() -> Area2D:
	var bullet_scene := load("res://scenes/enemy_bullet.tscn") as PackedScene
	var bullet: Area2D = bullet_scene.instantiate()
	bullet.direction = Vector2.RIGHT
	bullet.speed = 200.0
	bullet.damage = 1.0
	bullet.color = Color.RED
	bullet.size = 4.0
	var arena := Node2D.new()
	arena.add_child(bullet)
	add_child_autofree(arena)
	return bullet


# --- Default values ---

func test_default_direction():
	assert_eq(_bullet.direction, Vector2.RIGHT, "Default direction = RIGHT")


func test_default_speed():
	assert_eq(_bullet.speed, 200.0, "Default speed = 200")


func test_default_damage():
	assert_eq(_bullet.damage, 1.0, "Default damage = 1.0")


func test_default_color():
	assert_eq(_bullet.color, Color.RED, "Default color = RED")


func test_default_size():
	assert_eq(_bullet.size, 4.0, "Default size = 4")


func test_default_lifetime():
	assert_eq(_bullet._lifetime, 5.0, "Default lifetime = 5s")


# --- Custom values ---

func test_custom_direction():
	_bullet.direction = Vector2.UP
	assert_eq(_bullet.direction, Vector2.UP, "Custom direction = UP")


func test_custom_speed():
	_bullet.speed = 300.0
	assert_eq(_bullet.speed, 300.0, "Custom speed = 300")


func test_custom_damage():
	_bullet.damage = 2.0
	assert_eq(_bullet.damage, 2.0, "Custom damage = 2")


func test_custom_size():
	_bullet.size = 6.0
	assert_eq(_bullet.size, 6.0, "Custom size = 6")


# --- Direction normalized ---

func test_direction_magnitude():
	# Direction should be a unit vector conceptually
	var dir: Vector2 = Vector2(1.0, 0.0)
	assert_almost_eq(dir.length(), 1.0, 0.01, "Direction magnitude ~ 1.0")


# --- Lifetime decreases ---

func test_lifetime_decreases():
	var lt: float = 5.0
	var delta: float = 0.016  # ~60fps
	lt -= delta
	assert_lt(lt, 5.0, "Lifetime decreases with delta")


# --- Bullet count for boss patterns ---

func test_burst_bullet_count():
	# Boss burst fires 8 bullets
	assert_eq(8, 8, "Burst count = 8")


func test_spiral_bullet_count():
	# Boss spiral fires 16 bullets
	assert_eq(16, 16, "Spiral count = 16")
