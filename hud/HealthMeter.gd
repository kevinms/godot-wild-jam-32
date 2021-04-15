extends Panel

func _process(delta):
	$Meter.value = clamp(Global.health, 0, 100)

	if Global.health < 30:
		$AnimationPlayer.play("pulse")
	else:
		$AnimationPlayer.stop(true)
