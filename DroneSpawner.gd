extends Position3D

onready var drop_half_width = $DropPlane.mesh.size.x / 2
onready var drone_scene = preload("res://drone/Drone.tscn")

# Old
var max_drones: int = 20


var next_spawn: float = 5.0
var base_drones: int = 2

var next_wave: float = 0.0
var wave_drones_left: int = 0

func drones_per_wave() -> int:
	var n = base_drones + Global.plants_harvested / 4
	
	return n if n < max_drones else max_drones

func _ready():
	randomize()

func _process(delta):
	if Global.tutorial:
		return
	
	drone_wave(delta)
	
	#drone_drop(delta)

func drone_wave(delta):
	# Reset drones left each wave
	next_wave -= delta
	if next_wave <= 0:
		next_wave = 20.0
		wave_drones_left = drones_per_wave()
		print("Wave of ", wave_drones_left, " drones")
	
	if wave_drones_left <= 0:
		return
	
	if get_tree().get_nodes_in_group("drone").size() >= max_drones:
		return
	
	# Spawn drones for the current wave
	next_spawn -= delta
	if next_spawn <= 0:
		next_spawn = rand_range(0.0, 3.0)
		wave_drones_left -= 1
		spawn_drone()

func drone_drop(delta):
	max_drones = min(base_drones + Global.plants_harvested / 4, 15)
	
	next_spawn -= delta
	if next_spawn > 0:
		return
	next_spawn = rand_range(3.0, 5.0)
	
	if get_tree().get_nodes_in_group("drone").size() >= max_drones:
		return
	
	spawn_drone()

func spawn_drone():
	print("Spawning drone")
	
	var pos = pick_location()
	var drone = drone_scene.instance()
	add_child(drone)
	drone.global_transform.origin = pos

func pick_location() -> Vector3:
	var x_pos = rand_range(-drop_half_width, drop_half_width)
	var z_pos = rand_range(-drop_half_width, drop_half_width)
	return global_transform.origin + Vector3(x_pos, 0, z_pos)
