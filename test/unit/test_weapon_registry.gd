extends GutTest
## Tests for weapon_registry.gd: evolution recipes, check_evolution_available

var _registry: RefCounted


func before_each():
	_registry = load("res://scripts/weapons/weapon_registry.gd").new()


# --- Recipe count ---

func test_recipe_count():
	assert_eq(_registry.EVOLUTION_RECIPES.size(), 12, "12 evolution recipes")


# --- Recipe structure ---

func test_recipe_has_required_keys():
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		assert_true(recipe.has("a"), "Recipe has key 'a'")
		assert_true(recipe.has("b"), "Recipe has key 'b'")
		assert_true(recipe.has("result"), "Recipe has key 'result'")


func test_recipe_ingredients_differ():
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		assert_ne(recipe["a"], recipe["b"], "Ingredients a != b")


# --- check_evolution_available: no weapons ---

func test_no_weapons_returns_empty():
	var result: Dictionary = _registry.check_evolution_available({})
	assert_eq(result.size(), 0, "Empty weapons => empty result")


# --- check_evolution_available: weapons below level 3 ---

func test_weapons_below_level_3():
	var weapons: Dictionary = {"holywater": 2, "lightning": 3}
	var result: Dictionary = _registry.check_evolution_available(weapons)
	assert_eq(result.size(), 0, "holywater Lv2 + lightning Lv3 => no evolution")


func test_weapons_both_level_2():
	var weapons: Dictionary = {"holywater": 2, "lightning": 2}
	var result: Dictionary = _registry.check_evolution_available(weapons)
	assert_eq(result.size(), 0, "Both Lv2 => no evolution")


# --- check_evolution_available: exact level 3 ---

func test_exact_level_3():
	var weapons: Dictionary = {"holywater": 3, "lightning": 3}
	var result: Dictionary = _registry.check_evolution_available(weapons)
	assert_eq(result["result"], "thunderholywater", "holywater+lightning Lv3 => thunderholywater")


func test_knife_firestaff_level_3():
	var weapons: Dictionary = {"knife": 3, "firestaff": 3}
	var result: Dictionary = _registry.check_evolution_available(weapons)
	assert_eq(result["result"], "fireknife", "knife+firestaff Lv3 => fireknife")


func test_bible_boomerang_level_3():
	var weapons: Dictionary = {"bible": 3, "boomerang": 3}
	var result: Dictionary = _registry.check_evolution_available(weapons)
	assert_eq(result["result"], "sentineltotem", "bible+boomerang Lv3 => sentineltotem")


func test_bible_holywater_level_3():
	var weapons: Dictionary = {"knife": 3, "firestaff": 3, "bible": 3, "holywater": 3}
	var result: Dictionary = _registry.check_evolution_available(weapons)
	# First match: holywater+lightning not owned, but knife+firestaff => fireknife
	assert_eq(result["result"], "fireknife", "Returns first matching recipe")


# --- check_evolution_available: above level 3 ---

func test_above_level_3():
	var weapons: Dictionary = {"holywater": 5, "lightning": 5}
	var result: Dictionary = _registry.check_evolution_available(weapons)
	assert_eq(result["result"], "thunderholywater", "Lv5 both => still matches")


# --- check_evolution_available: already has result ---

func test_already_has_evolution():
	var weapons: Dictionary = {"holywater": 3, "lightning": 3, "thunderholywater": 1}
	var result: Dictionary = _registry.check_evolution_available(weapons)
	assert_eq(result.size(), 0, "Already owns thunderholywater => no evolution")


# --- check_evolution_available: partial matches ---

func test_only_one_ingredient_max():
	var weapons: Dictionary = {"holywater": 3, "knife": 3}
	var result: Dictionary = _registry.check_evolution_available(weapons)
	assert_eq(result.size(), 0, "No matching recipe for holywater+knife")


# --- All 9 recipes have unique results ---

func test_unique_result_ids():
	var results: Array = []
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		assert_false(results.has(recipe["result"]), "Result %s is unique" % recipe["result"])
		results.append(recipe["result"])


# --- All recipe ingredients are valid weapon IDs ---

func test_valid_weapon_ids():
	var base_weapons: Array = ["holywater", "knife", "lightning", "bible", "firestaff", "frostaura", "boomerang"]
	for recipe: Dictionary in _registry.EVOLUTION_RECIPES:
		assert_has(base_weapons, recipe["a"], "Ingredient a is a base weapon")
		assert_has(base_weapons, recipe["b"], "Ingredient b is a base weapon")


# --- Full match: multiple recipes available ---

func test_returns_first_match():
	var weapons: Dictionary = {
		"boomerang": 3, "lightning": 3, "firestaff": 3,
		"holywater": 3
	}
	var result: Dictionary = _registry.check_evolution_available(weapons)
	# First recipe that matches: holywater+lightning => thunderholywater
	assert_eq(result["result"], "thunderholywater", "First match in order")


# --- Empty recipe list handling ---

func test_recipes_not_empty():
	assert_gt(_registry.EVOLUTION_RECIPES.size(), 0, "Recipes array is not empty")
