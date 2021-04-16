extends Panel

func _process(delta):
	$Label.text = str(int(Global.ammo))
