extends Node

var paused = false
var debug=false

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Scoreboard.connect("player_died",self,"check_game_over")
	#Scoreboard.score = 0
	pass # Replace with function body.

func _print_map_children()->void:
	if(debug):
		var kids = get_children()
		for kid in kids:
			if(kid.name=="Map"):
				for mkid in kid.get_children():
					print("Map:",mkid.name)

func _toggle_pause():
	paused = !paused
	if(paused):
		_print_map_children()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_node("Map/CanvasModulate").visible=false
		get_node("PauseDialog").show()
		get_parent().get_tree().paused=true
	else:
		if(Input.get_mouse_mode()!=Input.MOUSE_MODE_CAPTURED):
			get_node("Map/CanvasModulate").visible=true
			get_node("PauseDialog").hide()
			get_parent().get_tree().paused=false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
func _resume_pressed():
	_toggle_pause()
	
#func _input(event):
func _unhandled_input(event):
	if (event.is_action_pressed("pause")):
		_toggle_pause()
		

func check_game_over():
	if(Scoreboard.isGameOver()):
		Scoreboard.play_music()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_node("GameOverDialog").updateScoreboard()
		get_node("GameOverDialog").popup()

func _on_Main_pressed():
	_toggle_pause()
	get_tree().change_scene("res://scenes/Start.tscn")

func _on_Resume_pressed():
	_toggle_pause()
