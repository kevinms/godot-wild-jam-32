extends Particles

export var splash_area = 20
export var splashes_per_second = 30
export var splash_pool_size = 300

var splash_scene = preload("res://rain/Splash.tscn")
var splashes = []

var time_since_splash = 0
var splash_rate = 1.0 / splashes_per_second
var cur_splash_ind = 0

enum LEVEL {NONE, LIGHT, HEAVY}
export var level = LEVEL.NONE
export var next_change: float = 5

func _ready():
	load_rain_sounds()
	rain_level(level, true)
	
	for i in range(splash_pool_size):
		var s = splash_scene.instance()
		add_child(s)
		splashes.append(s)
		s.hide()

func _process(delta):
	
	if level != LEVEL.NONE:
		time_since_splash += delta
		while time_since_splash >= splash_rate:
			make_splash()
			cur_splash_ind += 1
			cur_splash_ind %= splashes.size()
			time_since_splash -= splash_rate
	
	if Global.tutorial:
		return
	
	change_weather(delta)

func make_splash():
	var x_pos = rand_range(-splash_area, splash_area)
	var z_pos = rand_range(-splash_area, splash_area)
	var start_pos = global_transform.origin + Vector3(x_pos, 0, z_pos)
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(start_pos, start_pos - Vector3(0, 4000, 0))
	if result.size() > 0:
		#print("Splash")
		splashes[cur_splash_ind].global_transform.origin = result.position + Vector3(0, 2.0, 0)
		splashes[cur_splash_ind].get_node("AnimationPlayer").play("Splash")

var rain_sounds = []

func load_rain_sounds():
	rain_sounds.append(load("res://assets/sfx/rain/2-82367-A.ogg"))
	rain_sounds.append(load("res://assets/sfx/rain/1-26222-A.ogg"))

func rain_level(new_level, force = false):
	if !force and new_level == level:
		new_level = (new_level+1) % LEVEL.size()
		print("Rain level same")
	level = new_level
	
	print(LEVEL.keys()[level], " for ", next_change, " sec")
	
	if level == LEVEL.NONE:
		emitting = false
		$RainSound.stop()
		Global.change_rain(7.0, 0.0)
		return
	
	var stream
	match level:
		LEVEL.LIGHT:
			amount = 512
			$RainSound.stream = rain_sounds[0]
			Global.change_rain(4.0, 0.6)
		LEVEL.HEAVY:
			amount = 2048
			$RainSound.stream = rain_sounds[1]
			Global.change_rain(1.0, 1.2)
	
	emitting = true
	$RainSound.play()

func change_weather(delta):
	
	next_change -= delta
	if next_change > 0:
		return
	
	var n = randf()
	
	if n < 0.1:
		next_change = rand_range(4, 7)
		rain_level(LEVEL.NONE)
	elif n < 0.8:
		next_change = rand_range(7, 20)
		rain_level(LEVEL.LIGHT)
	else:
		next_change = rand_range(7, 20)
		rain_level(LEVEL.HEAVY)
