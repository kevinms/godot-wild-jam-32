extends Panel

func _process(delta):
	$Value/Label.text = "pH " + str(int(Global.rain_ph))
