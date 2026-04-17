extends GutTest
## R27: Unit tests for enemy_death_effects.gd
## Covers: death animation constants, get_death_duration, play_death_animation dispatch,
## hit feedback constants, and elite-specific behavior.

var _effects: RefCounted
var _enemy: CharacterBody2D
var _sprite: Sprite2D


func before_each():
	_effects = load("res://scripts/enemies/enemy_death_effects.gd").new()

	_enemy = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "zombie"
	data.max_hp = 10.0
	data.speed = 50.0
	data.damage = 1.0
	data.xp_value = 5
	data.color = Color.GREEN
	data.size = 16.0
	data.drop_chance = 0.0
	_enemy.enemy_data = data
	_enemy.global_position = Vector2(100, 100)
	add_child_autofree(_enemy)

	_sprite = Sprite2D.new()
	_sprite.position = Vector2.ZERO
	_sprite.texture = null
	_enemy.add_child(_sprite)


func after_each():
	await get_tree().process_frame


# =====================================================================
# Section A: Hit Feedback Constants
# =====================================================================

func test_hit_flash_color_is_hdr_white():
	var expected: Color = Color(8, 8, 8)
	assert_eq(_effects.HIT_FLASH_COLOR, expected, "Hit flash should be HDR white (8,8,8)")


func test_hit_flash_duration():
	assert_eq(_effects.HIT_FLASH_DURATION, 0.1, "Hit flash duration should be 0.1s")


func test_shake_strength():
	assert_eq(_effects.SHAKE_STRENGTH, 2.0, "Shake strength should be 2.0")


func test_shake_step_duration():
	assert_eq(_effects.SHAKE_STEP_DURATION, 0.03, "Shake step duration should be 0.03s")


func test_shake_return_duration():
	assert_eq(_effects.SHAKE_RETURN_DURATION, 0.02, "Shake return duration should be 0.02s")


# =====================================================================
# Section B: Elite Hit Feedback Constants
# =====================================================================

func test_elite_skeleton_red_linger():
	assert_eq(_effects.ELITE_SKELETON_RED_LINGER, 0.08, "Elite skeleton red linger should be 0.08s")


func test_elite_skeleton_recover():
	assert_eq(_effects.ELITE_SKELETON_RECOVER, 0.07, "Elite skeleton recover should be 0.07s")


func test_elite_knight_purple_linger():
	assert_eq(_effects.ELITE_KNIGHT_PURPLE_LINGER, 0.1, "Elite knight purple linger should be 0.1s")


func test_elite_knight_recover():
	assert_eq(_effects.ELITE_KNIGHT_RECOVER, 0.1, "Elite knight recover should be 0.1s")


# =====================================================================
# Section C: get_death_duration
# =====================================================================

func test_boss_death_duration():
	assert_eq(_effects.get_death_duration("boss"), 0.85, "Boss death duration should be 0.85s")


func test_elite_skeleton_death_duration():
	assert_eq(_effects.get_death_duration("elite_skeleton"), 0.45, "Elite skeleton duration should be 0.45s")


func test_elite_knight_death_duration():
	assert_eq(_effects.get_death_duration("elite_knight"), 0.55, "Elite knight duration should be 0.55s")


func test_ghost_death_duration():
	assert_eq(_effects.get_death_duration("ghost"), 0.4, "Ghost duration should be 0.4s")


func test_zombie_death_duration():
	assert_eq(_effects.get_death_duration("zombie"), 0.45, "Zombie duration should be 0.45s")


func test_bat_death_duration():
	assert_eq(_effects.get_death_duration("bat"), 0.3, "Bat duration should be 0.3s")


func test_skeleton_death_duration():
	assert_eq(_effects.get_death_duration("skeleton"), 0.45, "Skeleton duration should be 0.45s")


func test_splitter_death_duration():
	assert_eq(_effects.get_death_duration("splitter"), 0.25, "Splitter duration should be 0.25s")


func test_fire_slime_death_duration():
	assert_eq(_effects.get_death_duration("fire_slime"), 0.4, "Fire slime duration should be 0.4s")


func test_unknown_enemy_death_duration():
	assert_eq(_effects.get_death_duration("unknown"), 0.2, "Unknown enemy duration should default to 0.2s")


func test_default_enemy_death_duration():
	assert_eq(_effects.get_death_duration("generic"), 0.2, "Generic enemy duration should default to 0.2s")


# =====================================================================
# Section D: play_death_animation Dispatch
# =====================================================================

func test_play_death_animation_zombie_no_crash():
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Zombie death animation should not crash")


func test_play_death_animation_bat():
	_enemy.enemy_data.enemy_id = "bat"
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Bat death animation should not crash")


func test_play_death_animation_skeleton():
	_enemy.enemy_data.enemy_id = "skeleton"
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Skeleton death animation should not crash")


func test_play_death_animation_elite_skeleton():
	_enemy.enemy_data.enemy_id = "elite_skeleton"
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Elite skeleton death animation should not crash")


func test_play_death_animation_ghost():
	_enemy.enemy_data.enemy_id = "ghost"
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Ghost death animation should not crash")


func test_play_death_animation_splitter():
	_enemy.enemy_data.enemy_id = "splitter"
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Splitter death animation should not crash")


func test_play_death_animation_splitter_small():
	_enemy.enemy_data.enemy_id = "splitter_small"
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Splitter small death animation should not crash")


func test_play_death_animation_fire_slime():
	_enemy.enemy_data.enemy_id = "fire_slime"
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Fire slime death animation should not crash")


func test_play_death_animation_elite_knight():
	_enemy.enemy_data.enemy_id = "elite_knight"
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Elite knight death animation should not crash")


func test_play_death_animation_boss():
	_enemy.enemy_data.enemy_id = "boss"
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Boss death animation should not crash")


func test_play_death_animation_unknown_falls_to_default():
	_enemy.enemy_data.enemy_id = "unknown_enemy"
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Unknown enemy should use default death animation without crash")


# =====================================================================
# Section E: play_hit_feedback
# =====================================================================

func test_play_hit_feedback_no_crash():
	_effects.play_hit_feedback(_enemy, _sprite)
	assert_true(true, "Hit feedback should not crash")


func test_play_hit_feedback_null_sprite():
	_effects.play_hit_feedback(_enemy, null)
	assert_true(true, "Hit feedback with null sprite should not crash")


func test_play_hit_feedback_elite_skeleton():
	_enemy.enemy_data.enemy_id = "elite_skeleton"
	_effects.play_hit_feedback(_enemy, _sprite)
	assert_true(true, "Elite skeleton hit feedback should not crash")


func test_play_hit_feedback_elite_knight():
	_enemy.enemy_data.enemy_id = "elite_knight"
	_effects.play_hit_feedback(_enemy, _sprite)
	assert_true(true, "Elite knight hit feedback should not crash")


func test_play_hit_feedback_no_enemy_data():
	_enemy.enemy_data = null
	_effects.play_hit_feedback(_enemy, _sprite)
	assert_true(true, "Hit feedback with null enemy_data should not crash")


# =====================================================================
# Section F: play_death_animation null edge cases
# =====================================================================

func test_play_death_animation_null_sprite():
	_effects.play_death_animation(_enemy, null)
	assert_true(true, "Death animation with null sprite should not crash")


func test_play_death_animation_null_enemy_data():
	_enemy.enemy_data = null
	_effects.play_death_animation(_enemy, _sprite)
	assert_true(true, "Death animation with null enemy_data should not crash")
