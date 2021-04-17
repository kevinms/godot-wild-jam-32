extends Label

var speed: float = 50
var global_pos: Vector3
var max_scale: float = 1.0
var anim_type = Global.DOOT_NONE
var anim_duration: float = 1.0
var offset: Vector2

onready var camera = get_node("/root/World/Camera")

func start(doot_text: String, pos: Vector3, scale: float = 1.0, duration: float = 1.0, type = Global.DOOT_NONE, sound: bool = true):
	global_pos = pos
	max_scale = scale
	anim_type = type
	anim_duration = duration
	text = doot_text
	
	if sound:
		$Tween.interpolate_deferred_callback(self, rand_range(0, 0.1), "play_sound")
	
	match anim_type:
		Global.DOOT_NONE:
			$Tween.interpolate_property(self, "rect_scale", Vector2.ZERO, Vector2.ONE * max_scale, anim_duration, Tween.TRANS_QUART, Tween.EASE_OUT)
		Global.DOOT_UP:
			$Tween.interpolate_property(self, "rect_scale", Vector2.ZERO, Vector2.ONE * max_scale, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			$Tween.interpolate_property(self, "offset", Vector2.ZERO, Vector2.UP * 100, anim_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	$Tween.start()

func play_sound():
	$DootDoot.play()

func _process(delta):
	
	var screen_pos = camera.unproject_position(global_pos)
	screen_pos -= rect_size / 2.0
	screen_pos += offset
	
	rect_position = screen_pos

func _on_Tween_tween_all_completed():
	queue_free()
