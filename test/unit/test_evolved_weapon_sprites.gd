extends GutTest
## Tests for evolved weapon sprite loading in projectile.gd and boomerang.gd
## Verifies that weapon_id set before setup() correctly loads evolved sprites,
## and that empty/missing weapon_id falls back to default sprites.

var _projectile: Area2D
var _boomerang: Area2D


func before_each():
	_projectile = null
	_boomerang = null


# =====================================================================
# Helper: create a projectile with weapon_id set before setup()
# This mirrors the fix in weapon_fire.gd fire_projectile() line 71-72
# =====================================================================

func _create_projectile_with_id(wpn_id: String) -> Area2D:
	var scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = scene.instantiate()
	# Set weapon_id BEFORE setup() -- this is the bug fix being verified
	proj.weapon_id = wpn_id
	proj.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 1, Color.WHITE, 8.0)
	add_child_autofree(proj)
	return proj


# =====================================================================
# Helper: create a boomerang with weapon_id set before setup()
# This mirrors the fix in weapon_fire.gd _create_boomerang() line 358
# =====================================================================

func _create_boomerang_with_id(wpn_id: String) -> Area2D:
	var scene: PackedScene = load("res://scenes/projectile.tscn")
	var bm: Area2D = scene.instantiate()
	bm.set_script(load("res://scripts/weapons/boomerang.gd"))
	bm.global_position = Vector2.ZERO
	bm.direction = Vector2.RIGHT
	bm.speed = 280.0
	bm.damage = 3.0
	bm.pierce = 0
	bm.color = Color.WHITE
	bm.size = 8.0
	# Set weapon_id BEFORE setup() -- this is the bug fix being verified
	bm.weapon_id = wpn_id
	bm.setup(Vector2.ZERO, Vector2.RIGHT, Vector2.ZERO)
	add_child_autofree(bm)
	return bm


# =====================================================================
# 1. Projectile evolved weapon sprite loading
# =====================================================================

func test_projectile_fireknife_loads_fireknife_sprite():
	_projectile = _create_projectile_with_id("fireknife")
	var sprite: Sprite2D = _projectile.get_node_or_null("Sprite")
	assert_not_null(sprite, "Sprite node should exist")
	if sprite and sprite.texture:
		# The texture resource path should contain fireknife.png
		var tex_path: String = sprite.texture.resource_path
		assert_true(tex_path.find("fireknife") >= 0, "Should load fireknife.png, got: %s" % tex_path)


func test_projectile_frostknife_loads_frostknife_sprite():
	_projectile = _create_projectile_with_id("frostknife")
	var sprite: Sprite2D = _projectile.get_node_or_null("Sprite")
	assert_not_null(sprite, "Sprite node should exist")
	if sprite and sprite.texture:
		var tex_path: String = sprite.texture.resource_path
		assert_true(tex_path.find("frostknife") >= 0, "Should load frostknife.png, got: %s" % tex_path)


func test_projectile_default_empty_id_falls_back_to_enemy_bullet():
	_projectile = _create_projectile_with_id("")
	var sprite: Sprite2D = _projectile.get_node_or_null("Sprite")
	assert_not_null(sprite, "Sprite node should exist")
	if sprite and sprite.texture:
		var tex_path: String = sprite.texture.resource_path
		assert_true(tex_path.find("enemy_bullet") >= 0, "Empty weapon_id should fallback to enemy_bullet.png, got: %s" % tex_path)


func test_projectile_weapon_id_preserved_after_setup():
	_projectile = _create_projectile_with_id("fireknife")
	assert_eq(_projectile.weapon_id, "fireknife", "weapon_id should be preserved after setup()")


func test_projectile_nonexistent_id_falls_back_to_enemy_bullet():
	_projectile = _create_projectile_with_id("nonexistent_weapon_xyz")
	var sprite: Sprite2D = _projectile.get_node_or_null("Sprite")
	assert_not_null(sprite, "Sprite node should exist")
	if sprite and sprite.texture:
		var tex_path: String = sprite.texture.resource_path
		assert_true(tex_path.find("enemy_bullet") >= 0, "Nonexistent weapon_id should fallback to enemy_bullet.png, got: %s" % tex_path)


# =====================================================================
# 2. Boomerang evolved weapon sprite loading
# =====================================================================

func test_boomerang_thunderang_loads_thunderang_sprite():
	_boomerang = _create_boomerang_with_id("thunderang")
	var sprite: Sprite2D = _boomerang.get_node_or_null("Sprite")
	assert_not_null(sprite, "Sprite node should exist")
	if sprite and sprite.texture:
		var tex_path: String = sprite.texture.resource_path
		assert_true(tex_path.find("thunderang") >= 0, "Should load thunderang.png, got: %s" % tex_path)


func test_boomerang_blazerang_loads_blazerang_sprite():
	_boomerang = _create_boomerang_with_id("blazerang")
	var sprite: Sprite2D = _boomerang.get_node_or_null("Sprite")
	assert_not_null(sprite, "Sprite node should exist")
	if sprite and sprite.texture:
		var tex_path: String = sprite.texture.resource_path
		assert_true(tex_path.find("blazerang") >= 0, "Should load blazerang.png, got: %s" % tex_path)


func test_boomerang_default_boomerang_id_loads_boomerang_sprite():
	_boomerang = _create_boomerang_with_id("boomerang")
	var sprite: Sprite2D = _boomerang.get_node_or_null("Sprite")
	assert_not_null(sprite, "Sprite node should exist")
	if sprite and sprite.texture:
		var tex_path: String = sprite.texture.resource_path
		assert_true(tex_path.find("boomerang") >= 0, "boomerang id should load boomerang.png, got: %s" % tex_path)


func test_boomerang_empty_id_falls_back_to_boomerang():
	# Boomerang.gd setup() line 34-40: empty weapon_id skips weapon_id path,
	# then falls back to boomerang.png (if it exists), not enemy_bullet.png
	_boomerang = _create_boomerang_with_id("")
	var sprite: Sprite2D = _boomerang.get_node_or_null("Sprite")
	assert_not_null(sprite, "Sprite node should exist")
	if sprite and sprite.texture:
		var tex_path: String = sprite.texture.resource_path
		assert_true(tex_path.find("boomerang") >= 0, "Empty weapon_id should fallback to boomerang.png, got: %s" % tex_path)


func test_boomerang_weapon_id_preserved_after_setup():
	_boomerang = _create_boomerang_with_id("thunderang")
	assert_eq(_boomerang.weapon_id, "thunderang", "weapon_id should be preserved after setup()")


func test_boomerang_nonexistent_id_falls_back_to_boomerang():
	# Boomerang script has a two-level fallback: weapon_id -> boomerang.png -> enemy_bullet.png
	_boomerang = _create_boomerang_with_id("nonexistent_weapon_xyz")
	var sprite: Sprite2D = _boomerang.get_node_or_null("Sprite")
	assert_not_null(sprite, "Sprite node should exist")
	if sprite and sprite.texture:
		var tex_path: String = sprite.texture.resource_path
		assert_true(tex_path.find("boomerang") >= 0 or tex_path.find("enemy_bullet") >= 0,
			"Nonexistent weapon_id should fallback to boomerang.png or enemy_bullet.png, got: %s" % tex_path)


# =====================================================================
# 3. Sprite existence verification (asset files on disk)
# =====================================================================

func test_fireknife_sprite_file_exists():
	assert_true(ResourceLoader.exists("res://assets/sprites/weapons/fireknife.png"),
		"fireknife.png should exist in assets")


func test_frostknife_sprite_file_exists():
	assert_true(ResourceLoader.exists("res://assets/sprites/weapons/frostknife.png"),
		"frostknife.png should exist in assets")


func test_thunderang_sprite_file_exists():
	assert_true(ResourceLoader.exists("res://assets/sprites/weapons/thunderang.png"),
		"thunderang.png should exist in assets")


func test_blazerang_sprite_file_exists():
	assert_true(ResourceLoader.exists("res://assets/sprites/weapons/blazerang.png"),
		"blazerang.png should exist in assets")


func test_enemy_bullet_sprite_file_exists():
	assert_true(ResourceLoader.exists("res://assets/sprites/weapons/enemy_bullet.png"),
		"enemy_bullet.png should exist in assets")


func test_boomerang_sprite_file_exists():
	assert_true(ResourceLoader.exists("res://assets/sprites/weapons/boomerang.png"),
		"boomerang.png should exist in assets")


# =====================================================================
# 4. _create_boomerang in weapon_fire.gd passes weapon_id correctly
# =====================================================================

func test_create_boomerang_default_weapon_id():
	# Default wpn_id parameter is "boomerang"
	var mock_controller := Node.new()
	add_child_autofree(mock_controller)
	var wf: RefCounted = load("res://scripts/weapons/weapon_fire.gd").new(mock_controller)
	var bm: Area2D = wf._create_boomerang(
		Vector2.ZERO, Vector2.RIGHT, 5.0, 2, 300.0, 200.0, 1.5,
		Color.RED, 6.0
	)
	assert_eq(bm.weapon_id, "boomerang", "Default weapon_id should be 'boomerang'")
	add_child_autofree(bm)


func test_create_boomerang_custom_weapon_id():
	# Passing evolved weapon_id explicitly
	var mock_controller := Node.new()
	add_child_autofree(mock_controller)
	var wf: RefCounted = load("res://scripts/weapons/weapon_fire.gd").new(mock_controller)
	var bm: Area2D = wf._create_boomerang(
		Vector2.ZERO, Vector2.RIGHT, 5.0, 2, 300.0, 200.0, 1.5,
		Color.RED, 6.0, "thunderang"
	)
	assert_eq(bm.weapon_id, "thunderang", "Custom weapon_id should be 'thunderang'")
	add_child_autofree(bm)


func test_create_boomerang_blazerang_weapon_id():
	var mock_controller := Node.new()
	add_child_autofree(mock_controller)
	var wf: RefCounted = load("res://scripts/weapons/weapon_fire.gd").new(mock_controller)
	var bm: Area2D = wf._create_boomerang(
		Vector2.ZERO, Vector2.UP, 8.0, 3, 350.0, 250.0, 1.8,
		Color.ORANGE, 10.0, "blazerang"
	)
	assert_eq(bm.weapon_id, "blazerang", "weapon_id should be 'blazerang'")
	add_child_autofree(bm)
