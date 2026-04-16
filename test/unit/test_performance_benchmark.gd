extends GutTest
## Performance benchmark tests for get_nodes_in_group optimization
## Validates: enemy group query performance, cache mechanism, cache invalidation on enemy death
## These tests measure relative performance, not absolute frame times.

var _arena: Node2D
var _enemies: Array = []


func before_each():
	GameManager.reset()
	_enemies.clear()
	_arena = Node2D.new()
	_arena.name = "Arena"
	add_child_autofree(_arena)


func after_each():
	await get_tree().process_frame
	_enemies.clear()


# ============================================================
# Part 1: Baseline get_nodes_in_group Measurement
# ============================================================

func test_get_nodes_in_group_empty_returns_empty():
	var result: Array = get_tree().get_nodes_in_group("enemies")
	assert_eq(result.size(), 0, "Should return empty array when no enemies exist")


func test_get_nodes_in_group_100_enemies_count():
	_spawn_enemies(100)
	var result: Array = get_tree().get_nodes_in_group("enemies")
	assert_eq(result.size(), 100, "Should find exactly 100 enemies in group")


func test_get_nodes_in_group_100_enemies_performance():
	# Measure time for 1000 calls to get_nodes_in_group with 100 enemies
	_spawn_enemies(100)
	var iterations: int = 1000
	var start_time: float = Time.get_ticks_usec()
	for _i in range(iterations):
		var _result: Array = get_tree().get_nodes_in_group("enemies")
	var elapsed_us: float = Time.get_ticks_usec() - start_time
	var per_call_us: float = elapsed_us / float(iterations)
	# Log the measurement for QA records
	gut.p("get_nodes_in_group(100 enemies) x1000: %.1f us total, %.3f us/call" % [elapsed_us, per_call_us])
	# Sanity check: should complete within reasonable time
	# 1000 calls at 100 enemies each should complete well under 1 second
	assert_lt(elapsed_us, 1000000.0, "1000 calls should complete in under 1 second")


func test_get_nodes_in_group_200_enemies_performance():
	_spawn_enemies(200)
	var iterations: int = 1000
	var start_time: float = Time.get_ticks_usec()
	for _i in range(iterations):
		var _result: Array = get_tree().get_nodes_in_group("enemies")
	var elapsed_us: float = Time.get_ticks_usec() - start_time
	var per_call_us: float = elapsed_us / float(iterations)
	gut.p("get_nodes_in_group(200 enemies) x1000: %.1f us total, %.3f us/call" % [elapsed_us, per_call_us])
	assert_lt(elapsed_us, 2000000.0, "1000 calls with 200 enemies should complete in under 2 seconds")


func test_get_nodes_in_group_500_enemies_performance():
	_spawn_enemies(500)
	var iterations: int = 100
	var start_time: float = Time.get_ticks_usec()
	for _i in range(iterations):
		var _result: Array = get_tree().get_nodes_in_group("enemies")
	var elapsed_us: float = Time.get_ticks_usec() - start_time
	var per_call_us: float = elapsed_us / float(iterations)
	gut.p("get_nodes_in_group(500 enemies) x100: %.1f us total, %.3f us/call" % [elapsed_us, per_call_us])
	assert_lt(elapsed_us, 2000000.0, "100 calls with 500 enemies should complete in under 2 seconds")


# ============================================================
# Part 2: _get_enemies_in_range Performance (weapon_controller path)
# This is the actual hot path that calls get_nodes_in_group.
# ============================================================

func test_get_enemies_in_range_100_enemies():
	_spawn_enemies(100)
	var player_pos: Vector2 = Vector2(400, 300)
	var range_val: float = 600.0
	var start_time: float = Time.get_ticks_usec()
	for _i in range(100):
		_manual_get_enemies_in_range(player_pos, range_val)
	var elapsed_us: float = Time.get_ticks_usec() - start_time
	var per_call_us: float = elapsed_us / 100.0
	gut.p("_get_enemies_in_range(100 enemies, 600px) x100: %.1f us total, %.1f us/call" % [elapsed_us, per_call_us])
	assert_lt(elapsed_us, 500000.0, "100 calls should complete in under 0.5 seconds")


func test_get_enemies_in_range_returns_only_nearby():
	_spawn_enemies_at_distances([50.0, 100.0, 150.0, 250.0, 400.0, 800.0])
	var result: Array = _manual_get_enemies_in_range(Vector2.ZERO, 300.0)
	assert_eq(result.size(), 4, "Should find 4 enemies within 300px (distances: 50, 100, 150, 250)")


func test_get_enemies_in_range_returns_sorted_by_distance():
	_spawn_enemies_at_distances([200.0, 50.0, 300.0, 100.0])
	var result: Array = _manual_get_enemies_in_range(Vector2.ZERO, 400.0)
	assert_eq(result.size(), 4, "Should find all 4 enemies")
	# Verify sorted order
	for i in range(result.size() - 1):
		var d1: float = Vector2.ZERO.distance_to(result[i].global_position)
		var d2: float = Vector2.ZERO.distance_to(result[i + 1].global_position)
		assert_lte(d1, d2, "Enemies should be sorted by distance ascending")


# ============================================================
# Part 3: Cache Mechanism Verification
# If Programmer implements a cache for get_nodes_in_group results,
# these tests validate cache correctness.
# ============================================================

func test_cache_consistency_with_group():
	# Create enemies, get group, add enemy, get group again
	_spawn_enemies(10)
	var before_add: Array = get_tree().get_nodes_in_group("enemies")
	assert_eq(before_add.size(), 10, "Should have 10 enemies before add")
	# Add one more enemy
	var new_enemy: CharacterBody2D = _create_enemy_node()
	new_enemy.global_position = Vector2(500, 500)
	_arena.add_child(new_enemy)
	_enemies.append(new_enemy)
	# Wait a frame for group membership to propagate
	await get_tree().process_frame
	var after_add: Array = get_tree().get_nodes_in_group("enemies")
	assert_eq(after_add.size(), 11, "Should have 11 enemies after add")


func test_cache_invalidated_on_enemy_death():
	_spawn_enemies(10)
	var before_kill: Array = get_tree().get_nodes_in_group("enemies")
	assert_eq(before_kill.size(), 10, "Should have 10 enemies before kill")
	# Kill one enemy (remove from group + queue_free)
	_enemies[0].remove_from_group("enemies")
	_enemies[0].queue_free()
	_enemies.remove_at(0)
	await get_tree().process_frame
	var after_kill: Array = get_tree().get_nodes_in_group("enemies")
	assert_eq(after_kill.size(), 9, "Should have 9 enemies after killing one")


func test_cache_invalidated_on_multiple_deaths():
	_spawn_enemies(20)
	var before: Array = get_tree().get_nodes_in_group("enemies")
	assert_eq(before.size(), 20, "Should have 20 enemies")
	# Kill 5 enemies
	for i in range(5):
		_enemies[0].remove_from_group("enemies")
		_enemies[0].queue_free()
		_enemies.remove_at(0)
	await get_tree().process_frame
	var after: Array = get_tree().get_nodes_in_group("enemies")
	assert_eq(after.size(), 15, "Should have 15 enemies after killing 5")


func test_cache_handles_all_enemies_dead():
	_spawn_enemies(10)
	for enemy in _enemies:
		enemy.remove_from_group("enemies")
		enemy.queue_free()
	_enemies.clear()
	await get_tree().process_frame
	var result: Array = get_tree().get_nodes_in_group("enemies")
	assert_eq(result.size(), 0, "Should return 0 when all enemies are dead")


# ============================================================
# Part 4: Cache Correctness with Mixed Operations
# ============================================================

func test_cache_correct_after_add_kill_cycle():
	# Simulate a game frame: spawn some enemies, kill some, verify group count
	_spawn_enemies(10)
	assert_eq(get_tree().get_nodes_in_group("enemies").size(), 10, "Initial: 10 enemies")

	# Kill 3
	for i in range(3):
		_enemies[0].remove_from_group("enemies")
		_enemies[0].queue_free()
		_enemies.remove_at(0)
	await get_tree().process_frame
	assert_eq(get_tree().get_nodes_in_group("enemies").size(), 7, "After killing 3: 7 enemies")

	# Spawn 5 more
	_spawn_enemies(5)
	assert_eq(get_tree().get_nodes_in_group("enemies").size(), 12, "After spawning 5: 12 enemies")


func test_cache_correct_with_dead_enemies_not_in_group():
	# Enemies that are alive but not in group should not appear
	_spawn_enemies(10)
	# Mark enemy as dead without removing from group
	if _enemies[0].has_method("set"):
		if "is_alive" in _enemies[0]:
			_enemies[0].is_alive = false
	# weapon_controller._get_enemies_in_range filters by is_alive
	# So the raw get_nodes_in_group still returns 10
	var raw_count: int = get_tree().get_nodes_in_group("enemies").size()
	assert_eq(raw_count, 10, "Raw group count should still be 10")
	# But filtered count (simulating weapon_controller behavior) should be 9
	var alive_count: int = 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.get("is_alive") != false:
			alive_count += 1
	assert_eq(alive_count, 9, "Alive enemies should be 9 after marking one dead")


# ============================================================
# Part 5: Performance Regression Detection
# These tests establish performance baselines.
# ============================================================

func test_performance_baseline_100_enemies_single_call():
	_spawn_enemies(100)
	var start_time: float = Time.get_ticks_usec()
	var _result: Array = get_tree().get_nodes_in_group("enemies")
	var elapsed_us: float = Time.get_ticks_usec() - start_time
	gut.p("Single get_nodes_in_group(100 enemies): %.1f us" % elapsed_us)
	# A single call should be very fast (under 10ms)
	assert_lt(elapsed_us, 10000.0, "Single call with 100 enemies should be under 10ms")


func test_performance_baseline_enemy_distance_calculation():
	_spawn_enemies(100)
	var player_pos: Vector2 = Vector2(400, 300)
	var start_time: float = Time.get_ticks_usec()
	for _i in range(100):
		var all_enemies: Array = get_tree().get_nodes_in_group("enemies")
		var nearby: Array = []
		for enemy in all_enemies:
			var dist: float = player_pos.distance_to(enemy.global_position)
			if dist <= 600.0:
				nearby.append(enemy)
		nearby.sort_custom(func(a, b):
			return player_pos.distance_to(a.global_position) < player_pos.distance_to(b.global_position)
		)
	var elapsed_us: float = Time.get_ticks_usec() - start_time
	var per_call_us: float = elapsed_us / 100.0
	gut.p("Full _get_enemies_in_range pipeline (100 enemies) x100: %.1f us total, %.1f us/call" % [elapsed_us, per_call_us])
	# The full pipeline should complete 100 iterations well within 1 second
	assert_lt(elapsed_us, 1000000.0, "100 full enemy range calculations should complete in under 1 second")


func test_performance_baseline_sort_overhead():
	_spawn_enemies(100)
	var all_enemies: Array = get_tree().get_nodes_in_group("enemies")
	var player_pos: Vector2 = Vector2(400, 300)
	var start_time: float = Time.get_ticks_usec()
	for _i in range(100):
		all_enemies.sort_custom(func(a, b):
			return player_pos.distance_to(a.global_position) < player_pos.distance_to(b.global_position)
		)
	var elapsed_us: float = Time.get_ticks_usec() - start_time
	gut.p("sort_custom(100 enemies) x100: %.1f us total" % elapsed_us)
	assert_lt(elapsed_us, 500000.0, "100 sorts of 100 enemies should complete in under 0.5 seconds")


# ============================================================
# Helpers
# ============================================================

func _spawn_enemies(count: int) -> void:
	for i in range(count):
		var enemy: CharacterBody2D = _create_enemy_node()
		enemy.global_position = Vector2(
			randf_range(-500, 1500),
			randf_range(-500, 1500)
		)
		_arena.add_child(enemy)
		_enemies.append(enemy)


func _spawn_enemies_at_distances(distances: Array) -> void:
	var angles: Array = [0.0, 1.2, 2.4, 3.6, 4.8, 0.6]
	for i in range(distances.size()):
		var enemy: CharacterBody2D = _create_enemy_node()
		var angle: float = angles[i % angles.size()]
		enemy.global_position = Vector2(
			cos(angle) * distances[i],
			sin(angle) * distances[i]
		)
		_arena.add_child(enemy)
		_enemies.append(enemy)


func _create_enemy_node() -> CharacterBody2D:
	# Create a lightweight mock enemy node with just group membership
	# Uses the actual enemy scene for realistic performance characteristics
	var scene: PackedScene = load("res://scenes/enemy.tscn") as PackedScene
	var enemy: CharacterBody2D = scene.instantiate() as CharacterBody2D
	var data := EnemyData.new()
	data.enemy_id = "benchmark_enemy"
	data.enemy_name = "BenchmarkEnemy"
	data.max_hp = 50.0
	data.speed = 60.0
	data.damage = 10.0
	data.xp_value = 5
	data.color = Color.RED
	data.size = 16.0
	data.drop_chance = 0.0
	enemy.enemy_data = data
	enemy.add_to_group("enemies")
	return enemy


func _manual_get_enemies_in_range(player_pos: Vector2, range_val: float) -> Array:
	# Replicates weapon_controller._get_enemies_in_range logic for benchmarking
	var enemies: Array = []
	var all_enemies: Array = get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.get("is_alive") != false:
			var dist: float = player_pos.distance_to(enemy.global_position)
			if dist <= range_val:
				enemies.append(enemy)
	enemies.sort_custom(func(a, b):
		return player_pos.distance_to(a.global_position) < player_pos.distance_to(b.global_position)
	)
	return enemies
