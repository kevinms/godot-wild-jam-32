extends Spatial

export var radius: float = 3.0
export var pos: Vector3

var time_vertical = 0.3
var time_horizontal = 0.5

onready var cylinder: CylinderMesh = $MeshInstance.mesh

func _ready():
	global_transform.origin = pos
	
	cylinder.height = 0
	cylinder.top_radius = 0.1
	cylinder.bottom_radius = 0.2
	
	$Tween.interpolate_property(cylinder, "height", 0, 50.0, time_vertical, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
	$Particles.emitting = true
	
	feed_plants()

func _on_Tween_tween_all_completed():
#	$Particles.emitting = true
#	$Tween.interpolate_property(cylinder, "height", 50.0, 0, time_vertical, Tween.TRANS_LINEAR, Tween.EASE_IN)
#	$Tween.start()

	print("asdofijasoifjaosidfj")
	var particles_material: ParticlesMaterial = $Particles.process_material
	var scale_curve: CurveTexture = particles_material.scale_curve
	var curve = scale_curve.curve
	curve.min_value = 0.0
	curve.max_value = radius
	curve.set_point_value(1, radius)

	$Timer.start()

func _on_Timer_timeout():
	queue_free()

func feed_plants():
#	var shape = SphereShape.new()
#	shape.radius = radius

	var shape = CylinderShape.new()
	shape.radius = radius
	shape.height = 10.0
	
	var collision_mask = Global.BIT_PLANTS
	var objects = Global.shape_query(get_world(), global_transform.origin, shape, [], collision_mask)
	print("Feed ", len(objects), " plants in ", radius, " units")
	
	if len(objects) > 0:
		for object in objects:
			var plant = object["collider"]
			#print(plant.get_path())
			plant.set_ph(7.0)
