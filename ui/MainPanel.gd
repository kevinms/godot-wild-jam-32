extends Panel

func _ready():
	show()
	$"../CreditsPanel".hide()
	$GridContainer/TutorialOption.pressed = Global.tutorial_skip

func _on_Quit_pressed():
	get_tree().quit()

func _on_Play_pressed():
	get_tree().change_scene("res://World.tscn")

func _on_Credits_pressed():
	hide()
	$"../CreditsPanel".show()

func _on_Back_pressed():
	$"../CreditsPanel".hide()
	show()


func _on_TutorialOption_pressed():
	Global.tutorial_skip = $GridContainer/TutorialOption.pressed
	print("skip ", Global.tutorial_skip)
