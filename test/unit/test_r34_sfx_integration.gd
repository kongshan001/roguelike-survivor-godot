extends GutTest
## R34 SFX Integration Tests
## Verifies that AudioManager SFX IDs are defined and that game scripts
## call AudioManager.play_sfx_by_id with proper guards (if AudioManager:).
## Tests are source-code level (no scene instantiation).


const AUDIO_MANAGER_PATH := "res://scripts/autoload/audio_manager.gd"
const PLAYER_PATH := "res://scripts/player.gd"
const ENEMY_PATH := "res://scripts/enemy.gd"
const XP_GEM_PATH := "res://scripts/xp_gem.gd"
const HUD_PATH := "res://scripts/hud.gd"
const PROJECTILE_PATH := "res://scripts/projectile.gd"


# =====================================================================
# Helper: load source as text for string searching
# =====================================================================

func _load_source(path: String) -> String:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var content: String = f.get_as_text()
	f.close()
	return content


## Check that all AudioManager.play_sfx calls in a source file are guarded
## with "if AudioManager:" on the same line (inline guard pattern).
func _assert_all_sfx_guarded(file_path: String, file_label: String) -> void:
	var src: String = _load_source(file_path)
	if src.find("AudioManager") < 0:
		pending("%s has no AudioManager calls yet -- guard test not applicable" % file_label)
		return
	var lines: PackedStringArray = src.split("\n")
	var found_unguarded: bool = false
	var found_guarded: bool = false
	for i in range(lines.size()):
		var line: String = lines[i].strip_edges()
		if line.find("AudioManager.play_sfx_by_id") >= 0 or line.find("AudioManager.play_sfx(") >= 0:
			# Check if guard is on the same line (inline: "if AudioManager: AudioManager.play...")
			if line.find("if AudioManager") >= 0:
				found_guarded = true
			# Check if previous line is an if AudioManager block
			elif i > 0 and lines[i - 1].strip_edges().begins_with("if AudioManager"):
				found_guarded = true
			else:
				found_unguarded = true
	assert_false(found_unguarded, "All AudioManager SFX calls in %s should be guarded with if AudioManager:" % file_label)
	assert_true(found_guarded, "Should find at least one guarded AudioManager call in %s" % file_label)


# =====================================================================
# 1. AudioManager SFX_IDS completeness
# =====================================================================

func test_sfx_ids_includes_player_hurt():
	assert_true(AudioManager.SFX_IDS.has("player_hurt"),
		"SFX_IDS should contain player_hurt")


func test_sfx_ids_includes_player_levelup():
	assert_true(AudioManager.SFX_IDS.has("player_levelup"),
		"SFX_IDS should contain player_levelup")


func test_sfx_ids_includes_player_death():
	assert_true(AudioManager.SFX_IDS.has("player_death"),
		"SFX_IDS should contain player_death")


func test_sfx_ids_includes_player_dash():
	assert_true(AudioManager.SFX_IDS.has("player_dash"),
		"SFX_IDS should contain player_dash")


func test_sfx_ids_includes_player_skill():
	assert_true(AudioManager.SFX_IDS.has("player_skill"),
		"SFX_IDS should contain player_skill")


func test_sfx_ids_includes_enemy_death():
	assert_true(AudioManager.SFX_IDS.has("enemy_death"),
		"SFX_IDS should contain enemy_death")


func test_sfx_ids_includes_enemy_hurt():
	assert_true(AudioManager.SFX_IDS.has("enemy_hurt"),
		"SFX_IDS should contain enemy_hurt")


func test_sfx_ids_includes_elite_death():
	assert_true(AudioManager.SFX_IDS.has("elite_death"),
		"SFX_IDS should contain elite_death")


func test_sfx_ids_includes_boss_roar():
	assert_true(AudioManager.SFX_IDS.has("boss_roar"),
		"SFX_IDS should contain boss_roar")


func test_sfx_ids_includes_xp_pickup():
	assert_true(AudioManager.SFX_IDS.has("xp_pickup"),
		"SFX_IDS should contain xp_pickup")


func test_sfx_ids_includes_gold_drop():
	assert_true(AudioManager.SFX_IDS.has("gold_drop"),
		"SFX_IDS should contain gold_drop")


func test_sfx_ids_includes_chest_open():
	assert_true(AudioManager.SFX_IDS.has("chest_open"),
		"SFX_IDS should contain chest_open")


func test_sfx_ids_includes_item_pickup():
	assert_true(AudioManager.SFX_IDS.has("item_pickup"),
		"SFX_IDS should contain item_pickup")


func test_sfx_ids_includes_wave_start():
	assert_true(AudioManager.SFX_IDS.has("wave_start"),
		"SFX_IDS should contain wave_start")


func test_sfx_ids_includes_wave_clear():
	assert_true(AudioManager.SFX_IDS.has("wave_clear"),
		"SFX_IDS should contain wave_clear")


# =====================================================================
# 2. SFX_IDS count -- ensure no accidental removals
# =====================================================================

func test_sfx_ids_minimum_count():
	# v1.2.0 Phase B defines at least 34 SFX entries
	assert_true(AudioManager.SFX_IDS.size() >= 34,
		"SFX_IDS should have at least 34 entries, got %d" % AudioManager.SFX_IDS.size())


# =====================================================================
# 3. SFX_IDS values are well-formed strings
# =====================================================================

func test_sfx_ids_values_are_strings():
	for key in AudioManager.SFX_IDS:
		var val: Variant = AudioManager.SFX_IDS[key]
		assert_true(val is String,
			"SFX_IDS value for key '%s' should be String" % key)


func test_sfx_ids_values_prefixed():
	for key in AudioManager.SFX_IDS:
		var val: String = AudioManager.SFX_IDS[key]
		assert_true(val.begins_with("sfx_"),
			"SFX_IDS value '%s' for key '%s' should start with 'sfx_'" % [val, key])


# =====================================================================
# 4. AudioManager has no cross-references to other autoloads
# =====================================================================

func test_audio_manager_no_game_manager_reference():
	var src: String = _load_source(AUDIO_MANAGER_PATH)
	assert_false(src.find("GameManager") >= 0,
		"audio_manager.gd should not reference GameManager autoload")


func test_audio_manager_no_synergy_manager_reference():
	var src: String = _load_source(AUDIO_MANAGER_PATH)
	assert_false(src.find("SynergyManager") >= 0,
		"audio_manager.gd should not reference SynergyManager autoload")


func test_audio_manager_no_save_manager_reference():
	var src: String = _load_source(AUDIO_MANAGER_PATH)
	assert_false(src.find("SaveManager") >= 0,
		"audio_manager.gd should not reference SaveManager autoload")


func test_audio_manager_no_upgrade_pool_reference():
	var src: String = _load_source(AUDIO_MANAGER_PATH)
	assert_false(src.find("UpgradePool") >= 0,
		"audio_manager.gd should not reference UpgradePool autoload")


# =====================================================================
# 5. Player script SFX integration
# =====================================================================

func test_player_has_audio_manager_reference():
	var src: String = _load_source(PLAYER_PATH)
	assert_true(src.find("AudioManager") >= 0,
		"player.gd should reference AudioManager")


func test_player_sfx_calls_use_guard():
	_assert_all_sfx_guarded(PLAYER_PATH, "player.gd")


func test_player_has_player_hurt_sfx():
	var src: String = _load_source(PLAYER_PATH)
	assert_true(src.find('play_sfx_by_id("player_hurt")') >= 0,
		"player.gd should call play_sfx_by_id with player_hurt")


func test_player_has_player_dash_sfx():
	var src: String = _load_source(PLAYER_PATH)
	assert_true(src.find('play_sfx_by_id("player_dash")') >= 0,
		"player.gd should call play_sfx_by_id with player_dash")


# =====================================================================
# 6. Enemy script SFX integration
# =====================================================================

func test_enemy_has_audio_manager_reference():
	var src: String = _load_source(ENEMY_PATH)
	assert_true(src.find("AudioManager") >= 0,
		"enemy.gd should reference AudioManager")


func test_enemy_sfx_calls_use_guard():
	_assert_all_sfx_guarded(ENEMY_PATH, "enemy.gd")


func test_enemy_has_enemy_death_sfx():
	var src: String = _load_source(ENEMY_PATH)
	assert_true(src.find('play_sfx_by_id("enemy_death")') >= 0,
		"enemy.gd should call play_sfx_by_id with enemy_death")


func test_enemy_death_effects_has_audio_manager_reference():
	var path: String = "res://scripts/enemies/enemy_death_effects.gd"
	var src: String = _load_source(path)
	assert_true(src.find("AudioManager") >= 0, "enemy_death_effects.gd should reference AudioManager")


func test_enemy_death_effects_has_elite_death_sfx():
	var path: String = "res://scripts/enemies/enemy_death_effects.gd"
	var src: String = _load_source(path)
	assert_true(src.find('play_sfx_by_id("elite_death")') >= 0,
		"enemy_death_effects.gd should call play_sfx_by_id with elite_death")


func test_enemy_death_effects_has_boss_roar_sfx():
	var path: String = "res://scripts/enemies/enemy_death_effects.gd"
	var src: String = _load_source(path)
	assert_true(src.find('play_sfx_by_id("boss_roar")') >= 0,
		"enemy_death_effects.gd should call play_sfx_by_id with boss_roar")


func test_enemy_death_effects_sfx_calls_use_guard():
	_assert_all_sfx_guarded("res://scripts/enemies/enemy_death_effects.gd", "enemy_death_effects.gd")


func test_enemy_loot_has_audio_manager_reference():
	var path: String = "res://scripts/enemies/enemy_loot.gd"
	var src: String = _load_source(path)
	assert_true(src.find("AudioManager") >= 0, "enemy_loot.gd should reference AudioManager")


func test_enemy_loot_has_gold_drop_sfx():
	var path: String = "res://scripts/enemies/enemy_loot.gd"
	var src: String = _load_source(path)
	assert_true(src.find('play_sfx_by_id("gold_drop")') >= 0,
		"enemy_loot.gd should call play_sfx_by_id with gold_drop")


func test_enemy_loot_has_chest_open_sfx():
	var path: String = "res://scripts/enemies/enemy_loot.gd"
	var src: String = _load_source(path)
	assert_true(src.find('play_sfx_by_id("chest_open")') >= 0,
		"enemy_loot.gd should call play_sfx_by_id with chest_open")


func test_enemy_loot_sfx_calls_use_guard():
	_assert_all_sfx_guarded("res://scripts/enemies/enemy_loot.gd", "enemy_loot.gd")


# =====================================================================
# 7. XP Gem SFX integration
# =====================================================================

func test_xp_gem_has_audio_manager_reference():
	var src: String = _load_source(XP_GEM_PATH)
	assert_true(src.find("AudioManager") >= 0,
		"xp_gem.gd should reference AudioManager")


func test_xp_gem_sfx_calls_use_guard():
	_assert_all_sfx_guarded(XP_GEM_PATH, "xp_gem.gd")


func test_xp_gem_has_xp_pickup_sfx():
	var src: String = _load_source(XP_GEM_PATH)
	assert_true(src.find('play_sfx_by_id("xp_pickup")') >= 0,
		"xp_gem.gd should call play_sfx_by_id with xp_pickup")


# =====================================================================
# 8. HUD SFX integration (player_levelup)
# =====================================================================

func test_hud_has_audio_manager_reference():
	var src: String = _load_source(HUD_PATH)
	assert_true(src.find("AudioManager") >= 0,
		"hud.gd should reference AudioManager for player_levelup SFX")


func test_hud_sfx_calls_use_guard():
	_assert_all_sfx_guarded(HUD_PATH, "hud.gd")


func test_hud_has_player_levelup_sfx():
	var src: String = _load_source(HUD_PATH)
	assert_true(src.find('play_sfx_by_id("player_levelup")') >= 0,
		"hud.gd should call play_sfx_by_id with player_levelup")


# =====================================================================
# 9. Projectile SFX integration (weapon_hit)
# =====================================================================

func test_projectile_has_audio_manager_reference():
	var src: String = _load_source(PROJECTILE_PATH)
	assert_true(src.find("AudioManager") >= 0, "projectile.gd should reference AudioManager")


func test_projectile_sfx_calls_use_guard():
	_assert_all_sfx_guarded(PROJECTILE_PATH, "projectile.gd")


# =====================================================================
# 10. weapon_controller SFX integration status
# =====================================================================

func test_weapon_controller_has_necromancer_kill_scaling():
	var path: String = "res://scripts/weapon_controller.gd"
	var src: String = _load_source(path)
	assert_true(src.find("necromancer_kill_scaling") >= 0,
		"weapon_controller.gd should reference necromancer_kill_scaling passive")


# =====================================================================
# 11. Arena SFX integration status
# =====================================================================

func test_arena_has_audio_manager_reference():
	var path: String = "res://scripts/arena.gd"
	var src: String = _load_source(path)
	assert_true(src.find("AudioManager") >= 0, "arena.gd should reference AudioManager")


func test_arena_has_wave_start_sfx():
	var path: String = "res://scripts/arena.gd"
	var src: String = _load_source(path)
	assert_true(src.find('play_sfx_by_id("wave_start")') >= 0,
		"arena.gd should call play_sfx_by_id with wave_start")


func test_arena_has_wave_clear_sfx():
	var path: String = "res://scripts/arena.gd"
	var src: String = _load_source(path)
	assert_true(src.find('play_sfx_by_id("wave_clear")') >= 0,
		"arena.gd should call play_sfx_by_id with wave_clear")


func test_arena_sfx_calls_use_guard():
	_assert_all_sfx_guarded("res://scripts/arena.gd", "arena.gd")


# =====================================================================
# 12. SkillEffects SFX integration status
# =====================================================================

func test_skill_effects_has_audio_manager_reference():
	var path: String = "res://scripts/skill_effects.gd"
	var src: String = _load_source(path)
	assert_true(src.find("AudioManager") >= 0, "skill_effects.gd should reference AudioManager")


func test_skill_effects_has_player_skill_sfx():
	var path: String = "res://scripts/skill_effects.gd"
	var src: String = _load_source(path)
	assert_true(src.find('play_sfx_by_id("player_skill")') >= 0,
		"skill_effects.gd should call play_sfx_by_id with player_skill")


func test_skill_effects_sfx_calls_use_guard():
	_assert_all_sfx_guarded("res://scripts/skill_effects.gd", "skill_effects.gd")


# =====================================================================
# 13. Enemy Bullet SFX integration
# =====================================================================

func test_sfx_ids_includes_enemy_bullet_hit():
	assert_true(AudioManager.SFX_IDS.has("enemy_bullet_hit"),
		"SFX_IDS should contain enemy_bullet_hit")


func test_enemy_bullet_has_audio_manager_reference():
	var path: String = "res://scripts/enemy_bullet.gd"
	var src: String = _load_source(path)
	assert_true(src.find("AudioManager") >= 0, "enemy_bullet.gd should reference AudioManager")


func test_enemy_bullet_has_bullet_hit_sfx():
	var path: String = "res://scripts/enemy_bullet.gd"
	var src: String = _load_source(path)
	assert_true(src.find('play_sfx_by_id("enemy_bullet_hit")') >= 0,
		"enemy_bullet.gd should call play_sfx_by_id with enemy_bullet_hit")


func test_enemy_bullet_sfx_calls_use_guard():
	_assert_all_sfx_guarded("res://scripts/enemy_bullet.gd", "enemy_bullet.gd")


# =====================================================================
# 14. HUD upgrade_done SFX integration
# =====================================================================

func test_sfx_ids_includes_upgrade_done():
	assert_true(AudioManager.SFX_IDS.has("upgrade_done"),
		"SFX_IDS should contain upgrade_done")


func test_hud_has_upgrade_done_sfx():
	var src: String = _load_source(HUD_PATH)
	assert_true(src.find('play_sfx_by_id("upgrade_done")') >= 0,
		"hud.gd should call play_sfx_by_id with upgrade_done")
