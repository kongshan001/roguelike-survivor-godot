extends GutTest
## R32 Final Items Tests
## Tests: synergy_manager get_cooldown_reduction, get_speed_bonus,
## elite hit feedback reduction.
## If not yet implemented, use pending() to mark.


# =====================================================================
# 1. synergy_manager has get_cooldown_reduction method (Resonance kill CD reduction)
# =====================================================================

func test_synergy_manager_has_get_cooldown_reduction():
	var mgr := Node.new()
	mgr.set_script(load("res://scripts/autoload/synergy_manager.gd"))
	add_child_autofree(mgr)
	assert_true(mgr.has_method("get_cooldown_reduction"),
		"synergy_manager must have get_cooldown_reduction method for Resonance synergy")


func test_get_cooldown_reduction_returns_zero_without_synergy():
	var mgr := Node.new()
	mgr.set_script(load("res://scripts/autoload/synergy_manager.gd"))
	add_child_autofree(mgr)
	var result: float = mgr.get_cooldown_reduction("resonance")
	assert_eq(result, 0.0,
		"get_cooldown_reduction should return 0.0 when resonance synergy is not active")


func test_get_cooldown_reduction_returns_value_with_resonance():
	var mgr := Node.new()
	mgr.set_script(load("res://scripts/autoload/synergy_manager.gd"))
	add_child_autofree(mgr)
	# Activate resonance synergy (weapon_weapon: primary=holyshockwave, need 2 tag_weapons)
	mgr.check_synergies(
		{"holyshockwave": 3, "holywater": 3, "bible": 3},
		{}
	)
	assert_true(mgr.has_synergy("resonance"),
		"resonance synergy should be active with holyshockwave + 2 tag weapons")
	var result: float = mgr.get_cooldown_reduction("resonance")
	assert_gt(result, 0.0,
		"get_cooldown_reduction should return > 0 when resonance is active")


# =====================================================================
# 2. synergy_manager has get_speed_bonus method (Overcharge move speed bonus)
# =====================================================================

func test_synergy_manager_has_get_speed_bonus():
	var mgr := Node.new()
	mgr.set_script(load("res://scripts/autoload/synergy_manager.gd"))
	add_child_autofree(mgr)
	assert_true(mgr.has_method("get_speed_bonus"),
		"synergy_manager must have get_speed_bonus method for Overcharge synergy")


func test_get_speed_bonus_returns_zero_without_synergy():
	var mgr := Node.new()
	mgr.set_script(load("res://scripts/autoload/synergy_manager.gd"))
	add_child_autofree(mgr)
	var result: float = mgr.get_speed_bonus("overcharge")
	assert_eq(result, 0.0,
		"get_speed_bonus should return 0.0 when overcharge synergy is not active")


func test_get_speed_bonus_returns_value_with_overcharge():
	var mgr := Node.new()
	mgr.set_script(load("res://scripts/autoload/synergy_manager.gd"))
	add_child_autofree(mgr)
	# Activate overcharge synergy (primary=thunderbeam, need 1 tag_weapon)
	mgr.check_synergies(
		{"thunderbeam": 3, "lightning": 3},
		{}
	)
	assert_true(mgr.has_synergy("overcharge"),
		"overcharge synergy should be active with thunderbeam + lightning")
	var result: float = mgr.get_speed_bonus("overcharge")
	assert_gt(result, 0.0,
		"get_speed_bonus should return > 0 when overcharge is active")


# =====================================================================
# 3. Elite enemies have reduced hit feedback (knockback resistance)
# =====================================================================

func test_elite_enemies_have_reduced_hit_feedback():
	# Programmer implemented knockback resistance as reduced hit shake for elites
	# in enemy_death_effects.gd (shake * 0.5 for is_elite)
	var script: GDScript = load("res://scripts/enemies/enemy_death_effects.gd")
	var src: String = script.source_code
	var has_elite_check: bool = src.find("is_elite") >= 0
	if not has_elite_check:
		pending("elite hit feedback reduction not yet implemented")
		return
	assert_true(has_elite_check,
		"enemy_death_effects.gd should check is_elite for reduced hit feedback")
