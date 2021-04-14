extends Node

var rain_acidity_per_sec: float = 1.0

var health: float = 10

signal player_damaged(damage)

func damage_player(damage):
	health = max(0, health - damage)
	emit_signal("player_damaged", damage)

func get_player():
	var nodes = get_tree().get_nodes_in_group("player")
	if len(nodes) > 0:
		return nodes[0]
	push_error("The player is missing...")

func sphere_query(world: World, global_pos: Vector3, radius: float, excludes: Array = [], collision_mask: int = 0x7FFFFFFF, max_results: int = 30) -> Array:
	var space_state = world.direct_space_state
	
	var sphere = SphereShape.new()
	sphere.radius = radius
	
	var query = PhysicsShapeQueryParameters.new()
	query.set_shape(sphere)
	query.transform = Transform(Basis.IDENTITY, global_pos)
	if len(excludes) > 0:
		query.set_exclude(excludes)
	query.collision_mask = collision_mask
	
	return space_state.intersect_shape(query, max_results)
