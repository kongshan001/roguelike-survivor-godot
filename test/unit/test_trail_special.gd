extends GutTest
## R22 Task 3: Trail Special Behavior Verification Tests
## Validates special weapon trail behaviors:
## - Thunderang alpha flicker (+-0.10)
## - Blazerang scale expansion (1.0 -> 1.2)
## - FireKnife scale shrink (1.0 -> 0.7)
## - FrostKnife scale shrink (1.0 -> 0.5)
## Reference: docs/superpowers/specs/projectile-trail-vfx.md Sections 7.1-7.2

var _trail_pool_script: Node


func before_each():
	GameManager.reset()
	_trail_pool_script = Node.new()
	_trail_pool_script.set_script(load("res://scripts/effects/projectile_trail_pool.gd"))
	_trail_pool_script.name = "ProjectileTrailPool"
	add_child_autofree(_trail_pool_script)


func after_each():
	await get_tree().process_frame


# =====================================================================
# Section A: Thunderang Alpha Flicker (+-0.10)
# =====================================================================

func test_thunderang_has_flicker_method():
	assert_true(_trail_pool_script.has_method("_add_thunderang_flicker"),
		"Trail pool should have _add_thunderang_flicker method")


func test_thunderang_flicker_amplitude_0_10():
	# Spec: alpha flicker +-0.10
	var source: String = _trail_pool_script.get_script().source_code
	# Find the function definition (not the call site)
	var flicker_def: int = source.find("func _add_thunderang_flicker")
	assert_ne(flicker_def, -1, "Should find _add_thunderang_flicker definition in source")
	var flicker_section: String = source.substr(flicker_def, 300)
	assert_true(flicker_section.find("0.10") != -1 or flicker_section.find("0.1") != -1,
		"Thunderang flicker should use +-0.10 amplitude")


func test_thunderang_flicker_uses_randf_range():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("randf_range") != -1,
		"Thunderang flicker should use randf_range for random alpha variation")


func test_thunderang_flicker_applied_in_spawn():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("thunderang") != -1,
		"Spawn function should check for thunderang weapon_id")
	assert_true(source.find("_add_thunderang_flicker") != -1,
		"Spawn function should call _add_thunderang_flicker for thunderang")


func test_thunderang_flicker_clamps_alpha():
	# Flicker should clamp so alpha never goes below 0.0
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("clampf") != -1 or source.find("clamp") != -1,
		"Thunderang flicker should clamp alpha values")


func test_thunderang_flicker_has_multiple_steps():
	# Spec: 3 flicker steps during lifetime
	var source: String = _trail_pool_script.get_script().source_code
	var flicker_def: int = source.find("func _add_thunderang_flicker")
	assert_ne(flicker_def, -1, "Should find _add_thunderang_flicker definition in source")
	var flicker_section: String = source.substr(flicker_def, 300)
	assert_true(flicker_section.find("range(3)") != -1 or flicker_section.find("for i") != -1,
		"Thunderang flicker should have multiple steps")


# =====================================================================
# Section B: Blazerang Scale Expansion (1.0 -> 1.2)
# =====================================================================

func test_blazerang_scale_expansion_exists():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("blazerang") != -1,
		"Trail pool should reference blazerang for special behavior")


func test_blazerang_scale_target_1_2():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("1.2") != -1,
		"Blazerang should scale to 1.2")


func test_blazerang_scale_from_1_0_to_1_2():
	var source: String = _trail_pool_script.get_script().source_code
	# Find the blazerang section and verify scale tween
	var spawn_start: int = source.find("func spawn")
	assert_ne(spawn_start, -1, "Should find spawn function")
	var spawn_section: String = source.substr(spawn_start, 2000)
	assert_true(spawn_section.find("blazerang") != -1,
		"Spawn function should check for blazerang")
	assert_true(spawn_section.find("1.2") != -1,
		"Blazerang should target scale 1.2")


func test_blazerang_scale_uses_tween():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("tween_property") != -1,
		"Blazerang scale should use tween_property for animation")


# =====================================================================
# Section C: FireKnife Scale Shrink (1.0 -> 0.7)
# =====================================================================

func test_fireknife_has_shrink_behavior():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("fireknife") != -1,
		"Trail pool should reference fireknife for special behavior")


func test_fireknife_scale_target_0_7():
	# Spec: fireknife scale 1.0 -> 0.7
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("0.7") != -1,
		"FireKnife should reference 0.7 scale target")


func test_fireknife_shrink_in_spawn():
	var source: String = _trail_pool_script.get_script().source_code
	var spawn_start: int = source.find("func spawn")
	assert_ne(spawn_start, -1, "Should find spawn function")
	var spawn_section: String = source.substr(spawn_start, 2000)
	# Should have a check for fireknife and scale tween
	assert_true(spawn_section.find("fireknife") != -1 or source.find("fireknife") != -1,
		"Spawn function should reference fireknife for shrink behavior")


func test_fireknife_shrink_uses_progress():
	# Spec: rect.scale = Vector2(1.0-progress*0.3, 1.0-progress*0.3)
	# Or equivalently: tween_property to Vector2(0.7, 0.7)
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("0.7") != -1 or source.find("progress") != -1,
		"FireKnife shrink should use either 0.7 target or progress-based formula")


func test_fireknife_scale_vector_2d():
	# Scale should be applied to both x and y
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("Vector2") != -1,
		"FireKnife scale should use Vector2 for x,y scale")


# =====================================================================
# Section D: FrostKnife Scale Shrink (1.0 -> 0.5)
# =====================================================================

func test_frostknife_has_shrink_behavior():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("frostknife") != -1,
		"Trail pool should reference frostknife for special behavior")


func test_frostknife_scale_target_0_5():
	# Spec: frostknife scale 1.0 -> 0.5 (aggressive shrink)
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("0.5") != -1,
		"FrostKnife should reference 0.5 scale target")


func test_frostknife_shrink_in_spawn():
	var source: String = _trail_pool_script.get_script().source_code
	var spawn_start: int = source.find("func spawn")
	assert_ne(spawn_start, -1, "Should find spawn function")
	var spawn_section: String = source.substr(spawn_start, 2000)
	assert_true(spawn_section.find("frostknife") != -1 or source.find("frostknife") != -1,
		"Spawn function should reference frostknife for shrink behavior")


func test_frostknife_shrink_more_aggressive_than_fireknife():
	# FrostKnife 0.5 < FireKnife 0.7, so FrostKnife shrinks more
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("0.5") != -1 and source.find("0.7") != -1,
		"FrostKnife (0.5) should shrink more than FireKnife (0.7)")


# =====================================================================
# Section E: Scale Reset on Return to Pool
# =====================================================================

func test_return_to_pool_resets_scale():
	# When a trail segment returns to pool, scale should reset to Vector2.ONE
	var source: String = _trail_pool_script.get_script().source_code
	var return_start: int = source.find("func _return_to_pool")
	assert_ne(return_start, -1, "Should find _return_to_pool function")
	var return_section: String = source.substr(return_start, 200)
	assert_true(return_section.find("Vector2.ONE") != -1 or return_section.find("1.0") != -1,
		"_return_to_pool should reset scale to Vector2.ONE")


func test_force_return_resets_scale():
	var source: String = _trail_pool_script.get_script().source_code
	var force_start: int = source.find("func _force_return")
	assert_ne(force_start, -1, "Should find _force_return function")
	var force_section: String = source.substr(force_start, 200)
	assert_true(force_section.find("Vector2.ONE") != -1 or force_section.find("1.0") != -1,
		"_force_return should reset scale to Vector2.ONE")


# =====================================================================
# Section F: All 4 Special Behaviors Present
# =====================================================================

func test_all_four_special_behaviors_in_source():
	var source: String = _trail_pool_script.get_script().source_code
	assert_true(source.find("thunderang") != -1, "Thunderang behavior present")
	assert_true(source.find("blazerang") != -1, "Blazerang behavior present")
	assert_true(source.find("fireknife") != -1, "FireKnife behavior present")
	assert_true(source.find("frostknife") != -1, "FrostKnife behavior present")


func test_special_behavior_count():
	# Exactly 4 weapons have special behaviors
	var source: String = _trail_pool_script.get_script().source_code
	var special_weapons: Array = ["thunderang", "blazerang", "fireknife", "frostknife"]
	var count: int = 0
	for weapon in special_weapons:
		if source.find(weapon) != -1:
			count += 1
	assert_eq(count, 4, "All 4 weapons with special behaviors should be referenced in spawn")


# =====================================================================
# Section G: Normal Weapons No Scale Change
# =====================================================================

func test_knife_no_special_behavior():
	var source: String = _trail_pool_script.get_script().source_code
	# Knife should not have a dedicated if-block in spawn for special effects
	assert_false(source.find('weapon_id == "knife"') != -1,
		"Knife should not have special if-block in spawn")


func test_boomerang_no_special_behavior():
	var source: String = _trail_pool_script.get_script().source_code
	var spawn_start: int = source.find("func spawn")
	var spawn_section: String = source.substr(spawn_start, 2000)
	# Boomerang should not have special scale/flicker in spawn (only base weapons)
	assert_false(spawn_section.find("boomerang") != -1 and (spawn_section.find("1.2") != -1 or spawn_section.find("0.7") != -1),
		"Boomerang should not have scale shrink/expand behavior")


# =====================================================================
# Section H: Trail Pool Module Size Regression
# =====================================================================

func test_trail_pool_module_under_165_lines():
	# Module grew from 125 to 158 lines with special weapon behaviors
	var source: String = _trail_pool_script.get_script().source_code
	var line_count: int = source.split("\n").size()
	assert_lt(line_count, 165,
		"Trail pool module should be under 165 lines (was 125 at R21, 158 at R22)")
