extends GutTest
## R32 VFX Tests for Resonance and Overcharge synergies
## Tests: weapon_effects.gd VFX methods, pulse_ring.gd resonance VFX calls,
## overcharge_mark.gd explosion VFX calls.
## If not yet implemented, use pending() to mark.


# =====================================================================
# 1. weapon_effects.gd has create_resonance_ripple method
# =====================================================================

func test_weapon_effects_has_create_resonance_ripple():
	var script: GDScript = load("res://scripts/weapons/weapon_effects.gd")
	if script == null:
		pending("weapon_effects.gd does not exist -- skipping VFX check")
		return
	var src: String = script.source_code
	if src.find("create_resonance_ripple") < 0:
		pending("weapon_effects.gd does not yet have create_resonance_ripple -- Programmer not yet added")
		return
	assert_true(true, "weapon_effects.gd has create_resonance_ripple method")


# =====================================================================
# 2. weapon_effects.gd has create_overcharge_explosion method
# =====================================================================

func test_weapon_effects_has_create_overcharge_explosion():
	var script: GDScript = load("res://scripts/weapons/weapon_effects.gd")
	if script == null:
		pending("weapon_effects.gd does not exist -- skipping VFX check")
		return
	var src: String = script.source_code
	if src.find("create_overcharge_explosion") < 0:
		pending("weapon_effects.gd does not yet have create_overcharge_explosion -- Programmer not yet added")
		return
	assert_true(true, "weapon_effects.gd has create_overcharge_explosion method")


# =====================================================================
# 3. pulse_ring.gd source calls resonance VFX
# =====================================================================

func test_pulse_ring_calls_resonance_vfx():
	var script: GDScript = load("res://scripts/weapons/pulse_ring.gd")
	assert_ne(script, null, "pulse_ring.gd must exist")
	var src: String = script.source_code
	# pulse_ring.gd implements resonance by spawning sub-pulse rings directly
	# (_spawn_resonance_pulse creates new pulse_ring instances)
	if src.find("_spawn_resonance_pulse") < 0:
		pending("pulse_ring.gd does not yet have _spawn_resonance_pulse")
		return
	assert_true(src.find("_spawn_resonance_pulse") >= 0,
		"pulse_ring.gd must have resonance sub-pulse spawning logic")
	# Verify the sub-pulse creates a new ring with reduced params
	assert_true(src.find("RESONANCE_DAMAGE_MUL") >= 0,
		"pulse_ring.gd resonance must scale damage via RESONANCE_DAMAGE_MUL")
	assert_true(src.find("RESONANCE_RADIUS_MUL") >= 0,
		"pulse_ring.gd resonance must scale radius via RESONANCE_RADIUS_MUL")
	assert_true(src.find("_is_resonance = true") >= 0,
		"pulse_ring.gd must set _is_resonance = true on sub-pulses to prevent cascade")


# =====================================================================
# 4. overcharge_mark.gd source calls explosion VFX
# =====================================================================

func test_overcharge_mark_calls_explosion_vfx():
	var script: GDScript = load("res://scripts/weapons/overcharge_mark.gd")
	assert_ne(script, null, "overcharge_mark.gd must exist")
	var src: String = script.source_code
	# overcharge_mark.gd implements explosion visual via _spawn_explosion_visual
	if src.find("_spawn_explosion_visual") < 0:
		pending("overcharge_mark.gd does not yet have _spawn_explosion_visual")
		return
	assert_true(src.find("_spawn_explosion_visual") >= 0,
		"overcharge_mark.gd must have _spawn_explosion_visual for explosion VFX")
	# Verify the explosion creates visual feedback (ColorRect expanding ring)
	assert_true(src.find("EXPLOSION_RING_EXPAND_TIME") >= 0,
		"overcharge_mark.gd must define EXPLOSION_RING_EXPAND_TIME for explosion animation")
	assert_true(src.find("tween_property") >= 0,
		"overcharge_mark.gd explosion must use tween for expand animation")
	# Verify detonation deals AOE damage
	assert_true(src.find("explosion_damage") >= 0 or src.find("_explosion_damage") >= 0,
		"overcharge_mark.gd must use explosion_damage for AOE damage calculation")
	assert_true(src.find("explosion_radius") >= 0 or src.find("_explosion_radius") >= 0,
		"overcharge_mark.gd must use explosion_radius for AOE range check")
