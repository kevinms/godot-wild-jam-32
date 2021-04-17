extends Area

var speed: float = 50.0
var color: Color setget set_color
var max_distance: float = 100

onready var mi: MeshInstance = $MeshInstance
onready var sm: SpatialMaterial = mi.get_active_material(0)
onready var start_pos = global_transform.origin

var dead: bool = false

func _ready():
	$Fire.stream = AudioLibrary.random(AudioLibrary.player_laser_sounds)
	$Fire.play()
	$MuzzleFlash.emitting = true

func set_color(value):
	color = value
	#var sm: SpatialMaterial = $MeshInstance.get_active_material(0)
	sm.albedo_color = color
	sm.emission = color

func _process(delta):
	DebugDraw.reset($Debug)
	
	if dead:
		return
	
	var distance = (global_transform.origin - start_pos).length()
	if distance > max_distance:
		queue_free()
		return
	
	var hit = scan_for_drone()
	if hit != Vector3.ZERO:
		look_at(hit, Vector3.UP)
	
	var dir = -global_transform.basis.z
	var velocity = dir* speed
	
	global_translate(velocity * delta)

func scan_for_drone():
	var ray = -global_transform.basis.z
	var rot_axis = global_transform.basis.x.normalized()
	
	var num_rays = 4
	for i in range(num_rays):
		if i == 0:
			continue
		var max_angle = PI/2
		var phi = max_angle/num_rays * i
		
		var dir = ray.rotated(rot_axis, phi).normalized()
		var from = global_transform.origin
		var to = from + dir * 15
		
		#DebugDraw.global_sphere($Debug, from, Color.red, 0.5)
		#DebugDraw.global_sphere($Debug, to, Color.blue, 0.5)
		#DebugDraw.global_line($Debug, from, to)
		
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [], Global.BIT_ENEMIES, true, true)
		if result.size() > 0:
			
			#DebugDraw.global_sphere($Debug, result.position, Color.blue, 0.5)
			#DebugDraw.global_line($Debug, from, result.position, Color.red)
			#return result.position
			return result.collider.global_transform.origin
	
	return Vector3.ZERO

func destroy():
	$MeshInstance.hide()
	$ExplosionParticles.emitting = true
	$ExplosionTimer.start()
	$ExplosionSound.play()
	dead = true

func _on_Laser_body_entered(body):
	if body.is_in_group("plant"):
		destroy()

func _on_ExplosionTimer_timeout():
	queue_free()

func _on_Laser_area_entered(area):
	if area.is_in_group("drone"):
		destroy()
