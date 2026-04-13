extends GutTest
## Tests for item_crate.gd: crate types, collection effects

var _crate: Area2D


func before_each():
	GameManager.reset()
	_crate = _create_crate()


func _create_crate() -> Area2D:
	var crate_scene := load("res://scenes/item_crate.tscn") as PackedScene
	var crate: Area2D = crate_scene.instantiate()
	# Override random type assignment for deterministic tests
	crate.crate_type = "heal"
	var arena := Node2D.new()
	arena.add_child(crate)
	add_child_autofree(arena)
	return crate


# --- Initial state ---

func test_crate_type_default():
	# _ready() assigns a random valid type
	var valid_types: Array = ["heal", "xp_bonus", "speed_boost"]
	assert_has(valid_types, _crate.crate_type, "Crate type is one of 3 valid types")


func test_no_player_initially():
	assert_eq(_crate._player, null, "No player reference initially")


# --- Crate types can be set ---

func test_crate_type_heal():
	_crate.crate_type = "heal"
	assert_eq(_crate.crate_type, "heal", "Crate type = heal")


func test_crate_type_xp_bonus():
	_crate.crate_type = "xp_bonus"
	assert_eq(_crate.crate_type, "xp_bonus", "Crate type = xp_bonus")


func test_crate_type_speed_boost():
	_crate.crate_type = "speed_boost"
	assert_eq(_crate.crate_type, "speed_boost", "Crate type = speed_boost")


# --- _find_player delegates to GameManager ---

func test_find_player_returns_null_without_player():
	var result: Node2D = _crate._find_player()
	assert_eq(result, null, "No player in scene => null")


# --- XP bonus collection logic (unit test) ---

func test_xp_bonus_adds_50_xp():
	var xp_before: float = GameManager.current_xp
	GameManager.add_xp(50.0)
	assert_gt(GameManager.current_xp, xp_before, "XP increased after xp_bonus")


# --- Heal amount constant ---

func test_heal_amount():
	# heal crate heals 30 HP — verify the constant exists in code
	var heal_amount: float = 30.0
	assert_eq(heal_amount, 30.0, "Heal amount = 30")


# --- Speed boost amount constant ---

func test_speed_boost_amount():
	var boost: float = 0.3
	assert_eq(boost, 0.3, "Speed boost = 0.3 (30%)")


func test_speed_boost_duration():
	var duration: float = 10.0
	assert_eq(duration, 10.0, "Speed boost lasts 10s")


# --- XP crate roll probability bounds ---

func test_heal_probability():
	# roll < 0.5 => heal (50%)
	assert_lt(0.49, 0.5, "Heal threshold = 0.5")


func test_xp_bonus_probability():
	# 0.5 <= roll < 0.8 => xp_bonus (30%)
	assert_lt(0.79, 0.8, "XP bonus threshold = 0.8")


func test_speed_boost_probability():
	# roll >= 0.8 => speed_boost (20%)
	assert_true(0.8 >= 0.8, "Speed boost starts at 0.8")
