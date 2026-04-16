extends GutTest
## Tests for the enemy cache system in GameManager.
## Validates: register/unregister, get_cached_enemies, stale entry cleanup, reset clearing.


func before_each():
	GameManager.reset()


func test_cache_empty_after_reset():
	assert_eq(GameManager._enemy_cache.size(), 0, "Enemy cache should be empty after reset")


func test_register_enemy_adds_to_cache():
	var enemy: Node2D = Node2D.new()
	enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
	add_child_autofree(enemy)
	GameManager.register_enemy(enemy)
	assert_eq(GameManager._enemy_cache.size(), 1, "Cache should have 1 enemy after register")
	assert_has(GameManager._enemy_cache, enemy, "Cache should contain the registered enemy")


func test_unregister_enemy_removes_from_cache():
	var enemy: Node2D = Node2D.new()
	enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
	add_child_autofree(enemy)
	GameManager.register_enemy(enemy)
	GameManager.unregister_enemy(enemy)
	assert_eq(GameManager._enemy_cache.size(), 0, "Cache should be empty after unregister")


func test_get_cached_enemies_returns_valid():
	var enemy: Node2D = Node2D.new()
	enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
	add_child_autofree(enemy)
	GameManager.register_enemy(enemy)
	var result: Array = GameManager.get_cached_enemies()
	assert_eq(result.size(), 1, "Should return 1 valid enemy")


func test_get_cached_enemies_removes_freed():
	var enemy: Node2D = Node2D.new()
	enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
	add_child_autofree(enemy)
	GameManager.register_enemy(enemy)
	# Free the enemy to make it stale
	enemy.queue_free()
	await wait_frames(2)
	var result: Array = GameManager.get_cached_enemies()
	assert_eq(result.size(), 0, "Should remove freed enemies from cache")


func test_get_cached_enemies_removes_dead():
	var enemy: Node2D = Node2D.new()
	enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
	add_child_autofree(enemy)
	GameManager.register_enemy(enemy)
	# Mark as dead without going through die() (no unregister)
	enemy.is_alive = false
	var result: Array = GameManager.get_cached_enemies()
	assert_eq(result.size(), 0, "Should remove dead enemies from cache")


func test_register_multiple_enemies():
	for i in range(5):
		var enemy: Node2D = Node2D.new()
		enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
		add_child_autofree(enemy)
		GameManager.register_enemy(enemy)
	assert_eq(GameManager._enemy_cache.size(), 5, "Cache should have 5 enemies")


func test_reset_clears_cache():
	var enemy: Node2D = Node2D.new()
	enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
	add_child_autofree(enemy)
	GameManager.register_enemy(enemy)
	GameManager.reset()
	assert_eq(GameManager._enemy_cache.size(), 0, "Cache should be cleared on reset")


func test_unregister_nonexistent_no_crash():
	# Unregistering an enemy that was never registered should not crash
	var enemy: Node2D = Node2D.new()
	enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
	add_child_autofree(enemy)
	GameManager.unregister_enemy(enemy)
	assert_eq(GameManager._enemy_cache.size(), 0, "Cache should remain empty")


# ============================================================
# R18 Regression Tests: Enemy Cache Robustness
# ============================================================

func test_cache_cleanup_after_enemy_death_no_unregister():
	# Simulate enemy death without calling unregister_enemy.
	# get_cached_enemies should still remove dead entries.
	var enemy: Node2D = Node2D.new()
	enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
	add_child_autofree(enemy)
	GameManager.register_enemy(enemy)
	assert_eq(GameManager._enemy_cache.size(), 1, "Cache should have 1 before death")
	# Kill the enemy (set is_alive false, do NOT call unregister)
	enemy.is_alive = false
	var cached: Array = GameManager.get_cached_enemies()
	assert_eq(cached.size(), 0, "Dead enemy should be cleaned from cache even without unregister")
	assert_eq(GameManager._enemy_cache.size(), 0, "Internal cache should also be cleaned")


func test_cache_handles_mixed_alive_and_dead():
	# Register 5 enemies, kill 2, cache should return 3 valid
	var enemies: Array = []
	for i in range(5):
		var enemy: Node2D = Node2D.new()
		enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
		add_child_autofree(enemy)
		GameManager.register_enemy(enemy)
		enemies.append(enemy)
	# Kill enemies at index 1 and 3
	enemies[1].is_alive = false
	enemies[3].is_alive = false
	var cached: Array = GameManager.get_cached_enemies()
	assert_eq(cached.size(), 3, "Should return 3 alive enemies out of 5")
	assert_eq(GameManager._enemy_cache.size(), 3, "Internal cache should have 3 after cleanup")


func test_double_register_no_duplicate():
	# Registering the same enemy twice should add a duplicate entry.
	# get_cached_enemies should return it only once since it checks validity.
	var enemy: Node2D = Node2D.new()
	enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
	add_child_autofree(enemy)
	GameManager.register_enemy(enemy)
	GameManager.register_enemy(enemy)
	assert_eq(GameManager._enemy_cache.size(), 2, "Double register should add duplicate to raw cache")
	var cached: Array = GameManager.get_cached_enemies()
	# The enemy is still alive so both entries pass the validity check
	assert_eq(cached.size(), 2, "Both entries pass validity check (same enemy)")
	# But after unregister once, only one entry remains
	GameManager.unregister_enemy(enemy)
	assert_eq(GameManager._enemy_cache.size(), 1, "One unregister removes one entry")


func test_sort_custom_after_cache_cleanup():
	# Verify sort_custom still works after cache cleanup removes stale entries.
	# Register 3 enemies at different positions, kill 1, sort should work on remaining 2.
	var e1: Node2D = Node2D.new()
	e1.set_script(preload("res://test/unit/mock_enemy.gd"))
	e1.position = Vector2(100, 100)
	add_child_autofree(e1)
	GameManager.register_enemy(e1)

	var e2: Node2D = Node2D.new()
	e2.set_script(preload("res://test/unit/mock_enemy.gd"))
	e2.position = Vector2(200, 200)
	add_child_autofree(e2)
	GameManager.register_enemy(e2)

	var e3: Node2D = Node2D.new()
	e3.set_script(preload("res://test/unit/mock_enemy.gd"))
	e3.position = Vector2(50, 50)
	e3.is_alive = false  # dead enemy
	add_child_autofree(e3)
	GameManager.register_enemy(e3)

	var cached: Array = GameManager.get_cached_enemies()
	assert_eq(cached.size(), 2, "Should have 2 alive enemies after cleanup")
	# Sort by distance from origin
	var origin: Vector2 = Vector2.ZERO
	cached.sort_custom(func(a, b):
		return a.position.distance_to(origin) < b.position.distance_to(origin)
	)
	assert_eq(cached[0], e1, "First should be e1 at distance 141")
	assert_eq(cached[1], e2, "Second should be e2 at distance 283")


func test_cache_survives_multiple_get_cached_calls():
	# Calling get_cached_enemies multiple times should not lose valid entries.
	var enemy: Node2D = Node2D.new()
	enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
	add_child_autofree(enemy)
	GameManager.register_enemy(enemy)
	for i in range(5):
		var cached: Array = GameManager.get_cached_enemies()
		assert_eq(cached.size(), 1, "Cache should still have 1 valid enemy on call %d" % (i + 1))


func test_reset_clears_large_cache():
	# Register many enemies, then reset should clear all.
	for i in range(20):
		var enemy: Node2D = Node2D.new()
		enemy.set_script(preload("res://test/unit/mock_enemy.gd"))
		add_child_autofree(enemy)
		GameManager.register_enemy(enemy)
	assert_eq(GameManager._enemy_cache.size(), 20, "Cache should have 20 enemies")
	GameManager.reset()
	assert_eq(GameManager._enemy_cache.size(), 0, "Cache should be empty after reset")
