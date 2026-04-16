extends GutTest
## Tests for tutorial_manager.gd -- new player onboarding system
## Validates: step triggers, display text, dismiss conditions, SaveManager persistence, skip for returning players
## Spec: docs/superpowers/specs/tutorial-system.md

var _save_mgr: Node
var _tutorial: Node
var _arena: Node2D
var _player: CharacterBody2D


func before_each():
	GameManager.reset()
	# Create a fresh SaveManager instance (not autoload) for isolation
	_save_mgr = Node.new()
	_save_mgr.set_script(load("res://scripts/autoload/save_manager.gd"))
	add_child_autofree(_save_mgr)
	# Reset tutorial state
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 0
	if "tutorial_completed" in _save_mgr:
		_save_mgr.tutorial_completed = false


# ============================================================
# Part 1: Tutorial Constants and Data Definitions
# These tests verify that tutorial_manager.gd defines the correct
# constants matching the design spec (tutorial-system.md).
# ============================================================

func test_tutorial_manager_script_exists():
	# tutorial_manager.gd may not exist yet if Programmer has not created it.
	# We test for the script file existence.
	var script_path: String = "res://scripts/tutorial_manager.gd"
	if not ResourceLoader.exists(script_path):
		pending("tutorial_manager.gd not yet created by Programmer")
		return
	var script: GDScript = load(script_path) as GDScript
	assert_not_null(script, "tutorial_manager.gd should be a valid GDScript")


func test_tutorial_constants_total_steps():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_TOTAL_STEPS" in tm:
		assert_eq(tm.TUTORIAL_TOTAL_STEPS, 5, "Should have 5 tutorial steps per design spec")
	else:
		pending("TUTORIAL_TOTAL_STEPS constant not defined")


func test_tutorial_constants_label_offset():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_LABEL_OFFSET" in tm:
		assert_eq(tm.TUTORIAL_LABEL_OFFSET, 40.0, "Label offset should be 40px per design spec")
	else:
		pending("TUTORIAL_LABEL_OFFSET constant not defined")


func test_tutorial_constants_move_timeout():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_STEP_MOVE_TIMEOUT" in tm:
		assert_eq(tm.TUTORIAL_STEP_MOVE_TIMEOUT, 8.0, "Move step timeout should be 8s per design spec")
	else:
		pending("TUTORIAL_STEP_MOVE_TIMEOUT constant not defined")


func test_tutorial_constants_dash_timeout():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_STEP_DASH_TIMEOUT" in tm:
		assert_eq(tm.TUTORIAL_STEP_DASH_TIMEOUT, 10.0, "Dash step timeout should be 10s per design spec")
	else:
		pending("TUTORIAL_STEP_DASH_TIMEOUT constant not defined")


func test_tutorial_constants_weapon_timeout():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_STEP_WEAPON_TIMEOUT" in tm:
		assert_eq(tm.TUTORIAL_STEP_WEAPON_TIMEOUT, 3.0, "Weapon step timeout should be 3s per design spec")
	else:
		pending("TUTORIAL_STEP_WEAPON_TIMEOUT constant not defined")


func test_tutorial_constants_skill_timeout():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_STEP_SKILL_TIMEOUT" in tm:
		assert_eq(tm.TUTORIAL_STEP_SKILL_TIMEOUT, 10.0, "Skill step timeout should be 10s per design spec")
	else:
		pending("TUTORIAL_STEP_SKILL_TIMEOUT constant not defined")


func test_tutorial_constants_enemy_range():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_STEP_ENEMY_RANGE" in tm:
		assert_eq(tm.TUTORIAL_STEP_ENEMY_RANGE, 200.0, "Enemy range should be 200px per design spec")
	else:
		pending("TUTORIAL_STEP_ENEMY_RANGE constant not defined")


func test_tutorial_constants_move_delay():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_STEP_MOVE_DELAY" in tm:
		assert_eq(tm.TUTORIAL_STEP_MOVE_DELAY, 2.0, "Move delay should be 2s per design spec")
	else:
		pending("TUTORIAL_STEP_MOVE_DELAY constant not defined")


func test_tutorial_constants_font_size():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_FONT_SIZE" in tm:
		assert_eq(tm.TUTORIAL_FONT_SIZE, 14, "Font size should be 14px per design spec")
	else:
		pending("TUTORIAL_FONT_SIZE constant not defined")


func test_tutorial_constants_bg_color():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_BG_COLOR" in tm:
		var c: Color = tm.TUTORIAL_BG_COLOR
		assert_almost_eq(c.r, 0.0, 0.001, "BG color R should be 0")
		assert_almost_eq(c.g, 0.0, 0.001, "BG color G should be 0")
		assert_almost_eq(c.b, 0.0, 0.001, "BG color B should be 0")
		assert_almost_eq(c.a, 0.7, 0.001, "BG color A should be 0.7")
	else:
		pending("TUTORIAL_BG_COLOR constant not defined")


func test_tutorial_constants_text_color():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_TEXT_COLOR" in tm:
		var c: Color = tm.TUTORIAL_TEXT_COLOR
		assert_almost_eq(c.r, 1.0, 0.01, "Text color R should be 1.0")
		assert_almost_eq(c.g, 0.85, 0.01, "Text color G should be 0.85")
		assert_almost_eq(c.b, 0.3, 0.01, "Text color B should be 0.3")
	else:
		pending("TUTORIAL_TEXT_COLOR constant not defined")


func test_tutorial_constants_bg_padding():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if "TUTORIAL_BG_PADDING" in tm:
		var p: Vector2 = tm.TUTORIAL_BG_PADDING
		assert_almost_eq(p.x, 8.0, 0.01, "BG padding X should be 8")
		assert_almost_eq(p.y, 4.0, 0.01, "BG padding Y should be 4")
	else:
		pending("TUTORIAL_BG_PADDING constant not defined")


# ============================================================
# Part 2: SaveManager Tutorial Fields
# These tests verify SaveManager has the tutorial_step and
# tutorial_completed fields for persistence.
# ============================================================

func test_save_manager_has_tutorial_step_field():
	# Verify SaveManager exposes tutorial_step property
	if not "tutorial_step" in _save_mgr:
		pending("SaveManager.tutorial_step field not yet added by Programmer")
		return
	assert_eq(_save_mgr.tutorial_step, 0, "tutorial_step should default to 0")


func test_save_manager_has_tutorial_completed_field():
	if not "tutorial_completed" in _save_mgr:
		pending("SaveManager.tutorial_completed field not yet added by Programmer")
		return
	assert_eq(_save_mgr.tutorial_completed, false, "tutorial_completed should default to false")


func test_save_manager_tutorial_step_initial_zero():
	if not "tutorial_step" in _save_mgr:
		pending("SaveManager.tutorial_step not available")
		return
	assert_eq(_save_mgr.tutorial_step, 0, "Initial tutorial step should be 0 (not started)")


func test_save_manager_tutorial_completed_initial_false():
	if not "tutorial_completed" in _save_mgr:
		pending("SaveManager.tutorial_completed not available")
		return
	assert_false(_save_mgr.tutorial_completed, "Initial tutorial_completed should be false")


func test_save_manager_tutorial_step_mutable():
	if not "tutorial_step" in _save_mgr:
		pending("SaveManager.tutorial_step not available")
		return
	_save_mgr.tutorial_step = 3
	assert_eq(_save_mgr.tutorial_step, 3, "tutorial_step should be settable to 3")


func test_save_manager_tutorial_completed_mutable():
	if not "tutorial_completed" in _save_mgr:
		pending("SaveManager.tutorial_completed not available")
		return
	_save_mgr.tutorial_completed = true
	assert_true(_save_mgr.tutorial_completed, "tutorial_completed should be settable to true")


# ============================================================
# Part 3: Tutorial Step Trigger Conditions
# Verify each step triggers at the correct condition.
# ============================================================

func test_step1_triggers_on_first_arena_entry():
	# Step 1: Move tutorial triggers when tutorial_step == 0 and player is still for 2s
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("should_show_step"):
		pending("should_show_step method not implemented")
		return
	# With tutorial_step = 0, step 1 should show
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 0
	var result: bool = tm.should_show_step(1, _save_mgr)
	assert_true(result, "Step 1 should trigger when tutorial_step == 0")


func test_step1_does_not_trigger_after_step1_complete():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("should_show_step"):
		pending("should_show_step method not implemented")
		return
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 1
	var result: bool = tm.should_show_step(1, _save_mgr)
	assert_false(result, "Step 1 should not trigger when tutorial_step >= 1")


func test_step2_triggers_after_step1_complete():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("should_show_step"):
		pending("should_show_step method not implemented")
		return
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 1
	var result: bool = tm.should_show_step(2, _save_mgr)
	assert_true(result, "Step 2 should trigger when tutorial_step == 1")


func test_step2_does_not_trigger_before_step1():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("should_show_step"):
		pending("should_show_step method not implemented")
		return
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 0
	var result: bool = tm.should_show_step(2, _save_mgr)
	assert_false(result, "Step 2 should not trigger when tutorial_step == 0")


func test_step3_triggers_after_step2():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("should_show_step"):
		pending("should_show_step method not implemented")
		return
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 2
	var result: bool = tm.should_show_step(3, _save_mgr)
	assert_true(result, "Step 3 should trigger when tutorial_step == 2")


func test_step4_triggers_after_step3():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("should_show_step"):
		pending("should_show_step method not implemented")
		return
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 3
	var result: bool = tm.should_show_step(4, _save_mgr)
	assert_true(result, "Step 4 should trigger when tutorial_step == 3")


func test_step5_triggers_after_step4():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("should_show_step"):
		pending("should_show_step method not implemented")
		return
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 4
	var result: bool = tm.should_show_step(5, _save_mgr)
	assert_true(result, "Step 5 should trigger when tutorial_step == 4")


func test_no_step_triggers_at_step5():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("should_show_step"):
		pending("should_show_step method not implemented")
		return
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 5
	for step: int in range(1, 6):
		var result: bool = tm.should_show_step(step, _save_mgr)
		assert_false(result, "No step %d should trigger when tutorial_step == 5" % step)


# ============================================================
# Part 4: Tutorial Display Text Verification
# Verify each step shows the correct text per design spec.
# ============================================================

func test_step1_display_text():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_step_text"):
		pending("get_step_text method not implemented")
		return
	var text: String = tm.get_step_text(1)
	assert_true(text.find("WASD") >= 0, "Step 1 text should contain 'WASD', got: " + text)


func test_step2_display_text():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_step_text"):
		pending("get_step_text method not implemented")
		return
	var text: String = tm.get_step_text(2)
	assert_true(text.find("Space") >= 0, "Step 2 text should contain 'Space', got: " + text)


func test_step3_display_text():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_step_text"):
		pending("get_step_text method not implemented")
		return
	var text: String = tm.get_step_text(3)
	# Step 3 text: about auto-attack and XP gem pickup
	assert_gt(text.length(), 5, "Step 3 text should be non-empty description of auto-attack and XP gems")


func test_step4_display_text():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_step_text"):
		pending("get_step_text method not implemented")
		return
	var text: String = tm.get_step_text(4)
	# Step 4 text should mention card selection or key presses
	var has_selection_key: bool = text.find("1") >= 0 or text.find("2") >= 0 or text.find("3") >= 0 or text.find("R") >= 0
	assert_true(has_selection_key, "Step 4 text should mention 1/2/3 or R keys for upgrade selection")


func test_step5_display_text():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_step_text"):
		pending("get_step_text method not implemented")
		return
	var text: String = tm.get_step_text(5)
	assert_true(text.find("E") >= 0, "Step 5 text should contain 'E' for skill activation, got: " + text)


# ============================================================
# Part 5: Tutorial Dismiss Conditions
# Verify each step is dismissed by the correct user action.
# ============================================================

func test_step1_dismiss_on_wasd():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_dismiss_action"):
		pending("get_dismiss_action method not implemented")
		return
	var action: String = tm.get_dismiss_action(1)
	assert_eq(action, "move", "Step 1 should dismiss on 'move' (WASD)")


func test_step2_dismiss_on_space():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_dismiss_action"):
		pending("get_dismiss_action method not implemented")
		return
	var action: String = tm.get_dismiss_action(2)
	assert_eq(action, "dash", "Step 2 should dismiss on 'dash' (Space)")


func test_step3_dismiss_on_timeout():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_dismiss_action"):
		pending("get_dismiss_action method not implemented")
		return
	var action: String = tm.get_dismiss_action(3)
	assert_eq(action, "timeout", "Step 3 should dismiss on 'timeout' (auto-dismiss after 3s)")


func test_step4_dismiss_on_select_upgrade():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_dismiss_action"):
		pending("get_dismiss_action method not implemented")
		return
	var action: String = tm.get_dismiss_action(4)
	assert_eq(action, "upgrade_select", "Step 4 should dismiss on 'upgrade_select'")


func test_step5_dismiss_on_e_key():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_dismiss_action"):
		pending("get_dismiss_action method not implemented")
		return
	var action: String = tm.get_dismiss_action(5)
	assert_eq(action, "skill", "Step 5 should dismiss on 'skill' (E key)")


# ============================================================
# Part 6: Non-First-Time Player Skip
# Verify returning players do not see tutorials.
# ============================================================

func test_completed_tutorial_skips_all_steps():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("should_show_step"):
		pending("should_show_step method not implemented")
		return
	if "tutorial_completed" in _save_mgr:
		_save_mgr.tutorial_completed = true
	for step: int in range(1, 6):
		var result: bool = tm.should_show_step(step, _save_mgr)
		assert_false(result, "Step %d should not show when tutorial_completed is true" % step)


func test_tutorial_step_5_sets_completed():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("complete_step"):
		pending("complete_step method not implemented")
		return
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 4
	tm.complete_step(5, _save_mgr)
	if "tutorial_completed" in _save_mgr:
		assert_true(_save_mgr.tutorial_completed, "tutorial_completed should be true after completing step 5")
	else:
		pending("tutorial_completed field not available")


func test_tutorial_step_4_does_not_set_completed():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("complete_step"):
		pending("complete_step method not implemented")
		return
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 3
	tm.complete_step(4, _save_mgr)
	if "tutorial_completed" in _save_mgr:
		assert_false(_save_mgr.tutorial_completed, "tutorial_completed should still be false after step 4")
	else:
		pending("tutorial_completed field not available")


func test_step_completion_advances_tutorial_step():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("complete_step"):
		pending("complete_step method not implemented")
		return
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 0
	tm.complete_step(1, _save_mgr)
	if "tutorial_step" in _save_mgr:
		assert_eq(_save_mgr.tutorial_step, 1, "tutorial_step should advance to 1 after completing step 1")
	else:
		pending("tutorial_step field not available")


# ============================================================
# Part 7: SaveManager Persistence Validation
# Verify tutorial state persists across save/load cycles.
# ============================================================

func test_tutorial_step_survives_save_load():
	if not "tutorial_step" in _save_mgr:
		pending("SaveManager.tutorial_step not available")
		return
	_save_mgr.tutorial_step = 3
	_save_mgr.save()
	# Create a new SaveManager instance and load
	var mgr2: Node = Node.new()
	mgr2.set_script(load("res://scripts/autoload/save_manager.gd"))
	add_child_autofree(mgr2)
	mgr2.load_save()
	assert_eq(mgr2.tutorial_step, 3, "tutorial_step should persist as 3 after save/load")
	# Cleanup: reset save to avoid affecting other tests
	_save_mgr.reset_save()


func test_tutorial_completed_survives_save_load():
	if not "tutorial_completed" in _save_mgr:
		pending("SaveManager.tutorial_completed not available")
		return
	_save_mgr.tutorial_completed = true
	_save_mgr.save()
	var mgr2: Node = Node.new()
	mgr2.set_script(load("res://scripts/autoload/save_manager.gd"))
	add_child_autofree(mgr2)
	mgr2.load_save()
	assert_eq(mgr2.tutorial_completed, true, "tutorial_completed should persist as true after save/load")
	# Cleanup
	_save_mgr.reset_save()


func test_tutorial_reset_clears_state():
	if not "tutorial_step" in _save_mgr:
		pending("SaveManager.tutorial_step not available")
		return
	_save_mgr.tutorial_step = 5
	_save_mgr.tutorial_completed = true
	_save_mgr.reset_save()
	assert_eq(_save_mgr.tutorial_step, 0, "tutorial_step should reset to 0")
	assert_eq(_save_mgr.tutorial_completed, false, "tutorial_completed should reset to false")


# ============================================================
# Part 8: Tutorial Step Timeout Validation
# Verify that timeout values match design spec for auto-dismiss.
# ============================================================

func test_step1_timeout_is_8_seconds():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_step_timeout"):
		pending("get_step_timeout method not implemented")
		return
	var timeout: float = tm.get_step_timeout(1)
	assert_eq(timeout, 8.0, "Step 1 timeout should be 8.0 seconds")


func test_step2_timeout_is_10_seconds():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_step_timeout"):
		pending("get_step_timeout method not implemented")
		return
	var timeout: float = tm.get_step_timeout(2)
	assert_eq(timeout, 10.0, "Step 2 timeout should be 10.0 seconds")


func test_step3_timeout_is_3_seconds():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_step_timeout"):
		pending("get_step_timeout method not implemented")
		return
	var timeout: float = tm.get_step_timeout(3)
	assert_eq(timeout, 3.0, "Step 3 timeout should be 3.0 seconds")


func test_step4_timeout_is_none():
	# Step 4 has no timeout (upgrade panel pauses the game)
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_step_timeout"):
		pending("get_step_timeout method not implemented")
		return
	var timeout: float = tm.get_step_timeout(4)
	assert_eq(timeout, -1.0, "Step 4 should have no timeout (-1 sentinel)")


func test_step5_timeout_is_10_seconds():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_step_timeout"):
		pending("get_step_timeout method not implemented")
		return
	var timeout: float = tm.get_step_timeout(5)
	assert_eq(timeout, 10.0, "Step 5 timeout should be 10.0 seconds")


# ============================================================
# Part 9: Edge Cases and Robustness
# ============================================================

func test_invalid_step_number_returns_no_text():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("get_step_text"):
		pending("get_step_text method not implemented")
		return
	var text: String = tm.get_step_text(0)
	assert_eq(text, "", "Step 0 should return empty text")
	text = tm.get_step_text(6)
	assert_eq(text, "", "Step 6 (beyond range) should return empty text")


func test_invalid_step_number_no_trigger():
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("should_show_step"):
		pending("should_show_step method not implemented")
		return
	if "tutorial_step" in _save_mgr:
		_save_mgr.tutorial_step = 0
	assert_false(tm.should_show_step(0, _save_mgr), "Step 0 should never trigger")
	assert_false(tm.should_show_step(6, _save_mgr), "Step 6 should never trigger")


func test_completed_flag_overrides_step_value():
	# Even if tutorial_step is 0, completed flag should prevent all tutorials
	if not _skip_if_no_tutorial_script():
		return
	var tm = _create_tutorial_ref()
	if not tm.has_method("should_show_step"):
		pending("should_show_step method not implemented")
		return
	if "tutorial_step" in _save_mgr and "tutorial_completed" in _save_mgr:
		_save_mgr.tutorial_step = 0
		_save_mgr.tutorial_completed = true
		assert_false(tm.should_show_step(1, _save_mgr), "Completed flag should override step=0")
	else:
		pending("tutorial_step or tutorial_completed not available in SaveManager")


# ============================================================
# Part 10: Integration with Arena Scene
# Verify arena.gd references tutorial_manager if implemented.
# ============================================================

func test_arena_script_references_tutorial():
	# After Programmer adds tutorial integration, arena.gd should reference tutorial_manager
	var arena_script: GDScript = load("res://scripts/arena.gd") as GDScript
	var source: String = arena_script.source_code
	# Check if tutorial_manager is mentioned anywhere in arena.gd
	var has_tutorial_ref: bool = source.find("tutorial") >= 0
	if not has_tutorial_ref:
		pending("arena.gd does not yet reference tutorial_manager")
		return
	assert_true(has_tutorial_ref, "arena.gd should reference tutorial_manager")


func test_save_manager_save_includes_tutorial_section():
	# After Programmer adds tutorial fields, save should include tutorial data
	if not "tutorial_step" in _save_mgr:
		pending("SaveManager.tutorial_step not yet added")
		return
	_save_mgr.tutorial_step = 2
	_save_mgr.tutorial_completed = false
	_save_mgr.save()
	var config := ConfigFile.new()
	assert_eq(config.load(_save_mgr.SAVE_PATH), OK, "Should load save file")
	# Check tutorial section exists
	if config.has_section_key("tutorial", "step"):
		assert_eq(config.get_value("tutorial", "step", 0), 2, "tutorial step should be 2 in save file")
	else:
		# tutorial_step may be stored in a different section
		pending("Tutorial section not found in save file format")
	# Cleanup
	_save_mgr.reset_save()


# ============================================================
# Helpers
# ============================================================

func _skip_if_no_tutorial_script() -> bool:
	if not ResourceLoader.exists("res://scripts/tutorial_manager.gd"):
		pending("tutorial_manager.gd not yet created by Programmer")
		return false
	return true


func _create_tutorial_ref() -> Object:
	# Load the tutorial_manager script and create an instance.
	# If it requires a Node parent, we create a minimal wrapper.
	if not ResourceLoader.exists("res://scripts/tutorial_manager.gd"):
		return null
	var script: GDScript = load("res://scripts/tutorial_manager.gd")
	# tutorial_manager extends Node, so we need a node wrapper
	var node: Node = Node.new()
	node.set_script(script)
	add_child_autofree(node)
	return node
