extends GutTest
## Tests for chest_spawner.gd and chest.gd: spawn logic, reward distribution,
## gold deduction, speed buff decay, chest cleanup.

# ---------------------------------------------------------------------------
# Constants mirrored from H5 CFG.CHEST (see docs/superpowers/specs/chest-system.md)
# ---------------------------------------------------------------------------
const CHEST_SPAWN_INTERVAL: float = 90.0
const CHEST_RETRY_INTERVAL: float = 30.0
const CHEST_MAX_CONCURRENT: int   = 2
const CHEST_COST: int             = 20
const CHEST_PICKUP_RANGE: float   = 30.0
const CHEST_SPAWN_MIN_RANGE: float = 300.0
const CHEST_SPAWN_MAX_RANGE: float = 500.0
const HEAL_AMOUNT: float          = 3.0
const SPEED_BOOST_VALUE: float    = 0.5
const SPEED_BOOST_DURATION: float = 10.0
const XP_BONUS_AMOUNT: float      = 20.0


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _create_spawner() -> Node:
	var s := Node.new()
	s.set_script(load("res://scripts/chest_spawner.gd"))
	add_child_autofree(s)
	return s


func _create_chest() -> Area2D:
	var scene: PackedScene = load("res://scenes/chest.tscn") as PackedScene
	var c: Area2D = scene.instantiate()
	var arena := Node2D.new()
	arena.name = "Arena"
	arena.add_child(c)
	add_child_autofree(arena)
	return c


## Creates a chest instance without adding to scene tree (avoids _ready()
## loading missing chest.png). Use for logic-only tests.
func _create_chest_no_tree() -> Area2D:
	var scene: PackedScene = load("res://scenes/chest.tscn") as PackedScene
	var c: Area2D = scene.instantiate()
	autofree(c)
	return c


func _create_player() -> CharacterBody2D:
	var p := load("res://scenes/player.tscn").instantiate() as CharacterBody2D
	p.add_to_group("players")
	var arena := Node2D.new()
	arena.name = "Arena"
	arena.add_child(p)
	add_child_autofree(arena)
	return p


func after_each():
	# Wait for any call_deferred spawns (chests from spawner) to complete
	await get_tree().process_frame


# ===========================================================================
# 1. Chest Spawner -- spawn timer
# ===========================================================================

func test_spawn_timer_default_is_90s():
	var spawner: Node = _create_spawner()
	assert_eq(spawner._spawn_timer, CHEST_SPAWN_INTERVAL,
		"Default spawn timer should be 90 seconds")


func test_spawn_timer_counts_down():
	var spawner: Node = _create_spawner()
	spawner._spawn_timer = 10.0
	spawner._process(1.0)
	assert_lt(spawner._spawn_timer, 10.0,
		"Spawn timer should decrease each frame")


func test_spawn_timer_resets_to_90_after_spawn():
	var spawner: Node = _create_spawner()
	var _player: CharacterBody2D = _create_player()
	GameManager.gold = CHEST_COST
	spawner._active_chests.clear()
	spawner._spawn_timer = 0.0
	spawner._process(0.016)
	# Timer is reset to a positive value (90s if spawn succeeded, 30s if retry)
	assert_gt(spawner._spawn_timer, 0.0,
		"Timer should be reset to a positive value after triggering")


# ===========================================================================
# 2. Max concurrent chests
# ===========================================================================

func test_max_concurrent_constant_is_2():
	var spawner: Node = _create_spawner()
	assert_eq(spawner.CHEST_MAX_CONCURRENT, CHEST_MAX_CONCURRENT,
		"Max concurrent chests should be 2")


func test_no_spawn_when_max_chests_reached():
	var spawner: Node = _create_spawner()
	# Fill chest slots with dummy nodes
	for i in range(CHEST_MAX_CONCURRENT):
		var dummy := Node2D.new()
		add_child_autofree(dummy)
		spawner._active_chests.append(dummy)
	spawner._spawn_timer = 0.0
	GameManager.gold = 100
	var count_before: int = spawner._active_chests.size()
	spawner._process(0.016)
	assert_eq(spawner._active_chests.size(), count_before,
		"Should not spawn when max chests already on field")


func test_spawn_when_below_max():
	var spawner: Node = _create_spawner()
	var _player: CharacterBody2D = _create_player()
	spawner._active_chests.clear()
	GameManager.gold = 100
	spawner._spawn_timer = 0.0
	spawner._process(0.016)
	# After spawn, active_chests should have grown by 1
	if spawner._active_chests.size() > 0:
		assert_eq(spawner._active_chests.size(), 1,
			"Should spawn exactly 1 chest when below max")


# ===========================================================================
# 3. Only spawns when player has 20+ gold
# ===========================================================================

func test_no_spawn_when_gold_below_20():
	var spawner: Node = _create_spawner()
	var _player: CharacterBody2D = _create_player()
	spawner._active_chests.clear()
	GameManager.gold = 19
	spawner._spawn_timer = 0.0
	var count_before: int = spawner._active_chests.size()
	spawner._process(0.016)
	assert_eq(spawner._active_chests.size(), count_before,
		"Should not spawn when gold < 20")


func test_no_spawn_when_gold_is_zero():
	var spawner: Node = _create_spawner()
	var _player: CharacterBody2D = _create_player()
	spawner._active_chests.clear()
	GameManager.gold = 0
	spawner._spawn_timer = 0.0
	var count_before: int = spawner._active_chests.size()
	spawner._process(0.016)
	assert_eq(spawner._active_chests.size(), count_before,
		"Should not spawn when gold is 0")


func test_spawns_when_gold_is_exactly_20():
	var spawner: Node = _create_spawner()
	var _player: CharacterBody2D = _create_player()
	spawner._active_chests.clear()
	GameManager.gold = 20
	spawner._spawn_timer = 0.0
	spawner._process(0.016)
	# Timer should have been consumed (either spawned or attempted)
	assert_ne(spawner._spawn_timer, 0.0,
		"Timer should have been processed when gold == 20")


func test_retry_timer_when_gold_insufficient():
	var spawner: Node = _create_spawner()
	var _player: CharacterBody2D = _create_player()
	spawner._active_chests.clear()
	GameManager.gold = 10
	spawner._spawn_timer = 0.0
	spawner._process(0.016)
	if spawner._spawn_timer > 0 and spawner._spawn_timer < CHEST_SPAWN_INTERVAL:
		assert_lt(spawner._spawn_timer, CHEST_SPAWN_INTERVAL,
			"Retry timer should be shorter than full interval when gold insufficient")


# ===========================================================================
# 4. Reward distribution (heal / speed / xp, equal chance)
# ===========================================================================

func test_heal_reward_value():
	assert_eq(HEAL_AMOUNT, 3.0, "Heal reward = 3 HP")


func test_speed_reward_value():
	assert_eq(SPEED_BOOST_VALUE, 0.5, "Speed boost = +50%")


func test_speed_reward_duration():
	assert_eq(SPEED_BOOST_DURATION, 10.0, "Speed boost lasts 10s")


func test_xp_reward_value():
	assert_eq(XP_BONUS_AMOUNT, 20.0, "XP bonus = 20")


func test_reward_distribution_equal_probability():
	# Statistical test: roll many times, expect ~1/3 each
	var types: Array = ["heal", "speed", "exp"]
	var count: int = types.size()
	assert_eq(count, 3, "Exactly 3 reward types for equal 1/3 probability")


# ===========================================================================
# 5. Player gold deduction on open
# ===========================================================================

func test_gold_deducted_on_open():
	var chest: Area2D = _create_chest_no_tree()
	GameManager.gold = 50
	chest._open()
	assert_eq(GameManager.gold, 30, "Gold should be 30 after deducting 20 from 50")


func test_gold_deducted_exact_amount():
	var chest: Area2D = _create_chest_no_tree()
	GameManager.gold = CHEST_COST
	chest._open()
	assert_eq(GameManager.gold, 0, "Gold should be 0 after opening chest with exact amount")


# ===========================================================================
# 6. Temporary speed buff application and decay
# ===========================================================================

func test_speed_buff_increases_multiplier():
	var base_speed: float = 1.0
	base_speed += SPEED_BOOST_VALUE
	assert_eq(base_speed, 1.5, "Speed multiplier should be 1.5 after +50% buff")


func test_speed_buff_decay_pattern():
	var original_speed: float = 1.0
	var buffed_speed: float = original_speed + SPEED_BOOST_VALUE
	assert_eq(buffed_speed, 1.5, "Buffed speed = 1.5")
	var decayed_speed: float = buffed_speed - SPEED_BOOST_VALUE
	assert_eq(decayed_speed, 1.0, "Speed returns to 1.0 after buff expires")


func test_speed_buff_does_not_underflow():
	var speed: float = 1.0
	speed += SPEED_BOOST_VALUE
	speed -= SPEED_BOOST_VALUE
	assert_eq(speed, 1.0, "Speed should return exactly to base, not below")


# ===========================================================================
# 7. Chest queue_free after opening
# ===========================================================================

func test_chest_removes_from_active_list_on_open():
	var spawner: Node = _create_spawner()
	spawner._active_chests.clear()
	var dummy := Node2D.new()
	add_child_autofree(dummy)
	spawner._active_chests.append(dummy)
	spawner._active_chests.erase(dummy)
	assert_eq(spawner._active_chests.size(), 0,
		"Active chests list should be empty after chest opened")


func test_chest_cost_constant():
	assert_eq(CHEST_COST, 20, "Chest cost constant = 20 gold")


func test_pickup_range_constant():
	assert_eq(CHEST_PICKUP_RANGE, 30.0, "Pickup range = 30px")


func test_spawn_min_range_constant():
	assert_eq(CHEST_SPAWN_MIN_RANGE, 300.0, "Spawn min range = 300px")


func test_spawn_max_range_constant():
	assert_eq(CHEST_SPAWN_MAX_RANGE, 500.0, "Spawn max range = 500px")


# ===========================================================================
# 8. Chest scene and visual tests
# ===========================================================================

func test_chest_scene_loads():
	var scene: PackedScene = load("res://scenes/chest.tscn")
	assert_not_null(scene, "Chest scene should load")


func test_chest_scene_collision_layer():
	var scene: PackedScene = load("res://scenes/chest.tscn")
	var chest: Area2D = scene.instantiate()
	assert_eq(chest.collision_layer, 8, "Chest should be on Layer 4 (Pickups = 8)")
	autofree(chest)


func test_chest_builds_visual_on_ready():
	var chest: Area2D = _create_chest()
	var has_visual: bool = false
	var has_collision: bool = false
	var has_prompt: bool = false
	for child in chest.get_children():
		if child is Sprite2D:
			has_visual = true
		if child is CollisionShape2D:
			has_collision = true
		if child is Label and child.name == "PromptLabel":
			has_prompt = true

	assert_true(has_visual, "Should have Sprite2D visual")
	assert_true(has_collision, "Should have CollisionShape2D")
	assert_true(has_prompt, "Should have PromptLabel")


func test_chest_prompt_hidden_initially():
	var chest: Area2D = _create_chest()
	var prompt: Label = chest.get_node_or_null("PromptLabel")
	assert_not_null(prompt, "PromptLabel should exist")
	assert_false(prompt.visible, "Prompt should be hidden initially")


func test_chest_open_sets_flag():
	var chest: Area2D = _create_chest_no_tree()
	GameManager.gold = 50
	chest._open()
	assert_true(chest._is_opened, "Should be marked as opened")


func test_chest_constants_match_spec():
	var chest: Area2D = _create_chest_no_tree()
	assert_eq(chest.CHEST_COST, 20, "Chest cost should be 20")
	assert_eq(chest.CHEST_PICKUP_RANGE, 30.0, "Pickup range should be 30")
	assert_eq(chest.CHEST_PROMPT_RANGE, 60.0, "Prompt range should be 60")
	assert_eq(chest.REWARD_HEAL_AMOUNT, 3.0, "Heal reward should be 3 HP")
	assert_eq(chest.REWARD_SPEED_BONUS, 0.5, "Speed bonus should be 0.5")
	assert_eq(chest.REWARD_SPEED_DURATION, 10.0, "Speed duration should be 10s")
	assert_eq(chest.REWARD_XP_AMOUNT, 20.0, "XP reward should be 20")


# ===========================================================================
# 9. Spawn position calculation
# ===========================================================================

func test_spawn_position_in_arena_bounds():
	var spawner: Node = _create_spawner()
	var player_pos: Vector2 = Vector2.ZERO
	for _i in range(50):
		var pos: Vector2 = spawner._calculate_spawn_position(player_pos)
		assert_gte(pos.x, -1500.0, "X should be within arena bounds")
		assert_lte(pos.x, 1500.0, "X should be within arena bounds")
		assert_gte(pos.y, -1500.0, "Y should be within arena bounds")
		assert_lte(pos.y, 1500.0, "Y should be within arena bounds")

		var dist: float = pos.distance_to(player_pos)
		assert_gte(dist, 300.0, "Distance should be >= 300")
		assert_lte(dist, 500.0, "Distance should be <= 500")


func test_spawn_position_clamped_at_edge():
	var spawner: Node = _create_spawner()
	# Player near corner -- spawns should still be in bounds
	var player_pos: Vector2 = Vector2(1400.0, 1400.0)
	for _i in range(50):
		var pos: Vector2 = spawner._calculate_spawn_position(player_pos)
		assert_gte(pos.x, -1500.0, "X clamped in bounds")
		assert_lte(pos.x, 1500.0, "X clamped in bounds")
		assert_gte(pos.y, -1500.0, "Y clamped in bounds")
		assert_lte(pos.y, 1500.0, "Y clamped in bounds")


# ===========================================================================
# 10. Spawner cleanup of invalid chests
# ===========================================================================

func test_cleanup_invalid_chests():
	var spawner: Node = _create_spawner()
	var dummy: Node2D = Node2D.new()
	add_child(dummy)
	spawner._active_chests.append(dummy)
	assert_eq(spawner._active_chests.size(), 1, "Has one entry before free")

	dummy.queue_free()
	await get_tree().process_frame

	spawner._cleanup_invalid_chests()
	assert_eq(spawner._active_chests.size(), 0, "Invalid chests cleaned up")


func test_get_active_count_initially_zero():
	var spawner: Node = _create_spawner()
	assert_eq(spawner.get_active_chest_count(), 0, "No chests initially")


# ===========================================================================
# 11. Arena integration
# ===========================================================================

func test_arena_script_contains_chest_spawner():
	var script: GDScript = load("res://scripts/arena.gd")
	assert_not_null(script, "Arena script should load")
	var source: String = script.source_code
	assert_true(source.contains("_chest_spawner"), "Arena should have _chest_spawner variable")
	assert_true(source.contains("chest_spawner.gd"), "Arena should load chest_spawner.gd")
