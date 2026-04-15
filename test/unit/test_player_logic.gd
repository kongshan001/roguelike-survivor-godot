extends GutTest

# Test Player logic: damage, death, weapons, passives
# Instantiates player scene to test full behavior

var _player: CharacterBody2D


func before_each():
	GameManager.reset()
	# Reset SaveManager shop upgrades to prevent HP/speed/dmg bonus leakage
	if SaveManager:
		for id in SaveManager.SHOP_UPGRADES:
			SaveManager.shop_upgrades[id] = 0
	GameManager.selected_character = ""  # default, no bonus
	var player_scene = load("res://scenes/player.tscn")
	_player = player_scene.instantiate()
	add_child_autofree(_player)


# --- Health and Damage ---

func test_initial_hp():
	assert_eq(_player.current_health, 8.0, "HP should equal default max_health")


func test_take_damage():
	_player.take_damage(3.0)
	assert_eq(_player.current_health, 5.0, "HP should be 5 after 3 damage")


func test_take_damage_lethal():
	_player.take_damage(8.0)
	assert_eq(_player.current_health, 0.0)
	assert_false(_player.is_alive, "Player should be dead")


func test_take_damage_with_armor():
	_player.armor = 2
	_player.take_damage(5.0)
	assert_eq(_player.current_health, 5.0, "5 damage - 2 armor = 3 damage, HP = 5")


func test_take_damage_armor_min_1():
	_player.armor = 10
	_player.take_damage(5.0)
	assert_eq(_player.current_health, 7.0, "Min 1 damage even with high armor")


func test_take_damage_invincible():
	_player.take_damage(1.0)
	_player.take_damage(1.0)  # Should be ignored during invincibility
	assert_eq(_player.current_health, 7.0, "Damage should be blocked during invincibility")


func test_take_damage_when_dead():
	_player.take_damage(8.0)
	assert_false(_player.is_alive)
	_player.take_damage(5.0)  # Should not crash
	assert_eq(_player.current_health, 0.0)


func test_is_alive_initially_true():
	assert_true(_player.is_alive, "Player should start alive")


# --- Heal ---

func test_heal():
	_player.take_damage(3.0)
	_player.heal(2.0)
	assert_eq(_player.current_health, 7.0, "HP should be 7 after heal")


func test_heal_capped():
	_player.heal(100.0)
	assert_eq(_player.current_health, _player.max_health, "HP should cap at max")


# --- Weapon Management ---

func test_add_weapon():
	_player.add_weapon("knife")
	assert_eq(_player.owned_weapons.has("knife"), true, "Should have knife")
	assert_eq(_player.owned_weapons["knife"], 1, "Knife should be level 1")


func test_upgrade_weapon():
	_player.add_weapon("knife")
	var result = _player.upgrade_weapon("knife")
	assert_true(result, "Upgrade should succeed")
	assert_eq(_player.owned_weapons["knife"], 2, "Knife should be level 2")


func test_weapon_max_level():
	_player.add_weapon("knife")
	_player.upgrade_weapon("knife")
	_player.upgrade_weapon("knife")
	var result = _player.upgrade_weapon("knife")
	assert_false(result, "Should not upgrade past max level 3")
	assert_eq(_player.owned_weapons["knife"], 3, "Should stay at level 3")


func test_upgrade_nonexistent_weapon():
	var result = _player.upgrade_weapon("nonexistent")
	assert_false(result, "Should fail for nonexistent weapon")


func test_get_weapon_level():
	assert_eq(_player.get_weapon_level("knife"), 0, "Non-owned weapon level should be 0")
	_player.add_weapon("knife")
	assert_eq(_player.get_weapon_level("knife"), 1, "Owned weapon should be level 1")


# --- Passive Upgrades (new H5 passives) ---

func test_passive_speedboots():
	_player.apply_passive("speedboots")
	assert_eq(_player.speed_multiplier, 1.15, "Speed should increase by 15%")


func test_passive_armor():
	_player.apply_passive("armor")
	assert_eq(_player.armor, 1, "Armor should increase by 1")


func test_passive_maxhp():
	_player.apply_passive("maxhp")
	assert_eq(_player.max_health, 10.0, "Max HP should increase by 2")


func test_passive_crit():
	_player.apply_passive("crit")
	assert_eq(_player.crit_chance, 0.08, "Crit chance should increase by 8%")


func test_passive_regen():
	_player.apply_passive("regen")
	assert_eq(_player.regen_amount, 1.0, "Regen should increase by 1")


func test_multiple_passives():
	_player.apply_passive("speedboots")
	_player.apply_passive("armor")
	_player.apply_passive("crit")
	assert_eq(_player.speed_multiplier, 1.15)
	assert_eq(_player.armor, 1)
	assert_eq(_player.crit_chance, 0.08)


# --- Character Bonuses ---

func test_warrior_armor_bonus():
	GameManager.selected_character = "warrior"
	var p = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(p)
	assert_eq(p.armor, 1, "Warrior should start with +1 armor")


func test_ranger_crit_bonus():
	GameManager.selected_character = "ranger"
	var p = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(p)
	assert_eq(p.crit_chance, 0.1, "Ranger should start with +10% crit")


func test_mage_damage_bonus():
	GameManager.selected_character = "mage"
	var p = load("res://scenes/player.tscn").instantiate()
	add_child_autofree(p)
	assert_eq(p.damage_bonus, 0.2, "Mage should start with +20% damage bonus")


# --- Death ---

func test_death_sets_game_over():
	_player.take_damage(100.0)
	assert_true(GameManager.is_game_over, "Game over should be true on death")
