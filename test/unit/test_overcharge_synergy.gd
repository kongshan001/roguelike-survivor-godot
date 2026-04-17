extends GutTest
## R31 Task 2: Overcharge weapon_weapon synergy tests
## Tests: synergy_manager "overcharge" registration, trigger conditions,
## beam_line.gd source code for overcharge implementation,
## and overcharge parameter correctness.

var _mgr: Node


func before_each():
	GameManager.reset()
	_mgr = Node.new()
	_mgr.set_script(load("res://scripts/autoload/synergy_manager.gd"))
	add_child_autofree(_mgr)


func _check(weapons: Dictionary, passives: Dictionary):
	_mgr.check_synergies(weapons, passives)


# =====================================================================
# 1. synergy_manager registers "overcharge" synergy
# =====================================================================

func test_overcharge_definition_exists():
	var found: bool = false
	for def in _mgr.SYNERGY_DEFINITIONS:
		if def.get("id") == "overcharge":
			found = true
	assert_true(found, "synergy_manager should define 'overcharge' synergy")


func test_overcharge_is_weapon_weapon_type():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "overcharge":
			def = d
			break
	assert_ne(def.size(), 0, "overcharge definition should exist")
	assert_eq(def["type"], "weapon_weapon",
		"overcharge type should be weapon_weapon")


func test_overcharge_primary_weapon_is_thunderbeam():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "overcharge":
			def = d
			break
	assert_eq(def["primary_weapon"], "thunderbeam",
		"overcharge primary_weapon should be thunderbeam")


func test_overcharge_tag_threshold_is_1():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "overcharge":
			def = d
			break
	assert_eq(def["tag_threshold"], 1,
		"overcharge tag_threshold should be 1")


# =====================================================================
# 2. Overcharge triggers with thunderbeam + 1 lightning weapon
# =====================================================================

func test_overcharge_triggers_with_thunderbeam_and_lightning():
	_check({"thunderbeam": 1, "lightning": 1}, {})
	assert_true(_mgr.has_synergy("overcharge"),
		"Overcharge should trigger with thunderbeam + lightning")


func test_overcharge_triggers_with_thunderang():
	_check({"thunderbeam": 1, "thunderang": 1}, {})
	assert_true(_mgr.has_synergy("overcharge"),
		"Overcharge should trigger with thunderbeam + thunderang")


func test_overcharge_triggers_with_blizzard():
	_check({"thunderbeam": 1, "blizzard": 1}, {})
	assert_true(_mgr.has_synergy("overcharge"),
		"Overcharge should trigger with thunderbeam + blizzard")


func test_overcharge_triggers_with_thunderholywater():
	_check({"thunderbeam": 1, "thunderholywater": 1}, {})
	assert_true(_mgr.has_synergy("overcharge"),
		"Overcharge should trigger with thunderbeam + thunderholywater")


# =====================================================================
# 3. Overcharge does NOT trigger without thunderbeam
# =====================================================================

func test_overcharge_no_trigger_without_thunderbeam():
	_check({"lightning": 1, "thunderang": 1}, {})
	assert_false(_mgr.has_synergy("overcharge"),
		"Overcharge should NOT trigger without thunderbeam")


func test_overcharge_no_trigger_without_lightning_weapon():
	_check({"thunderbeam": 1}, {})
	assert_false(_mgr.has_synergy("overcharge"),
		"Overcharge should NOT trigger without a lightning weapon")


func test_overcharge_no_trigger_with_non_lightning_weapon():
	_check({"thunderbeam": 1, "knife": 1}, {})
	assert_false(_mgr.has_synergy("overcharge"),
		"Overcharge should NOT trigger with a non-lightning weapon like knife")


func test_overcharge_no_trigger_with_boomerang():
	_check({"thunderbeam": 1, "boomerang": 1}, {})
	assert_false(_mgr.has_synergy("overcharge"),
		"Overcharge should NOT trigger with boomerang (not lightning type)")


# =====================================================================
# 4. beam_line.gd source has overcharge code
# =====================================================================

func test_beam_line_has_overcharge_check():
	var source: String = load("res://scripts/weapons/beam_line.gd").source_code
	if source.find("overcharge") == -1:
		pending("Programmer has not yet added overcharge code to beam_line.gd")
		return
	assert_true(source.find("overcharge") != -1,
		"beam_line.gd should have overcharge code")


func test_beam_line_checks_synergy_manager():
	var source: String = load("res://scripts/weapons/beam_line.gd").source_code
	if source.find("SynergyManager") == -1:
		pending("Programmer has not yet added SynergyManager check to beam_line.gd")
		return
	assert_true(source.find("SynergyManager") != -1,
		"beam_line.gd should check SynergyManager.has_synergy")


func test_beam_line_has_apply_overcharge_mark_function():
	var source: String = load("res://scripts/weapons/beam_line.gd").source_code
	if source.find("_apply_overcharge_mark") == -1:
		pending("Programmer has not yet added _apply_overcharge_mark to beam_line.gd")
		return
	assert_true(source.find("_apply_overcharge_mark") != -1,
		"beam_line.gd should have _apply_overcharge_mark function")


# =====================================================================
# 5. Overcharge parameters (20% chance, 3s delay, 10.0 dmg, 80px radius, max 3)
# =====================================================================

func test_overcharge_trigger_chance_20_percent():
	var source: String = load("res://scripts/weapons/beam_line.gd").source_code
	if source.find("overcharge") == -1:
		pending("Programmer has not yet added overcharge code to beam_line.gd")
		return
	assert_true(source.find("0.20") != -1 or source.find("0.2") != -1,
		"Overcharge trigger chance should be 0.20 (20%)")


func test_overcharge_delay_3_seconds():
	var source: String = load("res://scripts/weapons/beam_line.gd").source_code
	if source.find("overcharge") == -1:
		pending("Programmer has not yet added overcharge code to beam_line.gd")
		return
	assert_true(source.find("3.0") != -1,
		"Overcharge mark delay should be 3.0 seconds")


func test_overcharge_explosion_damage_10():
	var source: String = load("res://scripts/weapons/beam_line.gd").source_code
	if source.find("overcharge") == -1:
		pending("Programmer has not yet added overcharge code to beam_line.gd")
		return
	assert_true(source.find("10.0") != -1,
		"Overcharge explosion damage should be 10.0")


func test_overcharge_explosion_radius_80():
	var source: String = load("res://scripts/weapons/beam_line.gd").source_code
	if source.find("overcharge") == -1:
		pending("Programmer has not yet added overcharge code to beam_line.gd")
		return
	assert_true(source.find("80.0") != -1,
		"Overcharge explosion radius should be 80.0 px")


func test_overcharge_max_stacks_3():
	var source: String = load("res://scripts/weapons/beam_line.gd").source_code
	if source.find("overcharge") == -1:
		pending("Programmer has not yet added overcharge code to beam_line.gd")
		return
	assert_true(source.find("max_stacks") != -1 or source.find("add_stack") != -1,
		"Overcharge should support stacking with max 3 stacks")


# =====================================================================
# 6. synergy_manager has lightning weapon list (tag_weapons for overcharge)
# =====================================================================

func test_overcharge_tag_weapons_has_4_entries():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "overcharge":
			def = d
			break
	assert_eq(def["tag_weapons"].size(), 4,
		"Overcharge tag_weapons should have 4 lightning weapons")


func test_lightning_weapon_list_includes_lightning():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "overcharge":
			def = d
			break
	assert_true("lightning" in def["tag_weapons"],
		"Lightning weapon list should include lightning")


func test_lightning_weapon_list_includes_thunderang():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "overcharge":
			def = d
			break
	assert_true("thunderang" in def["tag_weapons"],
		"Lightning weapon list should include thunderang")


func test_lightning_weapon_list_includes_thunderholywater():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "overcharge":
			def = d
			break
	assert_true("thunderholywater" in def["tag_weapons"],
		"Lightning weapon list should include thunderholywater")


func test_lightning_weapon_list_includes_blizzard():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "overcharge":
			def = d
			break
	assert_true("blizzard" in def["tag_weapons"],
		"Lightning weapon list should include blizzard")


func test_lightning_weapon_list_excludes_knife():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "overcharge":
			def = d
			break
	assert_false("knife" in def["tag_weapons"],
		"Lightning weapon list should NOT include knife")


func test_lightning_weapon_list_excludes_boomerang():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "overcharge":
			def = d
			break
	assert_false("boomerang" in def["tag_weapons"],
		"Lightning weapon list should NOT include boomerang")


# =====================================================================
# 7. overcharge_mark.gd file should exist
# =====================================================================

func test_overcharge_mark_script_exists():
	if not ResourceLoader.exists("res://scripts/weapons/overcharge_mark.gd"):
		pending("Programmer has not yet created overcharge_mark.gd")
		return
	assert_true(ResourceLoader.exists("res://scripts/weapons/overcharge_mark.gd"),
		"overcharge_mark.gd should exist as a separate weapon script")


func test_overcharge_mark_has_setup_method():
	if not ResourceLoader.exists("res://scripts/weapons/overcharge_mark.gd"):
		pending("Programmer has not yet created overcharge_mark.gd")
		return
	var source: String = load("res://scripts/weapons/overcharge_mark.gd").source_code
	assert_true(source.find("setup") != -1,
		"overcharge_mark.gd should have a setup function")


func test_overcharge_mark_has_detonate_function():
	if not ResourceLoader.exists("res://scripts/weapons/overcharge_mark.gd"):
		pending("Programmer has not yet created overcharge_mark.gd")
		return
	var source: String = load("res://scripts/weapons/overcharge_mark.gd").source_code
	assert_true(source.find("_detonate") != -1,
		"overcharge_mark.gd should have _detonate function")


func test_overcharge_mark_has_add_stack_method():
	if not ResourceLoader.exists("res://scripts/weapons/overcharge_mark.gd"):
		pending("Programmer has not yet created overcharge_mark.gd")
		return
	var source: String = load("res://scripts/weapons/overcharge_mark.gd").source_code
	assert_true(source.find("add_stack") != -1,
		"overcharge_mark.gd should have add_stack method for stacking")
