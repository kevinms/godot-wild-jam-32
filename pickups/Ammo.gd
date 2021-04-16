extends Area

func _on_Ammo_body_entered(body):
	if body.is_in_group("player"):
		Global.ammo += 10
		
		$ammo.visible = false
		$PickupSound.play()
		collision_layer = 0
		collision_mask = 0
		$PickupParticles.emitting = true

func _process(delta):
	rotate_y(delta)

func _on_PickupSound_finished():
	queue_free()
