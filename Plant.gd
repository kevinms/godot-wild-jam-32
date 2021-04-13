extends Spatial

onready var mi: MeshInstance = $StaticBody/MeshInstance
onready var sm: SpatialMaterial = mi.get_active_material(0)
const max_hue = 256.0 / 360.0

var buffer_capacity = 1.0
var pH: float = 7.0 setget set_ph

func set_ph(value):
	pH = clamp(value, 0, 14)

func _ready():
	randomize()
	
	# Randomize each plant's needs and resistance
	buffer_capacity = rand_range(0.4, 1.0)
	pH = rand_range(5.0, 14.0)

func acidification(acid: float):
	set_ph(pH - buffer_capacity * acid)

func _process(delta):
	acidification(Global.rain_acidity_per_sec * delta)
	
	var h = lerp(0, max_hue, pH / 14.0)
	var s = 0.92
	var v = 0.90
	var a = 1.0
	
	var color = Color.from_hsv(h, s, v, a)
	
	if h < 0.2:
		$AnimationPlayer.play("pulse")
	else:
		$AnimationPlayer.stop(true)
	
	sm.albedo_color = color
	sm.emission = color

func grow(delta):
	pass
