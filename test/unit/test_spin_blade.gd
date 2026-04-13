extends GutTest
## Tests for spin_blade.gd: orbit setup, damage, hit cooldown

var _blade: Node2D


func before_each():
	GameManager.reset()
	var blade := Node2D.new()
	blade.set_script(load("res://scripts/spin_blade.gd"))
	blade.setup(2, 15.0, 80.0, Color.WHITE, 10.0)
	blade.rotation_speed = 3.0
	blade.weapon_id = "holywater"
	add_child_autofree(blade)
	_blade = blade


# --- Setup ---

func test_setup_orbit_count():
	assert_eq(_blade.orbit_count, 2, "Should have 2 orbit blades")


func test_setup_damage():
	assert_eq(_blade.damage, 15.0, "Damage should be 15")


func test_setup_radius():
	assert_eq(_blade.orbit_radius, 80.0, "Radius should be 80")


func test_setup_color():
	assert_eq(_blade.color, Color.WHITE, "Color should be white")


func test_setup_blade_size():
	assert_eq(_blade.blade_size, 10.0, "Blade size should be 10")


func test_setup_rotation_speed():
	assert_eq(_blade.rotation_speed, 3.0, "Rotation speed should be 3")


func test_setup_weapon_id():
	assert_eq(_blade.weapon_id, "holywater", "Weapon ID should be holywater")


# --- Default values ---

func test_default_angle():
	assert_eq(_blade._angle, 0.0, "Angle starts at 0")


func test_default_hit_cooldowns():
	assert_eq(_blade._hit_cooldowns.size(), 0, "No hit cooldowns initially")


# --- Rotation speed setter ---

func test_set_rotation_speed():
	_blade.set_rotation_speed(5.0)
	assert_eq(_blade.rotation_speed, 5.0, "Should update rotation speed")


# --- Damage updates (used by weapon_controller) ---

func test_damage_can_be_updated():
	_blade.damage = 25.0
	assert_eq(_blade.damage, 25.0, "Damage can be updated")


# --- Multiple setups ---

func test_re_setup():
	_blade.setup(3, 20.0, 100.0, Color.RED, 12.0)
	assert_eq(_blade.orbit_count, 3, "Re-setup: count = 3")
	assert_eq(_blade.damage, 20.0, "Re-setup: damage = 20")
	assert_eq(_blade.orbit_radius, 100.0, "Re-setup: radius = 100")
	assert_eq(_blade.color, Color.RED, "Re-setup: color = red")
