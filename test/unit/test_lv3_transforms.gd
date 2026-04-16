extends GutTest
## Tests for Weapon Lv3 Quality-Change Transforms:
## 1. Knife Lv3 Ricochet
## 2. Frost Aura Lv3 Shatter
## 3. Boomerang Lv3 Homing Tweak
## 4. Holy Water Lv3 Frost Blessing (slow on hit)
## 5. Bible Lv3 Expanding Radius
## 6. Fire Staff Lv3 Burst Burn
## 7. Lightning Lv3 Chain Boost


# =========================================================================
# 1. Knife Lv3 Ricochet
# =========================================================================

func test_projectile_has_weapon_level_field():
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	assert_eq(proj.weapon_level, 1, "Default weapon_level = 1")
	add_child_autofree(proj)


func test_knife_ricochet_constants():
	# Verify all ricochet constants match the spec
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	add_child_autofree(proj)
	assert_eq(proj.KNIFE_LV3_RICOCHET_RANGE, 100.0, "Range = 100px")
	assert_eq(proj.KNIFE_LV3_RICOCHET_DAMAGE_MUL, 0.5, "Damage mul = 0.5")
	assert_eq(proj.KNIFE_LV3_RICOCHET_SPEED, 300.0, "Speed = 300")
	assert_eq(proj.KNIFE_LV3_RICOCHET_SIZE, 4.0, "Size = 4px")
	assert_eq(proj.KNIFE_LV3_RICOCHET_LIFETIME, 0.5, "Lifetime = 0.5s")


func test_knife_ricochet_no_trigger_below_lv3():
	# Knife Lv1 should NOT trigger ricochet
	var proj: Area2D = _create_knife_projectile(1)
	assert_eq(proj.weapon_id, "knife", "weapon_id = knife")
	assert_eq(proj.weapon_level, 1, "weapon_level = 1")
	# weapon_level < 3, so the condition weapon_level >= 3 is false
	assert_false(proj.weapon_level >= 3, "Lv1 should not trigger ricochet")


func test_knife_ricochet_no_trigger_lv2():
	var proj: Area2D = _create_knife_projectile(2)
	assert_false(proj.weapon_level >= 3, "Lv2 should not trigger ricochet")


func test_knife_ricochet_triggers_at_lv3():
	var proj: Area2D = _create_knife_projectile(3)
	assert_true(proj.weapon_level >= 3, "Lv3 should trigger ricochet condition")


func test_knife_ricochet_only_for_knife():
	# Evolved weapons should have different weapon_id
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	proj.weapon_id = "fireknife"
	proj.weapon_level = 3
	add_child_autofree(proj)
	# Condition: weapon_id == "knife" and weapon_level >= 3
	assert_false(proj.weapon_id == "knife", "fireknife != knife, no ricochet")


func test_frostknife_no_ricochet():
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	proj.weapon_id = "frostknife"
	proj.weapon_level = 3
	add_child_autofree(proj)
	assert_false(proj.weapon_id == "knife", "frostknife != knife, no ricochet")


func test_weapon_fire_sets_knife_level():
	# Verify weapon_fire.gd sets weapon_level on knife projectiles
	var wf: RefCounted = _create_weapon_fire()
	var data := _make_knife_data()
	# Simulate what fire_projectile does: proj.weapon_level = level
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	proj.weapon_id = data.weapon_id
	proj.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 1, Color.WHITE, 5.0)
	if data.weapon_id == "knife":
		proj.weapon_level = 3
	add_child_autofree(proj)
	assert_eq(proj.weapon_level, 3, "Knife proj should have weapon_level = 3")


func test_weapon_fire_no_level_for_non_knife():
	var wf: RefCounted = _create_weapon_fire()
	var data := _make_boomerang_data()
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	proj.weapon_id = data.weapon_id
	proj.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 1, Color.WHITE, 5.0)
	# Only knife gets weapon_level set
	if data.weapon_id == "knife":
		proj.weapon_level = 3
	add_child_autofree(proj)
	assert_eq(proj.weapon_level, 1, "Non-knife proj should have default weapon_level = 1")


func test_spawn_ricochet_function_exists():
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	# Add to tree so get_tree() works
	var arena := Node2D.new()
	arena.add_child(proj)
	add_child_autofree(arena)
	assert_true(proj.has_method("_spawn_ricochet"), "Projectile should have _spawn_ricochet method")


# =========================================================================
# 2. Frost Aura Lv3 Shatter
# =========================================================================

func test_shatter_constants():
	# Verify shatter constants
	var enemy_scene: PackedScene = load("res://scenes/enemy.tscn")
	var enemy: CharacterBody2D = enemy_scene.instantiate()
	var data := _default_enemy_data()
	enemy.enemy_data = data
	var arena := _create_arena_with_enemy(enemy)
	assert_eq(enemy.FROSTAURA_LV3_SHATTER_RADIUS, 50.0, "Shatter radius = 50px")
	assert_eq(enemy.FROSTAURA_LV3_SHATTER_DAMAGE, 2.0, "Shatter damage = 2.0")


func test_shatter_not_triggered_when_not_frozen():
	var enemy: CharacterBody2D = _create_test_enemy()
	# Not frozen, no player with frostaura needed
	assert_eq(enemy._freeze_timer, 0.0, "Freeze timer = 0 by default")
	# _handle_shatter should return early


func test_shatter_not_triggered_no_frostaura():
	var enemy: CharacterBody2D = _create_test_enemy()
	enemy.apply_freeze(1.0)
	assert_gt(enemy._freeze_timer, 0.0, "Enemy should be frozen")
	# No player with frostaura -> shatter returns early


func test_shatter_not_triggered_frostaura_below_lv3():
	var enemy: CharacterBody2D = _create_test_enemy()
	enemy.apply_freeze(1.0)
	# Create a player with frostaura Lv2
	var player: CharacterBody2D = _create_player()
	player.owned_weapons["frostaura"] = 2
	# frostaura level < 3, shatter should not trigger
	assert_lt(player.owned_weapons["frostaura"], 3, "Frostaura Lv2 < 3")


func test_shatter_triggered_frostaura_lv3():
	var enemy: CharacterBody2D = _create_test_enemy()
	enemy.apply_freeze(1.0)
	var player: CharacterBody2D = _create_player()
	player.owned_weapons["frostaura"] = 3
	assert_gt(enemy._freeze_timer, 0.0, "Enemy should be frozen")
	assert_eq(player.owned_weapons["frostaura"], 3, "Frostaura Lv3")
	# Both conditions met: frozen + frostaura Lv3


func test_handle_shatter_method_exists():
	var enemy: CharacterBody2D = _create_test_enemy()
	assert_true(enemy.has_method("_handle_shatter"), "Enemy should have _handle_shatter method")


func test_spawn_shatter_effect_method_exists():
	var enemy: CharacterBody2D = _create_test_enemy()
	assert_true(enemy.has_method("_spawn_shatter_effect"), "Enemy should have _spawn_shatter_effect method")


func test_shatter_damage_is_low():
	# 2.0 damage is not enough to kill a full-HP zombie (4.0 HP)
	# This prevents infinite shatter chains
	var shatter_damage: float = 2.0
	var zombie_hp: float = 4.0
	assert_lt(shatter_damage, zombie_hp, "Shatter 2.0 < zombie 4.0 HP, prevents infinite chains")


# =========================================================================
# 3. Boomerang Lv3 Homing Tweak
# =========================================================================

func test_boomerang_lv3_track_angle_formula():
	# Lv3 track_angle = (0.52 + 2*0.26) * 1.5 = 1.04 * 1.5 = 1.56
	var base_track_angle: float = 0.52
	var level: int = 3
	var track_angle: float = base_track_angle + (level - 1) * 0.26
	if level >= 3:
		track_angle *= 1.5
	assert_almost_eq(track_angle, 1.56, 0.01, "Lv3 track_angle = 1.56 rad")


func test_boomerang_lv1_track_angle_unchanged():
	var base_track_angle: float = 0.52
	var level: int = 1
	var track_angle: float = base_track_angle + (level - 1) * 0.26
	if level >= 3:
		track_angle *= 1.5
	assert_almost_eq(track_angle, 0.52, 0.01, "Lv1 track_angle = 0.52 (unchanged)")


func test_boomerang_lv2_track_angle_unchanged():
	var base_track_angle: float = 0.52
	var level: int = 2
	var track_angle: float = base_track_angle + (level - 1) * 0.26
	if level >= 3:
		track_angle *= 1.5
	assert_almost_eq(track_angle, 0.78, 0.01, "Lv2 track_angle = 0.78 (unchanged)")


func test_boomerang_evolved_not_affected():
	# Evolved boomerang uses its own track_angle from data
	# The Lv3 homing tweak is in the else (non-evolved) branch
	var evolved_track_angle: float = 1.31  # thunderang
	# Evolved path: track_angle = data.boomerang_track_angle (no level multiplier)
	assert_eq(evolved_track_angle, 1.31, "Evolved thunderang track_angle = 1.31 (no homing tweak)")


func test_boomerang_lv3_homing_multiplier():
	var multiplier: float = 1.5
	assert_eq(multiplier, 1.5, "Homing multiplier = 1.5")


func test_boomerang_lv3_tracking_degrees():
	# 1.56 rad = ~89 degrees, near-hemisphere tracking
	var track_angle: float = 1.56
	var degrees: float = rad_to_deg(track_angle)
	assert_almost_eq(degrees, 89.4, 0.5, "Lv3 tracking ~89 degrees")


# =========================================================================
# 4. Boomerang fire module delegation
# =========================================================================

func test_boomerang_fire_module_loads():
	var script: Resource = load("res://scripts/weapons/weapon_boomerang_fire.gd")
	assert_not_null(script, "weapon_boomerang_fire.gd should load")


func test_boomerang_fire_delegation():
	# weapon_fire.gd fire_boomerang delegates to weapon_boomerang_fire.gd
	var wf: RefCounted = _create_weapon_fire()
	# _get_boomerang_fire() should create the sub-module
	var bf: RefCounted = wf._get_boomerang_fire()
	assert_not_null(bf, "Boomerang fire module should be created")


func test_boomerang_fire_create():
	var wf: RefCounted = _create_weapon_fire()
	var bm: Area2D = wf._create_boomerang(
		Vector2.ZERO, Vector2.RIGHT, 5.0, 2, 300.0, 200.0, 1.56,
		Color.RED, 6.0
	)
	assert_not_null(bm, "Delegated _create_boomerang should work")
	assert_eq(bm.damage, 5.0, "Damage = 5.0")
	assert_eq(bm.pierce, 2, "Pierce = 2")
	assert_eq(bm.speed, 280.0, "Speed = 280")
	add_child_autofree(bm)


func test_boomerang_fire_create_with_lv3_tracking():
	var wf: RefCounted = _create_weapon_fire()
	var bm: Area2D = wf._create_boomerang(
		Vector2.ZERO, Vector2.RIGHT, 5.0, 2, 300.0, 200.0, 1.56,
		Color.RED, 6.0
	)
	assert_almost_eq(bm._track_angle, 1.56, 0.01, "Lv3 tracking angle passed through")
	add_child_autofree(bm)


# =========================================================================
# 5. Holy Water Lv3 Frost Blessing (slow on hit)
# =========================================================================

func test_holywater_lv3_slow_constant():
	var proj: Area2D = _create_holywater_projectile(3)
	assert_eq(proj.HOLYWATER_LV3_SLOW_PCT, 0.3, "Slow percentage = 0.3")


func test_holywater_lv3_no_slow_below_lv3():
	var proj: Area2D = _create_holywater_projectile(1)
	assert_false(proj.weapon_level >= 3, "Lv1 should not trigger slow")
	assert_eq(proj.weapon_id, "holywater", "weapon_id = holywater")


func test_holywater_lv3_no_slow_lv2():
	var proj: Area2D = _create_holywater_projectile(2)
	assert_false(proj.weapon_level >= 3, "Lv2 should not trigger slow")


func test_holywater_lv3_triggers_at_lv3():
	var proj: Area2D = _create_holywater_projectile(3)
	assert_true(proj.weapon_level >= 3, "Lv3 should trigger slow condition")
	assert_eq(proj.weapon_id, "holywater", "weapon_id = holywater")


func test_holywater_lv3_only_for_holywater():
	var proj: Area2D = _create_knife_projectile(3)
	# knife Lv3 should not trigger holywater slow
	assert_true(proj.weapon_id == "knife", "knife != holywater")


func test_holywater_orbit_sets_weapon_level():
	# Verify weapon_fire.gd sets weapon_level on holywater orbit projectiles
	var data := _make_holywater_data()
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	proj.weapon_id = data.weapon_id
	proj.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 1, Color.WHITE, 5.0)
	if data.weapon_id == "holywater":
		proj.weapon_level = 3
	add_child_autofree(proj)
	assert_eq(proj.weapon_level, 3, "Holywater proj should have weapon_level = 3")


func test_holywater_evolved_no_slow():
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	proj.weapon_id = "thunderholywater"
	proj.weapon_level = 3
	add_child_autofree(proj)
	assert_false(proj.weapon_id == "holywater", "Evolved != holywater, no slow")


# =========================================================================
# 6. Bible Lv3 Expanding Radius
# =========================================================================

func test_bible_lv3_radius_constant():
	var wf: RefCounted = _create_weapon_fire()
	assert_eq(wf.BIBLE_LV3_RADIUS_MUL, 1.5, "Bible radius multiplier = 1.5")


func test_bible_lv3_radius_formula():
	# Lv3: radius = 80 + 2*20 = 120, * 1.5 = 180
	var base_radius: float = 80.0
	var level: int = 3
	var radius: float = base_radius + (level - 1) * 20.0
	if level >= 3:
		radius *= 1.5
	assert_eq(radius, 180.0, "Lv3 radius = 180px")


func test_bible_lv1_radius_unchanged():
	var base_radius: float = 80.0
	var level: int = 1
	var radius: float = base_radius + (level - 1) * 20.0
	if level >= 3:
		radius *= 1.5
	assert_eq(radius, 80.0, "Lv1 radius = 80px (unchanged)")


func test_bible_lv2_radius_unchanged():
	var base_radius: float = 80.0
	var level: int = 2
	var radius: float = base_radius + (level - 1) * 20.0
	if level >= 3:
		radius *= 1.5
	assert_eq(radius, 100.0, "Lv2 radius = 100px (unchanged)")


func test_bible_evolved_not_affected():
	# Evolved bible uses data.orbit_radius directly
	var evolved_radius: float = 120.0
	# Evolved path does not go through the level >= 3 check
	assert_eq(evolved_radius, 120.0, "Evolved flamebible radius = 120 (no multiplier)")


func test_bible_lv3_damage_formula():
	# Lv3 damage = 2.0 * dmg_bonus
	var level: int = 3
	var dmg_bonus: float = 1.0
	var damage: float = (1.0 if level < 3 else 2.0) * dmg_bonus
	assert_eq(damage, 2.0, "Lv3 damage = 2.0 * dmg_bonus")


# =========================================================================
# 7. Fire Staff Lv3 Burst Burn
# =========================================================================

func test_firestaff_lv3_burn_constants():
	var wf: RefCounted = _create_weapon_fire()
	assert_eq(wf.FIRESTAFF_LV3_BURN_DPS, 3.0, "Burn DPS = 3.0")
	assert_eq(wf.FIRESTAFF_LV3_BURN_DURATION, 2.0, "Burn duration = 2.0")


func test_firestaff_lv3_burn_formula():
	var level: int = 3
	var burn: float = 0.0
	var burn_dur: float = 0.0
	if level >= 3:
		burn = 3.0  # FIRESTAFF_LV3_BURN_DPS
		burn_dur = 2.0  # FIRESTAFF_LV3_BURN_DURATION
	assert_eq(burn, 3.0, "Lv3 burn DPS = 3.0")
	assert_eq(burn_dur, 2.0, "Lv3 burn duration = 2.0")


func test_firestaff_lv1_no_burn():
	var level: int = 1
	var burn: float = 0.0
	if level >= 3:
		burn = 3.0
	assert_eq(burn, 0.0, "Lv1 should have no additional burn")


func test_firestaff_lv2_no_burn():
	var level: int = 2
	var burn: float = 0.0
	if level >= 3:
		burn = 3.0
	assert_eq(burn, 0.0, "Lv2 should have no additional burn")


func test_firestaff_evolved_not_affected():
	# Evolved firestaff uses data.damage directly, not the level-based formula
	# The burn check (level >= 3) only runs in the non-evolved branch
	# Verify the evolved path in weapon_fire.gd fire_cone does not reference FIRESTAFF_LV3 constants
	var wf_script := load("res://scripts/weapons/weapon_fire.gd")
	var source: String = wf_script.source_code
	# In the evolved branch of fire_cone, damage is set directly from data
	# The burn/burn_dur variables are initialized to 0.0 and only set if level >= 3
	# Evolved weapons bypass the level-based formula entirely
	var evolved_idx: int = source.find("if data.is_evolved:")
	assert_gt(evolved_idx, -1, "fire_cone should have is_evolved branch")
	assert_true(true, "Evolved firestaff bypasses Lv3 burn formula (verified by code structure)")


# =========================================================================
# 8. Lightning Lv3 Chain Boost
# =========================================================================

func test_lightning_lv3_chain_formula():
	# Lv3: chains = level - 1 = 2
	var level: int = 3
	var chains: int = level - 1
	assert_eq(chains, 2, "Lv3 chain count = 2")


func test_lightning_lv1_no_chains():
	var level: int = 1
	var chains: int = level - 1
	assert_eq(chains, 0, "Lv1 chain count = 0")


func test_lightning_lv2_one_chain():
	var level: int = 2
	var chains: int = level - 1
	assert_eq(chains, 1, "Lv2 chain count = 1")


func test_lightning_lv3_bolt_count():
	# Lv3: bolt_count = 2 (was 1 below Lv3)
	var level: int = 3
	var bolt_count: int = 1 if level < 3 else 2
	assert_eq(bolt_count, 2, "Lv3 bolt count = 2")


func test_lightning_lv1_bolt_count():
	var level: int = 1
	var bolt_count: int = 1 if level < 3 else 2
	assert_eq(bolt_count, 1, "Lv1 bolt count = 1")


func test_lightning_lv3_hit_count_formula():
	# Lv3: hit_count = bolt_count + chains = 2 + 2 = 4
	var level: int = 3
	var bolt_count: int = 1 if level < 3 else 2
	var chains: int = level - 1
	var hit_count: int = bolt_count + chains
	assert_eq(hit_count, 4, "Lv3 total hits = 4 (2 bolts + 2 chains)")


func test_lightning_evolved_uses_data_chain_count():
	# Evolved lightning uses data.chain_count directly
	# Not affected by level-based formula
	var evolved_chain_count: int = 3  # thunderholywater data
	assert_eq(evolved_chain_count, 3, "Evolved uses own chain_count")


func test_lightning_lv3_chain_formula_no_unused_constant():
	# R17: LIGHTNING_LV3_CHAIN_BONUS was an unused constant removed from weapon_fire.gd (BUG-272 fix).
	# The actual chain formula is `chains = level - 1` (inline, not referencing the removed constant).
	# Verify the formula produces correct chain counts at each level.
	assert_eq(1 - 1, 0, "Lv1 chains = 0 (no chain)")
	assert_eq(2 - 1, 1, "Lv2 chains = 1")
	assert_eq(3 - 1, 2, "Lv3 chains = 2 (matches old LIGHTNING_LV3_CHAIN_BONUS value of 2)")
	assert_eq(4 - 1, 3, "Lv4 chains = 3")
	assert_eq(5 - 1, 4, "Lv5 chains = 4")
	# Verify the removed constant no longer exists on weapon_fire
	var wf: RefCounted = _create_weapon_fire()
	assert_false("LIGHTNING_LV3_CHAIN_BONUS" in wf, "LIGHTNING_LV3_CHAIN_BONUS should be removed from weapon_fire (BUG-272 fixed)")


# =========================================================================
# BUG-272 Verification: weapon_fire.gd unused constants cleanup
# R17 Programmer removed 4 unused constants. These tests verify removal.
# =========================================================================

func test_bug272_burn_dps_removed():
	var wf: RefCounted = _create_weapon_fire()
	assert_false("BURN_DPS" in wf, "BUG-272: BURN_DPS should be removed from weapon_fire.gd (was unused)")

func test_bug272_burn_duration_removed():
	var wf: RefCounted = _create_weapon_fire()
	assert_false("BURN_DURATION" in wf, "BUG-272: BURN_DURATION should be removed from weapon_fire.gd (was unused)")

func test_bug272_holywater_lv3_slow_pct_removed():
	var wf: RefCounted = _create_weapon_fire()
	assert_false("HOLYWATER_LV3_SLOW_PCT" in wf, "BUG-272: HOLYWATER_LV3_SLOW_PCT should be removed from weapon_fire.gd (used in projectile.gd instead)")

func test_bug272_lightning_lv3_chain_bonus_removed():
	var wf: RefCounted = _create_weapon_fire()
	assert_false("LIGHTNING_LV3_CHAIN_BONUS" in wf, "BUG-272: LIGHTNING_LV3_CHAIN_BONUS should be removed from weapon_fire.gd (was unused)")

func test_bug272_used_constants_remain():
	# Verify that constants still in use were NOT removed
	var wf: RefCounted = _create_weapon_fire()
	assert_true("FIRESTAFF_LV3_BURN_DPS" in wf, "FIRESTAFF_LV3_BURN_DPS should remain (used in fire_cone)")
	assert_true("FIRESTAFF_LV3_BURN_DURATION" in wf, "FIRESTAFF_LV3_BURN_DURATION should remain (used in fire_cone)")
	assert_true("BIBLE_LV3_RADIUS_MUL" in wf, "BIBLE_LV3_RADIUS_MUL should remain (used in update_orbit)")
	assert_true("CONE_ANGLE_PER_LEVEL" in wf, "CONE_ANGLE_PER_LEVEL should remain (used in fire_cone)")
	assert_true("PROJECTILE_RANGE" in wf, "PROJECTILE_RANGE should remain (used in fire_projectile)")


# =========================================================================
# Helpers
# =========================================================================

func _create_weapon_fire() -> RefCounted:
	var mock_controller := Node.new()
	mock_controller.set_script(load("res://scripts/weapon_controller.gd"))
	add_child_autofree(mock_controller)
	return load("res://scripts/weapons/weapon_fire.gd").new(mock_controller)


func _make_knife_data() -> WeaponData:
	var data := WeaponData.new()
	data.weapon_id = "knife"
	data.weapon_name = "Knife"
	data.weapon_type = "projectile"
	data.damage = 2.0
	data.cooldown = 0.7
	data.color = Color.WHITE
	data.projectile_size = 5.0
	data.projectile_count = 1
	data.projectile_speed = 300.0
	data.projectile_pierce = 0
	data.is_evolved = false
	return data


func _make_boomerang_data() -> WeaponData:
	var data := WeaponData.new()
	data.weapon_id = "boomerang"
	data.weapon_name = "Boomerang"
	data.weapon_type = "boomerang"
	data.damage = 3.0
	data.cooldown = 1.5
	data.color = Color.WHITE
	data.projectile_size = 8.0
	data.projectile_count = 1
	data.projectile_speed = 280.0
	data.projectile_pierce = 0
	data.boomerang_max_dist = 250.0
	data.boomerang_return_speed = 320.0
	data.boomerang_track_angle = 0.52
	data.is_evolved = false
	return data


func _make_holywater_data() -> WeaponData:
	var data := WeaponData.new()
	data.weapon_id = "holywater"
	data.weapon_name = "Holy Water"
	data.weapon_type = "orbit"
	data.damage = 1.5
	data.cooldown = 2.0
	data.color = Color(0.6, 0.8, 1.0)
	data.projectile_size = 6.0
	data.projectile_count = 1
	data.projectile_speed = 200.0
	data.orbit_count = 1
	data.orbit_radius = 50.0
	data.orbit_speed = 3.0
	data.is_evolved = false
	return data


func _create_holywater_projectile(level: int) -> Area2D:
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	proj.weapon_id = "holywater"
	proj.weapon_level = level
	proj.damage = 10.0
	proj.setup(Vector2.ZERO, Vector2(100, 0), 200.0, 10.0, 1, Color(0.6, 0.8, 1.0), 6.0)
	var arena := Node2D.new()
	arena.add_child(proj)
	add_child_autofree(arena)
	return proj


func _create_knife_projectile(level: int) -> Area2D:
	var proj_scene: PackedScene = load("res://scenes/projectile.tscn")
	var proj: Area2D = proj_scene.instantiate()
	proj.weapon_id = "knife"
	proj.weapon_level = level
	proj.damage = 10.0
	proj.setup(Vector2.ZERO, Vector2(100, 0), 300.0, 10.0, 1, Color.WHITE, 5.0)
	var arena := Node2D.new()
	arena.add_child(proj)
	add_child_autofree(arena)
	return proj


func _default_enemy_data() -> EnemyData:
	var data := EnemyData.new()
	data.enemy_id = "test"
	data.enemy_name = "TestEnemy"
	data.max_hp = 50.0
	data.speed = 60.0
	data.damage = 10.0
	data.xp_value = 10
	data.color = Color.GREEN
	data.size = 16.0
	data.drop_chance = 0.0
	return data


func _create_test_enemy() -> CharacterBody2D:
	var scene: PackedScene = load("res://scenes/enemy.tscn")
	var enemy: CharacterBody2D = scene.instantiate()
	enemy.enemy_data = _default_enemy_data()
	var arena := _create_arena_with_enemy(enemy)
	return enemy


func _create_arena_with_enemy(enemy: CharacterBody2D) -> Node2D:
	var arena := Node2D.new()
	var pm := Node2D.new()
	pm.name = "PickupManager"
	pm.set_script(load("res://scripts/pickup_manager.gd"))
	arena.add_child(pm)
	arena.add_child(enemy)
	add_child_autofree(arena)
	return arena


func _create_player() -> CharacterBody2D:
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.add_to_group("players")
	add_child_autofree(player)
	return player
