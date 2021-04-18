extends Position3D

onready var drop_half_width = $DropPlane.mesh.size.x / 2
onready var ammo_scene = preload("res://pickups/Ammo.tscn")

func _ready():
	randomize()

func _process(delta):
	if Global.tutorial and Global.tutorial_step < 7:
		return
	
	ammo_drop(delta)

var next_ammo: float = 5.0
const max_ammo: int = 2

func ammo_drop(delta):
	next_ammo -= delta
	if next_ammo > 0:
		return
	next_ammo = rand_range(3.0, 5.0)
	
	if get_tree().get_nodes_in_group("ammo").size() >= max_ammo:
		return
	
	var pos = find_drop_location()
	var ammo = ammo_scene.instance()
	add_child(ammo)
	ammo.global_transform.origin = pos

func find_drop_location() -> Vector3:
	for i in range(4):
		var x_pos = rand_range(-drop_half_width, drop_half_width)
		var z_pos = rand_range(-drop_half_width, drop_half_width)
		var from = global_transform.origin + Vector3(x_pos, 0, z_pos)
		var to = from + Vector3.DOWN * 100
		
		#$DebugFrom.global_transform.origin = from
		#$DebugTo.global_transform.origin = to
		
		var collision_mask = 0b10000000
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [], collision_mask)
		if result.size() > 0:
			#$DebugHit.global_transform.origin = result.position
			return result.position
	return Vector3.ZERO
