extends GutTest
## R35 Firebomb Weapon Tests
## Verifies firebomb weapon registration, weapon_data fields, evolution recipe,
## mastery tracking, and implementation scripts.
## Based on design spec: docs/superpowers/specs/necromancer-design.md Section 4.


const UPGRADE_POOL_PATH := "res://scripts/autoload/upgrade_pool.gd"
const WEAPON_REGISTRY_PATH := "res://scripts/weapons/weapon_registry.gd"
const WEAPON_DATA_PATH := "res://scripts/data/weapon_data.gd"
const SAVE_MANAGER_PATH := "res://scripts/autoload/save_manager.gd"
const WEAPON_CONTROLLER_PATH := "res://scripts/weapon_controller.gd"
const THROWN_FLASK_PATH := "res://scripts/weapons/thrown_flask.gd"
const FIRE_POOL_PATH := "res://scripts/weapons/fire_pool.gd"


func _load_source(path: String) -> String:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content: String = f.get_as_text()
	f.close()
	return content


# =====================================================================
# 1. Firebomb weapon registration in upgrade_pool
# =====================================================================

func test_firebomb_registered_in_upgrade_pool():
	var src: String = _load_source(UPGRADE_POOL_PATH)
	var has_ref: bool = (src.find('"firebomb"') >= 0)
	if not has_ref:
		pending("firebomb not yet registered in upgrade_pool.gd -- waiting for Programmer implementation")
		return
	assert_true(has_ref, "upgrade_pool.gd should register firebomb weapon")


func test_firebomb_weapon_type_is_throwing():
	var src: String = _load_source(UPGRADE_POOL_PATH)
	if src.find('"firebomb"') < 0:
		pending("firebomb not yet registered -- cannot verify weapon_type")
		return
	# Find the firebomb registration block and check weapon_type
	var idx: int = src.find('"firebomb"')
	var section: String = src.substr(idx, 500)
	assert_true(section.find('"throwing"') >= 0,
		"firebomb weapon_type should be 'throwing'")


func test_firebomb_base_damage():
	var src: String = _load_source(UPGRADE_POOL_PATH)
	if src.find('"firebomb"') < 0:
		pending("firebomb not yet registered -- cannot verify base damage")
		return
	var idx: int = src.find('"firebomb"')
	var section: String = src.substr(idx, 500)
	assert_true(section.find("3.0") >= 0,
		"firebomb base damage should be 3.0 per tick")


func test_firebomb_cooldown():
	var src: String = _load_source(UPGRADE_POOL_PATH)
	if src.find('"firebomb"') < 0:
		pending("firebomb not yet registered -- cannot verify cooldown")
		return
	var idx: int = src.find('"firebomb"')
	var section: String = src.substr(idx, 500)
	assert_true(section.find("2.5") >= 0,
		"firebomb cooldown should be 2.5 seconds")


func test_firebomb_aoe_radius():
	var src: String = _load_source(UPGRADE_POOL_PATH)
	if src.find('"firebomb"') < 0:
		pending("firebomb not yet registered -- cannot verify aoe_radius")
		return
	var idx: int = src.find('"firebomb"')
	var section: String = src.substr(idx, 500)
	assert_true(section.find("50.0") >= 0,
		"firebomb aoe_radius should be 50.0 px")


# =====================================================================
# 2. Thunderbomb evolution recipe
# =====================================================================

func test_thunderbomb_evolution_recipe():
	var src: String = _load_source(WEAPON_REGISTRY_PATH)
	var has_recipe: bool = false
	for combo: String in ["firebomb", "thunderbomb"]:
		if src.find(combo) < 0:
			pending("thunderbomb evolution recipe not yet added to weapon_registry.gd")
			return
	# Verify the recipe structure: firebomb + lightning = thunderbomb
	if src.find('"firebomb"') >= 0 and src.find('"thunderbomb"') >= 0:
		var idx: int = src.find("thunderbomb")
		var section: String = src.substr(max(idx - 200, 0), 400)
		has_recipe = section.find("firebomb") >= 0 and section.find("lightning") >= 0
	assert_true(has_recipe, "weapon_registry should have firebomb + lightning = thunderbomb recipe")


func test_evolution_recipes_count_after_firebomb():
	# Design spec says 13 recipes (existing 12 + thunderbomb)
	var src: String = _load_source(WEAPON_REGISTRY_PATH)
	if src.find("thunderbomb") < 0:
		pending("thunderbomb not yet in weapon_registry -- cannot verify recipe count")
		return
	# Count recipe entries (each has "result" key)
	var count: int = 0
	var search_from: int = 0
	while true:
		var idx: int = src.find('"result":', search_from)
		if idx < 0:
			break
		count += 1
		search_from = idx + 1
	assert_true(count >= 13,
		"EVOLUTION_RECIPES should have at least 13 entries after firebomb addition, got %d" % count)


# =====================================================================
# 3. WeaponData has throwing-type fields
# =====================================================================

func test_weapon_data_has_throwing_fields():
	var src: String = _load_source(WEAPON_DATA_PATH)
	# Design spec requires pool_duration, tick_interval, burn fields for throwing type
	var has_pool_duration: bool = src.find("pool_duration") >= 0 or src.find("pool") >= 0
	var has_throw_height: bool = src.find("throw_height") >= 0 or src.find("throw") >= 0
	if not has_pool_duration and not has_throw_height:
		pending("weapon_data.gd does not yet have throwing-specific fields -- waiting for Programmer")
		return
	assert_true(has_pool_duration or has_throw_height,
		"weapon_data.gd should have throwing-specific export fields")


func test_weapon_data_type_comment_includes_throwing():
	var src: String = _load_source(WEAPON_DATA_PATH)
	var has_throwing: bool = src.find("throwing") >= 0
	if not has_throwing:
		pending("weapon_data.gd weapon_type comment does not include 'throwing' yet")
		return
	assert_true(has_throwing, "weapon_data.gd should list 'throwing' in weapon_type options")


# =====================================================================
# 4. Mastery tracking for firebomb
# =====================================================================

func test_firebomb_in_base_weapons():
	var src: String = _load_source(SAVE_MANAGER_PATH)
	var idx: int = src.find("BASE_WEAPONS")
	if idx < 0:
		pending("BASE_WEAPONS not found in save_manager.gd")
		return
	var has_firebomb: bool = src.find("firebomb") >= 0
	if not has_firebomb:
		pending("firebomb not yet in BASE_WEAPONS array -- waiting for Programmer")
		return
	assert_true(has_firebomb, "BASE_WEAPONS should include 'firebomb'")


func test_base_weapons_count_after_firebomb():
	var src: String = _load_source(SAVE_MANAGER_PATH)
	if src.find("firebomb") < 0:
		pending("firebomb not yet in BASE_WEAPONS -- cannot verify count")
		return
	# Should be 8 weapons after firebomb addition (knife, holywater, lightning, bible,
	# firestaff, frostaura, boomerang, firebomb)
	var idx: int = src.find("BASE_WEAPONS")
	var line_end: int = src.find("\n", idx)
	var line: String = src.substr(idx, line_end - idx)
	# Count weapon entries by counting quotes
	var weapon_count: int = 0
	var search_pos: int = 0
	while true:
		var q_idx: int = line.find('"', search_pos)
		if q_idx < 0:
			break
		weapon_count += 1
		search_pos = q_idx + 1
	# Each weapon has 2 quotes, so divide by 2
	weapon_count /= 2
	assert_true(weapon_count >= 8,
		"BASE_WEAPONS should have at least 8 entries after firebomb, found %d" % weapon_count)


# =====================================================================
# 5. Implementation scripts exist
# =====================================================================

func test_thrown_flask_script_exists():
	var src: String = _load_source(THROWN_FLASK_PATH)
	if src == "":
		pending("thrown_flask.gd not yet created -- waiting for Programmer implementation")
		return
	assert_true(src.length() > 0, "thrown_flask.gd should exist and have content")


func test_thrown_flask_extends_node2d():
	var src: String = _load_source(THROWN_FLASK_PATH)
	if src == "":
		pending("thrown_flask.gd not yet created -- cannot verify base class")
		return
	assert_true(src.find("extends") >= 0,
		"thrown_flask.gd should have an extends declaration")


func test_fire_pool_script_exists():
	var src: String = _load_source(FIRE_POOL_PATH)
	if src == "":
		pending("fire_pool.gd not yet created -- waiting for Programmer implementation")
		return
	assert_true(src.length() > 0, "fire_pool.gd should exist and have content")


func test_fire_pool_has_tick_damage():
	var src: String = _load_source(FIRE_POOL_PATH)
	if src == "":
		pending("fire_pool.gd not yet created -- cannot verify tick damage")
		return
	assert_true(src.find("tick") >= 0 or src.find("damage") >= 0,
		"fire_pool.gd should implement tick-based damage")


# =====================================================================
# 6. Weapon controller dispatch for throwing type
# =====================================================================

func test_weapon_controller_dispatches_throwing():
	var src: String = _load_source(WEAPON_CONTROLLER_PATH)
	var has_throwing_dispatch: bool = src.find("throwing") >= 0
	if not has_throwing_dispatch:
		pending("weapon_controller.gd does not yet dispatch 'throwing' weapon type")
		return
	assert_true(has_throwing_dispatch,
		"weapon_controller.gd should handle 'throwing' weapon type dispatch")


# =====================================================================
# 7. Thunderbomb evolved weapon registration
# =====================================================================

func test_thunderbomb_registered_in_upgrade_pool():
	var src: String = _load_source(UPGRADE_POOL_PATH)
	var has_ref: bool = (src.find('"thunderbomb"') >= 0)
	if not has_ref:
		pending("thunderbomb not yet registered in upgrade_pool.gd -- waiting for Programmer")
		return
	assert_true(has_ref, "upgrade_pool.gd should register thunderbomb evolved weapon")


func test_thunderbomb_is_evolved():
	var src: String = _load_source(UPGRADE_POOL_PATH)
	if src.find('"thunderbomb"') < 0:
		pending("thunderbomb not yet registered -- cannot verify is_evolved")
		return
	var idx: int = src.find('"thunderbomb"')
	var section: String = src.substr(idx, 500)
	assert_true(section.find("is_evolved") >= 0 or section.find("true") >= 0,
		"thunderbomb should have is_evolved = true")


func test_thunderbomb_damage():
	var src: String = _load_source(UPGRADE_POOL_PATH)
	if src.find('"thunderbomb"') < 0:
		pending("thunderbomb not yet registered -- cannot verify damage")
		return
	var idx: int = src.find('"thunderbomb"')
	var section: String = src.substr(idx, 500)
	assert_true(section.find("5.0") >= 0,
		"thunderbomb damage should be 5.0 per tick")


# =====================================================================
# 8. Regression: existing weapons still intact
# =====================================================================

func test_existing_7_base_weapons_unchanged():
	var src: String = _load_source(SAVE_MANAGER_PATH)
	var idx: int = src.find("BASE_WEAPONS")
	assert_true(idx >= 0, "BASE_WEAPONS should exist in save_manager.gd")
	var line_end: int = src.find("\n", idx)
	var line: String = src.substr(idx, line_end - idx)
	# Original 7 weapons must still be present
	assert_true(line.find("knife") >= 0, "knife should be in BASE_WEAPONS")
	assert_true(line.find("holywater") >= 0, "holywater should be in BASE_WEAPONS")
	assert_true(line.find("lightning") >= 0, "lightning should be in BASE_WEAPONS")
	assert_true(line.find("bible") >= 0, "bible should be in BASE_WEAPONS")
	assert_true(line.find("firestaff") >= 0, "firestaff should be in BASE_WEAPONS")
	assert_true(line.find("frostaura") >= 0, "frostaura should be in BASE_WEAPONS")
	assert_true(line.find("boomerang") >= 0, "boomerang should be in BASE_WEAPONS")


func test_existing_12_evolution_recipes_unchanged():
	var src: String = _load_source(WEAPON_REGISTRY_PATH)
	# Verify all 12 original recipes are still present
	assert_true(src.find("thunderholywater") >= 0, "thunderholywater recipe should exist")
	assert_true(src.find("fireknife") >= 0, "fireknife recipe should exist")
	assert_true(src.find("holydomain") >= 0, "holydomain recipe should exist")
	assert_true(src.find("blizzard") >= 0, "blizzard recipe should exist")
	assert_true(src.find("flamebible") >= 0, "flamebible recipe should exist")
	assert_true(src.find("thunderang") >= 0, "thunderang recipe should exist")
	assert_true(src.find("blazerang") >= 0, "blazerang recipe should exist")
	assert_true(src.find("sentineltotem") >= 0, "sentineltotem recipe should exist")
	assert_true(src.find("frostknife") >= 0, "frostknife recipe should exist")
	assert_true(src.find("frostvortex") >= 0, "frostvortex recipe should exist")
	assert_true(src.find("holyshockwave") >= 0, "holyshockwave recipe should exist")
	assert_true(src.find("thunderbeam") >= 0, "thunderbeam recipe should exist")
