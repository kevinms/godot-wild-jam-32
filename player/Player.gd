extends KinematicBody

export var speed = 14
export var gravity = 12

var velocity = Vector3.ZERO
var mouse_screen_pos: Vector2

var dead = false

onready var camera = get_viewport().get_camera()
onready var max_interaction_dist = $Hitbox/CollisionShape.shape.radius

func _ready():
	Global.connect("fruit_ready", self, "_on_Global_fruit_ready")
	Global.connect("player_died", self, "_on_Global_player_died")



func _input(event):
	if dead:
		return
	
	if event is InputEventMouseMotion:
		mouse_screen_pos = event.position

func global_mouse_dir() -> Vector3:
	var origin = camera.project_ray_origin(mouse_screen_pos)
	var normal = camera.project_ray_normal(mouse_screen_pos)
	
	var mouse_plane = Plane(Vector3.UP, 0)
	var mouse_plane_pos = mouse_plane.intersects_ray(origin, normal)
	
	var dir = mouse_plane_pos - global_transform.origin
	dir.y = global_transform.origin.y
	return dir.normalized()

func adjust_visuals(input_dir: Vector3):
	# Lean towards direction of movement
	var axis = input_dir.cross(Vector3.UP)
	var angle = PI/4
	var up = Vector3.ZERO.rotated(axis, angle)
	var target = up.cross(axis)
	$Feet.look_at(target, up)
	
	# Wave bumbershoot around
	if input_dir != Vector3.ZERO:
		$AnimationPlayer.play("wave")
	else:
		$AnimationPlayer.stop()

func _physics_process(delta):
	if dead:
		return
	
	var dir = global_input_dir()
	
	adjust_visuals(dir)
	
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
	if dead:
		return
	
	time_since_last_fire += delta
	
	if Input.is_action_just_pressed("fire"):
		time_since_last_fire = 0
		fire_laser()
	elif Input.is_action_pressed("fire"):
		while time_since_last_fire > fire_rate:
			fire_laser()
			time_since_last_fire -= fire_rate
	elif Input.is_action_just_pressed("plant"):
		emit_signal("place_a_plant")
	elif Input.is_action_just_pressed("feed"):
		if Global.gold >= Global.feed_price:
			Global.gold -= Global.feed_price
			
			var doot_pos = global_transform.origin + Vector3.UP * 3 + Vector3.RIGHT * 4
			var duration = 0.5
			Global.new_doot("-1 gold", doot_pos, 0.6, duration, Global.DOOT_NONE, true)
			
			var feed = feed_scene.instance()
			var root = get_node("/root/World")
			feed.radius = 7.0
			feed.pos = global_transform.origin
			feed.pos.y = -1.4
			root.add_child(feed)

onready var feed_scene = preload("res://feed/Feed.tscn")
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
	
	var doot_pos = global_transform.origin + Vector3.UP * 3 + Vector3.FORWARD * 4
	var duration = 0.5
	Global.new_doot("+" + str(Global.fruit_price) + " Gold", doot_pos, 0.6, duration, Global.DOOT_NONE, false)

func _on_Hitbox_body_entered(body):
	if body.is_in_group("plant"):
		print("plant in range", body.get_path())
		var plant = body
		#plant.set_ph(7.0)
		
		harvest(plant)

func _on_Global_fruit_ready(plant):
	# Attempt to harvest
	var dist = global_transform.origin.distance_to(plant.global_transform.origin)
	
	if dist > max_interaction_dist + 1.1:
		print("Player is ", dist, " units away -- must be within ", max_interaction_dist, " units")
		return
	
	harvest(plant)

func _on_Hitbox_body_exited(body):
	pass # Replace with function body.


func _on_Hurtbox_area_entered(area):
	if dead:
		return
	
	$DamageSound.play()
	Global.damage_player(1)
	
	var doot_pos = global_transform.origin + Vector3.UP * 3 + Vector3.FORWARD * 4
	var duration = 0.5
	Global.new_doot("-1 health", doot_pos, 0.6, duration, Global.DOOT_NONE, false)

func _on_Global_player_died():
	dead = true
