extends PopupDialog

var paused = false

onready var cursor = preload("res://assets/cursor/cursor.png")

func pause():
	print('pause')
	get_tree().paused = true
	show()
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW, Vector2(16,16))

func play():
	print("play")
	get_tree().paused = false
	hide()
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(16,16))

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !is_visible():
			pause()
		else:
			play()

func _on_Quit_pressed():
	get_tree().quit()

func _on_Menu_pressed():
	get_tree().change_scene("res://ui/MainMenu.tscn")
	get_tree().paused = false

func _on_Resume_pressed():
	get_tree().paused = false
	hide()

func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_MuteToggle_pressed():
	var i = AudioServer.get_bus_index("Master")
	var mute = !AudioServer.is_bus_mute(i)
	AudioServer.set_bus_mute(i, mute)

func _on_RainSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Rain"), value)

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
