extends Node

signal player_died
signal level_up(new_level: int)
signal xp_changed(current: float, needed: float)
signal health_changed(current: float, max_health: float)
signal enemies_changed(count: int)
signal combo_changed(count: int)
signal gold_changed(amount: int)

# XP experience table from H5 config (index 0 = level 1→2)
const EXP_TABLE: Array[float] = [8.0, 12.0, 18.0, 24.0, 32.0, 42.0, 55.0, 70.0, 88.0, 108.0, 132.0, 160.0, 195.0, 240.0]
const COMBO_TIMEOUT: float = 3.0

var score: int = 0
var enemies_killed: int = 0
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
	combo_count += 1
	combo_timer = COMBO_TIMEOUT
	if combo_count > best_combo:
		best_combo = combo_count
	combo_changed.emit(combo_count)


func update_combo(delta: float):
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
