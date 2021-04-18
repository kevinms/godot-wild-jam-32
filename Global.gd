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

# Don't reset this value
var tutorial_skip: bool = false

var tutorial: bool = false
var tutorial_no_acidification: bool
var tutorial_step: int

var max_health: float
var health: float
var gold: int
var ammo: int
var time_survived: float
var drones_killed: int
var plants_died: int
var plants_harvested: int
var plants_planted: int
var ammo_picked_up: int
var hearts_picked_up: int
var turrets_placed: int
var gold_acquired: int

var player_dead: bool = false

var plant_price: int
var fruit_price: int
var feed_price: int
var turret_price: int

func reset():
	# Let the Rain node set these
	#rain_acidity_per_sec = 0.75
	#rain_ph = 2.0
	
	tutorial = false
	tutorial_no_acidification = true
	tutorial_step = -1
	
	max_health = 10
	health = max_health
	gold = 30
	ammo = 5
	
	time_survived = 0
	drones_killed = 0
	plants_died = 0
	plants_harvested = 0
	plants_planted = 0
	ammo_picked_up = 0
	hearts_picked_up = 0
	turrets_placed = 0
	gold_acquired = 0
	
	player_dead = false
	
	plant_price = 5
	fruit_price = 10
	feed_price = 1
	turret_price = 15

func add_gold(amount):
	gold += amount
	gold_acquired += amount

func buy_plant():
	if gold < plant_price:
		return false
	
	gold -= plant_price
	return true

func buy_turret():
	if gold < turret_price:
		return false
	
	gold -= turret_price
	return true

func buy_feed():
	if gold < feed_price:
		return false
	
	gold -= feed_price
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

signal rain_changed()

func change_rain(ph, acidity_per_sec):
	rain_ph = ph
	rain_acidity_per_sec = acidity_per_sec
	emit_signal("rain_changed")

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

func shape_query(world: World, global_pos: Vector3, shape: Shape, excludes: Array = [], collision_mask: int = 0x7FFFFFFF, max_results: int = 30) -> Array:
	var space_state = world.direct_space_state
	
	var query = PhysicsShapeQueryParameters.new()
	query.set_shape(shape)
	query.transform = Transform(Basis.IDENTITY, global_pos)
	if len(excludes) > 0:
		query.set_exclude(excludes)
	query.collision_mask = collision_mask
	
	return space_state.intersect_shape(query, max_results)

onready var doot_scene = preload("res://hud/Doot.tscn")

const DOOT_NONE = 0
const DOOT_UP   = 1

func new_doot(text: String, global_pos: Vector3, scale: float = 1.0, duration: float = 1.0, type = DOOT_UP, sound: bool = true):
	var world = get_node("/root/World")
	
	var doot = doot_scene.instance()
	world.add_child(doot)
	doot.start(text, global_pos, scale, duration, type, sound)
