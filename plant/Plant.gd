extends Spatial

onready var plant_mesh = $PlantMesh
onready var mi: MeshInstance = $MeshInstance
onready var sm: SpatialMaterial = mi.get_active_material(0)
const max_hue = 256.0 / 360.0

var pH: float = 7.0 setget set_ph
var buffer_capacity = 1.0

func set_ph(value):
	pH = clamp(value, 0, 14)

# Returns false if fruit is not ready
func harvest() -> bool:
	if plant_mesh.stage != plant_mesh.HARVEST:
		return false

	$HarvestSound.play()
	#plant_mesh.reset()
	$PlantMesh/Fruit.visible = false
	$DeathAnimation.play("death")
	return true

func _on_DeathAnimation_animation_finished(anim_name):
	queue_free()

func _ready():
	randomize()
	
	# Randomize each plant's needs and resistance
	pH = rand_range(5.0, 14.0)
	buffer_capacity = rand_range(0.4, 1.0)

func acidification(acid: float):
	set_ph(pH - buffer_capacity * acid)

onready var camera = get_viewport().get_camera()

func _process(delta):
	acidification(Global.rain_acidity_per_sec * delta)
	
	update_color()
	
	$MeshInstance.rotate_y(PI*delta)
	
	if Global.tutorial:
		var pos = camera.unproject_position(global_transform.origin + Vector3.UP * 6 + Vector3.RIGHT * 2 + Vector3.FORWARD * 4)
		$Panel.set_global_position(pos)
	else:
		$Panel.visible = false

func update_color():
	var h = lerp(0, max_hue, pH / 14.0)
	var s = 0.92
	var v = 0.90
	var a = 1.0
	
	var color = Color.from_hsv(h, s, v, a)
	
	if h < 0.2:
		$CubePulse.play("pulse")
	else:
		$CubePulse.stop(true)
	
	sm.albedo_color = color
	sm.emission = color
