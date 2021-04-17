extends Node

const BIT_OBJECT_AVOIDANCE = 0b10
const BIT_ENEMY_LASER      = 0b100
const BIT_PLAYER_LASER     = 0b1000
const BIT_ENEMIES          = 0b10000
const BIT_PLAYER           = 0b100000
const BIT_PLANTS           = 0b1000000
const BIT_BUILDINGS        = 0b10000000

var rain_acidity_per_sec: float = 0.75
var rain_ph: float = 2.0

var tutorial: bool = false

var max_health: float = 10
var health: float = max_health
var gold: int = 10
var ammo: int = 5
var drones_killed: int = 0
var plants_died: int = 0
var plants_harvested: int = 0

var player_dead: bool = false

var plant_price = 5
var fruit_price = 10

func reset():
	rain_acidity_per_sec = 0.75
	rain_ph = 2.0
	
	tutorial = false
	
	max_health = 10
	health = max_health
	gold = 10
	ammo = 5
	drones_killed = 0
	plants_died = 0
	plants_harvested = 0
	
	player_dead = false
	
	plant_price = 5
	fruit_price = 10

func buy_plant():
	if gold < plant_price:
		return false
	
	gold -= plant_price
	return true

signal fruit_ready(plant)

func emit_fruit_ready(plant):
	emit_signal("fruit_ready", plant)

signal player_died()

func damage_player(damage):
	if player_dead:
		return
	
	health = max(0, health - damage)
	if health <= 0:
		player_dead = true
		emit_signal("player_died")

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
