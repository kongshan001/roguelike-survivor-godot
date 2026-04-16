extends "res://addons/gut/test.gd"
## Unit tests for Fire Slime enemy type
## Covers: EnemyData burn_aura fields, enemy burn aura behavior in _physics_process,
## normal combat (take_damage / die) still works for fire_slime
## Reference: docs/superpowers/specs/fire-slime-design.md


var _enemy: CharacterBody2D
var _player: CharacterBody2D
var _arena: Node2D


func before_each():
	GameManager.reset()
	GameManager.is_game_over = false
	GameManager.selected_difficulty = "normal"
	GameManager.selected_character = ""
	if SynergyManager:
		SynergyManager.active_synergies.clear()
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	UpgradePool.ensure_weapons_registered()

	# Build arena tree
	_arena = Node2D.new()
	_arena.name = "Arena"
	add_child_autofree(_arena)

	var pm = Node.new()
	pm.name = "ProjectileManager"
	_arena.add_child(pm)

	var pkm = Node.new()
	pkm.name = "PickupManager"
	_arena.add_child(pkm)

	# Create player
	_player = load("res://scenes/player.tscn").instantiate()
	_player.global_position = Vector2(400, 300)
	_player.add_to_group("players")
	_arena.add_child(_player)

	# Create fire slime enemy
	var fire_slime_data := _create_fire_slime_data()
	_enemy = _create_enemy(fire_slime_data)

	# SaveManager state isolation
	if SaveManager:
		SaveManager.shop_upgrades = {}

	await get_tree().process_frame


func after_each():
	await get_tree().process_frame


func _create_fire_slime_data() -> EnemyData:
	var data := EnemyData.new()
	data.enemy_id = "fire_slime"
	data.enemy_name = "Fire Slime"
	data.max_hp = 6.0
	data.speed = 30.0
	data.damage = 1.0
	data.xp_value = 4
	data.color = Color(0.9, 0.4, 0.1)
	data.size = 14.0
	data.drop_chance = 0.15
	data.has_burn_aura = true
	data.burn_aura_dps = 2.0
	data.burn_aura_duration = 1.5
	return data


func _create_enemy(data: EnemyData) -> CharacterBody2D:
	var enemy_scene := load("res://scenes/enemy.tscn") as PackedScene
	var enemy: CharacterBody2D = enemy_scene.instantiate()
	enemy.enemy_data = data
	enemy.global_position = Vector2(400, 300)
	_arena.add_child(enemy)
	return enemy


# =====================================================================
# 1. FIRE SLIME DATA EXISTS
# =====================================================================

func test_fire_slime_data_exists():
	# Verify EnemyData can represent fire_slime type
	var data := _create_fire_slime_data()
	assert_eq(data.enemy_id, "fire_slime", "enemy_id should be fire_slime")
	assert_eq(data.enemy_name, "Fire Slime", "enemy_name should be Fire Slime")


func test_fire_slime_data_values():
	# Verify fire slime stats match design spec
	var data := _create_fire_slime_data()
	assert_eq(data.max_hp, 6.0, "Fire Slime HP should be 6.0")
	assert_eq(data.speed, 30.0, "Fire Slime speed should be 30.0")
	assert_eq(data.damage, 1.0, "Fire Slime damage should be 1.0")
	assert_eq(data.xp_value, 4, "Fire Slime XP should be 4")
	assert_eq(data.size, 14.0, "Fire Slime size should be 14.0")


func test_fire_slime_sprite_exists():
	# Verify sprite asset file exists on disk (use FileAccess, not ResourceLoader,
	# since .import file may not exist until Godot reimports)
	assert_true(
		FileAccess.file_exists("res://assets/sprites/enemies/fire_slime.png"),
		"fire_slime.png sprite file should exist"
	)


# =====================================================================
# 2. BURN AURA DATA FIELDS
# =====================================================================

func test_fire_slime_has_burn_aura():
	# Verify burn_aura flag is set
	assert_true(_enemy.enemy_data.has_burn_aura, "Fire Slime should have burn_aura = true")


func test_fire_slime_burn_aura_dps():
	assert_eq(_enemy.enemy_data.burn_aura_dps, 2.0, "Burn aura DPS should be 2.0")


func test_fire_slime_burn_aura_duration():
	assert_eq(_enemy.enemy_data.burn_aura_duration, 1.5, "Burn aura duration should be 1.5s")


func test_default_enemy_no_burn_aura():
	# Verify default EnemyData does not have burn aura
	var data := EnemyData.new()
	assert_false(data.has_burn_aura, "Default enemy should not have burn aura")
	assert_eq(data.burn_aura_dps, 2.0, "Default burn_aura_dps should be 2.0")
	assert_eq(data.burn_aura_duration, 1.5, "Default burn_aura_duration should be 1.5")


# =====================================================================
# 3. FIRE SLIME BURN AURA BEHAVIOR
# =====================================================================

func test_fire_slime_burn_damage():
	# Fire Slime in range should apply burn to player
	# Place enemy close to player (within size + 16.0 = 14 + 16 = 30)
	_enemy.global_position = _player.global_position + Vector2(10, 0)

	# Check if player has apply_burn method (Programmer must add it)
	if not _player.has_method("apply_burn"):
		pending("Player does not have apply_burn method -- waiting for Programmer implementation")
		return

	# Simulate physics process to trigger burn aura check
	_enemy._physics_process(0.016)
	await get_tree().process_frame

	# Player should have burn applied
	assert_true(
		_player.get("_burn_timer") != null and _player.get("_burn_timer") > 0.0,
		"Player should have burn timer > 0 after Fire Slime proximity"
	)


func test_fire_slime_no_damage_outside_range():
	# Fire Slime outside range should NOT apply burn
	# Range is enemy_data.size + 16.0 = 14 + 16 = 30
	# Place enemy far from player
	_enemy.global_position = _player.global_position + Vector2(200, 0)

	# Check if player has apply_burn method
	if not _player.has_method("apply_burn"):
		pending("Player does not have apply_burn method -- waiting for Programmer implementation")
		return

	# Reset any burn state on player
	if _player.get("_burn_timer") != null:
		_player.set("_burn_timer", 0.0)
	if _player.get("_burn_dps") != null:
		_player.set("_burn_dps", 0.0)

	# Simulate physics process
	_enemy._physics_process(0.016)
	await get_tree().process_frame

	# Player should NOT have burn applied
	var burn_timer = _player.get("_burn_timer")
	assert_true(
		burn_timer == null or burn_timer == 0.0,
		"Player should NOT have burn when Fire Slime is far away"
	)


func test_fire_slime_burn_aura_boundary():
	# Test at exactly the boundary distance (size + 16.0 = 30.0)
	var boundary_dist: float = _enemy.enemy_data.size + 16.0
	_enemy.global_position = _player.global_position + Vector2(boundary_dist - 1.0, 0)

	if not _player.has_method("apply_burn"):
		pending("Player does not have apply_burn method -- waiting for Programmer implementation")
		return

	# Just inside boundary -- should burn
	_enemy._physics_process(0.016)
	var burn_timer_inside = _player.get("_burn_timer")
	assert_true(
		burn_timer_inside != null and burn_timer_inside > 0.0,
		"Player should burn when Fire Slime is just inside boundary"
	)


# =====================================================================
# 4. FIRE SLIME NORMAL COMBAT
# =====================================================================

func test_fire_slime_normal_combat():
	# Fire Slime can still be damaged normally
	_enemy.take_damage(3.0)
	assert_eq(_enemy.current_hp, _enemy.enemy_data.max_hp - 3.0, "Fire Slime should take normal damage")


func test_fire_slime_can_be_killed():
	# Fire Slime can be killed
	_enemy.take_damage(6.0)
	assert_false(_enemy.is_alive, "Fire Slime should die after taking 6 damage")
	assert_eq(GameManager.enemies_killed, 1, "Kill should be registered")


func test_fire_slime_killed_drops_xp():
	# Fire Slime should drop XP on death
	var pickup_mgr := _enemy.get_parent().get_node("PickupManager")
	var initial_children := pickup_mgr.get_child_count()
	_enemy.take_damage(6.0)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(
		pickup_mgr.get_child_count(),
		initial_children + 1,
		"Fire Slime should drop 1 XP gem on death"
	)


func test_fire_slime_kill_adds_gold():
	var gold_before := GameManager.gold
	_enemy.take_damage(6.0)
	assert_gt(GameManager.gold, gold_before, "Killing Fire Slime should add gold")


# =====================================================================
# 5. ENEMY SPAWNER TEMPLATE
# =====================================================================

func test_fire_slime_in_enemy_templates():
	# Access ENEMY_TEMPLATES directly from the spawner script
	var spawner_script: GDScript = load("res://scripts/enemy_spawner.gd")
	assert_true(
		spawner_script.ENEMY_TEMPLATES.has("fire_slime"),
		"ENEMY_TEMPLATES should contain fire_slime"
	)

	var template: Dictionary = spawner_script.ENEMY_TEMPLATES["fire_slime"]
	assert_eq(template.get("enemy_id", ""), "fire_slime", "Template enemy_id should be fire_slime")
	assert_eq(template.get("max_hp", 0.0), 6.0, "Template HP should be 6.0")
	assert_eq(template.get("speed", 0.0), 30.0, "Template speed should be 30.0")
	assert_eq(template.get("damage", 0.0), 1.0, "Template damage should be 1.0")
	assert_eq(template.get("xp_value", 0), 4, "Template XP should be 4")
	assert_eq(template.get("has_burn_aura", false), true, "Template should have burn_aura = true")
	assert_eq(template.get("burn_aura_dps", 0.0), 2.0, "Template burn_aura_dps should be 2.0")
	assert_eq(template.get("burn_aura_duration", 0.0), 1.5, "Template burn_aura_duration should be 1.5")


func test_fire_slime_create_enemy_data_passes_burn_fields():
	# Verify ENEMY_TEMPLATES has fire_slime with correct burn aura fields
	var spawner_script: GDScript = load("res://scripts/enemy_spawner.gd")
	if not spawner_script.ENEMY_TEMPLATES.has("fire_slime"):
		pending("fire_slime not in ENEMY_TEMPLATES")
		return

	var template: Dictionary = spawner_script.ENEMY_TEMPLATES["fire_slime"]
	assert_eq(template.get("has_burn_aura", false), true, "Template should have burn_aura")
	assert_eq(data.burn_aura_dps, 2.0, "_create_enemy_data should set burn_aura_dps")
	assert_eq(data.burn_aura_duration, 1.5, "_create_enemy_data should set burn_aura_duration")
