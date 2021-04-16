#tool
extends Camera

export(NodePath) var target_path
export(float) var distance = 5.0
export(float, 0, 89, 1.0) var angle_degrees = 45

onready var target: Spatial = get_node(target_path)
#onready var offset_from_target = global_transform.origin - target.global_transform.origin

func _process(delta):
	var axis = Vector3.RIGHT
	var angle = -deg2rad(angle_degrees)
	var arm = Vector3.BACK * distance
	arm = arm.rotated(Vector3(1,0,0), angle)
	
	#global_transform.origin = target.global_transform.origin + offset_from_target
	global_transform.origin = target.global_transform.origin + arm
	
	look_at(target.global_transform.origin, Vector3.UP)
