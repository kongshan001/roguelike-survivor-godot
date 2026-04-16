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
