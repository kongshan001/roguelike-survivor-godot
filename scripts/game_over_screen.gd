extends Control


func _ready():
	$VBox/TimeLabel.text = "Time: %s" % GameManager.format_time(GameManager.elapsed_time)
	$VBox/KillsLabel.text = "Enemies Killed: %d" % GameManager.enemies_killed
	$VBox/LevelLabel.text = "Level: %d" % GameManager.player_level
	$VBox/ScoreLabel.text = "Score: %d" % GameManager.score

	$VBox/RestartButton.pressed.connect(_on_restart)
	$VBox/MenuButton.pressed.connect(_on_menu)


func _on_restart():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/arena.tscn")


func _on_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")
