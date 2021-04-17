extends Panel

func _ready():
	Global.connect("rain_changed", self, "_on_Global_rain_changed")
	$Z/Needle/Particles.emitting = false

func needle_position(ph: float) -> Vector2:
	var normalized = ph / 14
	var needle_offset = normalized * rect_size.x
	
	var needle_pos = rect_global_position
	needle_pos.x += needle_offset - $Z/Needle.rect_size.x / 2
	needle_pos.y = $Z/Needle.rect_global_position.y
	
	return needle_pos

var prev_ph: float

func _on_Global_rain_changed():
	# Tween between positions
	$Tween.stop_all()
	
	if !$ChangeSound.playing:
		$ChangeSound.play()
	
	if !$Z/Needle/Particles.emitting:
		$Z/Needle/Particles.emitting = true
	
	var from = needle_position(prev_ph)
	var to = needle_position(Global.rain_ph)
	$Tween.interpolate_property($Z/Needle, "rect_global_position", from, to, 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	$Tween.start()
	
	prev_ph = Global.rain_ph


func _on_Tween_tween_all_completed():
	$Z/Needle/Particles.emitting = false
	$ChangeSound.stop()
