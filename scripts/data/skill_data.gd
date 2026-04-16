class_name SkillData
extends Resource

# --- Skill constants (canonical source for tests and specs) ---

# Mage: Elemental Burst
const MAGE_SKILL_ID: String = "elemental_burst"
const MAGE_SKILL_COOLDOWN: float = 20.0
const MAGE_SKILL_DAMAGE: float = 15.0
const MAGE_SKILL_RADIUS: float = 150.0
const MAGE_SKILL_FREEZE_DURATION: float = 1.5
const MAGE_SKILL_EXPAND_TIME: float = 0.2
const MAGE_SKILL_SCREENSHAKE: float = 4.0
const MAGE_SKILL_SCREENSHAKE_DUR: float = 0.15

# Warrior: Shield Charge
const WARRIOR_SKILL_ID: String = "shield_charge"
const WARRIOR_SKILL_COOLDOWN: float = 15.0
const WARRIOR_SKILL_DAMAGE: float = 10.0
const WARRIOR_SKILL_DISTANCE: float = 160.0
const WARRIOR_SKILL_DURATION: float = 0.25
const WARRIOR_SKILL_WIDTH: float = 40.0
const WARRIOR_SKILL_STUN_DURATION: float = 2.0
const WARRIOR_SKILL_SCREENSHAKE: float = 3.0
const WARRIOR_SKILL_SCREENSHAKE_DUR: float = 0.1

# Ranger: Arrow Rain
const RANGER_SKILL_ID: String = "arrow_rain"
const RANGER_SKILL_COOLDOWN: float = 18.0
const RANGER_SKILL_DAMAGE_PER_ARROW: float = 5.0
const RANGER_SKILL_ARROW_COUNT: int = 12
const RANGER_SKILL_RADIUS: float = 100.0
const RANGER_SKILL_TARGET_RANGE: float = 300.0
const RANGER_SKILL_FALL_DURATION: float = 0.5
const RANGER_SKILL_ARROW_WIDTH: float = 4.0
const RANGER_SKILL_ARROW_HEIGHT: float = 12.0
const RANGER_SKILL_WARNING_TIME: float = 0.3
const RANGER_SKILL_SCREENSHAKE: float = 2.0
const RANGER_SKILL_SCREENSHAKE_DUR: float = 0.08

# Passive constants
const MAGE_PASSIVE_DAMAGE_BONUS: float = 0.10
const WARRIOR_PASSIVE_ARMOR_BONUS: int = 3
const WARRIOR_PASSIVE_HP_THRESHOLD: float = 0.30
const WARRIOR_PASSIVE_DURATION: float = 3.0
const WARRIOR_PASSIVE_COOLDOWN: float = 30.0
const RANGER_PASSIVE_HIT_COUNT: int = 5

# --- Resource fields ---
@export var skill_id: String = ""
@export var skill_name: String = ""
@export var description: String = ""
@export var cooldown: float = 20.0
@export var damage: float = 10.0
@export var radius: float = 100.0
@export var duration: float = 0.0
@export var color: Color = Color.WHITE
@export var icon_color: Color = Color.WHITE
