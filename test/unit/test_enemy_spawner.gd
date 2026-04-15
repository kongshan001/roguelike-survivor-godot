extends GutTest
## Tests for enemy_spawner.gd: wave-based spawning, enemy templates, spawn interval/count/types
## Updated for R7 wave state machine (WAVE_STAGES replaced by GameManager.WAVE_DEFS)

var _spawner: Node


func before_each():
	GameManager.reset()
	GameManager.selected_difficulty = "normal"
	_spawner = Node.new()
	_spawner.set_script(load("res://scripts/enemy_spawner.gd"))
	# Avoid _ready accessing Camera2D
	add_child_autofree(_spawner)


# --- Wave definitions come from GameManager.WAVE_DEFS ---

func test_wave_defs_has_5_stages():
	assert_eq(GameManager.WAVE_DEFS.size(), 5, "Should have 5 wave definitions")


func test_wave_def_opening_enemies():
	assert_eq(GameManager.WAVE_DEFS[0]["enemies"], ["zombie"], "Wave 1 (Opening) has only zombie")


func test_wave_def_opening_spawn_base():
	assert_eq(GameManager.WAVE_DEFS[0]["spawn_base"], 2.0, "Opening spawn_base = 2.0")


func test_wave_def_opening_count_base():
	assert_eq(GameManager.WAVE_DEFS[0]["count_base"], 1, "Opening count_base = 1")


func test_wave_def_swarm_enemies():
	var enemies: Array = GameManager.WAVE_DEFS[1]["enemies"]
	assert_has(enemies, "zombie", "Swarm should have zombie")
	assert_has(enemies, "bat", "Swarm should have bat")


func test_wave_def_boss_has_boss_flag():
	assert_true(GameManager.WAVE_DEFS[4].get("boss", false), "Wave 5 (Boss) should have boss=true")


# --- Enemy templates ---

func test_enemy_templates_count():
	assert_eq(_spawner.ENEMY_TEMPLATES.size(), 6, "Should have 6 enemy types")


func test_zombie_template():
	var t: Dictionary = _spawner.ENEMY_TEMPLATES["zombie"]
	assert_eq(t["max_hp"], 3.0, "Zombie HP = 3")
	assert_eq(t["speed"], 40.0, "Zombie speed = 40")


func test_bat_template():
	var t: Dictionary = _spawner.ENEMY_TEMPLATES["bat"]
	assert_eq(t["max_hp"], 1.0, "Bat HP = 1")
	assert_eq(t["speed"], 80.0, "Bat speed = 80")


func test_skeleton_template():
	var t: Dictionary = _spawner.ENEMY_TEMPLATES["skeleton"]
	assert_eq(t["max_hp"], 5.0, "Skeleton HP = 5")
	assert_true(t.get("is_ranged", false), "Skeleton is ranged")
	assert_eq(t["shoot_cd"], 2.0, "Skeleton shoot CD = 2")


func test_elite_skeleton_template():
	var t: Dictionary = _spawner.ENEMY_TEMPLATES["elite_skeleton"]
	assert_eq(t["max_hp"], 12.0, "Elite HP = 12")
	assert_true(t.get("is_elite", false), "Elite is elite")
	assert_eq(t["shoot_cd"], 1.2, "Elite shoot CD = 1.2")


func test_ghost_template():
	var t: Dictionary = _spawner.ENEMY_TEMPLATES["ghost"]
	assert_eq(t["max_hp"], 2.0, "Ghost HP = 2")
	assert_true(t.get("can_phase_shift", false), "Ghost can phase shift")
	assert_true(t.get("can_teleport", false), "Ghost can teleport")


func test_splitter_template():
	var t: Dictionary = _spawner.ENEMY_TEMPLATES["splitter"]
	assert_eq(t["max_hp"], 4.0, "Splitter HP = 4")
	assert_true(t.get("is_splitter", false), "Splitter can split")
	assert_eq(t["split_count"], 2, "Splitter splits into 2")


# --- Spawn interval calculation (now wave-based via _get_current_wave_def) ---

func test_spawn_interval_wave_1_opening():
	GameManager.current_wave = 1
	GameManager.wave_state = GameManager.WaveState.ACTIVE
	var interval: float = _spawner._get_spawn_interval()
	assert_eq(interval, 2.0, "Wave 1 (Opening) spawn_base = 2.0, normal multiplier = 1.0")


func test_spawn_interval_wave_2_swarm():
	GameManager.current_wave = 2
	GameManager.wave_state = GameManager.WaveState.ACTIVE
	var interval: float = _spawner._get_spawn_interval()
	assert_eq(interval, 1.5, "Wave 2 (Swarm) spawn_base = 1.5")


func test_spawn_interval_wave_3_darkness():
	GameManager.current_wave = 3
	GameManager.wave_state = GameManager.WaveState.ACTIVE
	var interval: float = _spawner._get_spawn_interval()
	assert_eq(interval, 1.2, "Wave 3 (Darkness) spawn_base = 1.2")


func test_spawn_interval_wave_4_elite():
	GameManager.current_wave = 4
	GameManager.wave_state = GameManager.WaveState.ACTIVE
	var interval: float = _spawner._get_spawn_interval()
	assert_eq(interval, 1.0, "Wave 4 (Elite) spawn_base = 1.0")


func test_spawn_interval_wave_5_boss():
	GameManager.current_wave = 5
	GameManager.wave_state = GameManager.WaveState.ACTIVE
	var interval: float = _spawner._get_spawn_interval()
	assert_eq(interval, 0.8, "Wave 5 (Boss) spawn_base = 0.8")


func test_spawn_interval_hard_mode_floor():
	GameManager.selected_difficulty = "hard"
	GameManager.current_wave = 4
	GameManager.wave_state = GameManager.WaveState.ACTIVE
	var interval: float = _spawner._get_spawn_interval()
	# base=1.0, hard spawn_interval_mul=0.7 -> 1.0*0.7=0.7, but floor is 0.7
	assert_eq(interval, 0.7, "Hard mode spawn interval floor = 0.7")


# --- Spawn count calculation (wave count_base + time_bonus + difficulty mod) ---

func test_spawn_count_wave_1_early():
	GameManager.current_wave = 1
	GameManager.elapsed_time = 10.0
	assert_eq(_spawner._get_spawn_count(), 1, "Wave 1, early: count_base=1 + 0 bonus = 1")


func test_spawn_count_wave_2_mid():
	GameManager.current_wave = 2
	GameManager.elapsed_time = 45.0
	assert_eq(_spawner._get_spawn_count(), 2, "Wave 2, mid: count_base=2 + 0 bonus = 2")


func test_spawn_count_wave_3_with_time_bonus():
	GameManager.current_wave = 3
	GameManager.elapsed_time = 130.0  # >= 120 -> time_bonus = 1
	assert_eq(_spawner._get_spawn_count(), 4, "Wave 3, t>=120: count_base=3 + 1 bonus = 4")


func test_spawn_count_wave_4_with_time_bonus():
	GameManager.current_wave = 4
	GameManager.elapsed_time = 185.0  # >= 180 -> time_bonus = 2
	assert_eq(_spawner._get_spawn_count(), 6, "Wave 4, t>=180: count_base=4 + 2 bonus = 6")


func test_spawn_count_wave_5_max():
	GameManager.current_wave = 5
	GameManager.elapsed_time = 300.0
	assert_eq(_spawner._get_spawn_count(), 7, "Wave 5, t>=180: count_base=5 + 2 bonus = 7")


func test_spawn_count_difficulty_mod():
	GameManager.current_wave = 1
	GameManager.selected_difficulty = "hard"
	GameManager.elapsed_time = 10.0
	assert_eq(_spawner._get_spawn_count(), 2, "Wave 1 hard: count_base=1 + hard mod(+1) = 2")


# --- Available enemy types (wave-based via _get_current_wave_def) ---

func test_types_wave_1_opening():
	GameManager.current_wave = 1
	var types: Array = _spawner._get_available_types()
	assert_eq(types, ["zombie"], "Wave 1: only zombie")


func test_types_wave_2_swarm():
	GameManager.current_wave = 2
	var types: Array = _spawner._get_available_types()
	assert_has(types, "zombie", "Wave 2 should have zombie")
	assert_has(types, "bat", "Wave 2 should have bat")
	assert_eq(types.size(), 2, "Wave 2 should have 2 types")


func test_types_wave_3_darkness():
	GameManager.current_wave = 3
	var types: Array = _spawner._get_available_types()
	assert_has(types, "skeleton", "Wave 3 should have skeleton")
	assert_has(types, "ghost", "Wave 3 should have ghost")
	assert_eq(types.size(), 4, "Wave 3 should have 4 types")


func test_types_wave_4_elite():
	GameManager.current_wave = 4
	var types: Array = _spawner._get_available_types()
	assert_has(types, "elite_skeleton", "Wave 4 should have elite_skeleton")
	assert_has(types, "splitter", "Wave 4 should have splitter")
	assert_eq(types.size(), 6, "Wave 4 should have all 6 types")


func test_types_wave_5_boss():
	GameManager.current_wave = 5
	var types: Array = _spawner._get_available_types()
	assert_eq(types.size(), 6, "Wave 5 (boss wave) should also have 6 types")


# --- Boss spawn time ---

func test_boss_time_normal():
	var mul: float = GameManager.get_difficulty_mul("spawn_interval_mul")
	var boss_time: float = 270.0 * mul
	assert_eq(boss_time, 270.0, "Normal: boss at 270s")


func test_boss_warning_before_spawn():
	var boss_time: float = 270.0
	var warning_time: float = boss_time - 15.0
	assert_eq(warning_time, 255.0, "Boss warning at 255s")


# --- _create_enemy_data ---

func test_create_zombie_data():
	var data: EnemyData = _spawner._create_enemy_data("zombie")
	assert_eq(data.enemy_id, "zombie", "ID should be zombie")
	assert_eq(data.max_hp, 3.0, "HP should be 3")
	assert_eq(data.speed, 40.0, "Speed should be 40")
	assert_eq(data.xp_value, 2, "XP should be 2")


func test_create_skeleton_data():
	var data: EnemyData = _spawner._create_enemy_data("skeleton")
	assert_eq(data.enemy_id, "skeleton")
	assert_true(data.is_ranged, "Should be ranged")
	assert_eq(data.shoot_cd, 2.0, "Shoot CD = 2")


func test_create_unknown_falls_back_to_zombie():
	var data: EnemyData = _spawner._create_enemy_data("nonexistent")
	assert_eq(data.enemy_id, "zombie", "Unknown type falls back to zombie")


# --- Initial state ---

func test_initial_state():
	assert_eq(_spawner._spawn_timer, 0.0, "Spawn timer starts at 0")
	assert_false(_spawner._boss_spawned, "Boss not spawned initially")
	assert_eq(_spawner._endless_boss_timer, 240.0, "Endless boss timer = 240")
	assert_eq(_spawner._endless_cycle, 0, "Endless cycle starts at 0")
