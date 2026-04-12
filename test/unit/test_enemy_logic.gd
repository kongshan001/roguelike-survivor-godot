extends GutTest

# Test Enemy logic: damage, death, drops, status effects
# Instantiates enemy scene to test full behavior

var _enemy: CharacterBody2D


func before_each():
	GameManager.reset()
	var enemy_scene = load("res://scenes/enemy.tscn")
	_enemy = enemy_scene.instantiate()

	# Set up enemy data
	var data = EnemyData.new()
	data.enemy_name = "TestEnemy"
	data.max_hp = 50.0
	data.speed = 60.0
	data.damage = 10.0
	data.xp_value = 10
	data.color = Color.GREEN
	data.size = 16.0
	data.drop_chance = 0.0
	_enemy.enemy_data = data

	var arena = Node2D.new()
	var pickup_mgr = Node2D.new()
	pickup_mgr.name = "PickupManager"
	pickup_mgr.set_script(load("res://scripts/pickup_manager.gd"))
	arena.add_child(pickup_mgr)
	arena.add_child(_enemy)
	add_child_autofree(arena)


# --- Health and Damage ---

func test_initial_hp():
	assert_eq(_enemy.current_hp, 50.0, "HP should equal max_hp at time 0")


func test_take_damage():
	_enemy.take_damage(20.0)
	assert_eq(_enemy.current_hp, 30.0, "HP should be 30 after 20 damage")


func test_take_damage_lethal():
	_enemy.take_damage(50.0)
	assert_eq(_enemy.current_hp, 0.0)
	assert_false(_enemy.is_alive, "Enemy should be dead")


func test_take_damage_when_dead():
	_enemy.take_damage(50.0)
	assert_false(_enemy.is_alive)
	_enemy.take_damage(30.0)
	assert_eq(_enemy.current_hp, 0.0)


func test_is_alive_initially_true():
	assert_true(_enemy.is_alive, "Enemy should start alive")


# --- Death and Scoring ---

func test_die_increments_kills():
	_enemy.take_damage(50.0)
	assert_eq(GameManager.enemies_killed, 1, "Should increment kill count")


func test_die_increments_score():
	_enemy.take_damage(50.0)
	assert_eq(GameManager.score, 10, "Score should equal xp_value")


func test_die_adds_gold():
	_enemy.take_damage(50.0)
	assert_eq(GameManager.gold, 3, "Should add 3 gold on kill")


func test_die_decrements_enemy_count():
	GameManager.enemy_count = 5
	_enemy.take_damage(50.0)
	assert_eq(GameManager.enemy_count, 4, "Should decrement enemy count")


func test_die_drops_xp_gem():
	var pickup_mgr = _enemy.get_parent().get_node("PickupManager")
	var initial_children = pickup_mgr.get_child_count()
	_enemy.take_damage(50.0)
	assert_eq(pickup_mgr.get_child_count(), initial_children + 1, "Should spawn 1 XP gem")


# --- HP Scaling with Time ---

func test_time_scaled_hp():
	GameManager.elapsed_time = 60.0
	var enemy2_scene = load("res://scenes/enemy.tscn")
	var enemy2 = enemy2_scene.instantiate()
	var data = EnemyData.new()
	data.max_hp = 50.0
	data.speed = 60.0
	data.damage = 10.0
	data.xp_value = 5
	data.color = Color.GREEN
	data.size = 16.0
	enemy2.enemy_data = data

	var arena2 = Node2D.new()
	var pm = Node2D.new()
	pm.name = "PickupManager"
	pm.set_script(load("res://scripts/pickup_manager.gd"))
	arena2.add_child(pm)
	arena2.add_child(enemy2)
	add_child_autofree(arena2)

	# time_bonus = 1.0 + (60/60) * 0.1 = 1.1, hp = 50 * 1.1 = 55.0
	assert_almost_eq(enemy2.current_hp, 55.0, 0.1, "HP should scale with elapsed time")


# --- Boss Extra Drops ---

func test_boss_drops_multiple_xp_gems():
	var boss_data = EnemyData.new()
	boss_data.max_hp = 500.0
	boss_data.speed = 40.0
	boss_data.damage = 40.0
	boss_data.xp_value = 100
	boss_data.color = Color.RED
	boss_data.size = 32.0
	boss_data.is_boss = true
	boss_data.drop_chance = 0.0
	_enemy.enemy_data = boss_data
	_enemy.current_hp = 500.0

	var pickup_mgr = _enemy.get_parent().get_node("PickupManager")
	_enemy.take_damage(500.0)
	assert_eq(pickup_mgr.get_child_count(), 6, "Boss should drop 6 XP gems")
	assert_true(GameManager.boss_killed, "Boss killed should be true")
	assert_eq(GameManager.boss_kill_count, 1, "Boss kill count should be 1")


# --- Status Effects ---

func test_apply_burn():
	_enemy.apply_burn(5.0, 2.0)
	assert_eq(_enemy._burn_dps, 5.0, "Burn DPS should be set")
	assert_eq(_enemy._burn_timer, 2.0, "Burn timer should be set")


func test_apply_slow():
	_enemy.apply_slow(0.5)
	assert_eq(_enemy._slow_pct, 0.5, "Slow percentage should be set")
	assert_eq(_enemy._slow_timer, 1.0, "Slow timer should be 1s")


func test_apply_freeze():
	_enemy.apply_freeze(0.5)
	assert_eq(_enemy._freeze_timer, 0.5, "Freeze timer should be set")


func test_burn_does_not_overwrite_stronger():
	_enemy.apply_burn(5.0, 2.0)
	_enemy.apply_burn(3.0, 1.0)  # Weaker burn
	assert_eq(_enemy._burn_dps, 5.0, "Should keep stronger burn")
	assert_eq(_enemy._burn_timer, 2.0, "Should keep longer burn timer")
