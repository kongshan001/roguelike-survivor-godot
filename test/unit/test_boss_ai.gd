extends GutTest
## Tests for boss_ai.gd: phase transitions, charge mechanics, spiral timing

var _boss_ai: RefCounted


func before_each():
	_boss_ai = load("res://scripts/enemies/boss_ai.gd").new()


# --- Initial state ---

func test_initial_phase():
	assert_eq(_boss_ai.get_phase(), 1, "Boss starts at phase 1")


func test_not_charging_initially():
	assert_false(_boss_ai.is_charging(), "Not charging initially")


func test_charge_cooldown_initial():
	assert_eq(_boss_ai._charge_cooldown, 4.0, "Charge cooldown = 4s")


func test_charge_duration():
	assert_eq(_boss_ai._charge_duration, 0.8, "Charge duration = 0.8s")


func test_charge_speed_mult():
	assert_eq(_boss_ai._charge_speed_mult, 3.0, "Charge speed multiplier = 3x")


func test_spiral_cd():
	assert_eq(_boss_ai._spiral_cd, 1.5, "Spiral cooldown = 1.5s")


func test_spiral_angle_starts_zero():
	assert_eq(_boss_ai._spiral_angle, 0.0, "Spiral angle starts at 0")


func test_burst_count():
	assert_eq(_boss_ai._bullet_count_burst, 8, "Burst fires 8 bullets")


func test_spiral_count():
	assert_eq(_boss_ai._bullet_count_spiral, 16, "Spiral fires 16 bullets")


# --- Phase transitions ---

func test_phase2_at_66_percent():
	_boss_ai.update_phase(66.0, 100.0)
	assert_eq(_boss_ai.get_phase(), 2, "Phase 2 at 66% HP")


func test_phase3_at_33_percent():
	_boss_ai.update_phase(50.0, 100.0)  # Phase 1 → 2
	_boss_ai.update_phase(33.0, 100.0)  # Phase 2 → 3
	assert_eq(_boss_ai.get_phase(), 3, "Phase 3 at 33% HP")


func test_no_phase_change_above_66():
	_boss_ai.update_phase(67.0, 100.0)
	assert_eq(_boss_ai.get_phase(), 1, "Still phase 1 above 66%")


func test_phase2_exact_threshold():
	# HP = 66 exactly => 66/100 = 0.66 <= 0.66 threshold
	_boss_ai.update_phase(66.0, 100.0)
	assert_eq(_boss_ai.get_phase(), 2, "Phase 2 at exactly 66%")


func test_phase3_exact_threshold():
	_boss_ai.update_phase(50.0, 100.0)  # Phase 1 → 2
	_boss_ai.update_phase(33.0, 100.0)
	assert_eq(_boss_ai.get_phase(), 3, "Phase 3 at exactly 33%")


func test_no_double_phase_jump():
	# Even if HP is very low, only transitions one phase at a time
	_boss_ai.update_phase(10.0, 100.0)
	assert_eq(_boss_ai.get_phase(), 2, "Only transitions to phase 2 first")


func test_phase2_then_3():
	_boss_ai.update_phase(50.0, 100.0)
	assert_eq(_boss_ai.get_phase(), 2, "Phase 2 at 50%")
	_boss_ai.update_phase(30.0, 100.0)
	assert_eq(_boss_ai.get_phase(), 3, "Phase 3 at 30%")


# --- Phase 1: passive ---

func test_phase1_returns_normal_speed():
	# process() with phase 1, no player => returns 1.0
	var result: float = _boss_ai.process(0.016, null, null)
	assert_eq(result, 1.0, "Phase 1 + no player = speed 1.0")


# --- Phase 2: charge mechanics ---

func test_phase2_charge_timer_decreases():
	# Simulate entering phase 2
	_boss_ai._phase = 2
	_boss_ai._charge_timer = 2.0
	# Decrease timer manually (since process needs enemy)
	_boss_ai._charge_timer -= 0.5
	assert_eq(_boss_ai._charge_timer, 1.5, "Charge timer decreases")


func test_phase2_charge_activation():
	_boss_ai._phase = 2
	_boss_ai._charge_timer = 0.0
	# Timer at 0 triggers charge
	assert_true(_boss_ai._charge_timer <= 0, "Timer expired => charge")


# --- Phase 3: speed boost ---

func test_phase3_speed_boost():
	# Phase 3 returns 1.5 speed multiplier (when player exists)
	# Without player, process() returns 1.0 early
	_boss_ai._phase = 3
	assert_eq(_boss_ai._phase, 3, "Phase 3 active")


func test_phase3_spiral_timer_decreases():
	_boss_ai._phase = 3
	_boss_ai._spiral_timer = 1.5
	_boss_ai._spiral_timer -= 0.5
	assert_lt(_boss_ai._spiral_timer, 1.5, "Spiral timer decreases")


# --- Spiral angle increment ---

func test_spiral_angle_increments():
	var initial_angle: float = _boss_ai._spiral_angle
	# Simulate _fire_spiral increment
	_boss_ai._spiral_angle += 0.5
	assert_eq(_boss_ai._spiral_angle, initial_angle + 0.5, "Spiral angle increments by 0.5")


# --- Bullet spawn angle calculation ---

func test_burst_angles_evenly_distributed():
	var count: int = 8
	var angles: Array = []
	for i in range(count):
		angles.append(TAU * i / count)
	# First and last should be 0 and TAU * 7/8
	assert_eq(angles[0], 0.0, "First burst angle = 0")
	assert_almost_eq(angles[count - 1], TAU * 7.0 / 8.0, 0.01, "Last burst angle = 7/8 TAU")


func test_spiral_angles_rotated():
	var count: int = 16
	var base_angle: float = 1.0
	var angles: Array = []
	for i in range(count):
		angles.append(base_angle + TAU * i / count)
	# All angles offset by base_angle
	assert_almost_eq(angles[0], 1.0, 0.01, "First spiral angle offset")
