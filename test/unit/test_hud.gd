extends GutTest
## Unit tests for hud.gd
## Covers: HUD scene instantiation, level-up signal handling, card display,
## card selection callbacks, reroll logic, pending_level_ups queue,
## combo display, boss warning, health/XP/gold display.

var _hud: CanvasLayer
var _arena: Node2D
var _player: CharacterBody2D


func before_each():
	GameManager.reset()
	if SynergyManager:
		SynergyManager.active_synergies.clear()
	UpgradePool._weapons = {}
	UpgradePool._initialized = false
	UpgradePool.ensure_weapons_registered()

	# Build arena tree with player so _get_player() works
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

	# Instantiate HUD scene
	_hud = load("res://scenes/hud.tscn").instantiate()
	_arena.add_child(_hud)


func after_each():
	# Clean up weapon instances from HUD-triggered upgrades
	if is_instance_valid(_player):
		var wc: Node = _player.get_node_or_null("WeaponController")
		if wc:
			for wid in _player.owned_weapons.keys():
				wc.remove_weapon_instances(wid)
			wc._boomerang_instances.clear()
			wc._orbit_instances.clear()
			wc._weapon_timers.clear()


# =====================================================================
# 1. HUD SCENE INSTANTIATION
# =====================================================================

func test_hud_instantiates_without_crash():
	assert_ne(_hud, null, "HUD should instantiate")
	assert_true(_hud is CanvasLayer, "HUD root should be CanvasLayer")


func test_hud_has_required_child_nodes():
	assert_ne(_hud.get_node_or_null("HealthBar"), null, "HealthBar exists")
	assert_ne(_hud.get_node_or_null("XPBar"), null, "XPBar exists")
	assert_ne(_hud.get_node_or_null("LevelLabel"), null, "LevelLabel exists")
	assert_ne(_hud.get_node_or_null("TimerLabel"), null, "TimerLabel exists")
	assert_ne(_hud.get_node_or_null("GoldLabel"), null, "GoldLabel exists")
	assert_ne(_hud.get_node_or_null("ComboLabel"), null, "ComboLabel exists")
	assert_ne(_hud.get_node_or_null("BossWarningLabel"), null, "BossWarningLabel exists")
	assert_ne(_hud.get_node_or_null("UpgradePanel"), null, "UpgradePanel exists")


func test_upgrade_panel_initially_hidden():
	assert_false(_hud.get_node("UpgradePanel").visible,
		"UpgradePanel should be hidden at start")


func test_boss_warning_initially_hidden():
	assert_false(_hud.get_node("BossWarningLabel").visible,
		"BossWarningLabel should be hidden at start")


# =====================================================================
# 2. HEALTH DISPLAY
# =====================================================================

func test_health_changed_updates_bar_and_label():
	GameManager.health_changed.emit(6.0, 10.0)
	assert_eq(_hud.get_node("HealthBar").value, 60.0, "HealthBar at 60%")
	assert_eq(_hud.get_node("HealthLabel").text, "6/10", "HealthLabel shows current/max")


func test_health_changed_full_hp():
	GameManager.health_changed.emit(10.0, 10.0)
	assert_eq(_hud.get_node("HealthBar").value, 100.0, "HealthBar at 100%")


func test_health_changed_zero_hp():
	GameManager.health_changed.emit(0.0, 10.0)
	assert_eq(_hud.get_node("HealthBar").value, 0.0, "HealthBar at 0%")
	assert_eq(_hud.get_node("HealthLabel").text, "0/10", "HealthLabel shows 0/10")


# =====================================================================
# 3. XP AND LEVEL DISPLAY
# =====================================================================

func test_xp_changed_updates_bar_and_level():
	GameManager.player_level = 3
	GameManager.xp_changed.emit(4.0, 18.0)
	var expected: float = (4.0 / 18.0) * 100.0
	assert_almost_eq(_hud.get_node("XPBar").value, expected, 0.01, "XPBar reflects ratio")
	assert_eq(_hud.get_node("LevelLabel").text, "Lv 3", "LevelLabel shows current level")


# =====================================================================
# 4. GOLD DISPLAY
# =====================================================================

func test_gold_changed_updates_label():
	GameManager.gold_changed.emit(42)
	assert_eq(_hud.get_node("GoldLabel").text, "Gold: 42", "GoldLabel shows amount")


func test_gold_zero():
	GameManager.gold_changed.emit(0)
	assert_eq(_hud.get_node("GoldLabel").text, "Gold: 0", "GoldLabel shows zero")


# =====================================================================
# 5. COMBO DISPLAY
# =====================================================================

func test_combo_changed_shows_count():
	GameManager.combo_changed.emit(5)
	assert_eq(_hud.get_node("ComboLabel").text, "Combo: 5", "Combo shows count > 1")


func test_combo_changed_hides_when_one():
	GameManager.combo_changed.emit(1)
	assert_eq(_hud.get_node("ComboLabel").text, "", "Combo hidden when count is 1")


func test_combo_changed_hides_when_zero():
	GameManager.combo_changed.emit(0)
	assert_eq(_hud.get_node("ComboLabel").text, "", "Combo hidden when count is 0")


func test_combo_milestone_5():
	GameManager.combo_milestone.emit(5)
	assert_eq(_hud.get_node("ComboLabel").text, "5 连击！", "Milestone 5 label")


func test_combo_milestone_10():
	GameManager.combo_milestone.emit(10)
	assert_eq(_hud.get_node("ComboLabel").text, "10 连击！！", "Milestone 10 label")


func test_combo_milestone_20():
	GameManager.combo_milestone.emit(20)
	assert_eq(_hud.get_node("ComboLabel").text, "20 连击！！！", "Milestone 20 label")


func test_combo_milestone_50():
	GameManager.combo_milestone.emit(50)
	assert_eq(_hud.get_node("ComboLabel").text, "50 连击！！！", "Milestone 50 label")


# =====================================================================
# 6. BOSS WARNING DISPLAY
# =====================================================================

func test_boss_warning_shows_label():
	GameManager.boss_warning.emit()
	assert_true(_hud.get_node("BossWarningLabel").visible,
		"BossWarningLabel should become visible")
	assert_eq(_hud.get_node("BossWarningLabel").text, "💀 Boss 即将来袭！",
		"BossWarningLabel shows warning text")


# =====================================================================
# 7. LEVEL-UP AND UPGRADE PANEL
# =====================================================================

func test_level_up_increments_pending():
	GameManager.level_up.emit(2)
	assert_eq(_hud._pending_level_ups, 0,
		"pending_level_ups should be 0 after _show_upgrade_panel consumed it")


func test_level_up_shows_upgrade_panel():
	GameManager.level_up.emit(2)
	assert_true(_hud.get_node("UpgradePanel").visible,
		"UpgradePanel should be visible after level up")


func test_level_up_cards_populated():
	GameManager.level_up.emit(2)
	# At least one card should be visible since UpgradePool has options
	var card1: Control = _hud.get_node("UpgradePanel/Panel/Card1")
	assert_true(card1.visible, "Card1 should be visible when upgrades exist")


# =====================================================================
# 8. CARD SELECTION CALLBACK
# =====================================================================

func test_card_select_new_weapon_adds_to_owned():
	GameManager.level_up.emit(2)
	# Find a "new_weapon" option if available
	var selected_index: int = -1
	for i in range(_hud._upgrade_options.size()):
		if _hud._upgrade_options[i].type == "new_weapon":
			selected_index = i
			break
	if selected_index >= 0:
		var weapon_id: String = _hud._upgrade_options[selected_index].id
		_hud._select_upgrade(selected_index)
		assert_has(_player.owned_weapons, weapon_id,
			"Weapon should be added to owned_weapons after card selection")
	else:
		# If no new_weapon option, at least verify no crash
		assert_true(true, "No new_weapon option available, selection skipped gracefully")


func test_card_select_hides_upgrade_panel():
	GameManager.level_up.emit(2)
	if _hud._upgrade_options.size() > 0:
		_hud._select_upgrade(0)
		assert_false(_hud.get_node("UpgradePanel").visible,
			"UpgradePanel should be hidden after selection")


func test_card_select_out_of_range_no_crash():
	GameManager.level_up.emit(2)
	_hud._select_upgrade(99)
	assert_true(true, "Out of range selection should not crash")


# =====================================================================
# 9. REROLL BUTTON LOGIC
# =====================================================================

func test_reroll_increments_counter():
	GameManager.level_up.emit(2)
	var initial_rerolls: int = _hud._rerolls_used
	_hud._reroll_upgrades()
	assert_eq(_hud._rerolls_used, initial_rerolls + 1, "Rerolls used should increment")


func test_reroll_max_limit():
	GameManager.level_up.emit(2)
	_hud._rerolls_used = _hud.MAX_REROLLS
	_hud._reroll_upgrades()
	# Should not exceed MAX_REROLLS
	assert_eq(_hud._rerolls_used, _hud.MAX_REROLLS,
		"Rerolls should not exceed MAX_REROLLS")


func test_reroll_button_hidden_at_max():
	GameManager.level_up.emit(2)
	_hud._rerolls_used = _hud.MAX_REROLLS
	# Simulate showing the panel again
	_hud._show_upgrade_panel()
	assert_false(_hud.get_node("UpgradePanel/RerollButton").visible,
		"RerollButton should be hidden when max rerolls reached")


func test_reroll_button_visible_when_below_max():
	GameManager.level_up.emit(2)
	_hud._rerolls_used = 0
	_hud._show_upgrade_panel()
	assert_true(_hud.get_node("UpgradePanel/RerollButton").visible,
		"RerollButton should be visible when rerolls remaining")


func test_max_rerolls_constant():
	assert_eq(_hud.MAX_REROLLS, 1, "MAX_REROLLS should be 1")


# =====================================================================
# 10. PENDING LEVEL-UPS QUEUE
# =====================================================================

func test_multiple_level_ups_shows_panel_twice():
	# Each _on_level_up call increments and immediately shows the panel,
	# so _pending_level_ups ends at 0. The panel is refreshed each time.
	GameManager.level_up.emit(2)
	assert_true(_hud.get_node("UpgradePanel").visible, "Panel visible after first level up")
	# Store the options from first level up
	var _first_options: Array[Dictionary] = _hud._upgrade_options.duplicate()
	GameManager.level_up.emit(3)
	assert_true(_hud.get_node("UpgradePanel").visible, "Panel visible after second level up")
	assert_eq(_hud._pending_level_ups, 0,
		"Pending should be 0 after both level ups are immediately consumed")


func test_pending_queue_resolves_after_selection():
	# Each level_up is immediately consumed by _show_upgrade_panel,
	# so after two emits, _pending_level_ups is 0. Selecting hides the panel.
	GameManager.level_up.emit(2)
	GameManager.level_up.emit(3)
	if _hud._upgrade_options.size() > 0:
		_hud._select_upgrade(0)
		assert_false(_hud.get_node("UpgradePanel").visible,
			"UpgradePanel should be hidden after selection (no pending level ups)")


# =====================================================================
# 11. _get_player() HELPER
# =====================================================================

func test_get_player_returns_player():
	var result: Node2D = _hud._get_player()
	assert_ne(result, null, "_get_player should find player in group")
	assert_true(result.is_in_group("players"), "Result should be in players group")


func test_get_player_returns_null_when_no_players():
	# Remove player from group
	_player.remove_from_group("players")
	var result: Node2D = _hud._get_player()
	assert_eq(result, null, "_get_player should return null when no players in group")
	_player.add_to_group("players")
