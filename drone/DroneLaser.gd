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

func _on_Laser_body_entered(body):
	if body.is_in_group("player"):
		Global.damage_player(1)
		$MeshInstance.hide()
		$ExplosionParticles.emitting = true
		$ExplosionTimer.start()
		$ExplosionSound.play()
		dead = true
	else:
		print(body.get_path())

func _on_ExplosionTimer_timeout():
	queue_free()
