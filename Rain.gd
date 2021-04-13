extends Particles

export var splash_area = 20
export var splashes_per_second = 30
export var splash_pool_size = 300

var splash_scene = preload("res://Splash.tscn")
var splashes = []

var time_since_splash = 0
var splash_rate = 1.0 / splashes_per_second
var cur_splash_ind = 0

func _ready():
	for i in range(splash_pool_size):
		var s = splash_scene.instance()
		add_child(s)
		splashes.append(s)
		s.hide()

func _process(delta):
	time_since_splash += delta
	while time_since_splash >= splash_rate:
		make_splash()
		cur_splash_ind += 1
		cur_splash_ind %= splashes.size()
		time_since_splash -= splash_rate

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
