extends Control
@onready var background_music = $BackgroundMusic

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
