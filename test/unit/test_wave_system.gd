extends GutTest

## Unit tests for GameManager wave system (R7 state machine)
## Covers: wave state machine, WAVE_DEFS, wave progression, wave scaling,
## wave_changed/wave_started/wave_completed signals, game reset, victory, endless cycling


var _gm: Node


func before_each():
	_gm = autofree(Node.new())
	_gm.set_script(load("res://scripts/autoload/game_manager.gd"))
	_gm.reset()


# =====================================================================
# Wave Constants and Definitions
# =====================================================================

func test_wave_defs_has_5_entries():
	assert_eq(_gm.WAVE_DEFS.size(), 5, "WAVE_DEFS should have 5 wave definitions")

func test_wave_defs_opening_exists():
	assert_eq(_gm.WAVE_DEFS[0]["id"], "wave_opening", "First wave should be wave_opening")
	assert_eq(_gm.WAVE_DEFS[0]["name"], "Opening", "First wave name should be Opening")
	assert_eq(_gm.WAVE_DEFS[0]["duration"], 60.0, "Opening wave duration should be 60s")

func test_wave_defs_swarm_exists():
	assert_eq(_gm.WAVE_DEFS[1]["id"], "wave_swarm", "Second wave should be wave_swarm")
	assert_eq(_gm.WAVE_DEFS[1]["name"], "Swarm", "Second wave name should be Swarm")

func test_wave_defs_darkness_exists():
	assert_eq(_gm.WAVE_DEFS[2]["id"], "wave_darkness", "Third wave should be wave_darkness")

func test_wave_defs_elite_exists():
	assert_eq(_gm.WAVE_DEFS[3]["id"], "wave_elite", "Fourth wave should be wave_elite")

func test_wave_defs_boss_exists():
	assert_eq(_gm.WAVE_DEFS[4]["id"], "wave_boss", "Fifth wave should be wave_boss")
	assert_true(_gm.WAVE_DEFS[4].get("boss", false), "Boss wave should have boss=true")

func test_wave_intermission_constant():
	assert_eq(_gm.WAVE_INTERMISSION, 3.0, "WAVE_INTERMISSION should be 3.0s")

func test_victory_time_constant():
	assert_eq(_gm.VICTORY_TIME, 300.0, "VICTORY_TIME should be 300.0s")

func test_victory_gold_bonuses():
	assert_eq(_gm.VICTORY_GOLD_BONUS_EASY, 25, "Easy victory bonus = 25")
	assert_eq(_gm.VICTORY_GOLD_BONUS_NORMAL, 50, "Normal victory bonus = 50")
	assert_eq(_gm.VICTORY_GOLD_BONUS_HARD, 100, "Hard victory bonus = 100")

func test_endless_cycle_constants():
	assert_eq(_gm.ENDLESS_CYCLE_HP_BASE, 0.3, "Endless HP cycle base = 0.3")
	assert_eq(_gm.ENDLESS_CYCLE_SPD_BASE, 0.1, "Endless speed cycle base = 0.1")
	assert_eq(_gm.ENDLESS_CYCLE_RATE_BASE, 0.1, "Endless rate cycle base = 0.1")
	assert_eq(_gm.ENDLESS_CYCLE_RATE_FLOOR, 0.5, "Endless rate floor = 0.5")


# =====================================================================
# WaveState Enum
# =====================================================================

func test_wave_state_enum_values():
	assert_eq(_gm.WaveState.WARMUP, 0, "WARMUP should be 0")
	assert_eq(_gm.WaveState.ACTIVE, 1, "ACTIVE should be 1")
	assert_eq(_gm.WaveState.INTERMISSION, 2, "INTERMISSION should be 2")
	assert_eq(_gm.WaveState.VICTORY, 3, "VICTORY should be 3")


# =====================================================================
# Wave Initial State
# =====================================================================

func test_initial_wave_is_1():
	assert_eq(_gm.current_wave, 1, "current_wave should start at 1")

func test_initial_cycle_is_1():
	assert_eq(_gm.current_cycle, 1, "current_cycle should start at 1")

func test_initial_wave_state_is_warmup():
	assert_eq(_gm.wave_state, _gm.WaveState.WARMUP, "wave_state should start as WARMUP")

func test_initial_wave_timer_is_0():
	assert_eq(_gm._wave_timer, 0.0, "_wave_timer should start at 0.0")

func test_initial_intermission_timer_is_0():
	assert_eq(_gm._intermission_timer, 0.0, "_intermission_timer should start at 0.0")

func test_is_victory_initially_false():
	assert_false(_gm.is_victory, "is_victory should start false")


# =====================================================================
# Wave Progression - State Machine
# =====================================================================

func test_warmup_transitions_to_active_on_first_update():
	_gm.update_wave(0.016)
	assert_eq(_gm.wave_state, _gm.WaveState.ACTIVE, "WARMUP should transition to ACTIVE")

func test_warmup_emits_wave_started():
	watch_signals(_gm)
	_gm.update_wave(0.016)
	assert_signal_emitted(_gm, "wave_started", "wave_started should emit on WARMUP->ACTIVE")

func test_warmup_emits_wave_changed():
	watch_signals(_gm)
	_gm.update_wave(0.016)
	assert_signal_emitted(_gm, "wave_changed", "wave_changed should emit on WARMUP->ACTIVE")

func test_active_wave_timer_advances():
	_gm.update_wave(0.016)  # WARMUP -> ACTIVE
	_gm.update_wave(1.0)
	assert_eq(_gm._wave_timer, 1.0, "_wave_timer should advance by delta in ACTIVE state")

func test_active_wave_completes_after_duration():
	_gm.update_wave(0.016)  # WARMUP -> ACTIVE (wave 1 = Opening, duration = 60s)
	_gm.update_wave(60.0)   # timer reaches 60s -> wave ends
	assert_eq(_gm.wave_state, _gm.WaveState.INTERMISSION, "Should enter INTERMISSION after wave duration")

func test_wave_completed_signal_on_end():
	watch_signals(_gm)
	_gm.update_wave(0.016)  # WARMUP -> ACTIVE
	_gm.update_wave(60.0)   # wave ends
	assert_signal_emitted(_gm, "wave_completed", "wave_completed should emit when wave ends")

func test_wave_advances_after_intermission():
	_gm.update_wave(0.016)  # WARMUP -> ACTIVE (wave 1)
	_gm.update_wave(60.0)   # wave 1 ends -> INTERMISSION
	_gm.update_wave(3.0)    # intermission ends -> start wave 2
	assert_eq(_gm.current_wave, 2, "current_wave should be 2 after intermission")
	assert_eq(_gm.wave_state, _gm.WaveState.ACTIVE, "Should be ACTIVE for wave 2")

func test_intermission_timer_counts_down():
	_gm.update_wave(0.016)  # WARMUP -> ACTIVE
	_gm.update_wave(60.0)   # -> INTERMISSION (3s)
	_gm.update_wave(1.0)
	assert_eq(_gm._intermission_timer, 2.0, "Intermission should count down: 3-1=2")
	_gm.update_wave(2.0)
	assert_eq(_gm._intermission_timer, 0.0, "Intermission should reach 0")

func test_no_wave_update_when_game_over():
	_gm.is_game_over = true
	_gm.update_wave(60.0)
	assert_eq(_gm.wave_state, _gm.WaveState.WARMUP, "Should stay WARMUP when game_over")
	assert_eq(_gm.current_wave, 1, "Wave should not advance when game_over")


# =====================================================================
# Wave Progression - Full 5-Wave Sequence (Non-Endless)
# =====================================================================

func test_wave_1_is_opening():
	_gm.update_wave(0.016)
	var def: Dictionary = _gm._get_current_wave_def()
	assert_eq(def["id"], "wave_opening", "Wave 1 should be wave_opening")

func test_wave_2_is_swarm():
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	var def: Dictionary = _gm._get_current_wave_def()
	assert_eq(def["id"], "wave_swarm", "Wave 2 should be wave_swarm")

func test_wave_3_is_darkness():
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	var def: Dictionary = _gm._get_current_wave_def()
	assert_eq(def["id"], "wave_darkness", "Wave 3 should be wave_darkness")

func test_wave_4_is_elite():
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	var def: Dictionary = _gm._get_current_wave_def()
	assert_eq(def["id"], "wave_elite", "Wave 4 should be wave_elite")

func test_wave_5_is_boss():
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	var def: Dictionary = _gm._get_current_wave_def()
	assert_eq(def["id"], "wave_boss", "Wave 5 should be wave_boss")


# =====================================================================
# Victory (Non-Endless)
# =====================================================================

func test_victory_triggered_after_wave_5_in_normal():
	_gm.selected_difficulty = "normal"
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	assert_eq(_gm.wave_state, _gm.WaveState.VICTORY, "Should reach VICTORY after wave 5")
	assert_true(_gm.is_victory, "is_victory should be true")
	assert_true(_gm.is_game_over, "is_game_over should be true after victory")

func test_victory_emits_victory_achieved():
	_gm.selected_difficulty = "normal"
	watch_signals(_gm)
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	assert_signal_emitted(_gm, "victory_achieved", "victory_achieved should emit on victory")

func test_victory_gold_bonus_easy():
	_gm.selected_difficulty = "easy"
	watch_signals(_gm)
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	assert_signal_emitted_with_parameters(_gm, "victory_achieved", [25])

func test_victory_gold_bonus_hard():
	_gm.selected_difficulty = "hard"
	watch_signals(_gm)
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	assert_signal_emitted_with_parameters(_gm, "victory_achieved", [100])

func test_victory_adds_gold():
	_gm.selected_difficulty = "normal"
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	assert_eq(_gm.gold, 50, "Victory should add 50 gold for normal difficulty")


# =====================================================================
# Endless Mode - Cycling
# =====================================================================

func test_endless_no_victory_after_wave_5():
	_gm.selected_difficulty = "endless"
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	assert_ne(_gm.wave_state, _gm.WaveState.VICTORY, "Endless should not trigger VICTORY")
	assert_false(_gm.is_victory, "Endless should not set is_victory")

func test_endless_cycles_to_wave_6():
	_gm.selected_difficulty = "endless"
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)  # wave 6 starts (cycle 2)
	assert_eq(_gm.current_wave, 6, "Wave 6 should start after wave 5 in endless")
	assert_eq(_gm.current_cycle, 2, "Should be in cycle 2")

func test_endless_wave_6_is_opening_cycle_2():
	_gm.selected_difficulty = "endless"
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)  # wave 6 starts
	var def: Dictionary = _gm._get_current_wave_def()
	assert_eq(def["id"], "wave_opening", "Wave 6 in endless should cycle back to wave_opening")


# =====================================================================
# Wave Scaling Functions
# =====================================================================

func test_hp_scale_non_endless_is_1():
	_gm.selected_difficulty = "normal"
	assert_eq(_gm.get_wave_hp_scale(), 1.0, "Non-endless HP scale should always be 1.0")

func test_hp_scale_endless_cycle_1():
	_gm.selected_difficulty = "endless"
	_gm.current_cycle = 1
	assert_eq(_gm.get_wave_hp_scale(), 1.0, "Endless cycle 1 HP scale = 1.0")

func test_hp_scale_endless_cycle_2():
	_gm.selected_difficulty = "endless"
	_gm.current_cycle = 2
	assert_eq(_gm.get_wave_hp_scale(), 1.3, "Endless cycle 2 HP scale = 1.3")

func test_hp_scale_endless_cycle_3():
	_gm.selected_difficulty = "endless"
	_gm.current_cycle = 3
	assert_eq(_gm.get_wave_hp_scale(), 1.6, "Endless cycle 3 HP scale = 1.6")

func test_speed_scale_non_endless_is_1():
	_gm.selected_difficulty = "normal"
	assert_eq(_gm.get_wave_speed_scale(), 1.0, "Non-endless speed scale = 1.0")

func test_speed_scale_endless_cycle_2():
	_gm.selected_difficulty = "endless"
	_gm.current_cycle = 2
	assert_eq(_gm.get_wave_speed_scale(), 1.1, "Endless cycle 2 speed = 1.1")

func test_spawn_rate_scale_non_endless_is_1():
	_gm.selected_difficulty = "normal"
	assert_eq(_gm.get_wave_spawn_rate_scale(), 1.0, "Non-endless spawn rate = 1.0")

func test_spawn_rate_scale_endless_cycle_1():
	_gm.selected_difficulty = "endless"
	_gm.current_cycle = 1
	assert_eq(_gm.get_wave_spawn_rate_scale(), 1.0, "Endless cycle 1 spawn rate = 1.0")

func test_spawn_rate_scale_endless_cycle_2():
	_gm.selected_difficulty = "endless"
	_gm.current_cycle = 2
	assert_eq(_gm.get_wave_spawn_rate_scale(), 0.9, "Endless cycle 2 spawn rate = 0.9")

func test_spawn_rate_scale_has_floor():
	_gm.selected_difficulty = "endless"
	_gm.current_cycle = 10  # 1.0 - 0.1*9 = 0.1 < floor 0.5
	assert_eq(_gm.get_wave_spawn_rate_scale(), 0.5, "Spawn rate should not go below floor 0.5")


# =====================================================================
# Wave Progress and Helpers
# =====================================================================

func test_get_wave_progress_in_active():
	_gm.update_wave(0.016)
	_gm.update_wave(30.0)  # 30s into 60s wave 1
	assert_eq(_gm.get_wave_progress(), 0.5, "Progress should be 0.5 at 30s of 60s wave")

func test_get_wave_progress_in_intermission():
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)  # -> INTERMISSION
	assert_eq(_gm.get_wave_progress(), 1.0, "Progress should be 1.0 during INTERMISSION")

func test_get_wave_progress_in_warmup():
	assert_eq(_gm.get_wave_progress(), 0.0, "Progress should be 0.0 during WARMUP")

func test_get_wave_color_returns_color():
	_gm.update_wave(0.016)
	var color: Color = _gm.get_wave_color()
	assert_true(color is Color, "get_wave_color should return a Color")

func test_get_intermission_countdown():
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	assert_eq(_gm.get_intermission_countdown(), 3.0, "Intermission countdown should be 3.0")

func test_get_intermission_countdown_not_in_intermission():
	assert_eq(_gm.get_intermission_countdown(), 0.0, "Should be 0 when not in INTERMISSION")


# =====================================================================
# Signals
# =====================================================================

func test_wave_started_signal_emits():
	watch_signals(_gm)
	_gm.update_wave(0.016)
	assert_signal_emitted(_gm, "wave_started", "wave_started should emit")
	assert_signal_emit_count(_gm, "wave_started", 1, "wave_started should emit once")

func test_wave_changed_signal_emits_on_start():
	watch_signals(_gm)
	_gm.update_wave(0.016)
	assert_signal_emitted(_gm, "wave_changed", "wave_changed should emit on wave start")


# =====================================================================
# Game Reset
# =====================================================================

func test_reset_clears_wave():
	_gm.current_wave = 5
	_gm.current_cycle = 2
	_gm.wave_state = _gm.WaveState.INTERMISSION
	_gm._wave_timer = 30.0
	_gm._intermission_timer = 1.5
	_gm._wave_time_accumulator = 15.0
	_gm.is_victory = true
	_gm.reset()
	assert_eq(_gm.current_wave, 1)
	assert_eq(_gm.current_cycle, 1)
	assert_eq(_gm.wave_state, _gm.WaveState.WARMUP)
	assert_eq(_gm._wave_timer, 0.0)
	assert_eq(_gm._intermission_timer, 0.0)
	assert_eq(_gm._wave_time_accumulator, 0.0)
	assert_false(_gm.is_victory)

func test_reset_after_victory_allows_restart():
	_gm.selected_difficulty = "normal"
	_gm.update_wave(0.016)
	_gm.update_wave(60.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	_gm.update_wave(3.0)
	_gm.update_wave(57.0)
	assert_eq(_gm.wave_state, _gm.WaveState.VICTORY)
	_gm.reset()
	assert_eq(_gm.wave_state, _gm.WaveState.WARMUP)
	assert_eq(_gm.current_wave, 1)


# =====================================================================
# Edge Cases
# =====================================================================

func test_zero_delta_does_not_crash():
	_gm.update_wave(0.0)
	assert_eq(_gm.wave_state, _gm.WaveState.ACTIVE)

func test_wave_state_victory_does_nothing():
	_gm.wave_state = _gm.WaveState.VICTORY
	_gm.update_wave(60.0)
	assert_eq(_gm.wave_state, _gm.WaveState.VICTORY)

func test_get_current_wave_def_wraps_for_endless():
	_gm.selected_difficulty = "endless"
	_gm.current_wave = 7  # (7-1) % 5 = 1 -> wave_swarm
	var def: Dictionary = _gm._get_current_wave_def()
	assert_eq(def["id"], "wave_swarm", "Wave 7 should map to wave_swarm (cycle 2, pos 2)")

func test_get_current_wave_def_wraps_wave_10():
	_gm.current_wave = 10  # (10-1) % 5 = 4 -> wave_boss
	var def: Dictionary = _gm._get_current_wave_def()
	assert_eq(def["id"], "wave_boss", "Wave 10 should map to wave_boss (cycle 2, pos 5)")
