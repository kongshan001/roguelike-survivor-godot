extends Control


func _ready():
	$StartButton.pressed.connect(_on_start_pressed)
	$ShopButton.pressed.connect(_on_shop_pressed)
	$AchievementButton.pressed.connect(_on_achievement_pressed)

	if SaveManager:
		$SoulLabel.text = "Soul Fragments: %d" % SaveManager.soul_fragments


func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")


func _on_shop_pressed():
	get_tree().change_scene_to_file("res://scenes/shop.tscn")


func _on_achievement_pressed():
	get_tree().change_scene_to_file("res://scenes/achievement_screen.tscn")
