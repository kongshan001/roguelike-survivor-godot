extends GutTest
## R16 Wave boundary stress tests
## Covers: wave edge cases, endless numerical limits, VICTORY state invariants


func before_each():
	GameManager.reset()


# =====================================================================
# Wave Edge Cases
# =====================================================================

func _create_gm() -> Node:
	var gm := Node.new()
	gm.set_script(load("res://scripts/autoload/game_manager.gd"))
	gm.reset()
	add_child_autofree(gm)
	return gm


func test_wave_timer_exact_duration_triggers_end():
	var gm := _create_gm()
	gm.update_wave(0.016)  # WARMUP -> ACTIVE (wave 1 = Opening, duration = 60s)
	gm.update_wave(60.0)   # Exactly at duration
	assert_eq(gm.wave_state, gm.WaveState.INTERMISSION, "Exact duration should trigger wave end")


func test_wave_timer_just_below_duration_stays_active():
	var gm := _create_gm()
	gm.update_wave(0.016)
	gm.update_wave(59.99)
	assert_eq(gm.wave_state, gm.WaveState.ACTIVE, "Just below duration should stay ACTIVE")


func test_wave_def_has_all_required_fields():
	var gm := _create_gm()
	for i in range(gm.WAVE_DEFS.size()):
		var def: Dictionary = gm.WAVE_DEFS[i]
		assert_true(def.has("id"), "Wave %d should have id" % (i + 1))
		assert_true(def.has("name"), "Wave %d should have name" % (i + 1))
		assert_true(def.has("duration"), "Wave %d should have duration" % (i + 1))
		assert_true(def.has("enemies"), "Wave %d should have enemies array" % (i + 1))
		assert_true(def.has("spawn_base"), "Wave %d should have spawn_base" % (i + 1))
		assert_true(def.has("count_base"), "Wave %d should have count_base" % (i + 1))
		assert_true(def.has("color"), "Wave %d should have color" % (i + 1))
		assert_gt(def["duration"], 0.0, "Wave %d duration should be positive" % (i + 1))
		assert_gt(def["enemies"].size(), 0, "Wave %d should have at least 1 enemy type" % (i + 1))


func test_wave_duration_sum_less_than_victory_time():
	var gm := _create_gm()
	# Sum of all wave durations + intermissions should be close to VICTORY_TIME
	var total: float = 0.0
	for def: Dictionary in gm.WAVE_DEFS:
		total += def["duration"]
	total += gm.WAVE_INTERMISSION * (gm.WAVE_DEFS.size() - 1)  # 4 intermissions between 5 waves
	# Victory time = 300s, total should be in reasonable range
	assert_lt(total, 350.0, "Total wave time should be under 350s")
	assert_gt(total, 250.0, "Total wave time should be over 250s")


# =====================================================================
# Endless Mode Wave 100+ Numerical Safety
# =====================================================================

func test_endless_cycle_1_no_scaling():
	var gm := _create_gm()
	gm.selected_difficulty = "endless"
	gm.current_cycle = 1
	assert_eq(gm.get_wave_hp_scale(), 1.0, "Cycle 1 HP scale = 1.0")
	assert_eq(gm.get_wave_speed_scale(), 1.0, "Cycle 1 speed scale = 1.0")
	assert_eq(gm.get_wave_spawn_rate_scale(), 1.0, "Cycle 1 spawn rate = 1.0")


func test_endless_cycle_5_moderate_scaling():
	var gm := _create_gm()
	gm.selected_difficulty = "endless"
	gm.current_cycle = 5
	assert_almost_eq(gm.get_wave_hp_scale(), 2.2, 0.01, "Cycle 5 HP = 1.0 + 0.3*4 = 2.2")
	assert_almost_eq(gm.get_wave_speed_scale(), 1.4, 0.01, "Cycle 5 speed = 1.0 + 0.1*4 = 1.4")
	assert_almost_eq(gm.get_wave_spawn_rate_scale(), 0.6, 0.01, "Cycle 5 rate = max(0.5, 1.0-0.1*4) = 0.6")


func test_endless_cycle_6_spawn_rate_floor_hit():
	var gm := _create_gm()
	gm.selected_difficulty = "endless"
	gm.current_cycle = 6
	# maxf(0.5, 1.0 - 0.1*5) = maxf(0.5, 0.5) = 0.5
	assert_eq(gm.get_wave_spawn_rate_scale(), 0.5, "Cycle 6 should hit spawn rate floor")


func test_endless_cycle_50_hp_scale_no_nan():
	var gm := _create_gm()
	gm.selected_difficulty = "endless"
	gm.current_cycle = 50
	var hp_scale: float = gm.get_wave_hp_scale()
	assert_true(is_finite(hp_scale), "Cycle 50 HP scale should be finite")
	assert_gt(hp_scale, 0.0, "HP scale should be positive")
	# 1.0 + 0.3 * 49 = 15.7
	assert_almost_eq(hp_scale, 15.7, 0.01, "Cycle 50 HP scale should be 15.7")


func test_endless_cycle_500_hp_scale_no_inf():
	var gm := _create_gm()
	gm.selected_difficulty = "endless"
	gm.current_cycle = 500
	var hp_scale: float = gm.get_wave_hp_scale()
	assert_true(is_finite(hp_scale), "Cycle 500 HP scale should be finite (no overflow to inf)")
	# 1.0 + 0.3 * 499 = 150.7
	assert_almost_eq(hp_scale, 150.7, 0.01, "Cycle 500 HP scale should be 150.7")


func test_endless_wave_def_wraps_correctly_wave_11():
	var gm := _create_gm()
	gm.current_wave = 11  # (11-1) % 5 = 10 % 5 = 0 -> wave_opening
	var def: Dictionary = gm._get_current_wave_def()
	assert_eq(def["id"], "wave_opening", "Wave 11 should wrap to wave_opening (cycle 3)")


func test_endless_wave_def_wraps_correctly_wave_15():
	var gm := _create_gm()
	gm.current_wave = 15  # (15-1) % 5 = 14 % 5 = 4 -> wave_boss
	var def: Dictionary = gm._get_current_wave_def()
	assert_eq(def["id"], "wave_boss", "Wave 15 should wrap to wave_boss (cycle 3)")


# =====================================================================
# VICTORY State Invariants
# =====================================================================

func test_victory_sets_both_flags():
	var gm := _create_gm()
	gm.selected_difficulty = "normal"
	# Trigger victory via wave progression
	gm.update_wave(0.016)
	gm.update_wave(60.0)
	gm.update_wave(3.0)
	gm.update_wave(57.0)
	gm.update_wave(3.0)
	gm.update_wave(57.0)
	gm.update_wave(3.0)
	gm.update_wave(57.0)
	gm.update_wave(3.0)
	gm.update_wave(57.0)
	assert_true(gm.is_victory, "is_victory should be true")
	assert_true(gm.is_game_over, "is_game_over should be true")
	assert_eq(gm.wave_state, gm.WaveState.VICTORY, "wave_state should be VICTORY")


func test_victory_state_immune_to_wave_updates():
	var gm := _create_gm()
	gm.selected_difficulty = "normal"
	gm.wave_state = gm.WaveState.VICTORY
	gm.is_victory = true
	gm.is_game_over = true
	gm.current_wave = 5
	# Try to advance waves
	gm.update_wave(60.0)
	gm.update_wave(60.0)
	assert_eq(gm.current_wave, 5, "Wave should not advance in VICTORY state")
	assert_eq(gm.wave_state, gm.WaveState.VICTORY, "Should stay in VICTORY")


func test_reset_after_victory_clears_all_state():
	var gm := _create_gm()
	gm.selected_difficulty = "normal"
	gm.wave_state = gm.WaveState.VICTORY
	gm.is_victory = true
	gm.is_game_over = true
	gm.gold = 100
	gm.boss_killed = true
	gm.boss_kill_count = 2
	gm.reset()
	assert_eq(gm.wave_state, gm.WaveState.WARMUP, "Reset should set WARMUP")
	assert_false(gm.is_victory, "Reset should clear is_victory")
	assert_false(gm.is_game_over, "Reset should clear is_game_over")
	assert_eq(gm.gold, 0, "Reset should clear gold")
	assert_false(gm.boss_killed, "Reset should clear boss_killed")
	assert_eq(gm.boss_kill_count, 0, "Reset should clear boss_kill_count")


func test_intermission_after_wave_5_normal_triggers_victory():
	var gm := _create_gm()
	gm.selected_difficulty = "normal"
	gm.update_wave(0.016)  # Wave 1 starts
	gm.update_wave(60.0)   # Wave 1 ends
	gm.update_wave(3.0)    # Wave 2 starts
	gm.update_wave(57.0)   # Wave 2 ends
	gm.update_wave(3.0)    # Wave 3 starts
	gm.update_wave(57.0)   # Wave 3 ends
	gm.update_wave(3.0)    # Wave 4 starts
	gm.update_wave(57.0)   # Wave 4 ends
	gm.update_wave(3.0)    # Wave 5 starts
	gm.update_wave(57.0)   # Wave 5 ends -> should go to VICTORY (not INTERMISSION)
	assert_eq(gm.wave_state, gm.WaveState.VICTORY, "Wave 5 end should go to VICTORY, not INTERMISSION")


# =====================================================================
# Wave State Machine Edge Cases
# =====================================================================

func test_game_over_blocks_wave_update():
	var gm := _create_gm()
	gm.is_game_over = true
	gm.update_wave(60.0)
	assert_eq(gm.current_wave, 1, "Wave should not advance when game_over")
	assert_eq(gm.wave_state, gm.WaveState.WARMUP, "Should stay in WARMUP when game_over")


func test_multiple_warmup_calls_single_transition():
	var gm := _create_gm()
	# WARMUP -> ACTIVE on first update
	gm.update_wave(0.016)
	assert_eq(gm.wave_state, gm.WaveState.ACTIVE, "First call transitions to ACTIVE")
	# Second call should not re-trigger WARMUP->ACTIVE
	gm.update_wave(0.016)
	assert_eq(gm.wave_state, gm.WaveState.ACTIVE, "Should stay ACTIVE on second call")


func test_wave_progress_clamped_between_0_and_1():
	var gm := _create_gm()
	gm.update_wave(0.016)
	gm.update_wave(30.0)
	var progress: float = gm.get_wave_progress()
	assert_gt(progress, 0.0, "Progress should be > 0 during active wave")
	assert_lte(progress, 1.0, "Progress should be <= 1.0")


func test_get_wave_color_all_waves():
	var gm := _create_gm()
	for i in range(gm.WAVE_DEFS.size()):
		gm.current_wave = i + 1
		var color: Color = gm.get_wave_color()
		assert_true(color is Color, "Wave %d should return valid Color" % (i + 1))
		assert_gt(color.r + color.g + color.b, 0.0, "Wave %d color should not be black" % (i + 1))


func test_intermission_countdown_negative_delta():
	var gm := _create_gm()
	gm.update_wave(0.016)
	gm.update_wave(60.0)
	assert_eq(gm.get_intermission_countdown(), 3.0, "Intermission starts at 3.0")
	gm.update_wave(5.0)  # More than 3.0 delta
	assert_eq(gm.get_intermission_countdown(), 0.0, "Intermission should clamp to 0 after large delta")
