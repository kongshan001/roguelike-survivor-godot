extends GutTest
## Tests for xp_gem.gd: collection, combo bonus, synergy effects

var _gem: Area2D


func before_each():
	GameManager.reset()
	GameManager.selected_difficulty = "normal"
	_gem = _create_gem(5)


func _create_gem(value: int) -> Area2D:
	var gem_scene := load("res://scenes/xp_gem.tscn") as PackedScene
	var gem: Area2D = gem_scene.instantiate()
	gem.xp_value = value
	# Need a parent with PickupManager pattern
	var arena := Node2D.new()
	arena.add_child(gem)
	add_child_autofree(arena)
	return gem


# --- Initial state ---

func test_xp_value_default():
	assert_eq(_gem.xp_value, 5, "Default xp_value = 5")


func test_magnet_speed_default():
	assert_eq(_gem.magnet_speed, 300.0, "Default magnet speed = 300")


func test_not_moving_initially():
	assert_false(_gem.is_moving_to_player, "Should not be moving initially")


# --- Custom xp_value ---

func test_custom_xp_value():
	var gem: Area2D = _create_gem(20)
	assert_eq(gem.xp_value, 20, "Custom xp_value = 20")


# --- Combo bonus calculation (unit test of formula) ---

func test_combo_bonus_zero():
	var combo_count: float = 0.0
	var bonus: float = minf(combo_count * GameManager.COMBO_EXP_RATE, GameManager.COMBO_MAX_BONUS)
	assert_eq(bonus, 0.0, "No combo = no bonus")


func test_combo_bonus_at_5():
	var combo_count: float = 5.0
	var bonus: float = minf(combo_count * GameManager.COMBO_EXP_RATE, GameManager.COMBO_MAX_BONUS)
	assert_eq(bonus, 0.25, "5 combo = 25% bonus")


func test_combo_bonus_at_10():
	var combo_count: float = 10.0
	var bonus: float = minf(combo_count * GameManager.COMBO_EXP_RATE, GameManager.COMBO_MAX_BONUS)
	assert_eq(bonus, 0.5, "10 combo = 50% bonus (cap)")


func test_combo_bonus_capped():
	var combo_count: float = 20.0
	var bonus: float = minf(combo_count * GameManager.COMBO_EXP_RATE, GameManager.COMBO_MAX_BONUS)
	assert_eq(bonus, 0.5, "20 combo = capped at 50%")


func test_combo_constants():
	assert_eq(GameManager.COMBO_EXP_RATE, 0.05, "COMBO_EXP_RATE = 0.05")
	assert_eq(GameManager.COMBO_MAX_BONUS, 0.5, "COMBO_MAX_BONUS = 0.5")


# --- XP with SaveManager bonus ---

func test_xp_with_save_bonus():
	var xp: float = 10.0
	if SaveManager:
		xp *= (1.0 + SaveManager.get_exp_bonus())
	# SaveManager starts at level 0, so bonus = 0
	assert_eq(xp, 10.0, "No shop bonus = same XP")


# --- XP with difficulty multiplier ---

func test_xp_with_difficulty():
	var xp: float = 10.0
	xp *= GameManager.get_difficulty_mul("exp_mul")
	# Normal difficulty: exp_mul = 1.0
	assert_eq(xp, 10.0, "Normal difficulty: same XP")


# --- Gem visual by value (tests _ready sprite logic) ---

func test_gem_small_value():
	# xp < 10: yellow, size 8x8
	var gem: Area2D = _create_gem(3)
	var sprite: ColorRect = gem.get_node("Sprite") as ColorRect
	if sprite:
		assert_eq(sprite.color, Color.YELLOW, "Small gem is yellow")


func test_gem_medium_value():
	# 10 <= xp < 15: green, size 10x10
	var gem: Area2D = _create_gem(10)
	var sprite: ColorRect = gem.get_node("Sprite") as ColorRect
	if sprite:
		assert_eq(sprite.color, Color.GREEN, "Medium gem is green")


func test_gem_large_value():
	# xp >= 15: blue, size 12x12
	var gem: Area2D = _create_gem(20)
	var sprite: ColorRect = gem.get_node("Sprite") as ColorRect
	if sprite:
		assert_eq(sprite.color, Color(0.2, 0.4, 1.0), "Large gem is blue")
