extends Spatial


export(float) var pH = 7.0
export(bool) var fruit = false

onready var acid_cube = $Trunk/AcidCube
onready var sm: SpatialMaterial = acid_cube.get_active_material(0)
const max_hue = 256.0 / 360.0

func _ready():
	if fruit:
		$Fruit.visible = true
		acid_cube.visible = false
	update_color()
	
func update_color():
	var h = lerp(0, max_hue, pH / 14.0)
	var s = 0.92
	var v = 0.90
	var a = 1.0
	
	var color = Color.from_hsv(h, s, v, a)
	
	sm.albedo_color = color
	sm.emission = color
