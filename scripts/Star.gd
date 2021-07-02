class_name Star extends Chunkable

onready var enemyBullet = preload("res://scenes/EnemyBullet.tscn")
onready var fireTimer = $FireTimer
export var fireTimeout:float = 2
export var move_speed = 320
var direction = Vector2.ZERO

func _ready():
	setPose("S")
	setBodyInitialVisibility()
	fireTimer.start(fireTimeout)

func get_score_value()->int:
	Scoreboard.shotsHit+=1
	return 7

func usesPhysics()->bool:
	return true

func shoot():
	var shootPct:float = 30 # 40% chance every timeout to shoot
	if(Scoreboard.get_current_wavetype()==Scoreboard.WaveType.BLITZ):
		shootPct += 15.0
	var waveModifier = float((Scoreboard.wave / 15.0) + 0.7)
	shootPct *= waveModifier
	if shootPct > 100:
		shootPct = 100	
	var shootTest = Scoreboard.randi(100)
	#print ("star chance to shoot % :",shootPct," shootTest:",shootTest)	
	if(shootTest < shootPct):
		var bullet = enemyBullet.instance() as Node2D
		get_parent().add_child(bullet)
		var physBody:KinematicBody2D =$KinematicBody2D
		bullet.global_position = physBody.global_position
		var bPhys = bullet.get_node("EnemyBulletPhysics")
		bPhys.direction = (Scoreboard.get_player_position() - physBody.global_position ).normalized()
		bullet.rotation = physBody.global_position.angle_to_point(Scoreboard.get_player_position())	



func _on_FireTimer_timeout():
	# should fireTimeout get shorter as waves go up?  Probably
	# star enemies don't mine, theory is they move too fast to drop mines
	shoot()
	var timeout = fireTimeout
	if(Scoreboard.get_current_wavetype()==Scoreboard.WaveType.BLITZ):
		timeout *= 0.5 # blitz waves has enemy firing 50% more often		
	fireTimer.start(timeout)
