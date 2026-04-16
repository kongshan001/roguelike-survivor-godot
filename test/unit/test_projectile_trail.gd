extends GutTest
## Tests for projectile trail VFX system.
## Validates spec: docs/superpowers/specs/projectile-trail-vfx.md
## R21 QA Task 3


var _arena: Node2D
var _projectile: Area2D
var _trail_pool_script: Node


func before_each():
	GameManager.reset()
	GameManager.elapsed_time = 0.0
	GameManager.selected_difficulty = "normal"
	_arena = Node2D.new()
	_arena.name = "Arena"
	add_child_autofree(_arena)
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.name = "Player"
	player.add_to_group("players")
	_arena.add_child(player)
	_projectile = _create_projectile("knife")
	_arena.add_child(_projectile)
	# Load the trail pool as a Node and add to tree so _ready() runs
	_trail_pool_script = Node.new()
	_trail_pool_script.set_script(load("res://scripts/effects/projectile_trail_pool.gd"))
	_trail_pool_script.name = "ProjectileTrailPool"
	add_child_autofree(_trail_pool_script)


func after_each():
	await get_tree().process_frame


func _create_projectile(weapon_id: String) -> Area2D:
	var proj: Area2D = load("res://scenes/projectile.tscn").instantiate()
	proj.global_position = Vector2(100, 100)
	proj.direction = Vector2.RIGHT
	proj.speed = 300.0
	proj.damage = 5.0
	proj.pierce = 1
	proj.color = Color.WHITE
	proj.size = 8.0
	proj.weapon_id = weapon_id
	return proj


func _create_boomerang() -> Area2D:
	# Boomerang is created dynamically (no .tscn), matching weapon_boomerang_fire.gd
	var bm: Area2D = Area2D.new()
	var col_shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 8.0
	col_shape.shape = circle
	bm.add_child(col_shape)
	bm.set_script(load("res://scripts/weapons/boomerang.gd"))
	bm.global_position = Vector2(100, 100)
	bm.weapon_id = "boomerang"
	return bm


# ============================================================
# Section 1: Trail Constants
# ============================================================

func test_trail_pool_max_80():
	assert_eq(_trail_pool_script.MAX_TRAIL_SEGMENTS, 80,
		"MAX_TRAIL_SEGMENTS should be 80")


func test_trail_lifetime_constant():
	assert_eq(_trail_pool_script.TRAIL_LIFETIME, 0.15,
		"TRAIL_LIFETIME should be 0.15s")


func test_trail_frame_interval_in_projectile():
	# Spec: TRAIL_FRAME_INTERVAL = 3 in projectile.gd
	assert_eq(_projectile.TRAIL_FRAME_INTERVAL, 3,
		"TRAIL_FRAME_INTERVAL should be 3 frames")


func test_trail_frame_interval_in_boomerang():
	var boomerang: Area2D = _create_boomerang()
	_arena.add_child(boomerang)
	assert_eq(boomerang.TRAIL_FRAME_INTERVAL, 3,
		"Boomerang TRAIL_FRAME_INTERVAL should be 3 frames")


# ============================================================
# Section 2: Trail Colors per Weapon
# ============================================================

func test_trail_color_knife():
	assert_eq(_trail_pool_script.TRAIL_COLORS["knife"],
		Color(0.75, 0.75, 0.8, 0.3),
		"Knife trail color should be silver-white alpha 0.3")


func test_trail_color_boomerang():
	assert_eq(_trail_pool_script.TRAIL_COLORS["boomerang"],
		Color(0.6, 0.4, 0.2, 0.25),
		"Boomerang trail color should be brown alpha 0.25")


func test_trail_color_fireknife():
	assert_eq(_trail_pool_script.TRAIL_COLORS["fireknife"],
		Color(1.0, 0.4, 0.1, 0.35),
		"FireKnife trail color should be orange-red alpha 0.35")


func test_trail_color_frostknife():
	assert_eq(_trail_pool_script.TRAIL_COLORS["frostknife"],
		Color(0.53, 0.87, 1.0, 0.3),
		"FrostKnife trail color should be ice blue alpha 0.3")


func test_trail_color_thunderang():
	assert_eq(_trail_pool_script.TRAIL_COLORS["thunderang"],
		Color(1.0, 0.84, 0.0, 0.25),
		"Thunderang trail color should be gold alpha 0.25")


func test_trail_color_blazerang():
	assert_eq(_trail_pool_script.TRAIL_COLORS["blazerang"],
		Color(1.0, 0.27, 0.0, 0.35),
		"Blazerang trail color should be blaze red alpha 0.35")


func test_trail_color_count():
	# Spec: 6 trail-enabled weapons
	assert_eq(_trail_pool_script.TRAIL_COLORS.size(), 6,
		"Should have exactly 6 trail-enabled weapons")


# ============================================================
# Section 3: Trail Sizes per Weapon
# ============================================================

func test_trail_size_knife():
	assert_eq(_trail_pool_script.TRAIL_SIZES["knife"],
		Vector2(5.0, 7.0), "Knife trail size should be 5x7")


func test_trail_size_boomerang():
	assert_eq(_trail_pool_script.TRAIL_SIZES["boomerang"],
		Vector2(8.0, 8.0), "Boomerang trail size should be 8x8")


func test_trail_size_fireknife():
	assert_eq(_trail_pool_script.TRAIL_SIZES["fireknife"],
		Vector2(7.0, 9.0), "FireKnife trail size should be 7x9")


func test_trail_size_frostknife():
	assert_eq(_trail_pool_script.TRAIL_SIZES["frostknife"],
		Vector2(7.0, 9.0), "FrostKnife trail size should be 7x9")


func test_trail_size_thunderang():
	assert_eq(_trail_pool_script.TRAIL_SIZES["thunderang"],
		Vector2(9.0, 9.0), "Thunderang trail size should be 9x9")


func test_trail_size_blazerang():
	assert_eq(_trail_pool_script.TRAIL_SIZES["blazerang"],
		Vector2(9.0, 9.0), "Blazerang trail size should be 9x9")


func test_trail_size_count():
	assert_eq(_trail_pool_script.TRAIL_SIZES.size(), 6,
		"Should have 6 trail size entries")


# ============================================================
# Section 4: Object Pool Architecture
# ============================================================

func test_pool_uses_color_rect():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("ColorRect") != -1,
		"Trail pool should use ColorRect for trail segments")


func test_pool_preallocates_in_ready():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("_ready") != -1 and source.find("MAX_TRAIL_SEGMENTS") != -1,
		"Trail pool should pre-allocate in _ready")


func test_pool_has_spawn_method():
	assert_true(_trail_pool_script.has_method("spawn"),
		"Trail pool should have spawn method")


func test_pool_has_has_trail_method():
	assert_true(_trail_pool_script.has_method("has_trail"),
		"Trail pool should have has_trail method for weapon check")


func test_pool_has_get_trail_color_method():
	assert_true(_trail_pool_script.has_method("get_trail_color"),
		"Trail pool should have get_trail_color method")


func test_pool_has_trails_enabled_flag():
	assert_true("_trails_enabled" in _trail_pool_script,
		"Trail pool should have _trails_enabled flag")


func test_pool_has_set_trails_enabled():
	assert_true(_trail_pool_script.has_method("set_trails_enabled"),
		"Trail pool should have set_trails_enabled method")


func test_pool_has_get_active_count():
	assert_true(_trail_pool_script.has_method("get_active_count"),
		"Trail pool should have get_active_count method")


func test_pool_has_return_to_pool():
	assert_true(_trail_pool_script.has_method("_return_to_pool"),
		"Trail pool should have _return_to_pool method")


func test_pool_has_force_return():
	assert_true(_trail_pool_script.has_method("_force_return"),
		"Trail pool should have _force_return for culling")


func test_pool_has_get_available():
	assert_true(_trail_pool_script.has_method("_get_available"),
		"Trail pool should have _get_available method")


# ============================================================
# Section 5: Weapon Filtering
# ============================================================

func test_has_trail_true_for_knife():
	assert_true(_trail_pool_script.has_trail("knife"),
		"Knife should have trail")


func test_has_trail_true_for_boomerang():
	assert_true(_trail_pool_script.has_trail("boomerang"),
		"Boomerang should have trail")


func test_has_trail_true_for_fireknife():
	assert_true(_trail_pool_script.has_trail("fireknife"),
		"FireKnife should have trail")


func test_has_trail_false_for_holywater():
	assert_false(_trail_pool_script.has_trail("holywater"),
		"HolyWater should NOT have trail (orbit type)")


func test_has_trail_false_for_bible():
	assert_false(_trail_pool_script.has_trail("bible"),
		"Bible should NOT have trail (orbit type)")


func test_has_trail_false_for_lightning():
	assert_false(_trail_pool_script.has_trail("lightning"),
		"Lightning should NOT have trail (instant type)")


func test_has_trail_false_for_firestaff():
	assert_false(_trail_pool_script.has_trail("firestaff"),
		"FireStaff should NOT have trail (cone type)")


func test_has_trail_false_for_frostaura():
	assert_false(_trail_pool_script.has_trail("frostaura"),
		"FrostAura should NOT have trail (aura type)")


func test_has_trail_false_for_unknown():
	assert_false(_trail_pool_script.has_trail("unknown_weapon"),
		"Unknown weapons should NOT have trail")


# ============================================================
# Section 6: Trail Spawning in projectile.gd
# ============================================================

func test_projectile_has_trail_counter():
	assert_true("_trail_counter" in _projectile,
		"Projectile should have _trail_counter variable")


func test_projectile_counter_starts_at_zero():
	assert_eq(_projectile._trail_counter, 0,
		"Trail counter should start at 0")


func test_projectile_has_spawn_trail_method():
	assert_true(_projectile.has_method("_spawn_trail"),
		"Projectile should have _spawn_trail method")


func test_projectile_has_get_trail_pool_method():
	assert_true(_projectile.has_method("_get_trail_pool"),
		"Projectile should have _get_trail_pool method")


func test_projectile_spawn_trail_calls_pool():
	var source: String = _projectile.get_script().source_code
	assert_true(source.find("_get_trail_pool") != -1,
		"_spawn_trail should call _get_trail_pool")
	assert_true(source.find("pool.spawn") != -1,
		"_spawn_trail should call pool.spawn")


func test_projectile_trail_skips_without_pool():
	# When no ProjectileTrailPool in tree, trail should silently skip
	_projectile._spawn_trail()
	# Should not crash
	assert_true(is_instance_valid(_projectile),
		"Projectile should survive trail spawn without pool")


# ============================================================
# Section 7: Trail Spawning in boomerang.gd
# ============================================================

func test_boomerang_has_trail_counter():
	var boomerang: Area2D = _create_boomerang()
	_arena.add_child(boomerang)
	assert_true("_trail_counter" in boomerang,
		"Boomerang should have _trail_counter variable")


func test_boomerang_has_spawn_trail_method():
	var boomerang: Area2D = _create_boomerang()
	_arena.add_child(boomerang)
	assert_true(boomerang.has_method("_spawn_trail"),
		"Boomerang should have _spawn_trail method")


# ============================================================
# Section 8: Special Weapon Behaviors
# ============================================================

func test_thunderang_has_flicker():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("_add_thunderang_flicker") != -1,
		"Trail pool should have thunderang alpha flicker")
	assert_true(source.find("thunderang") != -1,
		"Thunderang special behavior should be referenced")


func test_blazerang_has_scale_expansion():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("blazerang") != -1,
		"Blazerang special behavior should be referenced")
	assert_true(source.find("1.2, 1.2") != -1,
		"Blazerang should have scale expansion to 1.2")


# ============================================================
# Section 9: Spec Value Regression
# ============================================================

func test_spec_trail_pool_module_size():
	var source: String = _trail_pool_script.get_script().source_code
	var line_count: int = source.split("\n").size()
	assert_lt(line_count, 131,
		"Trail pool module should be under 130 lines")


func test_spec_trail_uses_weapon_id_for_color():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("weapon_id") != -1,
		"Trail pool should use weapon_id for color differentiation")


func test_spec_trail_alpha_decay_to_zero():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("color:a") != -1,
		"Trail should tween color:a to 0.0 for alpha decay")


func test_spec_trail_rotation_matches_projectile():
	var source: String = _projectile.get_script().source_code
	assert_true(source.find("rotation") != -1,
		"Trail spawn should pass projectile rotation")


func test_spec_trail_toggle_works():
	# _trails_enabled flag + set_trails_enabled method
	_trail_pool_script.set_trails_enabled(false)
	assert_false(_trail_pool_script._trails_enabled,
		"set_trails_enabled(false) should disable trails")
	_trail_pool_script.set_trails_enabled(true)
	assert_true(_trail_pool_script._trails_enabled,
		"set_trails_enabled(true) should enable trails")
