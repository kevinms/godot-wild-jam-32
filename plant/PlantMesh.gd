extends Spatial

onready var trunk = $Trunk
onready var leaves = $Leafs
onready var bulbs = [$Cube010, $Cube011, $Cube012, $Cube013, $Cube014, $Cube015, $Cube016]
onready var fruit = $Fruit
onready var tween = $Tween

func _ready():
	trunk.scale = Vector3.ZERO
	leaves.scale = Vector3.ZERO
	for bulb in bulbs:
		bulb.scale = Vector3.ZERO
	fruit.scale = Vector3.ZERO
	$FruitParticles.emitting = false
	
	grow()

func grow():
	tween.start()
	tween.interpolate_property(trunk, "scale", Vector3.ZERO, Vector3.ONE, 3, Tween.TRANS_CUBIC, Tween.EASE_OUT)

func _on_Tween_tween_completed(object, key):
	if object == trunk:
		tween.interpolate_property(leaves, "scale", Vector3.ZERO, Vector3.ONE, 3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	if object == leaves:
		#tween.interpolate_property(bulbs[0], "scale", Vector3.ZERO, Vector3.ONE, 3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		for i in range(0, bulbs.size()):
			print(bulbs[i].scale)
			tween.interpolate_property(bulbs[i], "scale", Vector3.ZERO, Vector3.ONE*0.5, 3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.connect("tween_all_completed", self, "_on_Tween_tween_all_completed")

func _on_Tween_tween_all_completed():
	tween.interpolate_property(fruit, "scale", Vector3.ZERO, Vector3.ONE, 3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$FruitParticles.emitting = true
	tween.disconnect("tween_all_completed", self, "_on_Tween_tween_all_completed")
	tween.start()
