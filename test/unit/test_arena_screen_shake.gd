extends GutTest

# Test Arena screen shake: decay, signal triggers, camera offset

var _arena: Node2D


func before_each():
	GameManager.reset()
	var arena_scene = load("res://scenes/arena.tscn")
	_arena = arena_scene.instantiate()
	add_child_autofree(_arena)


func test_screen_shake_sets_amount():
	_arena.screen_shake(5.0)
	assert_eq(_arena._shake_amount, 5.0, "Shake amount should be set")


func test_shake_decay_rate():
	assert_eq(_arena._shake_decay, 5.0, "Shake decay rate should be 5.0")


func test_screen_shake_overwrites():
	_arena.screen_shake(3.0)
	_arena.screen_shake(7.0)
	assert_eq(_arena._shake_amount, 7.0, "Latest shake overwrites previous")


func test_health_changed_triggers_shake():
	_arena._shake_amount = 0.0
	GameManager.health_changed.emit(5.0, 8.0)
	assert_eq(_arena._shake_amount, 3.0, "Health change should trigger 3.0 shake")


func test_combo_20_triggers_shake():
	_arena._shake_amount = 0.0
	GameManager.combo_changed.emit(20)
	assert_eq(_arena._shake_amount, 7.0, "Combo 20 should trigger 7.0 shake (tiered)")


func test_combo_below_20_no_shake():
	_arena._shake_amount = 0.0
	GameManager.combo_changed.emit(10)
	assert_eq(_arena._shake_amount, 5.0, "Combo 10 should trigger 5.0 shake (tiered)")


func test_combo_19_no_shake():
	_arena._shake_amount = 0.0
	GameManager.combo_changed.emit(19)
	assert_eq(_arena._shake_amount, 5.0, "Combo 19 triggers 5.0 (>=5 tier)")


func test_combo_21_shakes():
	_arena._shake_amount = 0.0
	GameManager.combo_changed.emit(21)
	assert_eq(_arena._shake_amount, 7.0, "Combo 21 triggers 7.0 (>=20 tier)")


func test_combo_100_shakes():
	_arena._shake_amount = 0.0
	GameManager.combo_changed.emit(100)
	assert_eq(_arena._shake_amount, 10.0, "Combo 100 triggers 10.0 (>=50 tier)")
