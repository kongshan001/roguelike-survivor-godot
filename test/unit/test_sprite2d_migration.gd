extends GutTest
## R29: Sprite2D migration validation tests
## Verifies that all scene Sprite nodes are Sprite2D type with centered=true,
## and that all required texture assets exist for player, enemies, and weapons.
## These tests guard against accidental regression from Sprite2D back to ColorRect.


# ============================================================
# 1-6: Scene Sprite node type checks (Sprite2D, not ColorRect)
# ============================================================

func test_player_sprite_is_sprite2d():
	var scene: PackedScene = load("res://scenes/player.tscn")
	var player: CharacterBody2D = scene.instantiate()
	add_child_autofree(player)
	var sprite: Node = player.get_node("Sprite")
	assert_true(sprite is Sprite2D, "player.tscn Sprite node must be Sprite2D, not ColorRect")


func test_enemy_sprite_is_sprite2d():
	var scene: PackedScene = load("res://scenes/enemy.tscn")
	var enemy: CharacterBody2D = scene.instantiate()
	# Enemy needs enemy_data to avoid null errors in _ready
	var data := EnemyData.new()
	data.enemy_id = "zombie"
	data.enemy_name = "Zombie"
	data.max_hp = 30.0
	data.speed = 50.0
	data.damage = 5.0
	data.xp_value = 5
	data.color = Color.GREEN
	data.size = 16.0
	data.drop_chance = 0.0
	enemy.enemy_data = data
	var arena := Node2D.new()
	arena.add_child(enemy)
	add_child_autofree(arena)
	var sprite: Node = enemy.get_node("Sprite")
	assert_true(sprite is Sprite2D, "enemy.tscn Sprite node must be Sprite2D, not ColorRect")


func test_projectile_sprite_is_sprite2d():
	var scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = scene.instantiate()
	add_child_autofree(proj)
	var sprite: Node = proj.get_node("Sprite")
	assert_true(sprite is Sprite2D, "projectile.tscn Sprite node must be Sprite2D, not ColorRect")


func test_xp_gem_sprite_is_sprite2d():
	var scene: PackedScene = load("res://scenes/xp_gem.tscn")
	var gem: Area2D = scene.instantiate()
	gem.xp_value = 5
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	var sprite: Node = gem.get_node("Sprite")
	assert_true(sprite is Sprite2D, "xp_gem.tscn Sprite node must be Sprite2D, not ColorRect")


func test_enemy_bullet_sprite_is_sprite2d():
	var scene: PackedScene = load("res://scenes/enemy_bullet.tscn")
	var bullet: Area2D = scene.instantiate()
	bullet.direction = Vector2.RIGHT
	bullet.speed = 200.0
	bullet.damage = 1.0
	bullet.color = Color.RED
	bullet.size = 4.0
	var arena := Node2D.new()
	arena.add_child(bullet)
	add_child_autofree(arena)
	var sprite: Node = bullet.get_node("Sprite")
	assert_true(sprite is Sprite2D, "enemy_bullet.tscn Sprite node must be Sprite2D, not ColorRect")


func test_item_crate_sprite_is_sprite2d():
	GameManager.reset()
	var scene: PackedScene = load("res://scenes/item_crate.tscn")
	var crate: Area2D = scene.instantiate()
	crate.crate_type = "heal"
	var arena := Node2D.new()
	arena.add_child(crate)
	add_child_autofree(arena)
	var sprite: Node = crate.get_node("Sprite")
	assert_true(sprite is Sprite2D, "item_crate.tscn Sprite node must be Sprite2D, not ColorRect")


# ============================================================
# 7: Sprite2D nodes have centered = true
# ============================================================

func test_player_sprite_centered():
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(player)
	var sprite: Sprite2D = player.get_node("Sprite") as Sprite2D
	assert_true(sprite.centered, "player.tscn Sprite must have centered = true")


func test_enemy_sprite_centered():
	var data := EnemyData.new()
	data.enemy_id = "zombie"
	data.enemy_name = "Zombie"
	data.max_hp = 30.0
	data.speed = 50.0
	data.damage = 5.0
	data.xp_value = 5
	data.color = Color.GREEN
	data.size = 16.0
	data.drop_chance = 0.0
	var enemy: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	enemy.enemy_data = data
	var arena := Node2D.new()
	arena.add_child(enemy)
	add_child_autofree(arena)
	var sprite: Sprite2D = enemy.get_node("Sprite") as Sprite2D
	assert_true(sprite.centered, "enemy.tscn Sprite must have centered = true")


func test_projectile_sprite_centered():
	var proj: Area2D = load("res://scenes/projectile.tscn").instantiate()
	add_child_autofree(proj)
	var sprite: Sprite2D = proj.get_node("Sprite") as Sprite2D
	assert_true(sprite.centered, "projectile.tscn Sprite must have centered = true")


func test_xp_gem_sprite_centered():
	var gem: Area2D = load("res://scenes/xp_gem.tscn").instantiate()
	gem.xp_value = 5
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	var sprite: Sprite2D = gem.get_node("Sprite") as Sprite2D
	assert_true(sprite.centered, "xp_gem.tscn Sprite must have centered = true")


func test_enemy_bullet_sprite_centered():
	var bullet: Area2D = load("res://scenes/enemy_bullet.tscn").instantiate()
	bullet.direction = Vector2.RIGHT
	bullet.speed = 200.0
	bullet.damage = 1.0
	bullet.color = Color.RED
	bullet.size = 4.0
	var arena := Node2D.new()
	arena.add_child(bullet)
	add_child_autofree(arena)
	var sprite: Sprite2D = bullet.get_node("Sprite") as Sprite2D
	assert_true(sprite.centered, "enemy_bullet.tscn Sprite must have centered = true")


func test_item_crate_sprite_centered():
	GameManager.reset()
	var crate: Area2D = load("res://scenes/item_crate.tscn").instantiate()
	crate.crate_type = "heal"
	var arena := Node2D.new()
	arena.add_child(crate)
	add_child_autofree(arena)
	var sprite: Sprite2D = crate.get_node("Sprite") as Sprite2D
	assert_true(sprite.centered, "item_crate.tscn Sprite must have centered = true")


# ============================================================
# 8: Player character texture files exist
# ============================================================

func test_player_texture_exists():
	# Verify at least the 3 core character textures exist
	var paths: Array = [
		"res://assets/sprites/characters/warrior.png",
		"res://assets/sprites/characters/mage.png",
		"res://assets/sprites/characters/ranger.png",
	]
	for path in paths:
		assert_true(ResourceLoader.exists(path),
			"Character texture must exist: %s" % path)


# ============================================================
# 9: Enemy sprite directory has zombie/bat/skeleton/boss
# ============================================================

func test_enemy_sprites_core_four_exist():
	var required: Array = [
		"res://assets/sprites/enemies/zombie.png",
		"res://assets/sprites/enemies/bat.png",
		"res://assets/sprites/enemies/skeleton.png",
		"res://assets/sprites/enemies/boss.png",
	]
	for path in required:
		assert_true(ResourceLoader.exists(path),
			"Required enemy sprite must exist: %s" % path)


# ============================================================
# 10: Weapon sprite directory has knife/holy_water/bible
# ============================================================

func test_weapon_sprites_core_exist():
	var required: Array = [
		"res://assets/sprites/weapons/knife.png",
		"res://assets/sprites/weapons/holy_water.png",
		"res://assets/sprites/weapons/bible.png",
	]
	for path in required:
		assert_true(ResourceLoader.exists(path),
			"Required weapon sprite must exist: %s" % path)


# ============================================================
# Additional: Scene file content validation (parse .tscn directly)
# These catch regressions where someone might revert Sprite2D back to ColorRect
# ============================================================

func test_player_tscn_contains_sprite2d():
	var file := FileAccess.open("res://scenes/player.tscn", FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	assert_true(content.find('type="Sprite2D"') != -1,
		"player.tscn must contain Sprite2D node declaration")
	assert_false(content.find('type="ColorRect"') != -1,
		"player.tscn must NOT contain ColorRect node declaration")


func test_enemy_tscn_contains_sprite2d():
	var file := FileAccess.open("res://scenes/enemy.tscn", FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	assert_true(content.find('type="Sprite2D"') != -1,
		"enemy.tscn must contain Sprite2D node declaration")
	assert_false(content.find('type="ColorRect"') != -1,
		"enemy.tscn must NOT contain ColorRect node declaration")


func test_projectile_tscn_contains_sprite2d():
	var file := FileAccess.open("res://scenes/projectile.tscn", FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	assert_true(content.find('type="Sprite2D"') != -1,
		"projectile.tscn must contain Sprite2D node declaration")
	assert_false(content.find('type="ColorRect"') != -1,
		"projectile.tscn must NOT contain ColorRect node declaration")


func test_xp_gem_tscn_contains_sprite2d():
	var file := FileAccess.open("res://scenes/xp_gem.tscn", FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	assert_true(content.find('type="Sprite2D"') != -1,
		"xp_gem.tscn must contain Sprite2D node declaration")
	assert_false(content.find('type="ColorRect"') != -1,
		"xp_gem.tscn must NOT contain ColorRect node declaration")


func test_enemy_bullet_tscn_contains_sprite2d():
	var file := FileAccess.open("res://scenes/enemy_bullet.tscn", FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	assert_true(content.find('type="Sprite2D"') != -1,
		"enemy_bullet.tscn must contain Sprite2D node declaration")
	assert_false(content.find('type="ColorRect"') != -1,
		"enemy_bullet.tscn must NOT contain ColorRect node declaration")


func test_item_crate_tscn_contains_sprite2d():
	var file := FileAccess.open("res://scenes/item_crate.tscn", FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	assert_true(content.find('type="Sprite2D"') != -1,
		"item_crate.tscn must contain Sprite2D node declaration")
	assert_false(content.find('type="ColorRect"') != -1,
		"item_crate.tscn must NOT contain ColorRect node declaration")
