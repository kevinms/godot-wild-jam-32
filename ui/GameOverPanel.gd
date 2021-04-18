extends Panel

func _ready():
	Global.connect("player_died", self, "_on_Global_player_died")

func _on_Menu_pressed():
	get_tree().change_scene("res://ui/MainMenu.tscn")
	get_tree().paused = false

func _on_Restart_pressed():
	get_tree().change_scene("res://World.tscn")
	get_tree().paused = false

func format_time(seconds_float: float):
	var seconds = int(seconds_float)
	
	if seconds / 60 > 0:
		var minutes = seconds / 60
		seconds = seconds % 60
		return str(minutes) + "m " + str(seconds) + "s"
	return str(seconds) + "s"

func _on_Global_player_died():
	$GridContainer/Time.text = format_time(Global.time_survived)
	$GridContainer/Killed.text = str(Global.drones_killed)
	$GridContainer/Gold.text = str(Global.gold_acquired)
	$GridContainer/PlantsDied.text = str(Global.plants_died)
	$GridContainer/PlantsHarvested.text = str(Global.plants_harvested)
	$GridContainer/AmmoPickedUp.text = str(Global.ammo_picked_up)
	$GridContainer/HeartsPickedUp.text = str(Global.hearts_picked_up)
	$GridContainer/TurretsPlaced.text = str(Global.turrets_placed)
