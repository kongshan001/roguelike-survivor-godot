extends Node
## 音频管理器 — BGM交叉淡出 + SFX音池 + 音量控制
## v1.2.0 Phase A: 核心架构 + BGM播放 + SFX播放 + 音量控制

signal volume_changed(bus: String, value: int)

## 音频总线常量
const BUS_MASTER: String = "Master"
const BUS_BGM: String = "BGM"
const BUS_SFX: String = "SFX"
const BUS_UI: String = "UI"

## 默认音量 (0-100 整数)
const DEFAULT_MASTER_VOLUME: int = 80
const DEFAULT_BGM_VOLUME: int = 60
const DEFAULT_SFX_VOLUME: int = 80
const DEFAULT_UI_VOLUME: int = 70

## SFX音池大小
const SFX_POOL_SIZE: int = 4

## 音量范围常量
const MIN_VOLUME_DB: float = -40.0
const MAX_VOLUME_DB: float = 0.0

## BGM交叉淡出默认时间
const BGM_CROSSFADE_DEFAULT: float = 1.5

## BGM播放器 (2个用于交叉淡出)
var _bgm_players: Array[AudioStreamPlayer] = []
var _current_bgm_index: int = 0
var _current_bgm_id: String = ""

## SFX音池 (复用)
var _sfx_pool: Array[AudioStreamPlayer] = []

## UI播放器
var _ui_player: AudioStreamPlayer = null

## 音量存储 (0-100)
var _volumes: Dictionary = {
	"master": DEFAULT_MASTER_VOLUME,
	"bgm": DEFAULT_BGM_VOLUME,
	"sfx": DEFAULT_SFX_VOLUME,
	"ui": DEFAULT_UI_VOLUME,
}

## 静音状态
var _muted: bool = false

## SFX缓存 (id -> AudioStream)
var _sfx_cache: Dictionary = {}

## SFX ID常量
const SFX_IDS: Dictionary = {
	# Player
	"player_hurt": "sfx_player_hurt",
	"player_death": "sfx_player_death",
	"player_dash": "sfx_player_dash",
	"player_levelup": "sfx_player_levelup",
	"player_skill": "sfx_player_skill",
	# Weapons
	"knife_throw": "sfx_knife_throw",
	"boomerang_throw": "sfx_boomerang_throw",
	"lightning_strike": "sfx_lightning_strike",
	"holywater_orbit": "sfx_holywater_orbit",
	"bible_spin": "sfx_bible_spin",
	"firestaff_blast": "sfx_firestaff_blast",
	"frostaura_pulse": "sfx_frostaura_pulse",
	"spiral_blade": "sfx_spiral_blade",
	"pulse_ring": "sfx_pulse_ring",
	"beam_fire": "sfx_beam_fire",
	"weapon_hit": "sfx_weapon_hit",
	"weapon_crit": "sfx_weapon_crit",
	# Enemies
	"enemy_hurt": "sfx_enemy_hurt",
	"enemy_death": "sfx_enemy_death",
	"boss_roar": "sfx_boss_roar",
	"elite_death": "sfx_elite_death",
	# UI
	"ui_click": "sfx_ui_click",
	"ui_select": "sfx_ui_select",
	"ui_hover": "sfx_ui_hover",
	"ui_close": "sfx_ui_close",
	"shop_buy": "sfx_shop_buy",
	"upgrade_done": "sfx_upgrade_done",
	# Environment
	"xp_pickup": "sfx_xp_pickup",
	"gold_drop": "sfx_gold_drop",
	"chest_open": "sfx_chest_open",
	"item_pickup": "sfx_item_pickup",
	"wave_start": "sfx_wave_start",
	"wave_clear": "sfx_wave_clear",
}

## BGM ID常量
const BGM_IDS: Dictionary = {
	"title": "bgm_title",
	"select": "bgm_select",
	"arena": "bgm_arena",
	"boss": "bgm_boss",
	"victory": "bgm_victory",
	"gameover": "bgm_gameover",
}

const BGM_PATHS: Dictionary = {
	"bgm_title": "res://assets/audio/bgm/bgm_title.ogg",
	"bgm_select": "res://assets/audio/bgm/bgm_select.ogg",
	"bgm_arena": "res://assets/audio/bgm/bgm_arena.ogg",
	"bgm_boss": "res://assets/audio/bgm/bgm_boss.ogg",
	"bgm_victory": "res://assets/audio/bgm/bgm_victory.ogg",
	"bgm_gameover": "res://assets/audio/bgm/bgm_gameover.ogg",
}

func _ready() -> void:
	_ensure_audio_buses()
	_create_bgm_players()
	_create_sfx_pool()
	_create_ui_player()
	_apply_all_volumes()


func _ensure_audio_buses() -> void:
	## 确保BGM/SFX/UI总线存在
	for bus_name: String in [BUS_BGM, BUS_SFX, BUS_UI]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)


func _create_bgm_players() -> void:
	## 创建2个BGM播放器(用于交叉淡出)
	for i: int in range(2):
		var player := AudioStreamPlayer.new()
		player.name = "BGMPlayer%d" % i
		player.bus = BUS_BGM
		add_child(player)
		_bgm_players.append(player)


func _create_sfx_pool() -> void:
	## 创建SFX音池
	for i: int in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer%d" % i
		player.bus = BUS_SFX
		add_child(player)
		_sfx_pool.append(player)


func _create_ui_player() -> void:
	## 创建UI音频播放器
	_ui_player = AudioStreamPlayer.new()
	_ui_player.name = "UIPlayer"
	_ui_player.bus = BUS_UI
	add_child(_ui_player)


# --- BGM ---

func play_bgm(stream: AudioStream, fade_time: float = BGM_CROSSFADE_DEFAULT) -> void:
	## 播放BGM，支持交叉淡出。如果已有BGM在播放，先淡出旧BGM再淡入新BGM。
	var next_index: int = 1 - _current_bgm_index
	var next_player: AudioStreamPlayer = _bgm_players[next_index]
	var current_player: AudioStreamPlayer = _bgm_players[_current_bgm_index]

	next_player.stream = stream
	next_player.volume_db = MIN_VOLUME_DB
	next_player.play()

	# 交叉淡出: 新BGM淡入，旧BGM淡出
	var t: Tween = create_tween()
	t.tween_property(next_player, "volume_db", _volume_to_db(_volumes["bgm"]), fade_time)
	t.parallel().tween_property(current_player, "volume_db", MIN_VOLUME_DB, fade_time)
	t.tween_callback(func() -> void: current_player.stop())
	_current_bgm_index = next_index


func play_bgm_by_id(bgm_id: String, fade_time: float = BGM_CROSSFADE_DEFAULT) -> void:
	## 按BGM ID播放背景音乐
	_current_bgm_id = bgm_id
	var path: String = BGM_PATHS.get(bgm_id, "")
	if path == "":
		return
	if ResourceLoader.exists(path):
		var stream: AudioStream = load(path)
		if stream:
			play_bgm(stream, fade_time)


func stop_bgm(fade_time: float = 1.0) -> void:
	## 淡出停止当前BGM
	var player: AudioStreamPlayer = _bgm_players[_current_bgm_index]
	var t: Tween = create_tween()
	t.tween_property(player, "volume_db", MIN_VOLUME_DB, fade_time)
	t.tween_callback(func() -> void: player.stop())
	_current_bgm_id = ""


func get_current_bgm_id() -> String:
	## 返回当前播放的BGM ID
	return _current_bgm_id


# --- SFX ---

func play_sfx(stream: AudioStream, pitch_variation: float = 0.0) -> void:
	## 直接播放AudioStream作为SFX，支持音调变化
	if stream == null:
		return
	var player: AudioStreamPlayer = _get_available_sfx_player()
	if player == null:
		return
	player.stream = stream
	if pitch_variation > 0.0:
		player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	else:
		player.pitch_scale = 1.0
	player.play()


func play_sfx_by_id(id: String, pitch_variation: float = 0.0) -> void:
	## 按SFX ID播放音效。优先从缓存读取，否则尝试加载资源文件。
	if not SFX_IDS.has(id):
		return
	var sfx_key: String = SFX_IDS[id]
	if _sfx_cache.has(sfx_key):
		play_sfx(_sfx_cache[sfx_key], pitch_variation)
		return
	var path: String = "res://assets/audio/sfx/%s.wav" % sfx_key
	if ResourceLoader.exists(path):
		var stream: AudioStream = load(path)
		if stream:
			_sfx_cache[sfx_key] = stream
			play_sfx(stream, pitch_variation)


func play_ui_sfx(id: String) -> void:
	## 播放UI音效（使用独立UI播放器）
	if not SFX_IDS.has(id):
		return
	var sfx_key: String = SFX_IDS[id]
	if _sfx_cache.has(sfx_key):
		_ui_player.stream = _sfx_cache[sfx_key]
		_ui_player.pitch_scale = 1.0
		_ui_player.play()
		return
	var path: String = "res://assets/audio/sfx/%s.wav" % sfx_key
	if ResourceLoader.exists(path):
		var stream: AudioStream = load(path)
		if stream:
			_sfx_cache[sfx_key] = stream
			_ui_player.stream = stream
			_ui_player.pitch_scale = 1.0
			_ui_player.play()


func _get_available_sfx_player() -> AudioStreamPlayer:
	## 获取一个空闲的SFX播放器，全部占用则复用第一个
	for player: AudioStreamPlayer in _sfx_pool:
		if not player.playing:
			return player
	return _sfx_pool[0]


# --- Volume ---

func set_volume(bus_name: String, value: int) -> void:
	## 设置指定总线的音量 (0-100)
	value = clampi(value, 0, 100)
	_volumes[bus_name.to_lower()] = value
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, _volume_to_db(value))
	volume_changed.emit(bus_name, value)


func get_volume(bus_name: String) -> int:
	## 获取指定总线的音量 (0-100)
	return _volumes.get(bus_name.to_lower(), DEFAULT_MASTER_VOLUME)


func toggle_mute() -> void:
	## 切换静音状态
	_muted = not _muted
	var idx: int = AudioServer.get_bus_index(BUS_MASTER)
	if idx >= 0:
		AudioServer.set_bus_mute(idx, _muted)


func is_muted() -> bool:
	## 返回当前是否静音
	return _muted


func _volume_to_db(value: int) -> float:
	## 将0-100整数音量转换为dB值
	if value <= 0:
		return MIN_VOLUME_DB
	var linear: float = value / 100.0
	return linear_to_db(linear)


func _apply_all_volumes() -> void:
	## 初始化时应用所有音量设置
	set_volume(BUS_MASTER, _volumes["master"])
	set_volume(BUS_BGM, _volumes["bgm"])
	set_volume(BUS_SFX, _volumes["sfx"])
	set_volume(BUS_UI, _volumes["ui"])


# --- Resource Management ---

func preload_sfx(ids: Array) -> void:
	## 预加载指定SFX到缓存
	for id: String in ids:
		if not SFX_IDS.has(id):
			continue
		var sfx_key: String = SFX_IDS[id]
		if _sfx_cache.has(sfx_key):
			continue
		var path: String = "res://assets/audio/sfx/%s.wav" % sfx_key
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path)
			if stream:
				_sfx_cache[sfx_key] = stream


func preload_bgm(bgm_id: String) -> void:
	## 预加载指定BGM
	var path: String = BGM_PATHS.get(bgm_id, "")
	if path != "" and ResourceLoader.exists(path):
		load(path)


func unload_unused() -> void:
	## 清空SFX缓存，释放未使用资源
	_sfx_cache.clear()
