extends Node

var drone_laser_sounds = []
var player_laser_sounds = []
var music = []

func random(array: Array):
	return array[randi() % array.size()]

func _ready():
	load_drone_laser_sounds()
	load_player_laser_sounds()
	load_music()
	
	print(drone_laser_sounds)
	print(player_laser_sounds)
	print(music)

func load_drone_laser_sounds():
	drone_laser_sounds.append(load("res://assets/sfx/laser/synth_laser_01.ogg"))
	#drone_laser_sounds.append(load("res://assets/sfx/laser/synth_laser_03.ogg"))
	#drone_laser_sounds.append(load("res://assets/sfx/laser/synth_laser_06.ogg"))

func load_player_laser_sounds():
	#player_laser_sounds.append(load("res://assets/sfx/laser/synth_laser_01.ogg"))
	#player_laser_sounds.append(load("res://assets/sfx/laser/synth_laser_03.ogg"))
	player_laser_sounds.append(load("res://assets/sfx/laser/synth_laser_06.ogg"))

func load_music():
	music.append(load("res://assets/music/Punch Deck - By Force.ogg"))
	music.append(load("res://assets/music/Punch Deck - Fallen.ogg"))
	music.append(load("res://assets/music/Punch Deck - Flutter.ogg"))
