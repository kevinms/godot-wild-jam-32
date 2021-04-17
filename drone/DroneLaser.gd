extends Area

var speed: float = 50.0
var color: Color setget set_color
var max_distance: float = 100

onready var mi: MeshInstance = $MeshInstance
onready var sm: SpatialMaterial = mi.get_active_material(0)
onready var start_pos = global_transform.origin

var dead: bool

func _ready():
	$Fire.stream = AudioLibrary.random(AudioLibrary.drone_laser_sounds)
	$Fire.play()

func set_color(value):
	color = value
	#var sm: SpatialMaterial = $MeshInstance.get_active_material(0)
	sm.albedo_color = color
	sm.emission = color

func _process(delta):
	if dead:
		return
	
	var distance = (global_transform.origin - start_pos).length()
	if distance > max_distance:
		queue_free()
		return
	
	var dir = -global_transform.basis.z
	var velocity = dir* speed
	
	global_translate(velocity * delta)

func _on_ExplosionTimer_timeout():
	queue_free()


func _on_DroneLaser_area_entered(area):
	$MeshInstance.hide()
	$ExplosionParticles.emitting = true
	$ExplosionTimer.start()
	$ExplosionSound.play()
	dead = true
	collision_layer = 0
	collision_mask = 0
