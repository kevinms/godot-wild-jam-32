extends Panel

func _process(delta):
	$Meter.max_value = Global.max_health
	$Meter.value = clamp(Global.health, 0, Global.max_health)

	if Global.health / Global.max_health < 0.3:
		$AnimationPlayer.play("pulse")
	else:
		$AnimationPlayer.stop(true)
