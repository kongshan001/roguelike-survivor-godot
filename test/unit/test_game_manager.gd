extends GutTest

# Test GameManager autoload: XP, levels, reset, time formatting, combo, gold


func before_all():
		GameManager.reset()


func before_each():
	GameManager.reset()


# --- Reset ---

func test_reset_clears_all_state():
	GameManager.score = 100
	GameManager.enemies_killed = 50
	GameManager.elapsed_time = 30.0
	GameManager.player_level = 5
	GameManager.current_xp = 10.0
	GameManager.is_game_over = true
	GameManager.enemy_count = 10
	GameManager.gold = 25
	GameManager.boss_killed = true
	GameManager.combo_count = 10
	GameManager.best_combo = 15

	GameManager.reset()

	assert_eq(GameManager.score, 0, "Score should be 0 after reset")
	assert_eq(GameManager.enemies_killed, 0, "Enemies killed should be 0 after reset")
	assert_eq(GameManager.elapsed_time, 0.0, "Elapsed time should be 0 after reset")
	assert_eq(GameManager.player_level, 1, "Level should be 1 after reset")
	assert_eq(GameManager.current_xp, 0.0, "Current XP should be 0 after reset")
	assert_eq(GameManager.xp_to_next_level, 8.0, "XP to next level should be 8.0 (EXP_TABLE[0]) after reset")
	assert_false(GameManager.is_paused, "Paused should be false after reset")
	assert_false(GameManager.is_game_over, "Game over should be false after reset")
	assert_eq(GameManager.enemy_count, 0, "Enemy count should be 0 after reset")
	assert_eq(GameManager.gold, 0, "Gold should be 0 after reset")
	assert_false(GameManager.boss_killed, "Boss killed should be false after reset")
	assert_eq(GameManager.combo_count, 0, "Combo count should be 0 after reset")
	assert_eq(GameManager.best_combo, 0, "Best combo should be 0 after reset")


# --- XP and Leveling ---

func test_add_xp_without_level_up():
	GameManager.add_xp(3.0)
	assert_eq(GameManager.current_xp, 3.0, "XP should be 3.0")
	assert_eq(GameManager.player_level, 1, "Level should still be 1")


func test_add_xp_triggers_single_level_up():
	# Level 1→2 needs 8 XP (EXP_TABLE[0])
	GameManager.add_xp(8.0)
	assert_eq(GameManager.player_level, 2, "Level should be 2")
	assert_eq(GameManager.current_xp, 0.0, "Remaining XP should be 0")


func test_add_xp_overflow_carries():
	GameManager.add_xp(10.0)
	assert_eq(GameManager.player_level, 2, "Level should be 2")
	assert_eq(GameManager.current_xp, 2.0, "Extra 2.0 XP should carry over")


func test_xp_table_values():
	# EXP_TABLE = [8, 12, 18, 24, 32, ...]
	assert_eq(GameManager._calculate_xp_needed(1), 8.0, "Level 1→2 needs 8 XP")
	assert_eq(GameManager._calculate_xp_needed(2), 12.0, "Level 2→3 needs 12 XP")
	assert_eq(GameManager._calculate_xp_needed(3), 18.0, "Level 3→4 needs 18 XP")


# --- Signals ---

func test_xp_changed_signal_emitted():
	watch_signals(GameManager)
	GameManager.add_xp(3.0)
	assert_signal_emitted_with_parameters(GameManager, "xp_changed", [3.0, 8.0])


func test_level_up_signal_emitted():
	watch_signals(GameManager)
	GameManager.add_xp(8.0)
	assert_signal_emitted_with_parameters(GameManager, "level_up", [2])


func test_health_changed_signal():
	watch_signals(GameManager)
	GameManager.health_changed.emit(80.0, 100.0)
	assert_signal_emitted_with_parameters(GameManager, "health_changed", [80.0, 100.0])


# --- Time Formatting ---

func test_format_time_zero():
	assert_eq(GameManager.format_time(0.0), "00:00")


func test_format_time_seconds_only():
	assert_eq(GameManager.format_time(45.0), "00:45")


func test_format_time_minutes_and_seconds():
	assert_eq(GameManager.format_time(125.0), "02:05")


func test_format_time_large_values():
	assert_eq(GameManager.format_time(3661.0), "61:01")


func test_format_time_fractional_seconds():
	assert_eq(GameManager.format_time(30.7), "00:30")


# --- Gold ---

func test_add_gold():
	watch_signals(GameManager)
	GameManager.add_gold(10)
	assert_eq(GameManager.gold, 10, "Gold should be 10")
	assert_signal_emitted_with_parameters(GameManager, "gold_changed", [10])


func test_add_gold_multiple():
	GameManager.add_gold(5)
	GameManager.add_gold(3)
	assert_eq(GameManager.gold, 8, "Gold should accumulate")


# --- Combo ---

func test_register_kill_increments_combo():
	GameManager.register_kill()
	assert_eq(GameManager.combo_count, 1)
	GameManager.register_kill()
	assert_eq(GameManager.combo_count, 2)


func test_combo_resets_after_timeout():
	GameManager.register_kill()
	GameManager.register_kill()
	assert_eq(GameManager.combo_count, 2)
	GameManager.update_combo(3.0)  # COMBO_TIMEOUT = 3.0
	assert_eq(GameManager.combo_count, 0, "Combo should reset after timeout")


func test_best_combo_tracked():
	for i in range(5):
		GameManager.register_kill()
	assert_eq(GameManager.best_combo, 5)
	GameManager.update_combo(3.0)
	assert_eq(GameManager.combo_count, 0)
	assert_eq(GameManager.best_combo, 5, "Best combo should persist")


func test_combo_changed_signal():
	watch_signals(GameManager)
	GameManager.register_kill()
	assert_signal_emitted_with_parameters(GameManager, "combo_changed", [1])


# --- Enemy Count Setter ---

func test_enemy_count_setter():
	watch_signals(GameManager)
	GameManager.enemy_count = 5
	assert_eq(GameManager.enemy_count, 5)
	assert_signal_emitted_with_parameters(GameManager, "enemies_changed", [5])


# --- Difficulty Presets ---

func test_difficulty_presets_exist():
	assert_has(GameManager.DIFFICULTY_PRESETS, "easy")
	assert_has(GameManager.DIFFICULTY_PRESETS, "normal")
	assert_has(GameManager.DIFFICULTY_PRESETS, "hard")
	assert_has(GameManager.DIFFICULTY_PRESETS, "endless")


func test_difficulty_mul_easy():
	GameManager.selected_difficulty = "easy"
	assert_eq(GameManager.get_difficulty_mul("enemy_hp_mul"), 0.7)
	assert_eq(GameManager.get_difficulty_mul("spawn_interval_mul"), 1.4)
	assert_eq(GameManager.get_difficulty_mul("exp_mul"), 1.3)


func test_difficulty_mul_hard():
	GameManager.selected_difficulty = "hard"
	assert_eq(GameManager.get_difficulty_mul("enemy_hp_mul"), 1.5)
	assert_eq(GameManager.get_difficulty_mul("enemy_speed_mul"), 1.3)
	assert_eq(GameManager.get_difficulty_mul("enemy_dmg_mul"), 1.5)
	assert_eq(GameManager.get_difficulty_mul("spawn_interval_mul"), 0.7)
	assert_eq(GameManager.get_difficulty_mul("boss_hp_mul"), 1.8)


func test_difficulty_mul_normal():
	GameManager.selected_difficulty = "normal"
	assert_eq(GameManager.get_difficulty_mul("enemy_hp_mul"), 1.0)
	assert_eq(GameManager.get_difficulty_mul("player_hp_mul"), 1.0)


func test_difficulty_mul_default():
	GameManager.selected_difficulty = ""
	assert_eq(GameManager.get_difficulty_mul("enemy_hp_mul"), 1.0)


func test_difficulty_count_mod():
	GameManager.selected_difficulty = "hard"
	assert_eq(GameManager.get_difficulty_count_mod(), 1)
	GameManager.selected_difficulty = "easy"
	assert_eq(GameManager.get_difficulty_count_mod(), -1)
	GameManager.selected_difficulty = "normal"
	assert_eq(GameManager.get_difficulty_count_mod(), 0)


func test_damage_taken_initially_false():
	GameManager.reset()
	assert_eq(GameManager.damage_taken, false)


func test_damage_taken_reset():
	GameManager.damage_taken = true
	GameManager.reset()
	assert_eq(GameManager.damage_taken, false)


func test_character_kills_tracking():
	GameManager.reset()
	GameManager.register_kill()
	GameManager.register_kill()
	assert_eq(GameManager.character_kills, 2)
	assert_eq(GameManager.enemies_killed, 2)


func test_character_kills_reset():
	GameManager.register_kill()
	GameManager.reset()
	assert_eq(GameManager.character_kills, 0)


# --- Pacifist Tracking (kills_at_60) ---

func test_kills_at_60_initially_minus_one():
	GameManager.reset()
	assert_eq(GameManager.kills_at_60, -1, "Not recorded until 60s")


func test_kills_at_60_recorded():
	GameManager.reset()
	GameManager.elapsed_time = 30.0
	GameManager.register_kill()
	GameManager.register_kill()
	GameManager.update_combo(0.016)
	assert_eq(GameManager.kills_at_60, -1, "Not yet 60s")
	GameManager.elapsed_time = 60.0
	GameManager.update_combo(0.016)
	assert_eq(GameManager.kills_at_60, 2, "Should record kills at 60s mark")


func test_kills_at_60_zero_for_pacifist():
	GameManager.reset()
	GameManager.elapsed_time = 60.0
	GameManager.update_combo(0.016)
	assert_eq(GameManager.kills_at_60, 0, "No kills at 60s = pacifist eligible")


func test_kills_at_60_reset():
	GameManager.kills_at_60 = 5
	GameManager.reset()
	assert_eq(GameManager.kills_at_60, -1)


# --- Combo Milestones ---

func test_combo_milestone_at_5():
	watch_signals(GameManager)
	for i in range(5):
		GameManager.register_kill()
	assert_signal_emitted_with_parameters(GameManager, "combo_milestone", [5])


func test_combo_milestone_at_20():
	watch_signals(GameManager)
	for i in range(20):
		GameManager.register_kill()
	assert_signal_emitted_with_parameters(GameManager, "combo_milestone", [20])


func test_combo_constants():
	assert_eq(GameManager.COMBO_MILESTONES, [5, 10, 20, 50])
	assert_eq(GameManager.COMBO_EXP_RATE, 0.05)
	assert_eq(GameManager.COMBO_MAX_BONUS, 0.5)


# --- Boss Warning Signal ---

func test_boss_warning_signal_exists():
	watch_signals(GameManager)
	GameManager.boss_warning.emit()
	assert_signal_emitted(GameManager, "boss_warning")
