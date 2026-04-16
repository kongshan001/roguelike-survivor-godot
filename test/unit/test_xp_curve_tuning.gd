extends GutTest
## R20 Task 1: XP Curve Tuning Tests
## Validates the mid-game pacing fix per xp-curve-tuning.md spec.
## Programmer modifies EXP_TABLE indices 4,5,6 from [32,42,55] to [29,38,50].


func before_each():
	GameManager.reset()


# --- 1. Tuned values at indices 4, 5, 6 ---

func test_exp_table_index_4_is_29():
	assert_eq(GameManager.EXP_TABLE[4], 29.0, "EXP_TABLE[4] (Lv5->6) should be 29.0 (was 32.0)")

func test_exp_table_index_5_is_38():
	assert_eq(GameManager.EXP_TABLE[5], 38.0, "EXP_TABLE[5] (Lv6->7) should be 38.0 (was 42.0)")

func test_exp_table_index_6_is_50():
	assert_eq(GameManager.EXP_TABLE[6], 50.0, "EXP_TABLE[6] (Lv7->8) should be 50.0 (was 55.0)")


# --- 2. Unchanged indices regression ---

func test_exp_table_index_0_unchanged():
	assert_eq(GameManager.EXP_TABLE[0], 8.0, "EXP_TABLE[0] should remain 8.0")

func test_exp_table_index_1_unchanged():
	assert_eq(GameManager.EXP_TABLE[1], 12.0, "EXP_TABLE[1] should remain 12.0")

func test_exp_table_index_2_unchanged():
	assert_eq(GameManager.EXP_TABLE[2], 18.0, "EXP_TABLE[2] should remain 18.0")

func test_exp_table_index_3_unchanged():
	assert_eq(GameManager.EXP_TABLE[3], 24.0, "EXP_TABLE[3] should remain 24.0")

func test_exp_table_index_7_unchanged():
	assert_eq(GameManager.EXP_TABLE[7], 70.0, "EXP_TABLE[7] should remain 70.0")

func test_exp_table_index_8_unchanged():
	assert_eq(GameManager.EXP_TABLE[8], 88.0, "EXP_TABLE[8] should remain 88.0")

func test_exp_table_index_9_unchanged():
	assert_eq(GameManager.EXP_TABLE[9], 108.0, "EXP_TABLE[9] should remain 108.0")

func test_exp_table_index_10_unchanged():
	assert_eq(GameManager.EXP_TABLE[10], 132.0, "EXP_TABLE[10] should remain 132.0")

func test_exp_table_index_11_unchanged():
	assert_eq(GameManager.EXP_TABLE[11], 160.0, "EXP_TABLE[11] should remain 160.0")

func test_exp_table_index_12_unchanged():
	assert_eq(GameManager.EXP_TABLE[12], 195.0, "EXP_TABLE[12] should remain 195.0")

func test_exp_table_index_13_unchanged():
	assert_eq(GameManager.EXP_TABLE[13], 240.0, "EXP_TABLE[13] should remain 240.0")

func test_exp_table_size_unchanged():
	assert_eq(GameManager.EXP_TABLE.size(), 14, "EXP_TABLE should have 14 entries")


# --- 3. Calculate XP needed reflects tuning ---

func test_calculate_xp_needed_level_5():
	assert_eq(GameManager._calculate_xp_needed(5), 29.0, "Level 5->6 needs 29 XP")

func test_calculate_xp_needed_level_6():
	assert_eq(GameManager._calculate_xp_needed(6), 38.0, "Level 6->7 needs 38 XP")

func test_calculate_xp_needed_level_7():
	assert_eq(GameManager._calculate_xp_needed(7), 50.0, "Level 7->8 needs 50 XP")

func test_calculate_xp_needed_level_4_unchanged():
	assert_eq(GameManager._calculate_xp_needed(4), 24.0, "Level 4->5 still needs 24 XP")

func test_calculate_xp_needed_level_8_unchanged():
	assert_eq(GameManager._calculate_xp_needed(8), 70.0, "Level 8->9 still needs 70 XP")


# --- 4. Level-up flow with tuned values ---

func test_level_up_5_to_6_with_tuned_xp():
	# Set player to level 5
	GameManager.player_level = 5
	GameManager.xp_to_next_level = GameManager._calculate_xp_needed(5)
	GameManager.add_xp(29.0)
	assert_eq(GameManager.player_level, 6, "Should reach level 6 with exactly 29 XP")
	assert_eq(GameManager.current_xp, 0.0, "No leftover XP")

func test_level_up_6_to_7_with_tuned_xp():
	GameManager.player_level = 6
	GameManager.xp_to_next_level = GameManager._calculate_xp_needed(6)
	GameManager.add_xp(38.0)
	assert_eq(GameManager.player_level, 7, "Should reach level 7 with exactly 38 XP")
	assert_eq(GameManager.current_xp, 0.0, "No leftover XP")

func test_level_up_7_to_8_with_tuned_xp():
	GameManager.player_level = 7
	GameManager.xp_to_next_level = GameManager._calculate_xp_needed(7)
	GameManager.add_xp(50.0)
	assert_eq(GameManager.player_level, 8, "Should reach level 8 with exactly 50 XP")
	assert_eq(GameManager.current_xp, 0.0, "No leftover XP")


# --- 5. Pacing improvement: cumulative XP reduction ---

func test_cumulative_xp_reduction_level_8():
	# Old cumulative to level 8: 8+12+18+24+32+42+55 = 191
	# New cumulative to level 8: 8+12+18+24+29+38+50 = 179
	# Reduction: (191-179)/191 = 6.3%
	var old_cumulative: float = 8.0 + 12.0 + 18.0 + 24.0 + 32.0 + 42.0 + 55.0
	var new_cumulative: float = 0.0
	for i in range(7):
		new_cumulative += GameManager.EXP_TABLE[i]
	var reduction_pct: float = (old_cumulative - new_cumulative) / old_cumulative * 100.0
	assert_gt(reduction_pct, 5.0, "Cumulative reduction at Lv8 should exceed 5%")
	assert_lt(reduction_pct, 8.0, "Cumulative reduction at Lv8 should be under 8%")

func test_cumulative_xp_reduction_level_15():
	# Old cumulative to level 15: sum of all 14 entries with old values = 1184
	# New cumulative to level 15: old - (3+4+5) = 1184 - 12 = 1172
	# Reduction: 12/1184 = 1.0%
	var old_sum: float = 1184.0
	var new_sum: float = 0.0
	for i in range(14):
		new_sum += GameManager.EXP_TABLE[i]
	var reduction_pct: float = (old_sum - new_sum) / old_sum * 100.0
	assert_lt(reduction_pct, 2.0, "Cumulative reduction at Lv15 should be under 2%")
	assert_gt(reduction_pct, 0.5, "Cumulative reduction at Lv15 should be above 0.5%")


# --- 6. XP per level reduction percentages ---

func test_level_5_reduction_pct():
	var old_val: float = 32.0
	var new_val: float = GameManager.EXP_TABLE[4]
	var pct: float = (old_val - new_val) / old_val * 100.0
	assert_gt(pct, 8.0, "Level 5->6 reduction should be > 8%")
	assert_lt(pct, 11.0, "Level 5->6 reduction should be < 11%")

func test_level_6_reduction_pct():
	var old_val: float = 42.0
	var new_val: float = GameManager.EXP_TABLE[5]
	var pct: float = (old_val - new_val) / old_val * 100.0
	assert_gt(pct, 8.0, "Level 6->7 reduction should be > 8%")
	assert_lt(pct, 11.0, "Level 6->7 reduction should be < 11%")

func test_level_7_reduction_pct():
	var old_val: float = 55.0
	var new_val: float = GameManager.EXP_TABLE[6]
	var pct: float = (old_val - new_val) / old_val * 100.0
	assert_gt(pct, 8.0, "Level 7->8 reduction should be > 8%")
	assert_lt(pct, 11.0, "Level 7->8 reduction should be < 11%")


# --- 7. Multi-level flow through tuned zone ---

func test_multi_level_flow_level_4_to_8():
	# Start at level 4, give enough XP to reach level 8
	# Need: 24 (Lv4->5) + 29 (Lv5->6) + 38 (Lv6->7) + 50 (Lv7->8) = 141
	GameManager.player_level = 4
	GameManager.xp_to_next_level = GameManager._calculate_xp_needed(4)
	GameManager.add_xp(141.0)
	assert_eq(GameManager.player_level, 8, "Should reach level 8")
	assert_eq(GameManager.current_xp, 0.0, "No leftover XP at exact cumulative")

func test_multi_level_overflow_through_tuned_zone():
	# Give excess XP to ensure level-up chain works through the tuned zone
	# From Lv4: 24 + 29 + 38 + 50 + 70 = 211 to reach Lv9
	# 220 XP should reach Lv9 with 9 leftover
	GameManager.player_level = 4
	GameManager.xp_to_next_level = GameManager._calculate_xp_needed(4)
	GameManager.add_xp(220.0)
	assert_gt(GameManager.player_level, 8, "Should surpass level 8 with 220 XP from Lv4")


# --- 8. Reset initializes with correct first value ---

func test_reset_uses_exp_table_0():
	GameManager.reset()
	assert_eq(GameManager.xp_to_next_level, GameManager.EXP_TABLE[0], "Reset should use EXP_TABLE[0]")
	assert_eq(GameManager.xp_to_next_level, 8.0, "First level threshold should be 8.0")
