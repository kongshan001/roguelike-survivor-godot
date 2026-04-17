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
	_save_mgr.tutorial_step = 0
	_save_mgr.tutorial_completed = false


func after_each():
	await get_tree().process_frame


# ============================================================
# Part 1: Tutorial Constants and Data Definitions
# These tests verify that tutorial_manager.gd defines the correct
# constants matching the design spec (tutorial-system.md).
# ============================================================

func test_tutorial_manager_script_exists():
	var script_path: String = "res://scripts/tutorial_manager.gd"
	assert_true(ResourceLoader.exists(script_path), "tutorial_manager.gd should exist")
	var script: GDScript = load(script_path) as GDScript
	assert_not_null(script, "tutorial_manager.gd should be a valid GDScript")


func test_tutorial_constants_total_steps():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_TOTAL_STEPS, 8, "Should have 8 tutorial steps (5 core + 3 mid-game hints)")


func test_tutorial_constants_label_offset():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_LABEL_OFFSET, 40.0, "Label offset should be 40px per design spec")


func test_tutorial_constants_move_timeout():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_STEP_MOVE_TIMEOUT, 8.0, "Move step timeout should be 8s per design spec")


func test_tutorial_constants_dash_timeout():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_STEP_DASH_TIMEOUT, 10.0, "Dash step timeout should be 10s per design spec")


func test_tutorial_constants_weapon_timeout():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_STEP_WEAPON_TIMEOUT, 3.0, "Weapon step timeout should be 3s per design spec")


func test_tutorial_constants_skill_timeout():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_STEP_SKILL_TIMEOUT, 10.0, "Skill step timeout should be 10s per design spec")


func test_tutorial_constants_enemy_range():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_STEP_ENEMY_RANGE, 200.0, "Enemy range should be 200px per design spec")


func test_tutorial_constants_move_delay():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_STEP_MOVE_DELAY, 2.0, "Move delay should be 2s per design spec")


func test_tutorial_constants_font_size():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_FONT_SIZE, 14, "Font size should be 14px per design spec")


func test_tutorial_constants_bg_color():
	var tm = _create_tutorial_ref()
	var c: Color = tm.TUTORIAL_BG_COLOR
	assert_almost_eq(c.r, 0.0, 0.001, "BG color R should be 0")
	assert_almost_eq(c.g, 0.0, 0.001, "BG color G should be 0")
	assert_almost_eq(c.b, 0.0, 0.001, "BG color B should be 0")
	assert_almost_eq(c.a, 0.7, 0.001, "BG color A should be 0.7")


func test_tutorial_constants_text_color():
	var tm = _create_tutorial_ref()
	var c: Color = tm.TUTORIAL_TEXT_COLOR
	assert_almost_eq(c.r, 1.0, 0.01, "Text color R should be 1.0")
	assert_almost_eq(c.g, 0.85, 0.01, "Text color G should be 0.85")
	assert_almost_eq(c.b, 0.3, 0.01, "Text color B should be 0.3")


func test_tutorial_constants_bg_padding():
	var tm = _create_tutorial_ref()
	var p: Vector2 = tm.TUTORIAL_BG_PADDING
	assert_almost_eq(p.x, 8.0, 0.01, "BG padding X should be 8")
	assert_almost_eq(p.y, 4.0, 0.01, "BG padding Y should be 4")


# ============================================================
# Part 2: SaveManager Tutorial Fields
# These tests verify SaveManager has the tutorial_step and
# tutorial_completed fields for persistence.
# ============================================================

func test_save_manager_has_tutorial_step_field():
	assert_true("tutorial_step" in _save_mgr, "SaveManager should have tutorial_step field")
	assert_eq(_save_mgr.tutorial_step, 0, "tutorial_step should default to 0")


func test_save_manager_has_tutorial_completed_field():
	assert_true("tutorial_completed" in _save_mgr, "SaveManager should have tutorial_completed field")
	assert_eq(_save_mgr.tutorial_completed, false, "tutorial_completed should default to false")


func test_save_manager_tutorial_step_initial_zero():
	assert_eq(_save_mgr.tutorial_step, 0, "Initial tutorial step should be 0 (not started)")


func test_save_manager_tutorial_completed_initial_false():
	assert_false(_save_mgr.tutorial_completed, "Initial tutorial_completed should be false")


func test_save_manager_tutorial_step_mutable():
	_save_mgr.tutorial_step = 3
	assert_eq(_save_mgr.tutorial_step, 3, "tutorial_step should be settable to 3")


func test_save_manager_tutorial_completed_mutable():
	_save_mgr.tutorial_completed = true
	assert_true(_save_mgr.tutorial_completed, "tutorial_completed should be settable to true")


# ============================================================
# Part 3: Tutorial Step Trigger Conditions
# Verify each step triggers at the correct condition.
# ============================================================

func test_step1_triggers_on_first_arena_entry():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 0
	var result: bool = tm.should_show_step(1, _save_mgr)
	assert_true(result, "Step 1 should trigger when tutorial_step == 0")


func test_step1_does_not_trigger_after_step1_complete():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 1
	var result: bool = tm.should_show_step(1, _save_mgr)
	assert_false(result, "Step 1 should not trigger when tutorial_step >= 1")


func test_step2_triggers_after_step1_complete():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 1
	var result: bool = tm.should_show_step(2, _save_mgr)
	assert_true(result, "Step 2 should trigger when tutorial_step == 1")


func test_step2_does_not_trigger_before_step1():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 0
	var result: bool = tm.should_show_step(2, _save_mgr)
	assert_false(result, "Step 2 should not trigger when tutorial_step == 0")


func test_step3_triggers_after_step2():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 2
	var result: bool = tm.should_show_step(3, _save_mgr)
	assert_true(result, "Step 3 should trigger when tutorial_step == 2")


func test_step4_triggers_after_step3():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 3
	var result: bool = tm.should_show_step(4, _save_mgr)
	assert_true(result, "Step 4 should trigger when tutorial_step == 3")


func test_step5_triggers_after_step4():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 4
	var result: bool = tm.should_show_step(5, _save_mgr)
	assert_true(result, "Step 5 should trigger when tutorial_step == 4")


func test_no_step_triggers_at_step8():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 8
	for step: int in range(1, 9):
		var result: bool = tm.should_show_step(step, _save_mgr)
		assert_false(result, "No step %d should trigger when tutorial_step == 8" % step)


# ============================================================
# Part 4: Tutorial Display Text Verification
# Verify each step shows the correct text per design spec.
# ============================================================

func test_step1_display_text():
	var tm = _create_tutorial_ref()
	var text: String = tm.get_step_text(1)
	assert_true(text.find("WASD") >= 0, "Step 1 text should contain 'WASD', got: " + text)


func test_step2_display_text():
	var tm = _create_tutorial_ref()
	var text: String = tm.get_step_text(2)
	assert_true(text.find("Space") >= 0, "Step 2 text should contain 'Space', got: " + text)


func test_step3_display_text():
	var tm = _create_tutorial_ref()
	var text: String = tm.get_step_text(3)
	# Step 3 text: about auto-attack and XP gem pickup
	assert_gt(text.length(), 5, "Step 3 text should be non-empty description of auto-attack and XP gems")


func test_step4_display_text():
	var tm = _create_tutorial_ref()
	var text: String = tm.get_step_text(4)
	# Step 4 text should mention card selection or key presses
	var has_selection_key: bool = text.find("1") >= 0 or text.find("2") >= 0 or text.find("3") >= 0 or text.find("R") >= 0
	assert_true(has_selection_key, "Step 4 text should mention 1/2/3 or R keys for upgrade selection")


func test_step5_display_text():
	var tm = _create_tutorial_ref()
	var text: String = tm.get_step_text(5)
	assert_true(text.find("E") >= 0, "Step 5 text should contain 'E' for skill activation, got: " + text)


# ============================================================
# Part 5: Tutorial Dismiss Conditions
# Verify each step is dismissed by the correct user action.
# ============================================================

func test_step1_dismiss_on_wasd():
	var tm = _create_tutorial_ref()
	var action: String = tm.get_dismiss_action(1)
	assert_eq(action, "move", "Step 1 should dismiss on 'move' (WASD)")


func test_step2_dismiss_on_space():
	var tm = _create_tutorial_ref()
	var action: String = tm.get_dismiss_action(2)
	assert_eq(action, "dash", "Step 2 should dismiss on 'dash' (Space)")


func test_step3_dismiss_on_timeout():
	var tm = _create_tutorial_ref()
	var action: String = tm.get_dismiss_action(3)
	assert_eq(action, "timeout", "Step 3 should dismiss on 'timeout' (auto-dismiss after 3s)")


func test_step4_dismiss_on_select_upgrade():
	var tm = _create_tutorial_ref()
	var action: String = tm.get_dismiss_action(4)
	assert_eq(action, "upgrade_select", "Step 4 should dismiss on 'upgrade_select'")


func test_step5_dismiss_on_e_key():
	var tm = _create_tutorial_ref()
	var action: String = tm.get_dismiss_action(5)
	assert_eq(action, "skill", "Step 5 should dismiss on 'skill' (E key)")


# ============================================================
# Part 6: Non-First-Time Player Skip
# Verify returning players do not see tutorials.
# ============================================================

func test_completed_tutorial_skips_all_steps():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_completed = true
	for step: int in range(1, 9):
		var result: bool = tm.should_show_step(step, _save_mgr)
		assert_false(result, "Step %d should not show when tutorial_completed is true" % step)


func test_tutorial_step_8_sets_completed():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 7
	tm.complete_step(8, _save_mgr)
	assert_true(_save_mgr.tutorial_completed, "tutorial_completed should be true after completing step 8")


func test_tutorial_step_4_does_not_set_completed():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 3
	tm.complete_step(4, _save_mgr)
	assert_false(_save_mgr.tutorial_completed, "tutorial_completed should still be false after step 4")


func test_step_completion_advances_tutorial_step():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 0
	tm.complete_step(1, _save_mgr)
	assert_eq(_save_mgr.tutorial_step, 1, "tutorial_step should advance to 1 after completing step 1")


# ============================================================
# Part 7: SaveManager Persistence Validation
# Verify tutorial state persists across save/load cycles.
# ============================================================

func test_tutorial_step_survives_save_load():
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
	var tm = _create_tutorial_ref()
	var timeout: float = tm.get_step_timeout(1)
	assert_eq(timeout, 8.0, "Step 1 timeout should be 8.0 seconds")


func test_step2_timeout_is_10_seconds():
	var tm = _create_tutorial_ref()
	var timeout: float = tm.get_step_timeout(2)
	assert_eq(timeout, 10.0, "Step 2 timeout should be 10.0 seconds")


func test_step3_timeout_is_3_seconds():
	var tm = _create_tutorial_ref()
	var timeout: float = tm.get_step_timeout(3)
	assert_eq(timeout, 3.0, "Step 3 timeout should be 3.0 seconds")


func test_step4_timeout_is_none():
	# Step 4 has no timeout (upgrade panel pauses the game)
	var tm = _create_tutorial_ref()
	var timeout: float = tm.get_step_timeout(4)
	assert_eq(timeout, -1.0, "Step 4 should have no timeout (-1 sentinel)")


func test_step5_timeout_is_10_seconds():
	var tm = _create_tutorial_ref()
	var timeout: float = tm.get_step_timeout(5)
	assert_eq(timeout, 10.0, "Step 5 timeout should be 10.0 seconds")


# ============================================================
# Part 9: Edge Cases and Robustness
# ============================================================

func test_invalid_step_number_returns_no_text():
	var tm = _create_tutorial_ref()
	var text: String = tm.get_step_text(0)
	assert_eq(text, "", "Step 0 should return empty text")
	text = tm.get_step_text(9)
	assert_eq(text, "", "Step 9 (beyond range) should return empty text")


func test_invalid_step_number_no_trigger():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 0
	assert_false(tm.should_show_step(0, _save_mgr), "Step 0 should never trigger")
	assert_false(tm.should_show_step(9, _save_mgr), "Step 9 should never trigger")


func test_completed_flag_overrides_step_value():
	# Even if tutorial_step is 0, completed flag should prevent all tutorials
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 0
	_save_mgr.tutorial_completed = true
	assert_false(tm.should_show_step(1, _save_mgr), "Completed flag should override step=0")


# ============================================================
# Part 10: Integration with Arena Scene
# Verify arena.gd references tutorial_manager if implemented.
# ============================================================

func test_arena_script_references_tutorial():
	# arena.gd should reference tutorial_manager
	var arena_script: GDScript = load("res://scripts/arena.gd") as GDScript
	var source: String = arena_script.source_code
	var has_tutorial_ref: bool = source.find("tutorial") >= 0
	assert_true(has_tutorial_ref, "arena.gd should reference tutorial_manager")


func test_save_manager_save_includes_tutorial_section():
	_save_mgr.tutorial_step = 2
	_save_mgr.tutorial_completed = false
	_save_mgr.save()
	var config := ConfigFile.new()
	assert_eq(config.load(_save_mgr.SAVE_PATH), OK, "Should load save file")
	# Check tutorial section exists
	assert_true(config.has_section_key("tutorial", "step"), "Tutorial section 'step' should exist in save file")
	assert_eq(config.get_value("tutorial", "step", 0), 2, "tutorial step should be 2 in save file")
	# Cleanup
	_save_mgr.reset_save()


# ============================================================
# Part 11: R18 TutorialManager Runtime Fix Validation
# Verifies _prev_skill_ready initialization fix for step 5.
# ============================================================

func test_step5_prev_skill_ready_initialization():
	# When resuming at step 4, _prev_skill_ready should be false so the
	# first "skill becomes ready" event triggers the tooltip.
	var tm: Node = _create_tutorial_ref() as Node
	var arena_node: Node2D = Node2D.new()
	add_child_autofree(arena_node)
	# Configure SaveManager autoload state for setup()
	if SaveManager:
		SaveManager.tutorial_step = 4
		SaveManager.tutorial_completed = false
	tm.setup(arena_node)
	# After setup with step 4, _prev_skill_ready should be false
	if "_prev_skill_ready" in tm:
		assert_false(tm._prev_skill_ready, "_prev_skill_ready should be false when resuming at step 4")
	else:
		pending("_prev_skill_ready field not found in TutorialManager")


func test_step5_prev_skill_ready_true_when_step_below_4():
	# When starting from step 0, _prev_skill_ready should remain true (default)
	var tm: Node = _create_tutorial_ref() as Node
	var arena_node: Node2D = Node2D.new()
	add_child_autofree(arena_node)
	if SaveManager:
		SaveManager.tutorial_step = 0
		SaveManager.tutorial_completed = false
	tm.setup(arena_node)
	if "_prev_skill_ready" in tm:
		assert_true(tm._prev_skill_ready, "_prev_skill_ready should be true when step < 4")
	else:
		pending("_prev_skill_ready field not found in TutorialManager")


func test_step5_prev_skill_ready_untouched_when_completed():
	# When tutorial is completed, setup returns early and _prev_skill_ready stays default
	var tm: Node = _create_tutorial_ref() as Node
	var arena_node: Node2D = Node2D.new()
	add_child_autofree(arena_node)
	if SaveManager:
		SaveManager.tutorial_completed = true
	tm.setup(arena_node)
	if "_prev_skill_ready" in tm:
		# Should stay at initial default value (true)
		assert_true(tm._prev_skill_ready, "_prev_skill_ready should stay true when tutorial completed")
	else:
		pending("_prev_skill_ready field not found in TutorialManager")


func test_tutorial_step_internal_state_after_complete_step():
	# Verify internal _step advances correctly using the public complete_step API
	var tm: Node = _create_tutorial_ref() as Node
	# complete_step uses the passed save_mgr directly
	_save_mgr.tutorial_step = 2
	tm.complete_step(3, _save_mgr)
	assert_eq(_save_mgr.tutorial_step, 3, "tutorial_step should advance to 3")
	assert_false(_save_mgr.tutorial_completed, "tutorial should not be completed yet")
	# Complete step 3
	tm.complete_step(4, _save_mgr)
	assert_eq(_save_mgr.tutorial_step, 4, "tutorial_step should advance to 4")
	assert_false(_save_mgr.tutorial_completed, "tutorial should not be completed after step 4")
	# Complete step 5 (not final -- 8 steps total now)
	tm.complete_step(5, _save_mgr)
	assert_eq(_save_mgr.tutorial_step, 5, "tutorial_step should advance to 5")
	assert_false(_save_mgr.tutorial_completed, "tutorial should not be completed after step 5")
	# Complete step 8 (final)
	tm.complete_step(8, _save_mgr)
	assert_eq(_save_mgr.tutorial_step, 8, "tutorial_step should advance to 8")
	assert_true(_save_mgr.tutorial_completed, "tutorial should be completed after step 8")


# ============================================================
# Part 12: Steps 6-8 Extension (tutorial-extension.md)
# Verify mid-game discovery hint steps.
# ============================================================

func test_step6_constants():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_STEP6_TIMEOUT, 4.0, "Step 6 timeout should be 4.0s")
	assert_eq(tm.TUTORIAL_STEP6_MIN_WEAPONS, 2, "Step 6 min weapons should be 2")
	assert_eq(tm.TUTORIAL_STEP6_MIN_LEVEL, 2, "Step 6 min level should be 2")


func test_step7_constants():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_STEP7_TIMEOUT, 3.5, "Step 7 timeout should be 3.5s")
	assert_eq(tm.TUTORIAL_STEP7_COMBO_THRESHOLD, 5, "Step 7 combo threshold should be 5")


func test_step8_constants():
	var tm = _create_tutorial_ref()
	assert_eq(tm.TUTORIAL_STEP8_TIMEOUT, 4.0, "Step 8 timeout should be 4.0s")


func test_step6_triggers_after_step5():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 5
	var result: bool = tm.should_show_step(6, _save_mgr)
	assert_true(result, "Step 6 should trigger when tutorial_step == 5")


func test_step6_does_not_trigger_before_step5():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 4
	var result: bool = tm.should_show_step(6, _save_mgr)
	assert_false(result, "Step 6 should not trigger when tutorial_step == 4")


func test_step7_triggers_after_step6():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 6
	var result: bool = tm.should_show_step(7, _save_mgr)
	assert_true(result, "Step 7 should trigger when tutorial_step == 6")


func test_step8_triggers_after_step7():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 7
	var result: bool = tm.should_show_step(8, _save_mgr)
	assert_true(result, "Step 8 should trigger when tutorial_step == 7")


func test_step6_display_text():
	var tm = _create_tutorial_ref()
	var text: String = tm.get_step_text(6)
	assert_true(text.find("evolve") >= 0 or text.find("Evolve") >= 0, "Step 6 text should mention evolution, got: " + text)


func test_step7_display_text():
	var tm = _create_tutorial_ref()
	var text: String = tm.get_step_text(7)
	assert_true(text.find("Combo") >= 0, "Step 7 text should mention Combo, got: " + text)


func test_step8_display_text():
	var tm = _create_tutorial_ref()
	var text: String = tm.get_step_text(8)
	assert_true(text.find("Synergy") >= 0, "Step 8 text should mention Synergy, got: " + text)


func test_step6_timeout():
	var tm = _create_tutorial_ref()
	assert_eq(tm.get_step_timeout(6), 4.0, "Step 6 timeout should be 4.0s")


func test_step7_timeout():
	var tm = _create_tutorial_ref()
	assert_eq(tm.get_step_timeout(7), 3.5, "Step 7 timeout should be 3.5s")


func test_step8_timeout():
	var tm = _create_tutorial_ref()
	assert_eq(tm.get_step_timeout(8), 4.0, "Step 8 timeout should be 4.0s")


func test_step6_dismiss_on_timeout():
	var tm = _create_tutorial_ref()
	assert_eq(tm.get_dismiss_action(6), "timeout", "Step 6 should dismiss on timeout")


func test_step7_dismiss_on_timeout():
	var tm = _create_tutorial_ref()
	assert_eq(tm.get_dismiss_action(7), "timeout", "Step 7 should dismiss on timeout")


func test_step8_dismiss_on_timeout():
	var tm = _create_tutorial_ref()
	assert_eq(tm.get_dismiss_action(8), "timeout", "Step 8 should dismiss on timeout")


func test_step7_does_not_set_completed():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_step = 6
	tm.complete_step(7, _save_mgr)
	assert_false(_save_mgr.tutorial_completed, "tutorial_completed should still be false after step 7")


func test_existing_completed_save_skips_steps_6_8():
	var tm = _create_tutorial_ref()
	_save_mgr.tutorial_completed = true
	assert_false(tm.should_show_step(6, _save_mgr), "Step 6 should not show for returning players")
	assert_false(tm.should_show_step(7, _save_mgr), "Step 7 should not show for returning players")
	assert_false(tm.should_show_step(8, _save_mgr), "Step 8 should not show for returning players")


func test_has_two_weapons_at_level_helper():
	var tm: Node = _create_tutorial_ref() as Node
	# Empty dict: no qualifying weapons
	assert_false(tm._has_two_weapons_at_level({}, 2), "Should be false with no weapons")
	# One weapon at level 2
	assert_false(tm._has_two_weapons_at_level({"knife": 2}, 2), "Should be false with only 1 weapon")
	# Two weapons but one below min level
	assert_false(tm._has_two_weapons_at_level({"knife": 2, "holywater": 1}, 2), "Should be false when 1 weapon below min level")
	# Two weapons both at min level
	assert_true(tm._has_two_weapons_at_level({"knife": 2, "holywater": 2}, 2), "Should be true with 2 weapons at level 2")
	# Two weapons above min level
	assert_true(tm._has_two_weapons_at_level({"knife": 3, "holywater": 3}, 2), "Should be true with 2 weapons above level 2")


# ============================================================
# Helpers
# ============================================================

func _create_tutorial_ref() -> Object:
	# Load the tutorial_manager script and create an instance.
	var script: GDScript = load("res://scripts/tutorial_manager.gd")
	# tutorial_manager extends Node, so we need a node wrapper
	var node: Node = Node.new()
	node.set_script(script)
	add_child_autofree(node)
	return node
