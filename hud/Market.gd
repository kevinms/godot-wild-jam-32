extends Panel

func _process(delta):
	$PlantPrice.text = str(Global.plant_price)
	$TurretPrice.text = str(Global.turret_price)
	$FeedPrice.text = str(Global.feed_price)
