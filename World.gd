extends Spatial

const plant_distance = 3.0

onready var plant_scene = preload("res://plant/PlantMesh.tscn")
onready var player = $Player
onready var cursor = preload("res://assets/cursor/cursor.png")
onready var camera = $Camera

func _ready():
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(16,16))
	Global.connect("player_died", self, "_on_Global_player_died")
	
	$Music.stream = AudioLibrary.random(AudioLibrary.music)
	$Music.play()
	
	$GameOverPanel.hide()
	
	Global.reset()
	
	
	####################################################################
	# Tutorial Setup From Here
	####################################################################
	if Global.tutorial_skip:
		Global.tutorial = false
		$Tip.queue_free()
		return
	
	Global.tutorial = true
	
	var plant = $PlantTut
	plant.buffer_capacity = 1.5
	plant.connect("plant_died", self, "_on_PlantMesh_plant_died")
	tip_plant_global_pos = plant.global_transform.origin
	tip_world_pos = plant.global_transform.origin + Vector3.UP * 6 + Vector3.RIGHT * 2 + Vector3.FORWARD * 30
	
	$Ammo.monitorable = false
	$Ammo.monitoring = false
	$Ammo.visible = false

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if Global.tutorial:
		tutorial(delta)

var transition_in: float = 0.0

var tip_world_pos: Vector3
var tip_plant_global_pos: Vector3

func _on_PlantMesh_plant_died():
	if Global.plants_harvested < 1:
		var plant = plant_scene.instance()
		plant.name = "PlantTut"
		plant.buffer_capacity = 1.5
		add_child(plant)
		plant.global_transform.origin = tip_plant_global_pos
		plant.connect("plant_died", self, "_on_PlantMesh_plant_died")
		
		Global.gold = 10

func tutorial(delta):
	
	var pos = camera.unproject_position(tip_world_pos)
	$Tip.set_global_position(pos)
	
	if !Input.is_action_just_pressed("tutorial_next") and Global.tutorial_step != -1:
		return
	
	match Global.tutorial_step:
		4:
			if Global.plants_harvested <= 0:
				return
		5:
			if Global.plants_planted <= 0:
				return
		6:
			if Global.ammo_picked_up <= 0:
				return
		7:
			if Global.drones_killed <= 0:
				return
	
	Global.tutorial_step += 1
	
	match Global.tutorial_step:
		0:
			$Tip/Label.text = "I'm a plant.\n\nMy color indicates the soil pH (acidity). I prefer a neutral pH of 7 (green)."
		1:
			$Rain.rain_level($Rain.LEVEL.LIGHT)
			$Tip/Label.text = "The rain here is very acidic. Check the meter above."
			Global.tutorial_no_acidification = false
			$PlantTut.process_stage()
		2:
			$Tip/Label.text = "Run to me [WASD] and keep me alive by feeding me a pH up solution [Space]."
		3:
			$Tip/Label.text = "Eventually I will produce a fruit."
		4:
			$Tip/Label.text = "Harvest my fruit by standing close by for " + str(Global.fruit_price) + " gold."
		5:
			$Tip/Label.text = "Press [E] to buy and plant a new seed for " + str(Global.plant_price) + " gold."
		6:
			$Tip/Label.text = "Pick up the ammo box."
			$Ammo.monitorable = true
			$Ammo.monitoring = true
			$Ammo.visible = true
		7:
			$Tip/Label.text = "Shoot the drone [Left Click] while dodging lasers."
			$DroneSpawner.spawn_drone()
		8:
			$Tip/Label.text = "Great job!\n\nSee how many plants you can harvest without dying. Good luck."
		9:
			Global.tutorial = false
			$Tip.queue_free()

func _on_Player_place_a_plant():
	if Global.tutorial and Global.tutorial_step < 5:
		return
	
	if !Global.buy_plant():
		return
	
	Global.plants_planted += 1
	
	var doot_pos = global_transform.origin + Vector3.UP * 3 + Vector3.RIGHT * 4
	var duration = 0.5
	Global.new_doot("-" + str(Global.plant_price) + " gold", doot_pos, 0.6, duration, Global.DOOT_NONE, true)
	
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
