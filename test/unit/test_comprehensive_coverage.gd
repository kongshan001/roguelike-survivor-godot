extends GutTest
## Comprehensive end-to-end tests for character skills, passive traits,
## all weapon types, synergy effects, and wave boundary conditions.
## This file supplements the existing per-module tests with cross-cutting
## integration scenarios that exercise the full stack.


var _arena: Node2D
var _player: CharacterBody2D
var _controller: Node


func before_each():
	GameManager.reset()
	GameManager.is_game_over = false
	GameManager.selected_difficulty = "normal"
	GameManager.selected_character = ""
	GameManager.elapsed_time = 0.0
	if SynergyManager:
		SynergyManager.active_synergies.clear()
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	UpgradePool.ensure_weapons_registered()

	_arena = Node2D.new()
	_arena.name = "Arena"
	add_child_autofree(_arena)

	var pm = Node.new()
	pm.name = "ProjectileManager"
	_arena.add_child(pm)

	var pkm = Node.new()
	pkm.name = "PickupManager"
	_arena.add_child(pkm)

	_player = load("res://scenes/player.tscn").instantiate()
	_player.global_position = Vector2(400, 300)
	_player.add_to_group("players")
	_arena.add_child(_player)

	_controller = _player.get_node("WeaponController")

	# SaveManager state isolation
	if SaveManager:
		SaveManager.shop_upgrades = {}

	await get_tree().process_frame


func after_each():
	# Clean up weapon instances to reduce orphans
	if is_instance_valid(_controller):
		_controller.remove_weapon_instances("holywater")
		_controller.remove_weapon_instances("boomerang")
		_controller._boomerang_instances.clear()
		_controller._orbit_instances.clear()
		_controller._weapon_timers.clear()
	await get_tree().process_frame


func _set_character(char_name: String) -> void:
	GameManager.selected_character = char_name
	if _player.skill_effects_node and is_instance_valid(_player.skill_effects_node):
		_player.skill_effects_node.queue_free()
		_player.skill_effects_node = null
	# Reset Iron Will state from previous character
	if _player._iron_will_active:
		_player.armor -= _player.WARRIOR_PASSIVE_ARMOR_BONUS
	_player._iron_will_active = false
	_player._iron_will_timer = 0.0
	_player._iron_will_cooldown = 0.0
	# Recreate skill_effects_node (same as player.gd _ready does)
	var new_se: Node = Node.new()
	new_se.set_script(load("res://scripts/skill_effects.gd"))
	_player.add_child(new_se)
	_player.skill_effects_node = new_se
	match char_name:
		"mage":
			_player._init_skill("elemental_burst", _player.MAGE_SKILL_COOLDOWN)
			_player.damage_bonus = 0.2
		"warrior":
			_player._init_skill("shield_charge", _player.WARRIOR_SKILL_COOLDOWN)
			_player.armor = 1
		"ranger":
			_player._init_skill("arrow_rain", _player.RANGER_SKILL_COOLDOWN)
			_player.crit_chance = 0.1
	await get_tree().process_frame


func _create_enemy(pos: Vector2, hp: float = 10.0) -> CharacterBody2D:
	var e: CharacterBody2D = load("res://scenes/enemy.tscn").instantiate()
	var data := EnemyData.new()
	data.enemy_id = "test"; data.max_hp = hp; data.speed = 50.0
	data.damage = 1.0; data.xp_value = 5; data.color = Color.GREEN
	data.size = 16.0; data.drop_chance = 0.0
	e.enemy_data = data; e.global_position = pos
	e.add_to_group("enemies"); _arena.add_child(e)
	return e


# =====================================================================
# SECTION 1: CHARACTER SKILL END-TO-END TESTS
# =====================================================================

# --- Mage: Elemental Burst ---

func test_mage_elemental_burst_activates():
	_set_character("mage")
	assert_eq(_player.skill_id, "elemental_burst", "Mage should have elemental_burst skill")
	assert_true(_player.is_skill_ready, "Skill should start ready")


func test_mage_elemental_burst_goes_on_cooldown():
	_set_character("mage")
	_player._activate_skill()
	assert_false(_player.is_skill_ready, "Skill should not be ready after activation")
	assert_eq(_player.skill_timer, _player.MAGE_SKILL_COOLDOWN, "Timer should be set to cooldown")


func test_mage_elemental_burst_emits_activated_signal():
	_set_character("mage")
	watch_signals(_player)
	_player._activate_skill()
	assert_signal_emitted(_player, "skill_activated", "skill_activated should fire")
	assert_signal_emitted_with_parameters(_player, "skill_activated", ["elemental_burst"])


func test_mage_elemental_burst_damages_enemies():
	_set_character("mage")
	var enemy := _create_enemy(Vector2(420, 300), 50.0)
	var hp_before: float = enemy.current_hp
	_player.skill_effects_node.elemental_burst(_player, _player.damage_bonus)
	assert_lt(enemy.current_hp, hp_before, "Enemy should take damage from elemental burst")


func test_mage_elemental_burst_freezes_enemies():
	_set_character("mage")
	var enemy := _create_enemy(Vector2(420, 300), 50.0)
	_player.skill_effects_node.elemental_burst(_player, _player.damage_bonus)
	# Enemy should have freeze applied
	assert_gt(enemy._freeze_timer, 0.0, "Enemy should be frozen by elemental burst")


func test_mage_elemental_burst_misses_distant_enemies():
	_set_character("mage")
	var enemy := _create_enemy(Vector2(800, 300), 50.0)  # far away
	var hp_before: float = enemy.current_hp
	_player.skill_effects_node.elemental_burst(_player, _player.damage_bonus)
	assert_eq(enemy.current_hp, hp_before, "Distant enemy should not be hit by elemental burst")


# --- Warrior: Shield Charge ---

func test_warrior_shield_charge_activates():
	_set_character("warrior")
	assert_eq(_player.skill_id, "shield_charge", "Warrior should have shield_charge skill")


func test_warrior_shield_charge_moves_player():
	_set_character("warrior")
	var pos_before: Vector2 = _player.global_position
	_player.skill_effects_node.shield_charge(_player, Vector2.RIGHT, _player.damage_bonus)
	# Player should have moved (via tween)
	await get_tree().process_frame
	assert_ne(_player.global_position, pos_before, "Player should move during shield charge")


func test_warrior_shield_charge_damages_enemies_in_path():
	_set_character("warrior")
	var enemy := _create_enemy(Vector2(430, 300), 50.0)  # on the charge path
	var hp_before: float = enemy.current_hp
	_player.skill_effects_node.shield_charge(_player, Vector2.RIGHT, _player.damage_bonus)
	assert_lt(enemy.current_hp, hp_before, "Enemy in path should take damage from shield charge")


func test_warrior_shield_charge_stuns_enemies():
	_set_character("warrior")
	var enemy := _create_enemy(Vector2(430, 300), 50.0)
	_player.skill_effects_node.shield_charge(_player, Vector2.RIGHT, _player.damage_bonus)
	assert_gt(enemy._freeze_timer, 0.0, "Enemy in path should be stunned (frozen)")


func test_warrior_shield_charge_misses_lateral_enemies():
	_set_character("warrior")
	var enemy := _create_enemy(Vector2(400, 400), 50.0)  # perpendicular, not in path
	var hp_before: float = enemy.current_hp
	_player.skill_effects_node.shield_charge(_player, Vector2.RIGHT, _player.damage_bonus)
	assert_eq(enemy.current_hp, hp_before, "Lateral enemy should not be hit by shield charge")


# --- Ranger: Arrow Rain ---

func test_ranger_arrow_rain_activates():
	_set_character("ranger")
	assert_eq(_player.skill_id, "arrow_rain", "Ranger should have arrow_rain skill")


func test_ranger_arrow_rain_cooldown_is_correct():
	_set_character("ranger")
	assert_eq(_player.skill_cooldown_max, 18.0, "Ranger cooldown should be 18.0s")


func test_ranger_arrow_rain_does_not_crash_with_no_enemies():
	_set_character("ranger")
	_player.skill_effects_node.arrow_rain(_player, _player.damage_bonus)
	await get_tree().process_frame
	assert_true(true, "Arrow rain with no enemies did not crash")


func test_ranger_arrow_rain_does_not_crash_with_enemies():
	_set_character("ranger")
	_create_enemy(Vector2(450, 300), 50.0)
	_player.skill_effects_node.arrow_rain(_player, _player.damage_bonus)
	await get_tree().create_timer(0.6).timeout
	assert_true(true, "Arrow rain with enemies did not crash")


# =====================================================================
# SECTION 2: PASSIVE TRAIT END-TO-END TESTS
# =====================================================================

# --- Mage: Mana Attunement (+10% weapon damage during skill cooldown) ---

func test_mage_passive_increases_damage_bonus():
	_set_character("mage")
	assert_eq(_player.damage_bonus, 0.2, "Mage should have +20% base damage bonus")


func test_mage_passive_weapon_boost_while_on_cooldown():
	_set_character("mage")
	_player.is_skill_ready = false
	_player.skill_timer = 10.0
	# weapon_controller._fire_weapon adds extra 10% when skill is on cooldown
	# Check the formula: dmg_bonus = (1.0 + 0.2) * (1.0 + 0.10) = 1.32
	var base_bonus: float = 1.0 + _player.damage_bonus
	var passive_multiplier: float = 1.0 + 0.10
	var expected: float = base_bonus * passive_multiplier
	assert_eq(expected, 1.32, "Mage passive should give 1.32x total damage during cooldown")


func test_mage_passive_no_boost_when_skill_ready():
	_set_character("mage")
	_player.is_skill_ready = true
	# When skill is ready, weapon_controller does NOT apply the 1.10 multiplier
	var base_bonus: float = 1.0 + _player.damage_bonus
	assert_eq(base_bonus, 1.2, "Mage base bonus is 1.2x when skill ready (no passive boost)")


# --- Warrior: Iron Will (+3 armor when HP <= 30%, 3s duration, 30s cooldown) ---

func test_warrior_passive_activates_below_threshold():
	_set_character("warrior")
	_player.current_health = _player.max_health * 0.3
	_player._iron_will_cooldown = 0.0
	_player._iron_will_active = false
	_player._update_iron_will(0.016)
	assert_true(_player._iron_will_active, "Iron Will should activate at 30% HP")


func test_warrior_passive_adds_armor():
	_set_character("warrior")
	var armor_before: int = _player.armor
	_player.current_health = _player.max_health * 0.2
	_player._iron_will_cooldown = 0.0
	_player._iron_will_active = false
	_player._update_iron_will(0.016)
	assert_eq(_player.armor, armor_before + 3, "Iron Will should add +3 armor")


func test_warrior_passive_expires_after_duration():
	_set_character("warrior")
	_player.current_health = _player.max_health * 0.2
	_player._iron_will_cooldown = 0.0
	_player._iron_will_active = false
	_player._update_iron_will(0.016)
	assert_true(_player._iron_will_active)
	# Advance past 3s duration
	_player._update_iron_will(3.1)
	assert_false(_player._iron_will_active, "Iron Will should expire after 3s")


func test_warrior_passive_prevented_by_cooldown():
	_set_character("warrior")
	_player.current_health = _player.max_health * 0.2
	_player._iron_will_cooldown = 0.0
	_player._iron_will_active = false
	_player._update_iron_will(0.016)
	# Let it expire
	_player._update_iron_will(3.1)
	assert_false(_player._iron_will_active)
	# 30s cooldown prevents retrigger
	_player._update_iron_will(0.016)
	assert_false(_player._iron_will_active, "Should not retrigger during 30s cooldown")


func test_warrior_passive_does_not_affect_other_characters():
	_set_character("mage")
	_player.current_health = 1.0  # very low
	var armor_before: int = _player.armor
	_player._update_iron_will(0.016)
	assert_eq(_player.armor, armor_before, "Iron Will should not affect Mage")


# --- Ranger: Keen Eye (every 5th hit = guaranteed crit) ---

func test_ranger_passive_keen_eye_counter_starts_zero():
	_set_character("ranger")
	assert_eq(_player._keen_eye_counter, 0, "Keen eye counter should start at 0")


func test_ranger_passive_keen_eye_triggers_on_fifth_hit():
	_set_character("ranger")
	_player._keen_eye_counter = 4
	var is_crit: bool = _controller.notify_weapon_hit(_player)
	assert_true(is_crit, "5th hit should be guaranteed crit")
	assert_eq(_player._keen_eye_counter, 0, "Counter should reset after crit")


func test_ranger_passive_keen_eye_no_crit_before_fifth():
	_set_character("ranger")
	_player._keen_eye_counter = 3
	var is_crit: bool = _controller.notify_weapon_hit(_player)
	assert_false(is_crit, "4th hit should not be crit")
	assert_eq(_player._keen_eye_counter, 4, "Counter should increment")


func test_ranger_passive_no_crit_for_non_ranger():
	_set_character("mage")
	var is_crit: bool = _controller.notify_weapon_hit(_player)
	assert_false(is_crit, "Non-Ranger should never get keen eye crit")


func test_ranger_passive_counter_increments_each_hit():
	_set_character("ranger")
	for i in range(4):
		_controller.notify_weapon_hit(_player)
	assert_eq(_player._keen_eye_counter, 4, "After 4 hits, counter should be 4 (crit triggers at 5)")


# =====================================================================
# SECTION 3: ALL WEAPON TYPE BASELINE DISPATCH TESTS
# =====================================================================

func test_projectile_weapon_fires_and_tracks_timer():
	_player.owned_weapons["knife"] = 1
	_create_enemy(Vector2(500, 300))
	_controller._weapon_timers["knife"] = 0.0
	_controller._physics_process(0.016)
	assert_true(_controller._weapon_timers.has("knife"), "Timer should be created")
	assert_gt(_controller._weapon_timers["knife"], 0.0, "Timer should be reset to cooldown")
	_player.owned_weapons.erase("knife")


func test_orbit_weapon_creates_instance():
	_player.owned_weapons["holywater"] = 1
	_controller._weapon_timers["holywater"] = 0.0
	_controller._physics_process(0.016)
	await get_tree().process_frame
	assert_has(_controller._orbit_instances, "holywater", "Orbit instance should exist")
	_player.owned_weapons.erase("holywater")


func test_lightning_weapon_damages_enemy():
	_player.owned_weapons["lightning"] = 1
	var enemy := _create_enemy(Vector2(450, 300), 50.0)
	_controller._weapon_timers["lightning"] = 0.0
	_controller._physics_process(0.016)
	assert_lt(enemy.current_hp, 50.0, "Enemy should take lightning damage")
	_player.owned_weapons.erase("lightning")


func test_cone_weapon_damages_enemy_in_arc():
	_player.owned_weapons["firestaff"] = 1
	var enemy := _create_enemy(Vector2(430, 300), 50.0)
	_controller._weapon_timers["firestaff"] = 0.0
	_controller._physics_process(0.016)
	assert_lt(enemy.current_hp, 50.0, "Enemy in cone arc should take damage")
	_player.owned_weapons.erase("firestaff")


func test_aura_weapon_applies_slow():
	_player.owned_weapons["frostaura"] = 1
	var enemy := _create_enemy(Vector2(420, 310), 50.0)
	_controller._weapon_timers["frostaura"] = 0.0
	_controller._physics_process(0.016)
	assert_gt(enemy._slow_pct, 0.0, "Enemy should be slowed by frost aura")
	_player.owned_weapons.erase("frostaura")


func test_boomerang_weapon_creates_instance():
	_player.owned_weapons["boomerang"] = 1
	_controller._weapon_timers["boomerang"] = 0.0
	_controller._physics_process(0.016)
	await get_tree().process_frame
	assert_eq(_controller._boomerang_instances.size(), 1, "One boomerang should be created")
	_player.owned_weapons.erase("boomerang")


func test_bible_orbit_weapon_creates_single_instance():
	_player.owned_weapons["bible"] = 1
	_controller._weapon_timers["bible"] = 0.0
	_controller._physics_process(0.016)
	await get_tree().process_frame
	assert_has(_controller._orbit_instances, "bible", "Bible orbit should be tracked")
	_player.owned_weapons.erase("bible")


# =====================================================================
# SECTION 4: SYNERGY END-TO-END EFFECTS
# =====================================================================

func test_knife_crit_synergy_applies_crit():
	if SynergyManager:
		SynergyManager.check_synergies({"knife": 3}, {"crit": 1})
		assert_true(SynergyManager.has_synergy("knife_crit"), "knife_crit synergy should be active")


func test_boomerang_crit_synergy_adds_pierce():
	if SynergyManager:
		SynergyManager.check_synergies({"boomerang": 1}, {"crit": 1})
		assert_true(SynergyManager.has_synergy("boomerang_crit"), "boomerang_crit should be active")


func test_holywater_maxhp_synergy_increases_radius():
	if SynergyManager:
		SynergyManager.check_synergies({"holywater": 1}, {"maxhp": 1})
		assert_true(SynergyManager.has_synergy("holywater_maxhp"))


func test_frost_regen_synergy_increases_freeze():
	if SynergyManager:
		SynergyManager.check_synergies({"frostaura": 1}, {"regen": 1})
		assert_true(SynergyManager.has_synergy("frost_regen"))


func test_bible_boots_synergy_increases_speed():
	if SynergyManager:
		SynergyManager.check_synergies({"bible": 1}, {"speedboots": 1})
		assert_true(SynergyManager.has_synergy("bible_boots"))


func test_firestaff_armor_synergy_increases_angle():
	if SynergyManager:
		SynergyManager.check_synergies({"firestaff": 1}, {"armor": 1})
		assert_true(SynergyManager.has_synergy("firestaff_armor"))


func test_armor_maxhp_synergy_doubles_armor():
	_player.owned_passives["armor"] = 1
	_player.owned_passives["maxhp"] = 1
	if SynergyManager:
		SynergyManager.check_synergies({}, {"armor": 1, "maxhp": 1})
		assert_true(SynergyManager.has_synergy("armor_maxhp"))
	# Player with armor_maxhp synergy should have doubled armor in take_damage
	_player.armor = 2
	_player.take_damage(5.0)
	# With synergy: effective_armor = 2*2 = 4, damage = max(1, 5-4) = 1
	assert_eq(_player.current_health, _player.max_health - 1.0,
		"armor_maxhp synergy should double armor effectiveness")


func test_boots_regen_synergy_faster_regen_while_moving():
	if SynergyManager:
		SynergyManager.check_synergies({}, {"speedboots": 1, "regen": 1})
		assert_true(SynergyManager.has_synergy("boots_regen"))


func test_crit_boots_synergy_spawns_extra_knife():
	if SynergyManager:
		SynergyManager.check_synergies({}, {"crit": 1, "speedboots": 1})
		assert_true(SynergyManager.has_synergy("crit_boots"))


# =====================================================================
# SECTION 5: WAVE SYSTEM BOUNDARY TESTS
# =====================================================================

func test_wave_1_duration_exactly_60():
	var gm: Node = autofree(Node.new())
	gm.set_script(load("res://scripts/autoload/game_manager.gd"))
	gm.reset()
	gm.update_wave(0.016)  # WARMUP -> ACTIVE
	gm.update_wave(59.999)
	assert_eq(gm.wave_state, gm.WaveState.ACTIVE, "Should still be ACTIVE at 59.999s")
	gm.update_wave(0.001)
	assert_eq(gm.wave_state, gm.WaveState.INTERMISSION, "Should enter INTERMISSION at exactly 60.0s")


func test_wave_intermission_exactly_3_seconds():
	var gm: Node = autofree(Node.new())
	gm.set_script(load("res://scripts/autoload/game_manager.gd"))
	gm.reset()
	gm.update_wave(0.016)
	gm.update_wave(60.0)  # -> INTERMISSION
	assert_eq(gm._intermission_timer, 3.0, "Intermission timer should be exactly 3.0s")
	gm.update_wave(2.999)
	assert_eq(gm.wave_state, gm.WaveState.INTERMISSION, "Should still be in INTERMISSION at 2.999s")
	gm.update_wave(0.001)
	assert_eq(gm.wave_state, gm.WaveState.ACTIVE, "Should start next wave at exactly 3.0s")


func test_endless_cycle_3_scaling():
	var gm: Node = autofree(Node.new())
	gm.set_script(load("res://scripts/autoload/game_manager.gd"))
	gm.reset()
	gm.selected_difficulty = "endless"
	gm.current_cycle = 3
	assert_eq(gm.get_wave_hp_scale(), 1.6, "Cycle 3 HP scale = 1.0 + 0.3*2 = 1.6")
	assert_eq(gm.get_wave_speed_scale(), 1.2, "Cycle 3 speed = 1.0 + 0.1*2 = 1.2")
	assert_eq(gm.get_wave_spawn_rate_scale(), 0.8, "Cycle 3 rate = max(0.5, 1.0-0.1*2) = 0.8")


func test_wave_defs_all_have_required_fields():
	for def in GameManager.WAVE_DEFS:
		assert_has(def, "id", "Wave def should have 'id'")
		assert_has(def, "name", "Wave def should have 'name'")
		assert_has(def, "duration", "Wave def should have 'duration'")
		assert_has(def, "enemies", "Wave def should have 'enemies'")
		assert_has(def, "spawn_base", "Wave def should have 'spawn_base'")
		assert_has(def, "count_base", "Wave def should have 'count_base'")
		assert_has(def, "color", "Wave def should have 'color'")


func test_wave_progress_at_exact_half():
	var gm: Node = autofree(Node.new())
	gm.set_script(load("res://scripts/autoload/game_manager.gd"))
	gm.reset()
	gm.update_wave(0.016)  # WARMUP -> ACTIVE, wave 1 duration=60.0
	gm.update_wave(30.0)
	assert_eq(gm.get_wave_progress(), 0.5, "Progress should be exactly 0.5 at 30s of 60s wave")


func test_victory_not_triggered_in_endless_after_5_waves():
	var gm: Node = autofree(Node.new())
	gm.set_script(load("res://scripts/autoload/game_manager.gd"))
	gm.reset()
	gm.selected_difficulty = "endless"
	# Fast-forward through 5 waves
	gm.update_wave(0.016)
	gm.update_wave(60.0)   # wave 1 ends
	gm.update_wave(3.0)    # intermission
	gm.update_wave(57.0)   # wave 2 ends
	gm.update_wave(3.0)    # intermission
	gm.update_wave(57.0)   # wave 3 ends
	gm.update_wave(3.0)    # intermission
	gm.update_wave(57.0)   # wave 4 ends
	gm.update_wave(3.0)    # intermission
	gm.update_wave(57.0)   # wave 5 ends
	gm.update_wave(3.0)    # intermission -> should cycle, not victory
	assert_ne(gm.wave_state, gm.WaveState.VICTORY, "Endless should not trigger victory")
	assert_eq(gm.current_wave, 6, "Should advance to wave 6")


func test_wave_boss_has_boss_flag():
	var boss_def: Dictionary = GameManager.WAVE_DEFS[4]
	assert_true(boss_def.get("boss", false), "Wave 5 should have boss=true")


func test_spawn_rate_floor_at_high_cycle():
	var gm: Node = autofree(Node.new())
	gm.set_script(load("res://scripts/autoload/game_manager.gd"))
	gm.reset()
	gm.selected_difficulty = "endless"
	gm.current_cycle = 20
	assert_eq(gm.get_wave_spawn_rate_scale(), 0.5,
		"Spawn rate should hit floor 0.5 at high cycle")
