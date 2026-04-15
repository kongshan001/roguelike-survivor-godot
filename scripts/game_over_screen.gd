extends Control


func _ready():
	# Set title based on victory or defeat
	if GameManager.is_victory:
		$VBox/Title.text = "VICTORY"
		$VBox/Title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
		# Change background color for victory
		var bg: ColorRect = get_node_or_null("Background")
		if bg:
			bg.color = Color(0.05, 0.1, 0.05, 0.9)
	else:
		$VBox/Title.text = "GAME OVER"

	$VBox/TimeLabel.text = "Time: %s" % GameManager.format_time(GameManager.elapsed_time)
	$VBox/KillsLabel.text = "Enemies Killed: %d" % GameManager.enemies_killed
	$VBox/LevelLabel.text = "Level: %d" % GameManager.player_level
	$VBox/ScoreLabel.text = "Score: %d" % GameManager.score

	# Check quests/achievements and convert gold to soul fragments
	if SaveManager:
		SaveManager.check_quests_and_achievements()
		var soul_bonus_text: String = ""
		if GameManager.selected_difficulty == "endless":
			soul_bonus_text = " (+45% endless bonus!)"
		$VBox/GoldLabel.text = "Gold: %d -> Soul Fragments: %d%s" % [GameManager.gold, SaveManager.soul_fragments, soul_bonus_text]
	else:
		$VBox/GoldLabel.text = "Gold: %d" % GameManager.gold

	# Victory gold bonus display
	if GameManager.is_victory:
		var victory_label: Label = Label.new()
		victory_label.name = "VictoryBonusLabel"
		victory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var bonus: int = GameManager._get_victory_gold_bonus()
		victory_label.text = "Victory Bonus: +%d gold" % bonus
		victory_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
		$VBox.add_child(victory_label)
		$VBox.move_child(victory_label, $VBox.get_child_count() - 2)

	# Endless mode additional stats
	if GameManager.selected_difficulty == "endless":
		var endless_label: Label = Label.new()
		endless_label.name = "EndlessStatsLabel"
		endless_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var minutes: int = int(GameManager.elapsed_time / 60.0)
		endless_label.text = "Bosses Killed: %d / Best Combo: %d / Milestones: %d" % [GameManager.boss_kill_count, GameManager.best_combo, minutes]
		$VBox.add_child(endless_label)
		# Move before buttons
		$VBox.move_child(endless_label, $VBox.get_child_count() - 2)

	$VBox/RestartButton.pressed.connect(_on_restart)
	$VBox/MenuButton.pressed.connect(_on_menu)


func _on_restart():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/arena.tscn")


func _on_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")
