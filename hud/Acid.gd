extends Panel

func _process(delta):
	$Value.text = "pH " + str(int(Global.rain_ph))
