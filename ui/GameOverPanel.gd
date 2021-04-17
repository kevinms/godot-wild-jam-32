extends Panel

func _ready():
	Global.connect("player_died", self, "_on_Global_player_died")

func _on_Menu_pressed():
	get_tree().change_scene("res://ui/MainMenu.tscn")
	get_tree().paused = false

func _on_Restart_pressed():
	get_tree().change_scene("res://World.tscn")
	get_tree().paused = false

func _on_Global_player_died():
	$GridContainer/Killed.text = str(Global.drones_killed)
	$GridContainer/Gold.text = str(Global.gold)
	$GridContainer/PlantsDied.text = str(Global.plants_died)
	$GridContainer/PlantsHarvested.text = str(Global.plants_harvested)
