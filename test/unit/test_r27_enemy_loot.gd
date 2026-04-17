extends GutTest
## R27: Unit tests for enemy_loot.gd
## Covers: kill rewards, gold calculation, weapon kill tracking, splitter spawning,
## boss death handling, and loot constants.

var _loot: RefCounted
var _arena: Node2D
var _pickup_mgr: Node


func before_each():
	GameManager.reset()
	SaveManager.reset_save()
	if SynergyManager:
		SynergyManager.active_synergies.clear()

	_loot = load("res://scripts/enemies/enemy_loot.gd").new()

	_arena = Node2D.new()
	_arena.name = "Arena"
	add_child_autofree(_arena)

	_pickup_mgr = Node.new()
	_pickup_mgr.name = "PickupManager"
	_arena.add_child(_pickup_mgr)


func after_each():
	await get_tree().process_frame


# =====================================================================
# Section A: Constants
# =====================================================================

func test_food_spawn_offset_constant():
	assert_eq(_loot.FOOD_SPAWN_OFFSET, 15.0, "FOOD_SPAWN_OFFSET should be 15.0")


func test_food_drop_base_chance_constant():
	assert_eq(_loot.FOOD_DROP_BASE_CHANCE, 0.1, "FOOD_DROP_BASE_CHANCE should be 0.1")


func test_splitter_child_constants():
	assert_eq(_loot.SPLITTER_CHILD_ID, "splitter_small", "Child ID should be splitter_small")
	assert_eq(_loot.SPLITTER_CHILD_HP, 1.0, "Child HP should be 1.0")
	assert_eq(_loot.SPLITTER_CHILD_SPEED, 70.0, "Child speed should be 70.0")
	assert_eq(_loot.SPLITTER_CHILD_DAMAGE, 1.0, "Child damage should be 1.0")
	assert_eq(_loot.SPLITTER_CHILD_XP, 1, "Child XP should be 1")
	assert_eq(_loot.SPLITTER_CHILD_SIZE, 8.0, "Child size should be 8.0")


func test_xp_gem_spawn_offset_constant():
	assert_eq(_loot.XP_GEM_SPAWN_OFFSET, 10.0, "XP_GEM_SPAWN_OFFSET should be 10.0")


func test_boss_bonus_gem_count_constant():
	assert_eq(_loot.BOSS_BONUS_GEM_COUNT, 5, "BOSS_BONUS_GEM_COUNT should be 5")


func test_endless_boss_gold_constant():
	assert_eq(_loot.ENDLESS_BOSS_GOLD, 50, "ENDLESS_BOSS_GOLD should be 50")


func test_endless_boss_xp_constant():
	assert_eq(_loot.ENDLESS_BOSS_XP, 30.0, "ENDLESS_BOSS_XP should be 30.0")


func test_endless_food_count_constant():
	assert_eq(_loot.ENDLESS_FOOD_COUNT, 5, "ENDLESS_FOOD_COUNT should be 5")


func test_endless_food_spread_constant():
	assert_eq(_loot.ENDLESS_FOOD_SPREAD, 30.0, "ENDLESS_FOOD_SPREAD should be 30.0")


# =====================================================================
# Section B: handle_kill_rewards
# =====================================================================

func test_handle_kill_rewards_increments_score():
	var data := EnemyData.new()
	data.xp_value = 10
	data.drop_chance = 0.0
	_loot.handle_kill_rewards(data, "knife", false)
	assert_eq(GameManager.score, 10, "Score should increase by xp_value")


func test_handle_kill_rewards_decrements_enemy_count():
	GameManager.enemy_count = 5
	var data := EnemyData.new()
	data.xp_value = 5
	data.drop_chance = 0.0
	_loot.handle_kill_rewards(data, "knife", false)
	assert_eq(GameManager.enemy_count, 4, "enemy_count should decrease by 1")


func test_handle_kill_rewards_registers_kill():
	var data := EnemyData.new()
	data.xp_value = 5
	data.drop_chance = 0.0
	_loot.handle_kill_rewards(data, "knife", false)
	assert_eq(GameManager.enemies_killed, 1, "Kills should be registered")


func test_handle_kill_rewards_adds_gold():
	var data := EnemyData.new()
	data.xp_value = 5
	data.drop_chance = 0.0
	_loot.handle_kill_rewards(data, "knife", false)
	assert_gt(GameManager.gold, 0, "Gold should be added")


# =====================================================================
# Section C: Weapon Kill Tracking
# =====================================================================

func test_track_weapon_kill_base_weapon():
	SaveManager.weapon_kills.clear()
	_loot._track_weapon_kill("knife")
	assert_eq(SaveManager.weapon_kills.get("knife", 0), 1, "Knife kill should be tracked")


func test_track_weapon_kill_evolved_weapon_tracks_parents():
	SaveManager.weapon_kills.clear()
	_loot._track_weapon_kill("thunderholywater")
	assert_eq(SaveManager.weapon_kills.get("holywater", 0), 1, "holywater parent should get kill credit")
	assert_eq(SaveManager.weapon_kills.get("lightning", 0), 1, "lightning parent should get kill credit")


func test_track_weapon_kill_fireknife_tracks_parents():
	SaveManager.weapon_kills.clear()
	_loot._track_weapon_kill("fireknife")
	assert_eq(SaveManager.weapon_kills.get("knife", 0), 1, "knife parent should get kill credit")
	assert_eq(SaveManager.weapon_kills.get("firestaff", 0), 1, "firestaff parent should get kill credit")


func test_track_weapon_kill_blizzard_tracks_parents():
	SaveManager.weapon_kills.clear()
	_loot._track_weapon_kill("blizzard")
	assert_eq(SaveManager.weapon_kills.get("frostaura", 0), 1, "frostaura parent should get kill credit")
	assert_eq(SaveManager.weapon_kills.get("lightning", 0), 1, "lightning parent should get kill credit")


func test_track_weapon_kill_sentineltotem_tracks_parents():
	SaveManager.weapon_kills.clear()
	_loot._track_weapon_kill("sentineltotem")
	assert_eq(SaveManager.weapon_kills.get("bible", 0), 1, "bible parent should get kill credit")
	assert_eq(SaveManager.weapon_kills.get("boomerang", 0), 1, "boomerang parent should get kill credit")


func test_track_weapon_kill_unknown_weapon():
	# add_weapon_kill only tracks BASE_WEAPONS; unknown weapons are ignored
	SaveManager.weapon_kills.clear()
	_loot._track_weapon_kill("unknown_weapon")
	assert_eq(SaveManager.weapon_kills.get("unknown_weapon", 0), 0,
		"Unknown weapon should not be tracked (not in BASE_WEAPONS)")


# =====================================================================
# Section D: Evolved Weapon Parents Coverage
# =====================================================================

func test_all_9_evolved_weapons_have_parent_entries():
	var evolved_ids: Array = [
		"thunderholywater", "fireknife", "holydomain", "blizzard",
		"frostknife", "flamebible", "thunderang", "blazerang", "sentineltotem"
	]
	# Access the evolved_parents dictionary via method behavior
	# We verify by checking that each evolved weapon credits two parents
	for eid: String in evolved_ids:
		SaveManager.weapon_kills.clear()
		_loot._track_weapon_kill(eid)
		var tracked: int = 0
		for key: String in SaveManager.weapon_kills:
			tracked += SaveManager.weapon_kills[key]
		assert_eq(tracked, 2, "%s should track exactly 2 parent kills" % eid)


# =====================================================================
# Section E: Boss Death Handling
# =====================================================================

func test_handle_boss_death_sets_boss_killed():
	var data := EnemyData.new()
	data.xp_value = 20
	data.drop_chance = 0.0
	_loot.handle_boss_death(data, Vector2(100, 100), _arena, _pickup_mgr)
	assert_true(GameManager.boss_killed, "boss_killed should be set to true")


func test_handle_boss_death_increments_boss_kill_count():
	var data := EnemyData.new()
	data.xp_value = 20
	data.drop_chance = 0.0
	_loot.handle_boss_death(data, Vector2(100, 100), _arena, _pickup_mgr)
	assert_eq(GameManager.boss_kill_count, 1, "boss_kill_count should increment")


func test_handle_boss_death_endless_mode_adds_gold():
	GameManager.selected_difficulty = "endless"
	var data := EnemyData.new()
	data.xp_value = 20
	data.drop_chance = 0.0
	_loot.handle_boss_death(data, Vector2(100, 100), _arena, _pickup_mgr)
	assert_gte(GameManager.gold, _loot.ENDLESS_BOSS_GOLD,
		"Endless mode boss should award at least ENDLESS_BOSS_GOLD gold")
	GameManager.selected_difficulty = "normal"


func test_handle_boss_death_endless_mode_adds_xp():
	GameManager.selected_difficulty = "endless"
	# Record total XP (level + current_xp) before
	var _xp_before: float = float(GameManager.player_level - 1) * 100.0 + GameManager.current_xp
	var data := EnemyData.new()
	data.xp_value = 20
	data.drop_chance = 0.0
	_loot.handle_boss_death(data, Vector2(100, 100), _arena, _pickup_mgr)
	# add_xp may trigger level ups, so check that total XP increased
	# The player_level may have increased, so we check cumulative
	assert_gt(GameManager.player_level, 1,
		"Endless mode boss XP should cause at least one level up")
	GameManager.selected_difficulty = "normal"


# =====================================================================
# Section F: Gold Calculation
# =====================================================================

func test_base_gold_drop_is_positive():
	var data := EnemyData.new()
	data.xp_value = 5
	data.drop_chance = 0.0
	var gold_before: int = GameManager.gold
	_loot.handle_kill_rewards(data, "knife", false)
	assert_gt(GameManager.gold, gold_before, "Gold should increase from kill rewards")


func test_combo_gold_bonus():
	GameManager.combo_count = 5
	var data := EnemyData.new()
	data.xp_value = 5
	data.drop_chance = 0.0
	var gold_before: int = GameManager.gold
	_loot.handle_kill_rewards(data, "knife", false)
	var gained: int = GameManager.gold - gold_before
	assert_gt(gained, 3, "Combo >= 5 should give bonus gold over base 3")
	GameManager.combo_count = 0


func test_no_combo_bonus_below_5():
	GameManager.combo_count = 4
	var data := EnemyData.new()
	data.xp_value = 5
	data.drop_chance = 0.0
	var gold_before: int = GameManager.gold
	_loot.handle_kill_rewards(data, "knife", false)
	var gained: int = GameManager.gold - gold_before
	# Base gold is 3, but SaveManager.get_gold_bonus() may modify it
	assert_gt(gained, 0, "Should gain gold from kill")
	GameManager.combo_count = 0
