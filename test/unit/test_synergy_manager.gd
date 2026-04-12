extends GutTest

# Test synergy_manager: detection, active state, synergy values
# Uses a manually created instance since GUT may not load autoloads

var _mgr: Node


func before_each():
	GameManager.reset()
	_mgr = Node.new()
	_mgr.set_script(load("res://scripts/autoload/synergy_manager.gd"))
	add_child_autofree(_mgr)


func _check(weapons: Dictionary, passives: Dictionary):
	_mgr.check_synergies(weapons, passives)


# --- Passive+Passive Synergies ---

func test_no_synergy_with_empty():
	_check({}, {})
	assert_eq(_mgr.get_active_count(), 0, "No synergies with empty state")


func test_crit_boots_synergy():
	_check({}, {"crit": 1, "speedboots": 1})
	assert_true(_mgr.has_synergy("crit_boots"), "Should have crit_boots synergy")


func test_armor_maxhp_synergy():
	_check({}, {"armor": 1, "maxhp": 1})
	assert_true(_mgr.has_synergy("armor_maxhp"))


func test_magnet_crit_synergy():
	_check({}, {"magnet": 1, "crit": 1})
	assert_true(_mgr.has_synergy("magnet_crit"))


func test_boots_regen_synergy():
	_check({}, {"speedboots": 1, "regen": 1})
	assert_true(_mgr.has_synergy("boots_regen"))


func test_armor_regen_synergy():
	_check({}, {"armor": 1, "regen": 1})
	assert_true(_mgr.has_synergy("armor_regen"))


func test_magnet_maxhp_synergy():
	_check({}, {"magnet": 1, "maxhp": 1})
	assert_true(_mgr.has_synergy("magnet_maxhp"))


func test_no_synergy_with_only_one_passive():
	_check({}, {"crit": 1})
	assert_false(_mgr.has_synergy("crit_boots"), "Need both passives")


# --- Weapon+Passive Synergies ---

func test_holywater_maxhp_synergy():
	_check({"holywater": 1}, {"maxhp": 1})
	assert_true(_mgr.has_synergy("holywater_maxhp"))


func test_knife_crit_synergy():
	_check({"knife": 1}, {"crit": 1})
	assert_true(_mgr.has_synergy("knife_crit"))


func test_lightning_magnet_synergy():
	_check({"lightning": 1}, {"magnet": 1})
	assert_true(_mgr.has_synergy("lightning_magnet"))


func test_bible_boots_synergy():
	_check({"bible": 1}, {"speedboots": 1})
	assert_true(_mgr.has_synergy("bible_boots"))


func test_firestaff_armor_synergy():
	_check({"firestaff": 1}, {"armor": 1})
	assert_true(_mgr.has_synergy("firestaff_armor"))


func test_frost_regen_synergy():
	_check({"frostaura": 1}, {"regen": 1})
	assert_true(_mgr.has_synergy("frost_regen"))


func test_boomerang_crit_synergy():
	_check({"boomerang": 1}, {"crit": 1})
	assert_true(_mgr.has_synergy("boomerang_crit"))


func test_no_weapon_passive_synergy_without_weapon():
	_check({}, {"crit": 1})
	assert_false(_mgr.has_synergy("knife_crit"), "Need weapon too")


func test_no_weapon_passive_synergy_without_passive():
	_check({"knife": 1}, {})
	assert_false(_mgr.has_synergy("knife_crit"), "Need passive too")


# --- Multiple Synergies ---

func test_multiple_synergies_active():
	_check({"holywater": 3, "knife": 3}, {"crit": 1, "maxhp": 1, "speedboots": 1})
	assert_true(_mgr.has_synergy("holywater_maxhp"))
	assert_true(_mgr.has_synergy("knife_crit"))
	assert_true(_mgr.has_synergy("crit_boots"))
	assert_eq(_mgr.get_active_count(), 3, "Should have 3 active synergies")


# --- Synergy Values ---

func test_get_synergy_value():
	_check({}, {"magnet": 1, "maxhp": 1})
	var value = _mgr.get_synergy_value("magnet_maxhp", "value", 0.0)
	assert_eq(value, 0.02, "Gem heal chance should be 0.02")


func test_get_synergy_value_missing():
	var value = _mgr.get_synergy_value("nonexistent", "value", 99.0)
	assert_eq(value, 99.0, "Should return default for missing synergy")


func test_get_active_names():
	_check({}, {"crit": 1, "speedboots": 1})
	var names: Array = _mgr.get_active_names()
	assert_has(names, "风之锋刃", "Should have synergy name")


# --- Re-check clears old ---

func test_recheck_removes_lost_passive():
	_check({}, {"crit": 1, "speedboots": 1})
	assert_true(_mgr.has_synergy("crit_boots"))
	_check({}, {"crit": 1})
	assert_false(_mgr.has_synergy("crit_boots"), "Should lose synergy when passive removed")


# --- Definition count ---

func test_total_synergy_definitions():
	assert_eq(_mgr.SYNERGY_DEFINITIONS.size(), 17, "Should have 17 synergy definitions")
