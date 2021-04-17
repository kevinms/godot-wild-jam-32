extends Spatial

var next_fire: float = 1.0
var speed: float = 10.0
var since_last_fire: float = 0.0
var min_player_dist: float = 20.0
var velocity: Vector3

var health: float = 3.0

func _ready():
	randomize()
	
	$Drone/SmokeParticles.emitting = false

func global_player_dir() -> Vector3:
	var dir = player.global_transform.origin - $Pin.global_transform.origin
	#dir.y = $Pin.global_transform.origin.y
	return dir.normalized()

var drone_plane: Plane
var player_plane: Plane
var drone_pos: Vector3

var dead: bool = false

func death_physics(delta):
	print("death physics")
	#$Pin.rotate_y(delta)
	#var velocity = Vector3.DOWN * 2
	#$Pin.global_transform.origin -= velocity * delta
	
	var velocity = Vector3.DOWN * speed
	$Pin.move_and_slide(velocity, Vector3.UP)

var knockback_dir: Vector3
var knockback_duration: float

var preferred_drone_y = 7.0

func _physics_process(delta):
	if dead:
		death_physics(delta)
		return
	
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
		
		# Only fire if the drone is close to the preferred height
		if abs(preferred_drone_y - drone_pos.y) < 2.0:
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
	
	# Get back to the correct drone plane of preferred_drone_y
	if drone_pos.y > preferred_drone_y:
		
		# See if we are off by up to 1 unit
		var magnitude_off_by = clamp(preferred_drone_y - drone_pos.y, -1, 1)
		
		# Add a little to move_dir to nudge back towards preferred_drone_y
		move_dir = (move_dir + Vector3(0, magnitude_off_by, 0)).normalized()
	
	# Override with any knockback
	if knockback_duration > 0:
		knockback_duration -= delta
		move_dir = knockback_dir
	
	#DEBUG: no movement
	#move_dir = Vector3.ZERO
	
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
	var root = get_node("/root/World")
	if root == null:
		return
	
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

func crash():
	$CrashTimer.start()
	$Drone/SmokeParticles.emitting = true
	$Drone/HurtBox.collision_layer = 0
	$Drone/HurtBox.collision_mask = 0
	$Pin.collision_layer = 0
	$Pin.collision_mask = 0
	$Pin/ConeTwistJoint.queue_free()
	$Drone.collision_layer = 1
	$Drone.collision_mask = 1
	Global.drones_killed += 1
	
	dead = true

func _on_HurtBox_area_entered(area):
	health -= 1
	$DamageSound.play()
	
	# Pretend the player is in the same plane as the drone
	var player_pos = player.global_transform.origin
	player_pos.y = $Pin.global_transform.origin.y
	
	knockback_dir = player_pos.direction_to($Pin.global_transform.origin)
	knockback_dir
	knockback_duration = 1.0
	
	if health <= 0:
		crash()

func _on_CrashTimer_timeout():
	destroy()

func destroy():
	$Drone/SmokeParticles.emitting = false
	$Drone/ExplosionParticles.emitting = true
	$Drone/drone.visible = false
	$DeathSound.play()
	$DeathTimer.start()

func _on_DeathTimer_timeout():
	#queue_free()
	pass

func _on_DeathSound_finished():
	queue_free()
