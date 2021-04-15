extends Spatial

var next_fire: float = 1.0
var speed: float = 10.0
var since_last_fire: float = 0.0
var min_player_dist: float = 20.0
var velocity: Vector3

var health: float = 3.0

func _ready():
	randomize()

func global_player_dir() -> Vector3:
	var dir = player.global_transform.origin - $Pin.global_transform.origin
	#dir.y = $Pin.global_transform.origin.y
	return dir.normalized()

var drone_plane: Plane
var player_plane: Plane
var drone_pos: Vector3

func _physics_process(delta):
	
	drone_plane = Plane(Vector3.UP, $Pin.global_transform.origin.y)
	player_plane = Plane(Vector3.UP, player.global_transform.origin.y)
	drone_pos = $Pin.global_transform.origin
	
	var player_pos = drone_plane.project(player.global_transform.origin)
	var player_dist = drone_pos.distance_to(player_pos)
	var player_dir = drone_pos.direction_to(player_pos)
	
	# Pick a target (plant/player)
	var target = player
	var target_pos = drone_plane.project(target.global_transform.origin)
	var target_dist = drone_pos.distance_to(target_pos)
	var target_dir = drone_pos.direction_to(target_pos)
	
	# Switch to player if it's closer
	if player_dist < target_dist:
		target = player
		target_pos = player_pos
		target_dist = player_dist
		target_dir = player_dir
	
	# Look at target
	#TODO: slerp
	$Pin.look_at(target_pos, Vector3.UP)
	
	# Shoot the target
	since_last_fire += delta
	
	if since_last_fire >= next_fire:
		since_last_fire -= next_fire
		next_fire = rand_range(1.0, 3.0)
		fire_laser()
	
	
	var move_dir: Vector3
	
	# Move to within min/max target distance
	var min_target_dist: float = 7
	var max_target_dist: float = 30
	
	if target_dist < min_target_dist:
		#print("too close")
		move_dir = -target_dir
		free_move_next_change = 0
	elif target_dist > max_target_dist:
		#print("too far")
		move_dir = target_dir
		free_move_next_change = 0
	else:
		# Move freely
		move_dir = get_free_move_dir(delta)
		pass
	
	# Avoid other objects
	var min_object_dist: float = 7
	
	var excludes = [$Drone, $Pin]
	var collision_mask = 0b10
	var objects = Global.sphere_query(get_world(), drone_pos, min_object_dist, excludes, collision_mask)
	if len(objects) > 0:
		#print("objects: ", len(objects))
		move_dir = Vector3.ZERO
		for object in objects:
			var collider = object["collider"]
			#print(collider.get_path())
			var object_pos = drone_plane.project(collider.global_transform.origin)
			var object_ray = object_pos - drone_pos
			move_dir += object_ray
		move_dir *= -1.0/len(objects)
		move_dir = move_dir.normalized()
	
	# Move the drone
	var velocity = move_dir * speed
	$Pin.move_and_slide(velocity, Vector3.UP)

var free_move_dir: Vector3
var free_move_time: float
var free_move_next_change: float

func get_free_move_dir(delta):
	free_move_time += delta
	if free_move_time > free_move_next_change or free_move_dir == Vector3.ZERO:
		#print("changing dir")
		free_move_dir = Vector3(rand_range(-1,1), 0, rand_range(-1,1)).normalized()
		free_move_time = 0
		free_move_next_change = rand_range(2, 5)
	return free_move_dir

onready var laser_scene = preload("res://drone/DroneLaser.tscn")
onready var player = Global.get_player()
onready var cone_height = ($Drone.global_transform.origin - $Pin.global_transform.origin).length()

func global_aim_dir() -> Vector3:
	var dir = -$Pin.global_transform.basis.z
	dir.y = player.global_transform.origin.y
	return dir.normalized()

func at_player():
	return

func on_plane():
	return

func fire_laser():
	var root = get_tree().get_root()
	var laser = laser_scene.instance()
	#laser.global_transform = $Pin.global_transform
	#laser.global_transform.origin.y = player.global_transform.origin.y
	#laser.global_translate(Vector3.DOWN * cone_height)
	
	var position = player_plane.project(drone_pos)
	var target = player.global_transform.origin
	laser.look_at_from_position(position, target, Vector3.UP)
	
	laser.speed = 20.0
	root.add_child(laser)
	laser.color = Color(1,0,0)
