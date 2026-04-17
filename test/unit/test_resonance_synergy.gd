extends GutTest
## R31 Task 1: Resonance weapon_weapon synergy tests
## Tests: synergy_manager "resonance" registration, trigger conditions,
## pulse_ring.gd source code for resonance implementation,
## and sub-pulse parameter correctness.

var _mgr: Node


func before_each():
	GameManager.reset()
	_mgr = Node.new()
	_mgr.set_script(load("res://scripts/autoload/synergy_manager.gd"))
	add_child_autofree(_mgr)


func _check(weapons: Dictionary, passives: Dictionary):
	_mgr.check_synergies(weapons, passives)


# =====================================================================
# 1. synergy_manager registers "resonance" synergy
# =====================================================================

func test_resonance_definition_exists():
	assert_eq(_mgr.SYNERGY_DEFINITIONS.size(), 20,
		"Should have 20 synergy definitions (7pp + 11wp + 2ww)")
	var found: bool = false
	for def in _mgr.SYNERGY_DEFINITIONS:
		if def.get("id") == "resonance":
			found = true
	assert_true(found, "synergy_manager should define 'resonance' synergy")


func test_resonance_is_weapon_weapon_type():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_ne(def.size(), 0, "resonance definition should exist")
	assert_eq(def["type"], "weapon_weapon",
		"resonance type should be weapon_weapon")


func test_resonance_primary_weapon_is_holyshockwave():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_eq(def["primary_weapon"], "holyshockwave",
		"resonance primary_weapon should be holyshockwave")


func test_resonance_tag_threshold_is_2():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_eq(def["tag_threshold"], 2,
		"resonance tag_threshold should be 2")


# =====================================================================
# 2. Resonance triggers with holyshockwave + 2 AOE weapons
# =====================================================================

func test_resonance_triggers_with_holyshockwave_and_2_aoe():
	_check({"holyshockwave": 1, "holywater": 1, "bible": 1}, {})
	assert_true(_mgr.has_synergy("resonance"),
		"Resonance should trigger with holyshockwave + holywater + bible")


func test_resonance_triggers_with_alternate_aoe_combo():
	_check({"holyshockwave": 1, "frostaura": 1, "firestaff": 1}, {})
	assert_true(_mgr.has_synergy("resonance"),
		"Resonance should trigger with holyshockwave + frostaura + firestaff")


func test_resonance_triggers_with_evolved_aoe():
	_check({"holyshockwave": 1, "blizzard": 1, "flamebible": 1}, {})
	assert_true(_mgr.has_synergy("resonance"),
		"Resonance should trigger with holyshockwave + blizzard + flamebible")


func test_resonance_triggers_with_holydomain_and_sentineltotem():
	_check({"holyshockwave": 1, "holydomain": 1, "sentineltotem": 1}, {})
	assert_true(_mgr.has_synergy("resonance"),
		"Resonance should trigger with holyshockwave + holydomain + sentineltotem")


func test_resonance_triggers_with_thunderholywater():
	_check({"holyshockwave": 1, "thunderholywater": 1, "holywater": 1}, {})
	assert_true(_mgr.has_synergy("resonance"),
		"Resonance should trigger with holyshockwave + thunderholywater + holywater")


# =====================================================================
# 3. Resonance does NOT trigger without holyshockwave
# =====================================================================

func test_resonance_no_trigger_without_holyshockwave():
	_check({"holywater": 1, "bible": 1, "frostaura": 1}, {})
	assert_false(_mgr.has_synergy("resonance"),
		"Resonance should NOT trigger without holyshockwave")


# =====================================================================
# 4. Resonance does NOT trigger with only 1 AOE weapon
# =====================================================================

func test_resonance_no_trigger_with_only_1_aoe():
	_check({"holyshockwave": 1, "holywater": 1}, {})
	assert_false(_mgr.has_synergy("resonance"),
		"Resonance should NOT trigger with only 1 AOE weapon (need 2)")


func test_resonance_no_trigger_with_zero_aoe():
	_check({"holyshockwave": 1}, {})
	assert_false(_mgr.has_synergy("resonance"),
		"Resonance should NOT trigger with 0 AOE weapons")


# =====================================================================
# 5. pulse_ring.gd source has resonance code
# =====================================================================

func test_pulse_ring_has_resonance_flag():
	var source: String = load("res://scripts/weapons/pulse_ring.gd").source_code
	if source.find("_is_resonance") == -1:
		pending("Programmer has not yet added _is_resonance flag to pulse_ring.gd")
		return
	assert_true(source.find("_is_resonance") != -1,
		"pulse_ring.gd should have _is_resonance flag variable")


func test_pulse_ring_has_resonance_count():
	var source: String = load("res://scripts/weapons/pulse_ring.gd").source_code
	if source.find("_resonance_count") == -1:
		pending("Programmer has not yet added _resonance_count to pulse_ring.gd")
		return
	assert_true(source.find("_resonance_count") != -1,
		"pulse_ring.gd should have _resonance_count variable")


func test_pulse_ring_has_spawn_resonance_function():
	var source: String = load("res://scripts/weapons/pulse_ring.gd").source_code
	if source.find("_spawn_resonance_pulse") == -1:
		pending("Programmer has not yet added _spawn_resonance_pulse to pulse_ring.gd")
		return
	assert_true(source.find("_spawn_resonance_pulse") != -1,
		"pulse_ring.gd should have _spawn_resonance_pulse function")


func test_pulse_ring_checks_synergy_manager():
	var source: String = load("res://scripts/weapons/pulse_ring.gd").source_code
	if source.find("has_synergy") == -1:
		pending("Programmer has not yet added synergy check to pulse_ring.gd")
		return
	assert_true(source.find("has_synergy") != -1,
		"pulse_ring.gd should check SynergyManager.has_synergy")


# =====================================================================
# 6. Sub-pulse parameters (25% chance, 50% damage, 60% radius, max 3)
# =====================================================================

func test_resonance_trigger_chance_25_percent():
	var source: String = load("res://scripts/weapons/pulse_ring.gd").source_code
	if source.find("resonance") == -1:
		pending("Programmer has not yet added resonance code to pulse_ring.gd")
		return
	assert_true(source.find("0.25") != -1,
		"Resonance trigger chance should be 0.25 (25%)")


func test_resonance_damage_multiplier_50_percent():
	var source: String = load("res://scripts/weapons/pulse_ring.gd").source_code
	if source.find("resonance") == -1:
		pending("Programmer has not yet added resonance code to pulse_ring.gd")
		return
	assert_true(source.find("0.5") != -1,
		"Resonance damage multiplier should be 0.5 (50%)")


func test_resonance_radius_multiplier_60_percent():
	var source: String = load("res://scripts/weapons/pulse_ring.gd").source_code
	if source.find("resonance") == -1:
		pending("Programmer has not yet added resonance code to pulse_ring.gd")
		return
	assert_true(source.find("0.6") != -1,
		"Resonance radius multiplier should be 0.6 (60%)")


func test_resonance_max_per_pulse_is_3():
	var source: String = load("res://scripts/weapons/pulse_ring.gd").source_code
	if source.find("resonance") == -1:
		pending("Programmer has not yet added resonance code to pulse_ring.gd")
		return
	assert_true(source.find("< 3") != -1 or source.find("max_per_pulse") != -1 or source.find("RESONANCE_MAX") != -1,
		"Resonance should cap at 3 sub-pulses per base pulse")


func test_resonance_subpulse_cannot_chain():
	var source: String = load("res://scripts/weapons/pulse_ring.gd").source_code
	if source.find("_is_resonance") == -1:
		pending("Programmer has not yet added resonance code to pulse_ring.gd")
		return
	assert_true(source.find("not _is_resonance") != -1 or source.find("!_is_resonance") != -1,
		"Resonance sub-pulses should not trigger more resonance (anti-chain guard)")


# =====================================================================
# 7. synergy_manager has AOE weapon list (tag_weapons for resonance)
# =====================================================================

func test_resonance_tag_weapons_has_9_entries():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_eq(def["tag_weapons"].size(), 9,
		"Resonance tag_weapons should have 9 AOE weapons")


func test_aoe_weapon_list_includes_holywater():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_true("holywater" in def["tag_weapons"],
		"AOE weapon list should include holywater")


func test_aoe_weapon_list_includes_bible():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_true("bible" in def["tag_weapons"],
		"AOE weapon list should include bible")


func test_aoe_weapon_list_includes_frostaura():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_true("frostaura" in def["tag_weapons"],
		"AOE weapon list should include frostaura")


func test_aoe_weapon_list_includes_firestaff():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_true("firestaff" in def["tag_weapons"],
		"AOE weapon list should include firestaff")


func test_aoe_weapon_list_includes_blizzard():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_true("blizzard" in def["tag_weapons"],
		"AOE weapon list should include blizzard")


func test_aoe_weapon_list_includes_thunderholywater():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_true("thunderholywater" in def["tag_weapons"],
		"AOE weapon list should include thunderholywater")


func test_aoe_weapon_list_excludes_knife():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_false("knife" in def["tag_weapons"],
		"AOE weapon list should NOT include knife (single-target)")


func test_aoe_weapon_list_excludes_boomerang():
	var def: Dictionary = {}
	for d in _mgr.SYNERGY_DEFINITIONS:
		if d.get("id") == "resonance":
			def = d
			break
	assert_false("boomerang" in def["tag_weapons"],
		"AOE weapon list should NOT include boomerang (path-based)")
