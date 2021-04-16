extends Spatial

const plant_distance = 3.0

onready var plant_scene = preload("res://plant/PlantMesh.tscn")
onready var player = $Player

func _on_Player_place_a_plant():
	if !Global.buy_plant():
		return
	
	var offset = -player.global_transform.basis.z * plant_distance
	var pos = player.global_transform.origin + offset

	var plant = plant_scene.instance()
	plant.global_transform.origin = pos
	add_child(plant)
