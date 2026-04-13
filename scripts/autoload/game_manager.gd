extends Node

signal player_died
signal level_up(new_level: int)
signal xp_changed(current: float, needed: float)
signal health_changed(current: float, max_health: float)
signal enemies_changed(count: int)
signal combo_changed(count: int)
signal gold_changed(amount: int)
signal combo_milestone(count: int)
signal boss_warning()

# Difficulty multiplier presets (from H5 DIFFICULTY config)
const DIFFICULTY_PRESETS: Dictionary = {
	"easy": {
		"player_hp_mul": 1.25, "player_speed_mul": 1.0,
		"enemy_hp_mul": 0.7, "enemy_speed_mul": 0.8, "enemy_dmg_mul": 0.75,
		"spawn_interval_mul": 1.4, "spawn_count_mod": -1,
		"boss_hp_mul": 0.6, "boss_speed_mul": 0.8, "exp_mul": 1.3, "food_drop_mul": 1.5
	},
	"normal": {
		"player_hp_mul": 1.0, "player_speed_mul": 1.0,
		"enemy_hp_mul": 1.0, "enemy_speed_mul": 1.0, "enemy_dmg_mul": 1.0,
		"spawn_interval_mul": 1.0, "spawn_count_mod": 0,
		"boss_hp_mul": 1.0, "boss_speed_mul": 1.0, "exp_mul": 1.0, "food_drop_mul": 1.0
	},
	"hard": {
		"player_hp_mul": 0.75, "player_speed_mul": 0.9,
		"enemy_hp_mul": 1.5, "enemy_speed_mul": 1.3, "enemy_dmg_mul": 1.5,
		"spawn_interval_mul": 0.7, "spawn_count_mod": 1,
		"boss_hp_mul": 2.0, "boss_speed_mul": 1.3, "exp_mul": 0.8, "food_drop_mul": 0.6
	},
	"endless": {
		"player_hp_mul": 1.0, "player_speed_mul": 1.0,
		"enemy_hp_mul": 1.0, "enemy_speed_mul": 1.0, "enemy_dmg_mul": 1.0,
		"spawn_interval_mul": 1.0, "spawn_count_mod": 0,
		"boss_hp_mul": 1.0, "boss_speed_mul": 1.0, "exp_mul": 1.0, "food_drop_mul": 1.0
	}
}

# XP experience table from H5 config (index 0 = level 1→2)
const EXP_TABLE: Array[float] = [8.0, 12.0, 18.0, 24.0, 32.0, 42.0, 55.0, 70.0, 88.0, 108.0, 132.0, 160.0, 195.0, 240.0]
const COMBO_TIMEOUT: float = 3.0
const COMBO_MILESTONES: Array[int] = [5, 10, 20, 50]
const COMBO_EXP_RATE: float = 0.05
const COMBO_MAX_BONUS: float = 0.5

func get_difficulty_mul(key: String, default: float = 1.0) -> float:
	var preset: Dictionary = DIFFICULTY_PRESETS.get(selected_difficulty, {})
	return preset.get(key, default)

func get_difficulty_count_mod() -> int:
	var preset: Dictionary = DIFFICULTY_PRESETS.get(selected_difficulty, {})
	return preset.get("spawn_count_mod", 0)

var score: int = 0
var enemies_killed: int = 0
var character_kills: int = 0  # kills in current game for character-specific quests
var damage_taken: bool = false  # tracks if player took damage this run
var kills_at_60: int = -1  # -1 = not recorded yet, >= 0 = kills at 60s mark
var elapsed_time: float = 0.0
var player_level: int = 1
var current_xp: float = 0.0
var xp_to_next_level: float = EXP_TABLE[0]
var is_paused: bool = false
var is_game_over: bool = false

# Character & difficulty
var selected_character: String = ""
var selected_difficulty: String = ""
var gold: int = 0
var boss_killed: bool = false
var boss_kill_count: int = 0

# Combo system
var combo_count: int = 0
var combo_timer: float = 0.0
var best_combo: int = 0

var enemy_count: int = 0:
	set(v):
		enemy_count = v
		enemies_changed.emit(enemy_count)


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func reset():
	score = 0
	enemies_killed = 0
	elapsed_time = 0.0
	player_level = 1
	current_xp = 0.0
	xp_to_next_level = EXP_TABLE[0]
	is_paused = false
	is_game_over = false
	enemy_count = 0
	gold = 0
	boss_killed = false
	boss_kill_count = 0
	combo_count = 0
	combo_timer = 0.0
	best_combo = 0
	character_kills = 0
	damage_taken = false
	kills_at_60 = -1


func add_xp(amount: float):
	current_xp += amount
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		player_level += 1
		xp_to_next_level = _calculate_xp_needed(player_level)
		level_up.emit(player_level)
	xp_changed.emit(current_xp, xp_to_next_level)


func add_gold(amount: int):
	gold += amount
	gold_changed.emit(gold)


func register_kill():
	enemies_killed += 1
	character_kills += 1
	combo_count += 1
	combo_timer = COMBO_TIMEOUT
	if combo_count > best_combo:
		best_combo = combo_count
	combo_changed.emit(combo_count)
	# Check combo milestones
	for milestone in COMBO_MILESTONES:
		if combo_count == milestone:
			combo_milestone.emit(milestone)
			break


func update_combo(delta: float):
	# Track pacifist at 60s mark
	if kills_at_60 == -1 and elapsed_time >= 60.0:
		kills_at_60 = enemies_killed

	if combo_count > 0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			combo_count = 0
			combo_timer = 0.0
			combo_changed.emit(combo_count)


func _calculate_xp_needed(level: int) -> float:
	var idx = level - 1
	if idx < EXP_TABLE.size():
		return EXP_TABLE[idx]
	# Beyond table: scale with last value
	return EXP_TABLE[-1] * (1.0 + (idx - EXP_TABLE.size() + 1) * 0.5)


func format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]


static func find_player() -> Node2D:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		return null
	var players = tree.get_nodes_in_group("players")
	if players.size() > 0 and is_instance_valid(players[0]):
		return players[0]
	return null
