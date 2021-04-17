extends Spatial

onready var trunk = $Trunk
onready var leaves = $Leafs
onready var bulbs = [$Cube010, $Cube011, $Cube012, $Cube013, $Cube014, $Cube015, $Cube016]
onready var fruit = $Fruit
onready var tween = $Tween
onready var acid_cube = $Trunk/AcidCube
onready var acid_cube_pulse = $Trunk/AcidCubePulse
onready var camera = get_viewport().get_camera()

onready var sm: SpatialMaterial = acid_cube.get_active_material(0)
const max_hue = 256.0 / 360.0

export var pH: float = 7.0
export var buffer_capacity: float = 1.0
export var random: bool = true
export var danger_ph: float = 0.15

#const upgrade_time = 0.5
export var upgrade_time: float = 2.0
export var upgrade_delay: float = 0.5

#const stage_time_base: float = 0.5
export var stage_time_base: float = 5.0
var stage_time: float = stage_time_base

# A floating point factor. Set it to 0.5 to grow half-speed, 2.0 to grow 2x-speed, etc.
func set_growth_rate_factor(rate):
	stage_time = stage_time_base * rate

func _ready():
	randomize()
	
	# Randomize each plant's needs and resistance
	if random:
		#pH = rand_range(5.0, 14.0)
		pH = 7.0
		buffer_capacity = rand_range(0.4, 1.0)
	
	set_growth_rate_factor(1.0)
	reset()

func reset():
	$StageTimer.stop()
	stage = POT
	tween.reset_all()
	$UpgradeParticles.emitting = false
	$UpgradeSound.stop()
	
	trunk.scale = Vector3.ZERO
	leaves.scale = Vector3.ZERO
	for bulb in bulbs:
		bulb.scale = Vector3.ZERO
	fruit.scale = Vector3.ZERO
	$FruitParticles.emitting = false
	
	$StageTimer.start(stage_time)

func set_ph(new_ph: float):
	if stage >= FRUIT:
		return
	
	var already_zero = pH == 0
	
	if new_ph > pH:
		var doot_pos = global_transform.origin + Vector3.UP * 3 + Vector3.FORWARD * 4
		var duration = 0.8
		Global.new_doot("pH UP", doot_pos, 1.0, duration, Global.DOOT_UP)
		#$UpSound.play()
	
	pH = clamp(new_ph, 0, 14)
	
	if pH == 0 and !already_zero:
		$DeathTimer.start()
		$DangerAnimation.play("danger")
		tween.stop_all()
		$StageTimer.stop()
	elif pH != 0 and already_zero:
		$DeathTimer.stop()
		$DangerAnimation.stop(true)
		tween.resume_all()
		$StageTimer.start()

func acidification(delta):
	if stage == HARVEST:
		return
	
	# Acidification
	var acid = Global.rain_acidity_per_sec * delta
	var new_ph = pH - (buffer_capacity * acid)
	
	set_ph(new_ph)

func _process(delta):
	acidification(delta)
	
	update_color()
	
	#acid_cube.rotate_y(PI/2*delta)
	#acid_cube.rotate_x(PI/4*delta)
	
	if Global.tutorial:
		var pos = camera.unproject_position(global_transform.origin + Vector3.UP * 6 + Vector3.RIGHT * 2 + Vector3.FORWARD * 4)
		$Panel.set_global_position(pos)
	else:
		$Panel.visible = false

func update_color():
	if stage >= FRUIT:
		return
	
	var h = lerp(0, max_hue, pH / 14.0)
	var s = 0.92
	var v = 0.90
	var a = 1.0
	
	var color = Color.from_hsv(h, s, v, a)
	
	if h < danger_ph:
		acid_cube_pulse.play("pulse")
	else:
		acid_cube_pulse.stop(true)
	
	sm.albedo_color = color
	sm.emission = color


# Returns false if fruit is not ready
func harvest() -> bool:
	if stage != HARVEST:
		return false

	$HarvestSound.play()
	#reset()
	$Fruit.visible = false
	$DeathAnimation.play("death")
	Global.plants_harvested += 1
	
	return true

enum {POT, TRUNK, LEAVES, BULBS, FRUIT, HARVEST}
var stage = POT

func upgrade_effect():
	if stage < HARVEST:
		$UpgradeParticles.emitting = true
		$UpgradeSound.play()

func _on_StageTimer_timeout():
	match stage:
		POT:
			stage = TRUNK
			upgrade_effect()
			tween.interpolate_property(trunk, "scale", Vector3.ZERO, Vector3.ONE, upgrade_time, Tween.TRANS_BOUNCE, Tween.EASE_OUT, upgrade_delay)
			tween.start()
		TRUNK:
			stage = LEAVES
			upgrade_effect()
			tween.interpolate_property(leaves, "scale", Vector3.ZERO, Vector3.ONE, upgrade_time, Tween.TRANS_LINEAR, Tween.EASE_OUT, upgrade_delay)
			tween.start()
		LEAVES:
			stage = BULBS
			upgrade_effect()
			for i in range(0, bulbs.size()):
				tween.interpolate_property(bulbs[i], "scale", Vector3.ZERO, Vector3.ONE*0.5, upgrade_time, Tween.TRANS_LINEAR, Tween.EASE_OUT, upgrade_delay)
			tween.start()
		BULBS:
			stage = FRUIT
			upgrade_effect()
			acid_cube_pulse.stop(true)
			tween.interpolate_property(acid_cube, "scale", null, Vector3.ZERO, upgrade_delay, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.interpolate_property(fruit, "scale", Vector3.ZERO, Vector3.ONE, upgrade_time, Tween.TRANS_LINEAR, Tween.EASE_OUT, upgrade_delay)
			tween.start()
			$FruitParticles.emitting = true
		FRUIT:
			stage = HARVEST
			print("emit harvest ready")
			Global.emit_fruit_ready(self)

func _on_Tween_tween_all_completed():
	if stage == FRUIT:
		$StageTimer.start(0.01)
	else:
		$StageTimer.start(stage_time)

func _on_DeathAnimation_animation_finished(_anim_name):
	queue_free()


func _on_DeathTimer_timeout():
	Global.plants_died += 1
	$DeathAnimation.play("death")
