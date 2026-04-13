extends GutTest
## Tests for enemy_spawner.gd: wave progression, spawn intervals, enemy templates

var _spawner: Node


func before_each():
	GameManager.reset()
	GameManager.selected_difficulty = "normal"
	_spawner = Node.new()
	_spawner.set_script(load("res://scripts/enemy_spawner.gd"))
	# Avoid _ready accessing Camera2D
	add_child_autofree(_spawner)


# --- Wave stages ---

func test_wave_stages_count():
	assert_eq(_spawner.WAVE_STAGES.size(), 5, "Should have 5 wave stages")


func test_wave_stage_times():
	assert_eq(_spawner.WAVE_STAGES[0]["time"], 0, "Stage 0: time 0")
	assert_eq(_spawner.WAVE_STAGES[1]["time"], 120, "Stage 1: time 120")
	assert_eq(_spawner.WAVE_STAGES[2]["time"], 180, "Stage 2: time 180")
	assert_eq(_spawner.WAVE_STAGES[3]["time"], 210, "Stage 3: time 210")
	assert_eq(_spawner.WAVE_STAGES[4]["time"], 270, "Stage 4: time 270 (boss)")


func test_initial_enemies_only_zombie():
	assert_eq(_spawner.WAVE_STAGES[0]["enemies"], ["zombie"], "Stage 0 has only zombie")


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


# --- Spawn interval calculation ---

func test_spawn_interval_early():
	GameManager.elapsed_time = 10.0
	var interval: float = _spawner._get_spawn_interval()
	assert_eq(interval, 2.0, "t<30: interval = 2.0")


func test_spawn_interval_mid():
	GameManager.elapsed_time = 45.0
	var interval: float = _spawner._get_spawn_interval()
	assert_eq(interval, 1.5, "30<=t<60: interval = 1.5")


func test_spawn_interval_late():
	GameManager.elapsed_time = 150.0
	var interval: float = _spawner._get_spawn_interval()
	assert_eq(interval, 1.0, "120<=t<180: interval = 1.0")


func test_spawn_interval_endgame():
	GameManager.elapsed_time = 200.0
	var interval: float = _spawner._get_spawn_interval()
	assert_eq(interval, 0.8, "t>=180: interval = 0.8")


# --- Spawn count calculation ---

func test_spawn_count_early():
	GameManager.elapsed_time = 10.0
	assert_eq(_spawner._get_spawn_count(), 1, "t<30: count = 1")


func test_spawn_count_mid():
	GameManager.elapsed_time = 45.0
	assert_eq(_spawner._get_spawn_count(), 2, "30<=t<60: count = 2")


func test_spawn_count_late():
	GameManager.elapsed_time = 90.0
	assert_eq(_spawner._get_spawn_count(), 3, "60<=t<120: count = 3")


func test_spawn_count_endgame():
	GameManager.elapsed_time = 150.0
	assert_eq(_spawner._get_spawn_count(), 4, "120<=t<180: count = 4")


func test_spawn_count_max():
	GameManager.elapsed_time = 300.0
	assert_eq(_spawner._get_spawn_count(), 5, "t>=180: count = 5")


# --- Available enemy types ---

func test_types_initial():
	GameManager.elapsed_time = 0.0
	var types: Array = _spawner._get_available_types()
	assert_eq(types, ["zombie"], "t=0: only zombie")


func test_types_after_120():
	GameManager.elapsed_time = 120.0
	var types: Array = _spawner._get_available_types()
	assert_has(types, "zombie", "Should have zombie")
	assert_has(types, "bat", "Should have bat")
	assert_eq(types.size(), 2, "Should have 2 types at t=120")


func test_types_after_180():
	GameManager.elapsed_time = 180.0
	var types: Array = _spawner._get_available_types()
	assert_has(types, "skeleton", "Should have skeleton")
	assert_has(types, "ghost", "Should have ghost")
	assert_eq(types.size(), 4, "Should have 4 types at t=180")


func test_types_after_210():
	GameManager.elapsed_time = 210.0
	var types: Array = _spawner._get_available_types()
	assert_has(types, "elite_skeleton", "Should have elite_skeleton")
	assert_has(types, "splitter", "Should have splitter")
	assert_eq(types.size(), 6, "Should have all 6 types at t=210")


# --- Boss spawn time ---

func test_boss_time_normal():
	var mul: float = GameManager.get_difficulty_mul("spawn_interval_mul")
	var boss_time: float = 270.0 * mul
	assert_eq(boss_time, 270.0, "Normal: boss at 270s")


func test_boss_warning_before_spawn():
	# Warning should be 15s before boss
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
