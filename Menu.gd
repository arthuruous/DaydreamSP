extends Control

func _ready():
	pass

func _on_StartButton_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	
func _on_ExitButton_pressed():
	get_tree().quit()
