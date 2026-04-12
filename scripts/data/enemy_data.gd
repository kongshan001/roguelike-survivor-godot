class_name EnemyData
extends Resource

@export var enemy_id: String = ""
@export var enemy_name: String = "Enemy"
@export var max_hp: float = 20.0
@export var speed: float = 60.0
@export var damage: float = 10.0
@export var xp_value: int = 5
@export var color: Color = Color.GREEN
@export var size: float = 16.0
@export var shape: String = "circle"
@export var is_boss: bool = false
@export var drop_chance: float = 0.1

# Ranged enemy (skeleton, elite_skeleton)
@export var is_ranged: bool = false
@export var shoot_cd: float = 2.0
@export var is_elite: bool = false  # 3-way shot

# Ghost abilities
@export var can_phase_shift: bool = false
@export var can_teleport: bool = false

# Splitter
@export var is_splitter: bool = false
@export var is_child: bool = false
@export var split_count: int = 2

# Boss phases
@export var boss_phase2_hp_pct: float = 0.66
@export var boss_phase3_hp_pct: float = 0.33
