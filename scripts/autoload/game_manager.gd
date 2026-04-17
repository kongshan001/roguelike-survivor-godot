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
signal boss_kill_reward(gold: int, exp: int)
signal milestone_reached(minutes: int, gold: int)
signal retreat_requested()
signal wave_changed(wave: int)
signal wave_started(wave: int, wave_name: String)
signal wave_completed(wave: int)
signal victory_achieved(gold_bonus: int)

# Wave state machine constants
enum WaveState { WARMUP, ACTIVE, INTERMISSION, VICTORY }
const WAVE_INTERMISSION: float = 3.0
const BOSS_WARNING_TIME: float = 15.0
const TOAST_DURATION: float = 2.5
const VICTORY_TIME: float = 300.0
const VICTORY_TRANSITION_DELAY: float = 3.0
const VICTORY_GOLD_BONUS_EASY: int = 25
const VICTORY_GOLD_BONUS_NORMAL: int = 50
const VICTORY_GOLD_BONUS_HARD: int = 100

# Wave definitions (stage-system.md Section 2.3)
const WAVE_DEFS: Array = [
	{"id": "wave_opening", "name": "Opening", "duration": 60.0,
	 "enemies": ["zombie"], "spawn_base": 2.0, "count_base": 1,
	 "color": [0.30, 0.69, 0.31]},
	{"id": "wave_swarm", "name": "Swarm", "duration": 57.0,
	 "enemies": ["zombie", "bat"], "spawn_base": 1.5, "count_base": 2,
	 "color": [1.0, 0.84, 0.31]},
	{"id": "wave_darkness", "name": "Darkness", "duration": 57.0,
	 "enemies": ["zombie", "bat", "skeleton", "ghost", "elite_knight"], "spawn_base": 1.2, "count_base": 3,
	 "color": [1.0, 0.57, 0.0]},
	{"id": "wave_elite", "name": "Elite", "duration": 57.0,
	 "enemies": ["zombie", "bat", "skeleton", "ghost", "elite_skeleton", "splitter", "fire_slime", "elite_knight"],
	 "spawn_base": 1.0, "count_base": 4, "color": [0.94, 0.33, 0.31]},
	{"id": "wave_boss", "name": "Boss", "duration": 57.0,
	 "enemies": ["zombie", "bat", "skeleton", "ghost", "elite_skeleton", "splitter", "fire_slime", "elite_knight"],
	 "spawn_base": 0.8, "count_base": 5, "color": [1.0, 0.09, 0.17], "boss": true}
]

# Endless cycle scaling constants (difficulty-tuning.md Section 8.2)
const ENDLESS_CYCLE_HP_BASE: float = 0.3
const ENDLESS_CYCLE_SPD_BASE: float = 0.1
const ENDLESS_CYCLE_RATE_BASE: float = 0.1
const ENDLESS_CYCLE_RATE_FLOOR: float = 0.5

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
		"boss_hp_mul": 1.8, "boss_speed_mul": 1.3, "exp_mul": 0.8, "food_drop_mul": 0.6
	},
	"endless": {
		"player_hp_mul": 1.0, "player_speed_mul": 1.0,
		"enemy_hp_mul": 1.0, "enemy_speed_mul": 1.0, "enemy_dmg_mul": 1.0,
		"spawn_interval_mul": 1.0, "spawn_count_mod": 0,
		"boss_hp_mul": 1.0, "boss_speed_mul": 1.0, "exp_mul": 1.0, "food_drop_mul": 1.0
	}
}

# XP experience table from H5 config (index 0 = level 1→2)
const EXP_TABLE: Array[float] = [8.0, 12.0, 18.0, 24.0, 29.0, 38.0, 50.0, 70.0, 88.0, 108.0, 132.0, 160.0, 195.0, 240.0]
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

	# Enemy cache (performance optimization: avoids repeated get_nodes_in_group)
var _enemy_cache: Array = []

# Combo system
var combo_count: int = 0
var combo_timer: float = 0.0
var best_combo: int = 0

# Wave state machine
var current_wave: int = 1
var current_cycle: int = 1
var wave_state: int = WaveState.WARMUP
var is_victory: bool = false
var _wave_timer: float = 0.0
var _intermission_timer: float = 0.0
var _wave_time_accumulator: float = 0.0

var enemy_count: int = 0:
	set(v):
		enemy_count = v
		enemies_changed.emit(enemy_count)


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


# --- Enemy cache management ---

func register_enemy(enemy: Node2D) -> void:
	_enemy_cache.append(enemy)


func unregister_enemy(enemy: Node2D) -> void:
	_enemy_cache.erase(enemy)


## Get a snapshot of the cached enemy list with stale entries removed.
func get_cached_enemies() -> Array:
	var valid: Array = []
	for enemy in _enemy_cache:
		if is_instance_valid(enemy) and enemy.is_alive:
			valid.append(enemy)
	_enemy_cache = valid
	return valid


func reset():
	score = 0
	enemies_killed = 0
	elapsed_time = 0.0
	player_level = 1
	current_xp = 0.0
	xp_to_next_level = EXP_TABLE[0]
	is_paused = false
	is_game_over = false
	is_victory = false
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
	current_wave = 1
	current_cycle = 1
	wave_state = WaveState.WARMUP
	_wave_timer = 0.0
	_intermission_timer = 0.0
	_wave_time_accumulator = 0.0
	_enemy_cache.clear()


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


func update_wave(delta: float) -> void:
	if is_game_over:
		return

	var is_endless: bool = selected_difficulty == "endless"
	_wave_time_accumulator += delta

	match wave_state:
		WaveState.WARMUP:
			# Transition to ACTIVE immediately on first call
			_start_wave()
		WaveState.ACTIVE:
			_wave_timer += delta
			var def: Dictionary = _get_current_wave_def()
			var duration: float = def["duration"]
			if _wave_timer >= duration:
				_end_wave()
		WaveState.INTERMISSION:
			_intermission_timer -= delta
			if _intermission_timer <= 0.0:
				_intermission_timer = 0.0
				if not is_endless and current_wave >= WAVE_DEFS.size():
					_trigger_victory()
				else:
					_start_wave()
		WaveState.VICTORY:
			pass


func _get_current_wave_def() -> Dictionary:
	var idx: int = (current_wave - 1) % WAVE_DEFS.size()
	return WAVE_DEFS[idx]


func _start_wave() -> void:
	wave_state = WaveState.ACTIVE
	_wave_timer = 0.0
	var def: Dictionary = _get_current_wave_def()
	var wave_name: String = def["name"]
	if current_cycle > 1:
		wave_name = "C%d %s" % [current_cycle, wave_name]
	wave_started.emit(current_wave, wave_name)
	wave_changed.emit(current_wave)


func _end_wave() -> void:
	wave_completed.emit(current_wave)
	var is_endless: bool = selected_difficulty == "endless"

	if not is_endless and current_wave >= WAVE_DEFS.size():
		_trigger_victory()
		return

	# Enter intermission
	wave_state = WaveState.INTERMISSION
	_intermission_timer = WAVE_INTERMISSION
	current_wave += 1

	# Track cycle for endless mode
	if is_endless and current_wave > WAVE_DEFS.size() * current_cycle:
		current_cycle += 1


func _trigger_victory() -> void:
	wave_state = WaveState.VICTORY
	is_victory = true
	is_game_over = true
	var bonus: int = _get_victory_gold_bonus()
	gold += bonus
	victory_achieved.emit(bonus)
	player_died.emit()


func _get_victory_gold_bonus() -> int:
	match selected_difficulty:
		"easy":
			return VICTORY_GOLD_BONUS_EASY
		"hard":
			return VICTORY_GOLD_BONUS_HARD
		_:
			return VICTORY_GOLD_BONUS_NORMAL


func get_wave_hp_scale() -> float:
	var is_endless: bool = selected_difficulty == "endless"
	if is_endless:
		var cycle_idx: int = current_cycle - 1
		return 1.0 + ENDLESS_CYCLE_HP_BASE * cycle_idx
	return 1.0


func get_wave_speed_scale() -> float:
	var is_endless: bool = selected_difficulty == "endless"
	if is_endless:
		var cycle_idx: int = current_cycle - 1
		return 1.0 + ENDLESS_CYCLE_SPD_BASE * cycle_idx
	return 1.0


func get_wave_spawn_rate_scale() -> float:
	var is_endless: bool = selected_difficulty == "endless"
	if is_endless:
		var cycle_idx: int = current_cycle - 1
		return maxf(ENDLESS_CYCLE_RATE_FLOOR, 1.0 - ENDLESS_CYCLE_RATE_BASE * cycle_idx)
	return 1.0


func get_wave_progress() -> float:
	if wave_state == WaveState.INTERMISSION:
		return 1.0
	if wave_state != WaveState.ACTIVE:
		return 0.0
	var def: Dictionary = _get_current_wave_def()
	var duration: float = def["duration"]
	if duration <= 0.0:
		return 0.0
	return clampf(_wave_timer / duration, 0.0, 1.0)


func get_wave_color() -> Color:
	var def: Dictionary = _get_current_wave_def()
	var c: Array = def["color"]
	return Color(c[0], c[1], c[2])


func get_intermission_countdown() -> float:
	if wave_state != WaveState.INTERMISSION:
		return 0.0
	return _intermission_timer


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
