extends KinematicBody

export var speed = 14
export var gravity = 12

var velocity = Vector3.ZERO
var mouse_plane_pos: Vector3

onready var camera = get_viewport().get_camera()
onready var max_interaction_dist = $Hitbox/CollisionShape.shape.radius

func _ready():
	Global.connect("player_damaged", self, "_on_Player_player_damaged")
	Global.connect("fruit_ready", self, "_on_Player_fruit_ready")

func _input(event):
	if event is InputEventMouseMotion:
		var origin = camera.project_ray_origin(event.position)
		var normal = camera.project_ray_normal(event.position)
		
		var mouse_plane = Plane(Vector3.UP, 0)
		mouse_plane_pos = mouse_plane.intersects_ray(origin, normal)

func global_mouse_dir() -> Vector3:
	var dir = mouse_plane_pos - global_transform.origin
	dir.y = global_transform.origin.y
	return dir.normalized()

func _physics_process(delta):
	var dir = global_input_dir()
	
	# Rotate towards mouse pointer
	var mouse_dir = global_mouse_dir()
	var target = global_transform.origin + mouse_dir
	$DebugTarget.global_transform.origin = target
	look_at(target, Vector3.UP)
	
	# Apply input
	velocity = dir * speed
	
	# Apply gravity
	velocity += Vector3.DOWN * gravity
	
	velocity = move_and_slide(velocity, Vector3.UP)

#TODO: character lean

var fire_rate: float = 0.2
var time_since_last_fire: float = 0.0

signal place_a_plant()

func _process(delta):
	time_since_last_fire += delta
	
	if Input.is_action_just_pressed("fire"):
		time_since_last_fire = 0
		fire_laser()
	elif Input.is_action_pressed("fire"):
		while time_since_last_fire > fire_rate:
			fire_laser()
			time_since_last_fire -= fire_rate
	elif Input.is_action_just_pressed("action"):
		emit_signal("place_a_plant")

onready var laser_scene = preload("res://player/Laser.tscn")

func fire_laser():
	if Global.ammo <= 0:
		return
	Global.ammo -= 1
	
	var root = get_node("/root/World")
	var laser = laser_scene.instance()
	laser.global_transform = global_transform
	laser.speed = 50.0
	root.add_child(laser)

func global_input_dir() -> Vector3:
	var dir = Vector3.ZERO
	
	dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	return dir

func harvest(plant):
	print("harvesting")
	if !plant.harvest():
		return
	
	Global.gold += Global.fruit_price

func _on_Hitbox_body_entered(body):
	if body.is_in_group("plant"):
		print("plant in range", body.get_path())
		var plant = body
		plant.feed(7.0)
		
		harvest(plant)

func _on_Player_fruit_ready(plant):
	# Attempt to harvest
	var dist = global_transform.origin.distance_to(plant.global_transform.origin)
	
	if dist > max_interaction_dist + 1.1:
		print("Player is ", dist, " units away -- must be within ", max_interaction_dist, " units")
		return
	
	harvest(plant)

func _on_Hitbox_body_exited(body):
	pass # Replace with function body.

func _on_Player_player_damaged(damage):
	print("damaged!!!")
	$DamageSound.play()
