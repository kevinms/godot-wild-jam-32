extends Spatial

const plant_distance = 3.0

onready var plant_scene = preload("res://plant/PlantMesh.tscn")
onready var player = $Player
onready var cursor = preload("res://assets/cursor/cursor.png")

func _ready():
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(16,16))
	Global.connect("player_died", self, "_on_Global_player_died")
	
	$Music.stream = AudioLibrary.random(AudioLibrary.music)
	$Music.play()
	
	$GameOverPanel.hide()
	
	Global.reset()

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_Player_place_a_plant():
	if !Global.buy_plant():
		return
	
	var offset = -player.global_transform.basis.z * plant_distance
	var pos = player.global_transform.origin + offset

	var plant = plant_scene.instance()
	plant.global_transform.origin = pos
	add_child(plant)

func game_over():
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	$GameOverPanel.show()
	$DeathAnimation.play("zoom")

func _on_Global_player_died():
	game_over()
