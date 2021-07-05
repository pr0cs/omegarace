extends Control

onready var score: Label =  get_node("ScoreValue")
onready var wave: Label =  get_node("WaveValue")
onready var hiscore: Label =  get_node("HiScoreValue")
onready var waveType: Label = get_node("WaveType")
onready var shipIconPosition: Position2D = get_node("LivesLabel/ShipIconLoc")
onready var shipIcon = preload("res://scenes//ShipIcon.tscn")

var shipIconArray=[]


func _ready() -> void:
	Scoreboard.connect("score_updated",self,"update_interface")
	Scoreboard.connect("wave_updated",self,"update_interface")
	Scoreboard.connect("player_died",self,"player_death")
	Scoreboard.connect("rotation",self,"ship_rotated")
	Scoreboard.wave = 1
	Scoreboard.lives = 3
	var _numShips = Scoreboard.lives
	
	for s in _numShips:
		var _curPos:Vector2 = shipIconPosition.position
		var _life = shipIcon.instance() as Sprite
		var _size:Vector2 = _life.get_rect().size/1.5
		_size.x*=_life.scale.x
		_curPos.x+=(_size.x*s)
		_life.translate(_curPos)
		add_child(_life)
		shipIconArray.append(_life)
	update_interface()

func ship_rotated(rot:float):
	for si in shipIconArray:
		si.rotation_degrees = rot-180

func increase_player_score(_enemy:KinematicBody2D):	
	Scoreboard.score+=_enemy.get_score_value()

func player_death() -> void:
	if(shipIconArray.size()>0):
		var _deadShip = shipIconArray.pop_back()
		if _deadShip!=null:
			_deadShip.queue_free()
			
func update_interface() -> void:
	score.text = "%s" % Scoreboard.score
	wave.text = "%s" % Scoreboard.wave
	hiscore.text = "%s" % Scoreboard.hiscore
	waveType.text = Scoreboard.getWaveTypeText()
