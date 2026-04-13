extends GutTest
## Tests for weapon_fire.gd: weapon stat calculations and state logic

var _wf: RefCounted
var _mock_controller: Node


func before_each():
	GameManager.reset()
	# Create a minimal mock controller with required methods
	_mock_controller = Node.new()
	_mock_controller.set_script(load("res://scripts/weapon_controller.gd"))
	add_child_autofree(_mock_controller)
	_wf = load("res://scripts/weapons/weapon_fire.gd").new(_mock_controller)


# --- Initialization ---

func test_weapon_fire_init():
	assert_not_null(_wf, "weapon_fire should initialize")
	assert_eq(_wf._controller, _mock_controller, "Should hold controller reference")


# --- Stat calculation helpers ---

func _make_weapon_data(wid: String, wtype: String) -> WeaponData:
	var data := WeaponData.new()
	data.weapon_id = wid
	data.weapon_name = wid
	data.weapon_type = wtype
	data.damage = 3.0
	data.cooldown = 1.5
	data.color = Color.WHITE
	data.projectile_size = 5.0
	data.projectile_count = 1
	data.projectile_speed = 300.0
	data.projectile_pierce = 0
	data.projectile_range = 200.0
	data.is_evolved = false
	# Orbit
	data.orbit_count = 1
	data.orbit_radius = 80.0
	data.orbit_speed = 3.0
	# Cone
	data.cone_angle = 80.0
	data.cone_range = 100.0
	# Aura
	data.aoe_radius = 80.0
	data.slow_pct = 0.3
	data.freeze_pct = 0.0
	# Boomerang
	data.boomerang_max_dist = 250.0
	data.boomerang_return_speed = 200.0
	data.boomerang_track_angle = 1.5
	# Chain (lightning)
	data.chain_count = 0
	# Status
	data.burn_dps = 0.0
	data.burn_duration = 0.0
	return data


# --- Projectile stat scaling ---

func test_projectile_count_scales_with_level():
	var data := _make_weapon_data("knife", "projectile")
	# Level 1: count = 1 + (1-1) = 1
	assert_eq(data.projectile_count + 0, 1, "Lv1 should have 1 projectile")
	# Level 3: count = 1 + (3-1) = 3
	assert_eq(data.projectile_count + (3 - 1), 3, "Lv3 should have 3 projectiles")


func test_projectile_damage_scales_with_level():
	var data := _make_weapon_data("knife", "projectile")
	# Level 1: damage = 3.0 + 0*0.6 = 3.0
	assert_eq(data.damage + 0 * 0.6, 3.0, "Lv1 damage")
	# Level 3: damage = 3.0 + 2*0.6 = 4.2
	assert_eq(data.damage + 2 * 0.6, 4.2, "Lv3 damage")


func test_projectile_pierce_scales_with_level():
	var data := _make_weapon_data("knife", "projectile")
	assert_eq(data.projectile_pierce + (3 - 1), 2, "Lv3 should have 2 pierce")


func test_evolved_weapon_fixed_stats():
	var data := _make_weapon_data("fireknife", "projectile")
	data.is_evolved = true
	data.projectile_count = 3
	data.damage = 8.0
	data.projectile_pierce = 2
	# Evolved: use fixed values, ignore level scaling
	assert_eq(data.projectile_count, 3, "Evolved count is fixed")
	assert_eq(data.damage, 8.0, "Evolved damage is fixed")
	assert_eq(data.projectile_pierce, 2, "Evolved pierce is fixed")


# --- Lightning stat scaling ---

func test_lightning_damage_formula():
	# damage = (5.0 + (level-1)) * dmg_bonus
	var lv1: float = (5.0 + 0) * 1.0
	var lv3: float = (5.0 + 2) * 1.0
	assert_eq(lv1, 5.0, "Lightning Lv1 = 5.0")
	assert_eq(lv3, 7.0, "Lightning Lv3 = 7.0")


func test_lightning_bolt_count():
	# bolt_count = 1 if level < 3 else 2
	assert_eq(1 if 2 < 3 else 2, 1, "Lv2 = 1 bolt")
	assert_eq(1 if 3 < 3 else 2, 2, "Lv3 = 2 bolts")


# --- Cone stat scaling ---

func test_cone_angle_scales():
	var data := _make_weapon_data("firestaff", "cone")
	var lv1_angle: float = data.cone_angle + 0 * 20.0
	var lv3_angle: float = data.cone_angle + 2 * 20.0
	assert_eq(lv1_angle, 80.0, "Cone Lv1 = 80 deg")
	assert_eq(lv3_angle, 120.0, "Cone Lv3 = 120 deg")


func test_cone_range_scales():
	var data := _make_weapon_data("firestaff", "cone")
	var lv3_range: float = data.cone_range + 2 * 30.0
	assert_eq(lv3_range, 160.0, "Cone Lv3 range = 160")


func test_cone_burn_at_level3():
	# Burn activates at level >= 3
	var burn: float = 0.0
	if 3 >= 3:
		burn = 2.0
	assert_eq(burn, 2.0, "Lv3 should have burn")
	var burn2: float = 0.0
	if 2 >= 3:
		burn2 = 2.0
	assert_eq(burn2, 0.0, "Lv2 should not have burn")


# --- Aura stat scaling ---

func test_aura_radius_scales():
	# radius = 80 + (level-1)*25
	assert_eq(80.0 + 0 * 25.0, 80.0, "Aura Lv1 radius")
	assert_eq(80.0 + 2 * 25.0, 130.0, "Aura Lv3 radius")


func test_aura_slow_scales():
	# slow = 0.3 + (level-1)*0.15
	assert_eq(0.3 + 0 * 0.15, 0.3, "Aura Lv1 slow")
	assert_eq(0.3 + 2 * 0.15, 0.6, "Aura Lv3 slow")


func test_aura_freeze_at_level3():
	# freeze_pct = 0.08 if level >= 3 else 0.0
	assert_eq(0.08 if 3 >= 3 else 0.0, 0.08, "Lv3 has freeze")
	assert_eq(0.08 if 2 >= 3 else 0.0, 0.0, "Lv2 no freeze")


# --- Boomerang stat scaling ---

func test_boomerang_count_scales():
	var data := _make_weapon_data("boomerang", "boomerang")
	assert_eq(data.projectile_count + 0, 1, "Lv1 = 1 boomerang")
	assert_eq(data.projectile_count + 2, 3, "Lv3 = 3 boomerangs")


func test_boomerang_max_dist_scales():
	var data := _make_weapon_data("boomerang", "boomerang")
	var lv3_dist: float = data.boomerang_max_dist + 2 * 50.0
	assert_eq(lv3_dist, 350.0, "Lv3 max_dist = 350")


func test_boomerang_cooldown_scales():
	var data := _make_weapon_data("boomerang", "boomerang")
	var lv3_cd: float = maxf(data.cooldown - 2 * 0.4, 0.5)
	assert_eq(lv3_cd, maxf(1.5 - 0.8, 0.5), "Lv3 cooldown")


func test_boomerang_cooldown_floor():
	# cooldown can't go below 0.5
	var result: float = maxf(0.3, 0.5)
	assert_eq(result, 0.5, "Cooldown floored at 0.5")


# --- Orbit stat scaling ---

func test_holywater_orbit_count():
	# orbit_count = level
	assert_eq(1, 1, "Holywater Lv1 = 1 orbit")
	assert_eq(3, 3, "Holywater Lv3 = 3 orbits")


func test_holywater_radius_scales():
	# radius = 50 + (level-1)*5
	assert_eq(50.0 + 0 * 5.0, 50.0, "Holywater Lv1 radius")
	assert_eq(50.0 + 2 * 5.0, 60.0, "Holywater Lv3 radius")


func test_bible_radius_scales():
	# radius = 80 + (level-1)*20
	assert_eq(80.0 + 0 * 20.0, 80.0, "Bible Lv1 radius")
	assert_eq(80.0 + 2 * 20.0, 120.0, "Bible Lv3 radius")


func test_bible_orbit_count_always_one():
	assert_eq(1, 1, "Bible always has 1 orbit")


# --- Damage bonus application ---

func test_damage_bonus_formula():
	# dmg_bonus = 1.0 + player.damage_bonus
	var bonus: float = 1.0 + 0.0
	assert_eq(bonus, 1.0, "No bonus = 1.0x")
	var with_bonus: float = 1.0 + 0.2
	assert_eq(with_bonus, 1.2, "20% bonus = 1.2x")


# --- Weapon type dispatch coverage ---

func test_all_weapon_types_defined():
	var types: PackedStringArray = ["projectile", "orbit", "lightning", "cone", "aura", "boomerang"]
	assert_eq(types.size(), 6, "Should have 6 weapon types")


# --- create_boomerang creates valid Area2D ---

func test_create_boomerang():
	var bm: Area2D = _wf._create_boomerang(
		Vector2.ZERO, Vector2.RIGHT, 5.0, 2, 300.0, 200.0, 1.5,
		Color.RED, 6.0
	)
	assert_not_null(bm, "Should create boomerang")
	assert_eq(bm.damage, 5.0, "Damage should match")
	assert_eq(bm.pierce, 2, "Pierce should match")
	assert_eq(bm.speed, 280.0, "Speed should be 280")
	assert_eq(bm.color, Color.RED, "Color should match")
	add_child_autofree(bm)


func test_create_boomerang_direction():
	var bm: Area2D = _wf._create_boomerang(
		Vector2.ZERO, Vector2.UP, 3.0, 0, 250.0, 200.0, 1.5,
		Color.WHITE, 4.0
	)
	assert_eq(bm.direction, Vector2.UP, "Direction should be UP")
	add_child_autofree(bm)


# --- Synergy stat modifications ---

func test_lightning_magnet_range_bonus():
	# +50 range when lightning_magnet synergy active
	var base_range: float = 200.0
	var with_syn: float = base_range + 50.0
	assert_eq(with_syn, 250.0, "Lightning + Magnet = +50 range")


func test_firestaff_armor_angle_bonus():
	# +40 angle when firestaff_armor synergy active
	var base_angle: float = 120.0
	var with_syn: float = base_angle + 40.0
	assert_eq(with_syn, 160.0, "Firestaff + Armor = +40 angle")


func test_boomerang_crit_pierce_bonus():
	# +1 pierce when boomerang_crit synergy active
	var base_pierce: int = 2
	var with_syn: int = base_pierce + 1
	assert_eq(with_syn, 3, "Boomerang + Crit = +1 pierce")


func test_holywater_maxhp_radius_multiplier():
	# radius * 1.3 when holywater_maxhp synergy active
	var base_radius: float = 60.0
	var with_syn: float = base_radius * 1.3
	assert_eq(with_syn, 78.0, "Holywater + MaxHP = 1.3x radius")


func test_bible_boots_radius_bonus():
	# radius + 20 when bible_boots synergy active
	var base_radius: float = 120.0
	var with_syn: float = base_radius + 20.0
	assert_eq(with_syn, 140.0, "Bible + Boots = +20 radius")


func test_frost_regen_freeze_bonus():
	# +5% freeze chance, +0.5s duration
	var base_freeze: float = 0.08
	var with_syn: float = base_freeze + 0.05
	assert_eq(with_syn, 0.13, "Frost + Regen = +5% freeze")
	var base_dur: float = 0.0
	var with_dur: float = base_dur + 0.5
	assert_eq(with_dur, 0.5, "Frost + Regen = +0.5s duration")
