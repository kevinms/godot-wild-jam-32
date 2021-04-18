extends StaticBody

var fire_rate = 1.5
var next_fire = fire_rate

onready var laser_scene = preload("res://player/Laser.tscn")
onready var gun = $Gun
onready var label = $Viewport/Label

var life_remaining: float = 60
var target_path: String
var locking_start_transform: Transform
var slerp_weight: float = 0.0

func _ready():
	$Timer.start(life_remaining)

func _physics_process(delta):
	life_remaining = max(life_remaining - delta, 0)
	label.text = str(int(life_remaining))
	
	var target = pick_a_drone()
	if target == null:
		return
	
	# Look at target
	slerp_weight = clamp(slerp_weight + delta, 0.0, 1.0)
	var gun_transform = gun.global_transform
	var look_transform = gun_transform.looking_at(target.global_transform.origin, Vector3.UP)
	gun.global_transform = gun_transform.interpolate_with(look_transform, slerp_weight)
	
	# Shoot target occasionally
	next_fire -= delta
	if next_fire <= 0:
		next_fire = fire_rate
		
		print("firing")
		
		var root = get_node("/root/World")
		var laser = laser_scene.instance()
		laser.global_transform = gun.global_transform
		laser.speed = 50.0
		root.add_child(laser)
		
		laser.set_color(Color.yellow)

func valid_target(target: Spatial) -> bool:
	if target == null:
		return false
	if target.global_transform.origin.y < 0.5:
		return false
	return true

func pick_a_drone() -> Spatial:
	var target: Spatial
	
	# Use an existing one
	if target_path != "":
		target = get_tree().get_root().get_node_or_null(target_path)
		if valid_target(target):
			return target
		target_path = ""
	
	# Pick a drone to target
	var drones = get_tree().get_nodes_in_group("drone")
	if drones.size() <= 0:
		return null
	
	for drone in drones:
		if !valid_target(drone):
			continue
		
		target_path = drone.get_path()
		locking_start_transform = drone.global_transform
		slerp_weight = 0.0
		return drone
	
	return null


func _on_Timer_timeout():
	queue_free()
