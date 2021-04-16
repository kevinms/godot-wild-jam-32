extends Panel

func _on_Menu_pressed():
	get_tree().change_scene("res://ui/MainMenu.tscn")
	get_tree().paused = false

func _on_Restart_pressed():
	get_tree().change_scene("res://World.tscn")
	get_tree().paused = false
