extends GutTest

# Test DifficultyData resource class


func test_defaults():
	var data = DifficultyData.new()
	assert_eq(data.difficulty_id, "")
	assert_eq(data.name, "")
	assert_eq(data.description, "")
	assert_eq(data.player_hp_mul, 1.0)
	assert_eq(data.player_speed_mul, 1.0)
	assert_eq(data.enemy_hp_mul, 1.0)
	assert_eq(data.enemy_speed_mul, 1.0)
	assert_eq(data.enemy_dmg_mul, 1.0)
	assert_eq(data.spawn_interval_mul, 1.0)
	assert_eq(data.spawn_count_mod, 0)
	assert_eq(data.boss_hp_mul, 1.0)
	assert_eq(data.boss_speed_mul, 1.0)
	assert_eq(data.exp_mul, 1.0)
	assert_eq(data.color, Color.WHITE)


func test_easy_preset():
	var data = DifficultyData.new()
	data.difficulty_id = "easy"
	data.name = "简单"
	data.player_hp_mul = 1.25
	data.enemy_hp_mul = 0.7
	data.spawn_interval_mul = 1.4
	data.exp_mul = 1.3
	assert_eq(data.difficulty_id, "easy")
	assert_eq(data.player_hp_mul, 1.25)
	assert_eq(data.enemy_hp_mul, 0.7)
	assert_eq(data.spawn_interval_mul, 1.4)
	assert_eq(data.exp_mul, 1.3)


func test_normal_preset():
	var data = DifficultyData.new()
	data.difficulty_id = "normal"
	data.name = "普通"
	data.player_hp_mul = 1.0
	data.player_speed_mul = 1.0
	data.enemy_hp_mul = 1.0
	data.enemy_speed_mul = 1.0
	data.enemy_dmg_mul = 1.0
	data.spawn_interval_mul = 1.0
	data.spawn_count_mod = 0
	data.boss_hp_mul = 1.0
	data.boss_speed_mul = 1.0
	data.exp_mul = 1.0
	assert_eq(data.difficulty_id, "normal")
	assert_eq(data.player_hp_mul, 1.0)
	assert_eq(data.enemy_hp_mul, 1.0)
	assert_eq(data.spawn_count_mod, 0)
	assert_eq(data.exp_mul, 1.0)


func test_hard_preset():
	var data = DifficultyData.new()
	data.difficulty_id = "hard"
	data.name = "困难"
	data.player_hp_mul = 0.75
	data.enemy_hp_mul = 1.5
	data.spawn_count_mod = 1
	assert_eq(data.difficulty_id, "hard")
	assert_eq(data.player_hp_mul, 0.75)
	assert_eq(data.enemy_hp_mul, 1.5)
	assert_eq(data.spawn_count_mod, 1)


func test_resource_inheritance():
	var data = DifficultyData.new()
	assert_true(data is Resource, "DifficultyData should extend Resource")
