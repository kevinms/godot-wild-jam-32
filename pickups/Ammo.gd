extends Area

func _on_Ammo_body_entered(body):
	if body.is_in_group("player"):
		var amount = 10
		Global.ammo += amount
		
		var doot_pos = global_transform.origin + Vector3.UP * 3 + Vector3.FORWARD * 4
		var duration = 0.5
		Global.new_doot("+" + str(amount) + " Ammo", doot_pos, 0.6, duration, Global.DOOT_NONE, false)
		
		$ammo.visible = false
		$PickupSound.play()
		collision_layer = 0
		collision_mask = 0
		$PickupParticles.emitting = true

func _process(delta):
	rotate_y(delta)

func _on_PickupSound_finished():
	queue_free()
