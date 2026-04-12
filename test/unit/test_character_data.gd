extends GutTest

# Test CharacterData resource class


func test_defaults():
	var data = CharacterData.new()
	assert_eq(data.character_id, "")
	assert_eq(data.character_name, "")
	assert_eq(data.max_hp, 8.0)
	assert_eq(data.move_speed, 160.0)
	assert_eq(data.description, "")
	assert_eq(data.start_weapon, "")
	assert_eq(data.passive_ability, "")
	assert_eq(data.color, Color.WHITE)


func test_mage_preset():
	var data = CharacterData.new()
	data.character_id = "mage"
	data.character_name = "魔法师"
	data.max_hp = 8.0
	data.move_speed = 160.0
	data.start_weapon = "choose"
	data.passive_ability = "dmg_bonus"
	assert_eq(data.character_id, "mage")
	assert_eq(data.character_name, "魔法师")
	assert_eq(data.max_hp, 8.0)
	assert_eq(data.move_speed, 160.0)
	assert_eq(data.start_weapon, "choose")
	assert_eq(data.passive_ability, "dmg_bonus")


func test_warrior_preset():
	var data = CharacterData.new()
	data.character_id = "warrior"
	data.character_name = "战士"
	data.max_hp = 12.0
	data.move_speed = 140.0
	data.start_weapon = "knife"
	data.passive_ability = "armor_bonus"
	assert_eq(data.character_id, "warrior")
	assert_eq(data.max_hp, 12.0)
	assert_eq(data.move_speed, 140.0)
	assert_eq(data.start_weapon, "knife")
	assert_eq(data.passive_ability, "armor_bonus")


func test_ranger_preset():
	var data = CharacterData.new()
	data.character_id = "ranger"
	data.character_name = "游侠"
	data.max_hp = 6.0
	data.move_speed = 190.0
	data.start_weapon = "holywater"
	data.passive_ability = "crit_bonus"
	assert_eq(data.character_id, "ranger")
	assert_eq(data.max_hp, 6.0)
	assert_eq(data.move_speed, 190.0)
	assert_eq(data.start_weapon, "holywater")
	assert_eq(data.passive_ability, "crit_bonus")


func test_resource_inheritance():
	var data = CharacterData.new()
	assert_true(data is Resource, "CharacterData should extend Resource")
