extends GutTest
## R30 Task 1: elite_knight registration tests
## Verifies: ENEMY_TEMPLATES entry, sprite file, stat values, wave appearance, scene instantiation.
## If Programmer has not yet registered elite_knight, tests use pending() to mark the gap.


var _spawner: Node


func before_each():
	GameManager.reset()
	GameManager.selected_difficulty = "normal"
	_spawner = Node.new()
	_spawner.set_script(load("res://scripts/enemy_spawner.gd"))
	add_child_autofree(_spawner)


# =====================================================================
# 1. elite_knight exists in ENEMY_TEMPLATES
# =====================================================================

func test_elite_knight_in_enemy_templates():
	if not _spawner.ENEMY_TEMPLATES.has("elite_knight"):
		pending("elite_knight not yet registered in ENEMY_TEMPLATES -- waiting for Programmer")
		return
	var template: Dictionary = _spawner.ENEMY_TEMPLATES["elite_knight"]
	assert_eq(template.get("enemy_id", ""), "elite_knight",
		"elite_knight template should have correct enemy_id")


func test_elite_knight_template_count():
	# Once elite_knight is added, total templates should be 8
	if not _spawner.ENEMY_TEMPLATES.has("elite_knight"):
		pending("elite_knight not yet registered -- waiting for Programmer")
		return
	assert_eq(_spawner.ENEMY_TEMPLATES.size(), 8,
		"ENEMY_TEMPLATES should have 8 types after elite_knight is added")


# =====================================================================
# 2. elite_knight sprite file exists
# =====================================================================

func test_elite_knight_sprite_exists():
	assert_true(
		ResourceLoader.exists("res://assets/sprites/enemies/elite_knight.png"),
		"elite_knight.png sprite file should exist"
	)


# =====================================================================
# 3. elite_knight has reasonable HP / speed / damage values
# =====================================================================

func test_elite_knight_hp_reasonable():
	if not _spawner.ENEMY_TEMPLATES.has("elite_knight"):
		pending("elite_knight not yet registered -- waiting for Programmer")
		return
	var t: Dictionary = _spawner.ENEMY_TEMPLATES["elite_knight"]
	var hp: float = t.get("max_hp", 0.0)
	assert_gt(hp, 0.0, "elite_knight HP should be > 0")
	assert_lte(hp, 100.0, "elite_knight HP should be <= 100 (non-boss enemy)")


func test_elite_knight_speed_reasonable():
	if not _spawner.ENEMY_TEMPLATES.has("elite_knight"):
		pending("elite_knight not yet registered -- waiting for Programmer")
		return
	var t: Dictionary = _spawner.ENEMY_TEMPLATES["elite_knight"]
	var speed: float = t.get("speed", 0.0)
	assert_gt(speed, 0.0, "elite_knight speed should be > 0")
	assert_lte(speed, 150.0, "elite_knight speed should be <= 150")


func test_elite_knight_damage_reasonable():
	if not _spawner.ENEMY_TEMPLATES.has("elite_knight"):
		pending("elite_knight not yet registered -- waiting for Programmer")
		return
	var t: Dictionary = _spawner.ENEMY_TEMPLATES["elite_knight"]
	var damage: float = t.get("damage", 0.0)
	assert_gt(damage, 0.0, "elite_knight damage should be > 0")
	assert_lte(damage, 10.0, "elite_knight damage should be <= 10")


func test_elite_knight_is_elite():
	if not _spawner.ENEMY_TEMPLATES.has("elite_knight"):
		pending("elite_knight not yet registered -- waiting for Programmer")
		return
	var t: Dictionary = _spawner.ENEMY_TEMPLATES["elite_knight"]
	assert_true(t.get("is_elite", false),
		"elite_knight should have is_elite = true")


func test_elite_knight_is_ranged():
	if not _spawner.ENEMY_TEMPLATES.has("elite_knight"):
		pending("elite_knight not yet registered -- waiting for Programmer")
		return
	var t: Dictionary = _spawner.ENEMY_TEMPLATES["elite_knight"]
	assert_true(t.get("is_ranged", false),
		"elite_knight should be ranged (like elite_skeleton)")


# =====================================================================
# 4. elite_knight appears in at least one wave enemy list
# =====================================================================

func test_elite_knight_in_wave_4_or_later():
	if not _spawner.ENEMY_TEMPLATES.has("elite_knight"):
		pending("elite_knight not yet registered -- waiting for Programmer")
		return
	var found: bool = false
	for i in range(GameManager.WAVE_DEFS.size()):
		var enemies: Array = GameManager.WAVE_DEFS[i].get("enemies", [])
		if "elite_knight" in enemies:
			found = true
			assert_gte(i, 2,
				"elite_knight should only appear in wave 3 or later (index >= 2)")
	assert_true(found,
		"elite_knight should appear in at least one wave definition")


# =====================================================================
# 5. elite_knight scene instantiation does not crash
# =====================================================================

func test_elite_knight_instantiate_no_crash():
	if not _spawner.ENEMY_TEMPLATES.has("elite_knight"):
		pending("elite_knight not yet registered -- waiting for Programmer")
		return
	var template: Dictionary = _spawner.ENEMY_TEMPLATES["elite_knight"]
	var data: EnemyData = _spawner._create_enemy_data("elite_knight")
	assert_eq(data.enemy_id, "elite_knight",
		"_create_enemy_data should produce elite_knight data")
	assert_gt(data.max_hp, 0.0, "Created data should have HP > 0")


func test_elite_knight_enemy_instance():
	if not _spawner.ENEMY_TEMPLATES.has("elite_knight"):
		pending("elite_knight not yet registered -- waiting for Programmer")
		return

	var arena := Node2D.new()
	arena.name = "Arena"
	add_child_autofree(arena)

	var pm := Node.new()
	pm.name = "PickupManager"
	arena.add_child(pm)

	# Create a player for enemy target finding
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.name = "Player"
	player.add_to_group("players")
	arena.add_child(player)

	var data: EnemyData = _spawner._create_enemy_data("elite_knight")
	data.drop_chance = 0.0
	var enemy: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	enemy.enemy_data = data
	enemy.global_position = Vector2(500, 300)
	arena.add_child(enemy)

	assert_true(is_instance_valid(enemy), "elite_knight enemy should instantiate without crash")
	assert_eq(enemy.enemy_data.enemy_id, "elite_knight", "Enemy data ID should be elite_knight")
