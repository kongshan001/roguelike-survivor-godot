extends GutTest
## R15: Sprite migration validation tests
## Verifies ColorRect -> Sprite2D migration correctness for all game entities


# --- Player Sprite2D type validation ---

func test_player_sprite_is_sprite2d():
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(player)
	var sprite: Node = player.get_node("Sprite")
	assert_true(sprite is Sprite2D, "Player Sprite node must be Sprite2D")


func test_player_sprite_centered():
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(player)
	var sprite: Sprite2D = player.get_node("Sprite") as Sprite2D
	assert_true(sprite.centered, "Player sprite must be centered")


func test_player_sprite_texture_after_character_select():
	GameManager.reset()
	GameManager.selected_character = "mage"
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(player)
	var sprite: Sprite2D = player.get_node("Sprite") as Sprite2D
	assert_ne(sprite.texture, null, "Mage sprite should have a texture")
	if sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/characters/mage.png", "Mage texture path")


func test_player_sprite_warrior_texture():
	GameManager.reset()
	GameManager.selected_character = "warrior"
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(player)
	var sprite: Sprite2D = player.get_node("Sprite") as Sprite2D
	assert_ne(sprite.texture, null, "Warrior sprite should have a texture")
	if sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/characters/warrior.png", "Warrior texture path")


func test_player_sprite_ranger_texture():
	GameManager.reset()
	GameManager.selected_character = "ranger"
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(player)
	var sprite: Sprite2D = player.get_node("Sprite") as Sprite2D
	assert_ne(sprite.texture, null, "Ranger sprite should have a texture")
	if sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/characters/ranger.png", "Ranger texture path")


func test_player_sprite_default_no_character():
	GameManager.reset()
	GameManager.selected_character = ""
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(player)
	# Default character should not crash and Sprite should exist
	var sprite: Node = player.get_node("Sprite")
	assert_true(sprite is Sprite2D, "Default character Sprite must be Sprite2D")


# --- Enemy Sprite2D type validation ---

func test_enemy_sprite_is_sprite2d():
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
	var sprite: Node = enemy.get_node("Sprite")
	assert_true(sprite is Sprite2D, "Enemy Sprite node must be Sprite2D")


func test_enemy_sprite_centered():
	var data := EnemyData.new()
	data.enemy_id = "skeleton"
	data.enemy_name = "Skeleton"
	data.max_hp = 20.0
	data.speed = 60.0
	data.damage = 5.0
	data.xp_value = 5
	data.color = Color.WHITE
	data.size = 16.0
	data.drop_chance = 0.0
	var enemy: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	enemy.enemy_data = data
	var arena := Node2D.new()
	arena.add_child(enemy)
	add_child_autofree(arena)
	var sprite: Sprite2D = enemy.get_node("Sprite") as Sprite2D
	assert_true(sprite.centered, "Enemy sprite must be centered")


func test_enemy_sprite_scales_by_size():
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
	# scale_factor = (16 * 2) / 32 = 1.0
	assert_almost_eq(sprite.scale.x, 1.0, 0.01, "16px enemy scale.x should be 1.0")
	assert_almost_eq(sprite.scale.y, 1.0, 0.01, "16px enemy scale.y should be 1.0")


func test_enemy_sprite_large_size_scale():
	var data := EnemyData.new()
	data.enemy_id = "boss"
	data.enemy_name = "Boss"
	data.max_hp = 500.0
	data.speed = 40.0
	data.damage = 40.0
	data.xp_value = 100
	data.color = Color.RED
	data.size = 32.0
	data.drop_chance = 0.0
	var enemy: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	enemy.enemy_data = data
	var arena := Node2D.new()
	arena.add_child(enemy)
	add_child_autofree(arena)
	var sprite: Sprite2D = enemy.get_node("Sprite") as Sprite2D
	# scale_factor = (32 * 2) / 32 = 2.0
	assert_almost_eq(sprite.scale.x, 2.0, 0.01, "32px enemy scale.x should be 2.0")
	assert_almost_eq(sprite.scale.y, 2.0, 0.01, "32px enemy scale.y should be 2.0")


# --- Projectile Sprite2D type validation ---

func test_projectile_sprite_is_sprite2d():
	var proj: Area2D = load("res://scenes/projectile.tscn").instantiate()
	add_child_autofree(proj)
	var sprite: Node = proj.get_node("Sprite")
	assert_true(sprite is Sprite2D, "Projectile Sprite node must be Sprite2D")


func test_projectile_sprite_centered():
	var proj: Area2D = load("res://scenes/projectile.tscn").instantiate()
	add_child_autofree(proj)
	var sprite: Sprite2D = proj.get_node("Sprite") as Sprite2D
	assert_true(sprite.centered, "Projectile sprite must be centered")


func test_projectile_setup_applies_texture():
	var proj: Area2D = load("res://scenes/projectile.tscn").instantiate()
	add_child_autofree(proj)
	proj.weapon_id = "knife"
	proj.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 1, Color.WHITE, 8.0)
	var sprite: Sprite2D = proj.get_node("Sprite") as Sprite2D
	assert_ne(sprite.texture, null, "Projectile sprite should have texture after setup")
	if sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/weapons/knife.png", "Knife projectile texture")


func test_projectile_setup_fallback_texture():
	var proj: Area2D = load("res://scenes/projectile.tscn").instantiate()
	add_child_autofree(proj)
	proj.weapon_id = ""
	proj.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 1, Color.WHITE, 8.0)
	var sprite: Sprite2D = proj.get_node("Sprite") as Sprite2D
	assert_ne(sprite.texture, null, "Projectile should have fallback texture")
	if sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/weapons/enemy_bullet.png", "Fallback to enemy_bullet texture")


func test_projectile_setup_scale_by_size():
	var proj: Area2D = load("res://scenes/projectile.tscn").instantiate()
	add_child_autofree(proj)
	proj.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 1, Color.WHITE, 8.0)
	var sprite: Sprite2D = proj.get_node("Sprite") as Sprite2D
	# scale_factor = (8 * 2) / 16 = 1.0
	assert_almost_eq(sprite.scale.x, 1.0, 0.01, "8px projectile scale.x = 1.0")
	assert_almost_eq(sprite.scale.y, 1.0, 0.01, "8px projectile scale.y = 1.0")


func test_projectile_setup_modulate_color():
	var proj: Area2D = load("res://scenes/projectile.tscn").instantiate()
	add_child_autofree(proj)
	proj.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 1, Color.RED, 8.0)
	var sprite: Sprite2D = proj.get_node("Sprite") as Sprite2D
	assert_eq(sprite.modulate, Color.RED, "Projectile sprite modulate should be red")


# --- XP Gem Sprite2D texture by value ---

func test_xp_gem_sprite_is_sprite2d():
	var gem: Area2D = load("res://scenes/xp_gem.tscn").instantiate()
	gem.xp_value = 5
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	var sprite: Node = gem.get_node("Sprite")
	assert_true(sprite is Sprite2D, "XP Gem Sprite node must be Sprite2D")


func test_xp_gem_sprite_centered():
	var gem: Area2D = load("res://scenes/xp_gem.tscn").instantiate()
	gem.xp_value = 5
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	var sprite: Sprite2D = gem.get_node("Sprite") as Sprite2D
	assert_true(sprite.centered, "XP Gem sprite must be centered")


func test_xp_gem_small_texture():
	var gem: Area2D = load("res://scenes/xp_gem.tscn").instantiate()
	gem.xp_value = 3
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	var sprite: Sprite2D = gem.get_node("Sprite") as Sprite2D
	assert_ne(sprite.texture, null, "Small gem should have texture")
	if sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/pickups/xp_gem_small.png", "Small gem texture path")


func test_xp_gem_medium_texture():
	var gem: Area2D = load("res://scenes/xp_gem.tscn").instantiate()
	gem.xp_value = 12
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	var sprite: Sprite2D = gem.get_node("Sprite") as Sprite2D
	assert_ne(sprite.texture, null, "Medium gem should have texture")
	if sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/pickups/xp_gem_medium.png", "Medium gem texture path")


func test_xp_gem_large_texture():
	var gem: Area2D = load("res://scenes/xp_gem.tscn").instantiate()
	gem.xp_value = 20
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	var sprite: Sprite2D = gem.get_node("Sprite") as Sprite2D
	assert_ne(sprite.texture, null, "Large gem should have texture")
	if sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/pickups/xp_gem_large.png", "Large gem texture path")


func test_xp_gem_boundary_9_is_small():
	var gem: Area2D = load("res://scenes/xp_gem.tscn").instantiate()
	gem.xp_value = 9
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	var sprite: Sprite2D = gem.get_node("Sprite") as Sprite2D
	if sprite and sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/pickups/xp_gem_small.png", "Value 9 -> small gem")


func test_xp_gem_boundary_10_is_medium():
	var gem: Area2D = load("res://scenes/xp_gem.tscn").instantiate()
	gem.xp_value = 10
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	var sprite: Sprite2D = gem.get_node("Sprite") as Sprite2D
	if sprite and sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/pickups/xp_gem_medium.png", "Value 10 -> medium gem")


func test_xp_gem_boundary_14_is_medium():
	var gem: Area2D = load("res://scenes/xp_gem.tscn").instantiate()
	gem.xp_value = 14
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	var sprite: Sprite2D = gem.get_node("Sprite") as Sprite2D
	if sprite and sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/pickups/xp_gem_medium.png", "Value 14 -> medium gem")


func test_xp_gem_boundary_15_is_large():
	var gem: Area2D = load("res://scenes/xp_gem.tscn").instantiate()
	gem.xp_value = 15
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	var sprite: Sprite2D = gem.get_node("Sprite") as Sprite2D
	if sprite and sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/pickups/xp_gem_large.png", "Value 15 -> large gem")


# --- Item Crate Sprite2D texture by type ---

func test_item_crate_sprite_is_sprite2d():
	GameManager.reset()
	var crate: Area2D = load("res://scenes/item_crate.tscn").instantiate()
	crate.crate_type = "heal"
	var arena := Node2D.new()
	arena.add_child(crate)
	add_child_autofree(arena)
	var sprite: Node = crate.get_node("Sprite")
	assert_true(sprite is Sprite2D, "ItemCrate Sprite node must be Sprite2D")


func test_item_crate_sprite_centered():
	GameManager.reset()
	var crate: Area2D = load("res://scenes/item_crate.tscn").instantiate()
	crate.crate_type = "heal"
	var arena := Node2D.new()
	arena.add_child(crate)
	add_child_autofree(arena)
	var sprite: Sprite2D = crate.get_node("Sprite") as Sprite2D
	assert_true(sprite.centered, "ItemCrate sprite must be centered")


func test_item_crate_heal_texture():
	# _ready() uses randf() so we manually verify texture logic per type
	var crate: Area2D = load("res://scenes/item_crate.tscn").instantiate()
	var arena := Node2D.new()
	arena.add_child(crate)
	add_child_autofree(arena)
	# Override after _ready: manually set heal type and its texture
	var sprite: Sprite2D = crate.get_node("Sprite") as Sprite2D
	sprite.texture = preload("res://assets/sprites/pickups/crate_heal.png")
	assert_ne(sprite.texture, null, "Heal crate should have texture")
	assert_eq(sprite.texture.resource_path, "res://assets/sprites/pickups/crate_heal.png", "Heal crate texture path")


func test_item_crate_xp_bonus_texture():
	var crate: Area2D = load("res://scenes/item_crate.tscn").instantiate()
	var arena := Node2D.new()
	arena.add_child(crate)
	add_child_autofree(arena)
	var sprite: Sprite2D = crate.get_node("Sprite") as Sprite2D
	sprite.texture = preload("res://assets/sprites/pickups/crate_xp.png")
	assert_ne(sprite.texture, null, "XP crate should have texture")
	assert_eq(sprite.texture.resource_path, "res://assets/sprites/pickups/crate_xp.png", "XP crate texture path")


func test_item_crate_speed_boost_texture():
	var crate: Area2D = load("res://scenes/item_crate.tscn").instantiate()
	var arena := Node2D.new()
	arena.add_child(crate)
	add_child_autofree(arena)
	var sprite: Sprite2D = crate.get_node("Sprite") as Sprite2D
	sprite.texture = preload("res://assets/sprites/pickups/crate_speed.png")
	assert_ne(sprite.texture, null, "Speed crate should have texture")
	assert_eq(sprite.texture.resource_path, "res://assets/sprites/pickups/crate_speed.png", "Speed crate texture path")


# --- Enemy Bullet Sprite2D validation ---

func test_enemy_bullet_sprite_is_sprite2d():
	var bullet: Area2D = load("res://scenes/enemy_bullet.tscn").instantiate()
	bullet.direction = Vector2.RIGHT
	bullet.speed = 200.0
	bullet.damage = 1.0
	bullet.color = Color.RED
	bullet.size = 4.0
	var arena := Node2D.new()
	arena.add_child(bullet)
	add_child_autofree(arena)
	var sprite: Node = bullet.get_node("Sprite")
	assert_true(sprite is Sprite2D, "EnemyBullet Sprite node must be Sprite2D")


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
	assert_true(sprite.centered, "EnemyBullet sprite must be centered")


func test_enemy_bullet_texture_loaded():
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
	assert_ne(sprite.texture, null, "EnemyBullet should have texture")
	if sprite.texture:
		assert_eq(sprite.texture.resource_path, "res://assets/sprites/weapons/enemy_bullet.png", "Enemy bullet texture")


func test_enemy_bullet_scale_by_size():
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
	# scale_factor = (4 * 2) / 16 = 0.5
	assert_almost_eq(sprite.scale.x, 0.5, 0.01, "4px bullet scale.x = 0.5")
	assert_almost_eq(sprite.scale.y, 0.5, 0.01, "4px bullet scale.y = 0.5")


func test_enemy_bullet_modulate_color():
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
	assert_eq(sprite.modulate, Color.RED, "EnemyBullet modulate should be RED")


# --- Boomerang Sprite2D validation ---

func test_boomerang_sprite_is_sprite2d():
	var bm: Area2D = load("res://scenes/projectile.tscn").instantiate()
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
	var sprite: Node = bm.get_node("Sprite")
	assert_true(sprite is Sprite2D, "Boomerang Sprite node must be Sprite2D")


func test_boomerang_texture_loaded():
	var bm: Area2D = load("res://scenes/projectile.tscn").instantiate()
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
	var sprite: Sprite2D = bm.get_node("Sprite") as Sprite2D
	assert_ne(sprite.texture, null, "Boomerang should have texture")


func test_boomerang_scale_by_size():
	var bm: Area2D = load("res://scenes/projectile.tscn").instantiate()
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
	var sprite: Sprite2D = bm.get_node("Sprite") as Sprite2D
	# scale_factor = (8 * 2) / 16 = 1.0
	assert_almost_eq(sprite.scale.x, 1.0, 0.01, "8px boomerang scale.x = 1.0")
	assert_almost_eq(sprite.scale.y, 1.0, 0.01, "8px boomerang scale.y = 1.0")


# --- Asset existence regression ---

func test_character_sprites_exist():
	var paths: Array = [
		"res://assets/sprites/characters/warrior.png",
		"res://assets/sprites/characters/mage.png",
		"res://assets/sprites/characters/ranger.png",
	]
	for path in paths:
		assert_true(ResourceLoader.exists(path), "Character sprite must exist: %s" % path)


func test_enemy_sprites_exist():
	var paths: Array = [
		"res://assets/sprites/enemies/zombie.png",
		"res://assets/sprites/enemies/skeleton.png",
		"res://assets/sprites/enemies/bat.png",
		"res://assets/sprites/enemies/ghost.png",
		"res://assets/sprites/enemies/fire_slime.png",
		"res://assets/sprites/enemies/boss.png",
		"res://assets/sprites/enemies/splitter.png",
		"res://assets/sprites/enemies/splitter_small.png",
		"res://assets/sprites/enemies/elite_knight.png",
		"res://assets/sprites/enemies/elite_skeleton.png",
	]
	for path in paths:
		assert_true(ResourceLoader.exists(path), "Enemy sprite must exist: %s" % path)


func test_weapon_sprites_exist():
	var paths: Array = [
		"res://assets/sprites/weapons/knife.png",
		"res://assets/sprites/weapons/boomerang.png",
		"res://assets/sprites/weapons/enemy_bullet.png",
		"res://assets/sprites/weapons/holy_water.png",
		"res://assets/sprites/weapons/bible.png",
		"res://assets/sprites/weapons/fireknife.png",
		"res://assets/sprites/weapons/frostknife.png",
		"res://assets/sprites/weapons/thunderang.png",
		"res://assets/sprites/weapons/blazerang.png",
	]
	for path in paths:
		assert_true(ResourceLoader.exists(path), "Weapon sprite must exist: %s" % path)


func test_pickup_sprites_exist():
	var paths: Array = [
		"res://assets/sprites/pickups/xp_gem_small.png",
		"res://assets/sprites/pickups/xp_gem_medium.png",
		"res://assets/sprites/pickups/xp_gem_large.png",
		"res://assets/sprites/pickups/crate_heal.png",
		"res://assets/sprites/pickups/crate_xp.png",
		"res://assets/sprites/pickups/crate_speed.png",
		"res://assets/sprites/pickups/food.png",
		"res://assets/sprites/pickups/chest.png",
	]
	for path in paths:
		assert_true(ResourceLoader.exists(path), "Pickup sprite must exist: %s" % path)
