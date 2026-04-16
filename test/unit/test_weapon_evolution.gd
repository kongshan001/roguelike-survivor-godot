extends GutTest

# Test weapon evolution system: recipes, evolved weapon data, UpgradePool integration

var _registry: RefCounted


func before_all():
	_registry = load("res://scripts/weapons/weapon_registry.gd").new()


func before_each():
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	GameManager.reset()


# --- Evolution Recipes ---

func test_evolution_recipes_count():
	assert_eq(_registry.EVOLUTION_RECIPES.size(), 9, "Should have 9 evolution recipes")


func _register_all_weapons():
	UpgradePool._register_base_weapons()
	UpgradePool._register_evolved_weapons()


func test_evolution_recipe_structure():
	var recipe: Dictionary = _registry.EVOLUTION_RECIPES[0]
	assert_true(recipe.has("a"), "Recipe should have key 'a'")
	assert_true(recipe.has("b"), "Recipe should have key 'b'")
	assert_true(recipe.has("result"), "Recipe should have key 'result'")


func test_evolution_recipe_holywater_lightning():
	var recipe: Dictionary = _registry.EVOLUTION_RECIPES[0]
	assert_eq(recipe["a"], "holywater")
	assert_eq(recipe["b"], "lightning")
	assert_eq(recipe["result"], "thunderholywater")


func test_evolution_recipe_knife_firestaff():
	var recipe: Dictionary = _registry.EVOLUTION_RECIPES[1]
	assert_eq(recipe["a"], "knife")
	assert_eq(recipe["b"], "firestaff")
	assert_eq(recipe["result"], "fireknife")


func test_evolution_recipe_bible_holywater():
	var recipe: Dictionary = _registry.EVOLUTION_RECIPES[2]
	assert_eq(recipe["a"], "bible")
	assert_eq(recipe["b"], "holywater")
	assert_eq(recipe["result"], "holydomain")


# --- check_evolution_available ---

func test_no_evolution_when_weapons_not_max():
	UpgradePool._register_base_weapons()
	var owned := {"holywater": 2, "lightning": 2}
	var result: Dictionary = _registry.check_evolution_available(owned)
	assert_true(result.is_empty(), "Should not evolve when weapons not Lv3")


func test_evolution_available_when_both_max():
	UpgradePool._register_base_weapons()
	var owned := {"holywater": 3, "lightning": 3}
	var result: Dictionary = _registry.check_evolution_available(owned)
	assert_false(result.is_empty(), "Should find evolution")
	assert_eq(result["result"], "thunderholywater")


func test_no_evolution_when_already_evolved():
	_register_all_weapons()
	var owned := {"holywater": 3, "lightning": 3, "thunderholywater": 1}
	var result: Dictionary = _registry.check_evolution_available(owned)
	assert_true(result.is_empty(), "Should not evolve when result already owned")


func test_evolution_returns_first_match():
	UpgradePool._register_base_weapons()
	var owned := {"holywater": 3, "lightning": 3, "bible": 3}
	var result: Dictionary = _registry.check_evolution_available(owned)
	assert_false(result.is_empty(), "Should find at least one evolution")
	assert_eq(result["result"], "thunderholywater")


func test_no_evolution_with_empty_weapons():
	var result: Dictionary = _registry.check_evolution_available({})
	assert_true(result.is_empty(), "Should not evolve with no weapons")


# --- Evolved Weapon Data ---

func test_evolved_weapon_is_flagged():
	_register_all_weapons()
	var thw: WeaponData = UpgradePool._weapons.get("thunderholywater")
	assert_ne(thw, null, "Evolved weapon should be registered")
	assert_true(thw.is_evolved, "Evolved weapon should have is_evolved=true")


func test_evolved_weapon_names():
	_register_all_weapons()
	var names := {
		"thunderholywater": "雷暴圣水",
		"fireknife": "火焰飞刀",
		"holydomain": "圣光领域",
		"blizzard": "暴风雪",
		"frostknife": "冰霜飞刀",
		"flamebible": "烈焰经文",
		"thunderang": "雷霆回旋",
		"blazerang": "烈焰回旋",
	}
	for id in names:
		var w: WeaponData = UpgradePool._weapons.get(id)
		assert_ne(w, null, "%s should be registered" % id)
		assert_eq(w.weapon_name, names[id], "%s name should match" % id)


func test_base_weapon_is_not_evolved():
	UpgradePool._register_base_weapons()
	var knife: WeaponData = UpgradePool._weapons.get("knife")
	assert_ne(knife, null)
	assert_false(knife.is_evolved, "Base weapon should not be evolved")


# --- WeaponData.is_evolved ---

func test_weapon_data_evolved_default():
	var d := WeaponData.new()
	assert_false(d.is_evolved, "Default is_evolved should be false")


# --- UpgradePool Evolution Integration ---

func test_evolution_option_appears_in_upgrades():
	_register_all_weapons()
	var owned := {"holywater": 3, "lightning": 3}
	var passives := {}
	var options := UpgradePool.get_random_upgrades(owned, passives, 3)
	var has_evolution := false
	for opt in options:
		if opt.type == "evolution":
			has_evolution = true
			assert_eq(opt.id, "thunderholywater")
			assert_eq(opt.recipe_a, "holywater")
			assert_eq(opt.recipe_b, "lightning")
	assert_true(has_evolution, "Evolution option should appear")


func test_evolved_weapons_not_offered_as_new():
	_register_all_weapons()
	var owned := {}
	var passives := {}
	var options := UpgradePool.get_random_upgrades(owned, passives, 10)
	for opt in options:
		if opt.type == "new_weapon":
			assert_ne(opt.id, "thunderholywater", "Evolved weapon should not appear as new_weapon")


func test_all_8_base_weapons_registered():
	UpgradePool._register_base_weapons()
	var expected := ["holywater", "knife", "lightning", "bible", "firestaff", "frostaura", "boomerang"]
	for id in expected:
		assert_ne(UpgradePool._weapons.get(id), null, "%s should be registered" % id)


func test_all_9_evolved_weapons_registered():
	_register_all_weapons()
	var expected := ["thunderholywater", "fireknife", "holydomain", "blizzard", "frostknife", "flamebible", "thunderang", "blazerang", "sentineltotem"]
	for id in expected:
		assert_ne(UpgradePool._weapons.get(id), null, "%s should be registered" % id)
