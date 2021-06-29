extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Scoreboard.play_music()

func _on_Play_pressed():
	Scoreboard.stop_music()
	Scoreboard.score = 0
	get_tree().change_scene("res://scenes/Main.tscn")

func _on_Settings_pressed():
	get_node("ColorRect/SettingsDialog").popup()

func _on_Cancel_pressed():
	get_node("ColorRect/SettingsDialog").hide()

func _on_OK_pressed():
	var fullscreen = get_node("ColorRect/SettingsDialog/Panel/Fullscreen").is_pressed()
	OS.window_fullscreen = fullscreen
	get_node("ColorRect/SettingsDialog").hide()

func _on_Quit_pressed():
	Scoreboard.stop_music()
	get_tree().quit()

