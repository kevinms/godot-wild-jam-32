extends KinematicBody

export var speed = 14
export var gravity = 12

var velocity = Vector3.ZERO

func _physics_process(delta):
	# Rotate to input direction
	var dir = global_input_dir()
	var target = global_transform.origin + dir
	$DebugTarget.global_transform.origin = target
	look_at(target, Vector3.UP)
	
	# Apply input
	velocity = dir * speed
	
	# Apply gravity
	velocity += Vector3.DOWN * gravity
	
	velocity = move_and_slide(velocity, Vector3.UP)

#TODO: character lean

func _process(delta):
	if Input.is_action_just_pressed("fire"):
		fire_laser()

onready var laser_scene = preload("res://Laser.tscn")

func fire_laser():
	var root = get_tree().get_root()
	var laser = laser_scene.instance()
	laser.global_transform = global_transform
	laser.speed = 50.0
	root.add_child(laser)

func global_input_dir() -> Vector3:
	var dir = Vector3()
	
	dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	return dir

func _on_Hitbox_body_entered(body):
	if body.is_in_group("plant"):
		var plant = body.get_parent()
		plant.pH = 7.0

func _on_Hitbox_body_exited(body):
	pass # Replace with function body.
