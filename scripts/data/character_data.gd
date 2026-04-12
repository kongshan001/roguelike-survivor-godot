class_name CharacterData
extends Resource

@export var character_id: String = ""
@export var character_name: String = ""
@export var max_hp: float = 8.0
@export var move_speed: float = 160.0
@export var description: String = ""
@export var start_weapon: String = ""  # "choose" for mage, weapon_id for others
@export var passive_ability: String = ""  # "dmg_bonus", "armor_bonus", "crit_bonus"
@export var color: Color = Color.WHITE
