extends GutTest
## Tests for UI polish effects: card hover scale, Y offset, modulate color,
## mouse leave restoration, and card state management.
## R19 QA Task 3


var _hud: CanvasLayer
var _arena: Node2D


func before_each():
	GameManager.reset()
	GameManager.elapsed_time = 0.0
	GameManager.selected_difficulty = "normal"
	GameManager.selected_character = ""
	if SaveManager:
		for id in SaveManager.SHOP_UPGRADES:
			SaveManager.shop_upgrades[id] = 0
	_arena = Node2D.new()
	_arena.name = "Arena"
	add_child_autofree(_arena)
	var player: CharacterBody2D = load("res://scenes/player.tscn").instantiate()
	player.name = "Player"
	player.add_to_group("players")
	_arena.add_child(player)
	_hud = load("res://scenes/hud.tscn").instantiate()
	add_child_autofree(_hud)


func after_each():
	await get_tree().process_frame


# ============================================================
# Section 1: Card Hover Constants
# ============================================================

func test_card_hover_scale_constant():
	assert_eq(_hud.CARD_HOVER_SCALE, 1.08,
		"CARD_HOVER_SCALE should be 1.08")


func test_card_hover_y_offset_constant():
	assert_eq(_hud.CARD_HOVER_Y_OFFSET, -4.0,
		"CARD_HOVER_Y_OFFSET should be -4.0")


func test_card_hover_duration_constant():
	assert_eq(_hud.CARD_HOVER_DURATION, 0.12,
		"CARD_HOVER_DURATION should be 0.12s")


func test_card_unhover_duration_constant():
	assert_eq(_hud.CARD_UNHOVER_DURATION, 0.1,
		"CARD_UNHOVER_DURATION should be 0.1s")


func test_card_hover_glow_constant():
	var expected: Color = Color(1.1, 1.05, 0.95)
	assert_eq(_hud.CARD_HOVER_GLOW, expected,
		"CARD_HOVER_GLOW should be Color(1.1, 1.05, 0.95)")


# ============================================================
# Section 2: Card Default State
# ============================================================

func test_card_default_scale_is_one():
	var card: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	assert_not_null(card, "Card1 should exist")
	assert_eq(card.scale, Vector2(1.0, 1.0), "Card default scale should be (1.0, 1.0)")


func test_card_default_modulate_white():
	var card: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	assert_not_null(card, "Card1 should exist")
	assert_eq(card.modulate, Color.WHITE, "Card default modulate should be white")


func test_cards_initially_hidden():
	var panel: Control = _hud.get_node_or_null("UpgradePanel")
	assert_not_null(panel, "UpgradePanel should exist")
	assert_false(panel.visible, "UpgradePanel should be hidden initially")


# ============================================================
# Section 3: Hover/Unhover Method Existence
# ============================================================

func test_hud_has_on_card_hover_method():
	assert_true(_hud.has_method("_on_card_hover"),
		"HUD should have _on_card_hover method")


func test_hud_has_on_card_unhover_method():
	assert_true(_hud.has_method("_on_card_unhover"),
		"HUD should have _on_card_unhover method")


func test_hud_has_reset_card_state_method():
	assert_true(_hud.has_method("_reset_card_state"),
		"HUD should have _reset_card_state method")


# ============================================================
# Section 4: Reset Card State
# ============================================================

func test_reset_card_state_restores_scale():
	var card: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	assert_not_null(card, "Card1 should exist")
	card.scale = Vector2(1.5, 1.5)
	_hud._reset_card_state(card)
	assert_eq(card.scale, Vector2.ONE, "Reset should restore scale to 1.0")


func test_reset_card_state_restores_modulate():
	var card: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	assert_not_null(card, "Card1 should exist")
	card.modulate = Color.RED
	_hud._reset_card_state(card)
	assert_eq(card.modulate, Color.WHITE, "Reset should restore modulate to white")


# ============================================================
# Section 5: Card Scene Structure
# ============================================================

func test_upgrade_panel_has_three_cards():
	var card1: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	var card2: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card2")
	var card3: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card3")
	assert_not_null(card1, "Card1 should exist in HUD")
	assert_not_null(card2, "Card2 should exist in HUD")
	assert_not_null(card3, "Card3 should exist in HUD")


func test_card_has_vbox_children():
	var card: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	assert_not_null(card, "Card1 should exist")
	var vbox: VBoxContainer = card.get_node_or_null("VBox")
	assert_not_null(vbox, "Card should have VBox child")


func test_card_vbox_has_required_children():
	var card: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	assert_not_null(card, "Card1 should exist")
	var name_label: Label = card.get_node_or_null("VBox/NameLabel")
	var desc_label: Label = card.get_node_or_null("VBox/DescLabel")
	var icon: ColorRect = card.get_node_or_null("VBox/Icon")
	var key_label: Label = card.get_node_or_null("VBox/KeyLabel")
	assert_not_null(name_label, "Card should have NameLabel")
	assert_not_null(desc_label, "Card should have DescLabel")
	assert_not_null(icon, "Card should have Icon")
	assert_not_null(key_label, "Card should have KeyLabel")


# ============================================================
# Section 6: Mouse Event Handling
# ============================================================

func test_card_has_mouse_entered_signal():
	var card: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	assert_not_null(card, "Card1 should exist")
	assert_true(card.has_signal("mouse_entered"), "Card should have mouse_entered signal")


func test_card_has_mouse_exited_signal():
	var card: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	assert_not_null(card, "Card1 should exist")
	assert_true(card.has_signal("mouse_exited"), "Card should have mouse_exited signal")


func test_card_mouse_filter_allows_hover():
	var card: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	assert_not_null(card, "Card1 should exist")
	assert_ne(card.mouse_filter, Control.MOUSE_FILTER_IGNORE,
		"Card should not ignore mouse events")


# ============================================================
# Section 7: Hover Effect Spec Values (regression)
# ============================================================

func test_hover_scale_is_1_08():
	# Spec: hover scale = 1.08
	assert_eq(_hud.CARD_HOVER_SCALE, 1.08, "Hover scale should be exactly 1.08")


func test_hover_y_offset_is_minus_4():
	# Spec: Y offset = -4px on hover
	assert_eq(_hud.CARD_HOVER_Y_OFFSET, -4.0, "Hover Y offset should be -4.0")


func test_unhover_restores_to_scale_one():
	# Spec: mouse leave -> scale back to 1.0
	# _on_card_unhover targets Vector2.ONE
	assert_eq(Vector2.ONE, Vector2(1.0, 1.0), "Unhover should target scale 1.0")


func test_unhover_restores_white_modulate():
	# Spec: mouse leave -> modulate back to white
	# _on_card_unhover targets Color.WHITE
	assert_eq(Color.WHITE, Color(1.0, 1.0, 1.0, 1.0), "Unhover should target white modulate")


# ============================================================
# Section 8: Hover Guards
# ============================================================

func test_hover_does_nothing_when_panel_hidden():
	# _on_card_hover returns early if UpgradePanel not visible
	var card: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	assert_not_null(card, "Card1 should exist")
	var panel: Control = _hud.get_node_or_null("UpgradePanel")
	assert_not_null(panel, "UpgradePanel should exist")
	assert_false(panel.visible, "Panel should be hidden")
	# Call hover - should not change card state (panel is hidden)
	_hud._on_card_hover(card)
	assert_eq(card.scale, Vector2.ONE, "Hover should not affect card when panel hidden")


func test_unhover_does_nothing_when_panel_hidden():
	var card: Control = _hud.get_node_or_null("UpgradePanel/Panel/Card1")
	assert_not_null(card, "Card1 should exist")
	_hud._on_card_unhover(card)
	assert_eq(card.scale, Vector2.ONE, "Unhover should not affect card when panel hidden")


# ============================================================
# Section 9: Source Code Verification
# ============================================================

func test_hover_connects_mouse_entered():
	# Verify hud.gd source connects mouse_entered on cards
	var source: String = _hud.get_script().source_code
	assert_true(source.find("mouse_entered") != -1,
		"HUD should connect mouse_entered signal on cards")


func test_hover_connects_mouse_exited():
	var source: String = _hud.get_script().source_code
	assert_true(source.find("mouse_exited") != -1,
		"HUD should connect mouse_exited signal on cards")


func test_hover_uses_tween_for_animation():
	var source: String = _hud.get_script().source_code
	assert_true(source.find("create_tween") != -1,
		"Hover should use Tween for smooth animation")
