extends Position3D

onready var drop_half_width = $DropPlane.mesh.size.x / 2
onready var drone_scene = preload("res://drone/Drone.tscn")

var next_spawn: float = 5.0
var max_drones: int = 10

func _ready():
	randomize()

func _process(delta):
	drone_drop(delta)

func drone_drop(delta):
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
