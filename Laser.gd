extends Area

var speed: float = 50.0

func _process(delta):
	var dir = -global_transform.basis.z
	var velocity = dir* speed
	
	global_translate(velocity * delta)

func _on_Laser_body_entered(body):
	#queue_free()
	pass
