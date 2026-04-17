extends GutTest
## AudioManager unit tests
## Spec: docs/superpowers/specs/v1.2.0-audio-system.md
## Tests verify AudioManager autoload singleton: instantiation, BGM players, SFX pool,
## public API methods, volume clamping, mute toggle, constants, and null safety.


const AUDIO_MANAGER_PATH := "res://scripts/autoload/audio_manager.gd"


func _create_audio_manager() -> Node:
	var script: GDScript = load(AUDIO_MANAGER_PATH) as GDScript
	var node: Node = Node.new()
	node.set_script(script)
	add_child_autofree(node)
	return node


# =====================================================================
# 1. Instantiation
# =====================================================================

func test_audio_manager_instantiation():
	var am: Node = _create_audio_manager()
	assert_ne(am, null, "AudioManager node should instantiate without crash")


# =====================================================================
# 2. BGM Players (2 for crossfade)
# =====================================================================

func test_ready_creates_two_bgm_players():
	var am: Node = _create_audio_manager()
	var bgm_players: Array = []
	for child in am.get_children():
		if child is AudioStreamPlayer and child.name.to_lower().find("bgm") >= 0:
			bgm_players.append(child)
	assert_eq(bgm_players.size(), 2, "_ready() should create exactly 2 BGM AudioStreamPlayer nodes (BGMPlayer0, BGMPlayer1)")


func test_bgm_players_on_bgm_bus():
	var am: Node = _create_audio_manager()
	for child in am.get_children():
		if child is AudioStreamPlayer and child.name.to_lower().find("bgm") >= 0:
			assert_eq(child.bus, "BGM", "BGM player should be on BGM bus")


# =====================================================================
# 3. SFX Pool (4 players)
# =====================================================================

func test_ready_creates_four_sfx_pool_players():
	var am: Node = _create_audio_manager()
	var sfx_players: Array = []
	for child in am.get_children():
		if child is AudioStreamPlayer and child.name.to_lower().find("sfx") >= 0:
			sfx_players.append(child)
	assert_eq(sfx_players.size(), 4, "_ready() should create exactly 4 SFX pool AudioStreamPlayer nodes (SFXPlayer0-3)")


func test_sfx_players_on_sfx_bus():
	var am: Node = _create_audio_manager()
	for child in am.get_children():
		if child is AudioStreamPlayer and child.name.to_lower().find("sfx") >= 0:
			assert_eq(child.bus, "SFX", "SFX player should be on SFX bus")


# =====================================================================
# 4. UI Player
# =====================================================================

func test_ui_player_exists():
	var am: Node = _create_audio_manager()
	var ui_player: AudioStreamPlayer = am.get_node_or_null("UIPlayer")
	assert_ne(ui_player, null, "UIPlayer should exist")
	assert_eq(ui_player.bus, "UI", "UIPlayer should be on UI bus")


# =====================================================================
# 5. Audio Buses
# =====================================================================

func test_bgm_bus_exists():
	_create_audio_manager()
	assert_ne(AudioServer.get_bus_index("BGM"), -1, "BGM bus should exist")


func test_sfx_bus_exists():
	_create_audio_manager()
	assert_ne(AudioServer.get_bus_index("SFX"), -1, "SFX bus should exist")


func test_ui_bus_exists():
	_create_audio_manager()
	assert_ne(AudioServer.get_bus_index("UI"), -1, "UI bus should exist")


# =====================================================================
# 6. Method Existence
# =====================================================================

func test_has_method_play_bgm():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("play_bgm"), "AudioManager should have play_bgm() method")


func test_has_method_stop_bgm():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("stop_bgm"), "AudioManager should have stop_bgm() method")


func test_has_method_play_sfx():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("play_sfx"), "AudioManager should have play_sfx() method")


func test_has_method_set_volume():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("set_volume"), "AudioManager should have set_volume() method")


func test_has_method_get_volume():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("get_volume"), "AudioManager should have get_volume() method")


func test_has_method_toggle_mute():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("toggle_mute"), "AudioManager should have toggle_mute() method")


func test_has_method_is_muted():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("is_muted"), "AudioManager should have is_muted() method")


func test_has_method_play_sfx_by_id():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("play_sfx_by_id"), "AudioManager should have play_sfx_by_id() method")


func test_has_method_play_ui_sfx():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("play_ui_sfx"), "AudioManager should have play_ui_sfx() method")


func test_has_method_play_bgm_by_id():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("play_bgm_by_id"), "AudioManager should have play_bgm_by_id() method")


func test_has_method_get_current_bgm_id():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("get_current_bgm_id"), "AudioManager should have get_current_bgm_id() method")


func test_has_method_preload_sfx():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("preload_sfx"), "AudioManager should have preload_sfx() method")


func test_has_method_preload_bgm():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("preload_bgm"), "AudioManager should have preload_bgm() method")


func test_has_method_unload_unused():
	var am: Node = _create_audio_manager()
	assert_true(am.has_method("unload_unused"), "AudioManager should have unload_unused() method")


# =====================================================================
# 7. Volume Control
# =====================================================================

func test_set_volume_accepts_valid():
	var am: Node = _create_audio_manager()
	am.set_volume("master", 50)
	var vol = am.get_volume("master")
	assert_eq(vol, 50, "set_volume should accept valid value 50")


func test_set_volume_clamps_low():
	var am: Node = _create_audio_manager()
	am.set_volume("master", -50)
	var vol = am.get_volume("master")
	assert_eq(vol, 0, "set_volume should clamp negative values to 0")


func test_set_volume_clamps_high():
	var am: Node = _create_audio_manager()
	am.set_volume("master", 150)
	var vol = am.get_volume("master")
	assert_eq(vol, 100, "set_volume should clamp values above 100 to 100")


func test_set_volume_0_is_min_db():
	var am: Node = _create_audio_manager()
	am.set_volume("Master", 0)
	var idx: int = AudioServer.get_bus_index("Master")
	assert_almost_eq(AudioServer.get_bus_volume_db(idx), -40.0, 0.01, "Volume 0 should map to -40 dB")


func test_set_volume_100_is_zero_db():
	var am: Node = _create_audio_manager()
	am.set_volume("Master", 100)
	var idx: int = AudioServer.get_bus_index("Master")
	assert_almost_eq(AudioServer.get_bus_volume_db(idx), 0.0, 0.01, "Volume 100 should map to 0 dB")


func test_set_volume_master_db():
	var am: Node = _create_audio_manager()
	am.set_volume("Master", 50)
	var idx: int = AudioServer.get_bus_index("Master")
	var expected_db: float = linear_to_db(0.5)
	assert_almost_eq(AudioServer.get_bus_volume_db(idx), expected_db, 0.01, "Master volume dB should match 50%")


func test_set_volume_bgm_db():
	var am: Node = _create_audio_manager()
	am.set_volume("BGM", 80)
	var idx: int = AudioServer.get_bus_index("BGM")
	var expected_db: float = linear_to_db(0.8)
	assert_almost_eq(AudioServer.get_bus_volume_db(idx), expected_db, 0.01, "BGM volume dB should match 80%")


func test_set_volume_sfx_db():
	var am: Node = _create_audio_manager()
	am.set_volume("SFX", 60)
	var idx: int = AudioServer.get_bus_index("SFX")
	var expected_db: float = linear_to_db(0.6)
	assert_almost_eq(AudioServer.get_bus_volume_db(idx), expected_db, 0.01, "SFX volume dB should match 60%")


func test_set_volume_ui_db():
	var am: Node = _create_audio_manager()
	am.set_volume("UI", 70)
	var idx: int = AudioServer.get_bus_index("UI")
	var expected_db: float = linear_to_db(0.7)
	assert_almost_eq(AudioServer.get_bus_volume_db(idx), expected_db, 0.01, "UI volume dB should match 70%")


func test_volume_changed_signal():
	var am: Node = _create_audio_manager()
	watch_signals(am)
	am.set_volume("Master", 42)
	assert_signal_emitted_with_parameters(am, "volume_changed", ["Master", 42])


func test_get_volume_default_master():
	var am: Node = _create_audio_manager()
	assert_eq(am.get_volume("master"), am.DEFAULT_MASTER_VOLUME, "Default master volume should match constant")


func test_get_volume_default_bgm():
	var am: Node = _create_audio_manager()
	assert_eq(am.get_volume("bgm"), am.DEFAULT_BGM_VOLUME, "Default BGM volume should match constant")


func test_get_volume_default_sfx():
	var am: Node = _create_audio_manager()
	assert_eq(am.get_volume("sfx"), am.DEFAULT_SFX_VOLUME, "Default SFX volume should match constant")


func test_get_volume_default_ui():
	var am: Node = _create_audio_manager()
	assert_eq(am.get_volume("ui"), am.DEFAULT_UI_VOLUME, "Default UI volume should match constant")


# =====================================================================
# 8. Mute Toggle
# =====================================================================

func test_toggle_mute_changes_state():
	var am: Node = _create_audio_manager()
	var was_muted: bool = am.is_muted()
	am.toggle_mute()
	assert_ne(am.is_muted(), was_muted, "Mute state should toggle")


func test_mute_double_toggle_restores():
	var am: Node = _create_audio_manager()
	var initial: bool = am.is_muted()
	am.toggle_mute()
	am.toggle_mute()
	assert_eq(am.is_muted(), initial, "Double toggle should return to original state")


func test_toggle_mute_affects_master_bus():
	var am: Node = _create_audio_manager()
	var idx: int = AudioServer.get_bus_index("Master")
	am.toggle_mute()
	var muted: bool = AudioServer.is_bus_mute(idx)
	assert_eq(am.is_muted(), muted, "Master bus mute should match AudioManager state")
	# Cleanup
	if am.is_muted():
		am.toggle_mute()


# =====================================================================
# 9. SFX Playback Safety
# =====================================================================

func test_play_sfx_null_no_crash():
	var am: Node = _create_audio_manager()
	am.play_sfx(null)
	assert_true(true, "play_sfx(null) should not crash")


func test_play_sfx_by_id_empty_string_no_crash():
	var am: Node = _create_audio_manager()
	am.play_sfx_by_id("")
	assert_true(true, "play_sfx_by_id('') should not crash")


func test_play_sfx_by_id_unknown_id_no_crash():
	var am: Node = _create_audio_manager()
	am.play_sfx_by_id("nonexistent_sfx_id")
	assert_true(true, "play_sfx_by_id('nonexistent_sfx_id') should not crash")


func test_play_sfx_stream_sets_on_pool_player():
	var am: Node = _create_audio_manager()
	var stream: AudioStream = AudioStreamGenerator.new()
	am.play_sfx(stream)
	var found: bool = false
	for child in am.get_children():
		if child is AudioStreamPlayer and child.name.to_lower().find("sfx") >= 0 and child.stream == stream:
			found = true
			break
	assert_true(found, "SFX stream should be set on a pool player")


func test_play_sfx_pitch_variation():
	var am: Node = _create_audio_manager()
	var stream: AudioStream = AudioStreamGenerator.new()
	am.play_sfx(stream, 0.1)
	var found_player: AudioStreamPlayer = null
	for child in am.get_children():
		if child is AudioStreamPlayer and child.name.to_lower().find("sfx") >= 0 and child.stream == stream:
			found_player = child
			break
	assert_ne(found_player, null, "Should find SFX player with our stream")
	assert_almost_eq(found_player.pitch_scale, 1.0, 0.11, "Pitch scale should vary around 1.0")


func test_play_sfx_no_pitch_variation():
	var am: Node = _create_audio_manager()
	var stream: AudioStream = AudioStreamGenerator.new()
	am.play_sfx(stream, 0.0)
	var found_player: AudioStreamPlayer = null
	for child in am.get_children():
		if child is AudioStreamPlayer and child.name.to_lower().find("sfx") >= 0 and child.stream == stream:
			found_player = child
			break
	assert_ne(found_player, null, "Should find SFX player with our stream")
	assert_eq(found_player.pitch_scale, 1.0, "Pitch scale should be 1.0 with no variation")


func test_sfx_pool_exhaustion_safe():
	var am: Node = _create_audio_manager()
	for i in range(am.SFX_POOL_SIZE + 2):
		am.play_sfx(AudioStreamGenerator.new())
	assert_true(true, "Playing more SFX than pool size should not crash")


func test_play_ui_sfx_unknown_safe():
	var am: Node = _create_audio_manager()
	am.play_ui_sfx("nonexistent_ui")
	assert_true(true, "play_ui_sfx with unknown ID should not crash")


# =====================================================================
# 10. BGM Playback
# =====================================================================

func test_play_bgm_sets_stream():
	var am: Node = _create_audio_manager()
	var stream: AudioStream = AudioStreamGenerator.new()
	am.play_bgm(stream, 0.0)
	var player: AudioStreamPlayer = am.get_node("BGMPlayer%d" % am._current_bgm_index)
	assert_eq(player.stream, stream, "BGM stream should be set after play_bgm")


func test_play_bgm_switches_player_index():
	var am: Node = _create_audio_manager()
	var initial: int = am._current_bgm_index
	am.play_bgm(AudioStreamGenerator.new(), 0.0)
	assert_ne(am._current_bgm_index, initial, "Player index should switch on play_bgm")


func test_stop_bgm_clears_id():
	var am: Node = _create_audio_manager()
	am._current_bgm_id = "test_bgm"
	am.stop_bgm(0.0)
	assert_eq(am.get_current_bgm_id(), "", "BGM ID should be cleared after stop")


func test_get_current_bgm_id_default():
	var am: Node = _create_audio_manager()
	assert_eq(am.get_current_bgm_id(), "", "Default BGM ID should be empty string")


func test_play_bgm_by_id_unknown_id():
	var am: Node = _create_audio_manager()
	am.play_bgm_by_id("nonexistent_bgm", 0.0)
	assert_true(true, "play_bgm_by_id with unknown ID should not crash")


# =====================================================================
# 11. Constants
# =====================================================================

func test_sfx_ids_count():
	assert_eq(AudioManager.SFX_IDS.size(), 33, "SFX_IDS should have 33 entries")


func test_sfx_ids_unique():
	var values: Array = AudioManager.SFX_IDS.values()
	var unique: Array = []
	for v in values:
		assert_false(unique.has(v), "SFX ID '%s' should be unique" % v)
		unique.append(v)


func test_bgm_ids_count():
	assert_eq(AudioManager.BGM_IDS.size(), 6, "BGM_IDS should have 6 entries")


func test_bgm_paths_count():
	assert_eq(AudioManager.BGM_PATHS.size(), 6, "BGM_PATHS should have 6 entries")


func test_bgm_paths_format():
	for key in AudioManager.BGM_PATHS:
		var path: String = AudioManager.BGM_PATHS[key]
		assert_true(path.begins_with("res://assets/audio/bgm/"), "BGM path should be in correct directory")
		assert_true(path.ends_with(".ogg"), "BGM path should end with .ogg")


# =====================================================================
# 12. Resource Management
# =====================================================================

func test_preload_sfx_unknown_safe():
	var am: Node = _create_audio_manager()
	am.preload_sfx(["nonexistent1", "nonexistent2"])
	assert_true(true, "preload_sfx with unknown IDs should not crash")


func test_unload_unused_clears_cache():
	var am: Node = _create_audio_manager()
	am._sfx_cache["test_key"] = AudioStreamGenerator.new()
	am.unload_unused()
	assert_eq(am._sfx_cache.size(), 0, "unload_unused should clear SFX cache")


func test_preload_bgm_unknown_safe():
	var am: Node = _create_audio_manager()
	am.preload_bgm("nonexistent_bgm")
	assert_true(true, "preload_bgm with unknown ID should not crash")
