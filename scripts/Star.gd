class_name Star extends Chunkable

onready var enemyBullet = preload("res://scenes/EnemyBullet.tscn")

export var move_speed = 320
var direction = Vector2.ZERO

func _ready():
	setPose("S")
	setBodyInitialVisibility()

func get_score_value()->int:
	return 7

func usesPhysics()->bool:
	return true

func shoot():
	var shootPct = 40 # 40% chance every timeout to shoot
	var waveModifier = (Scoreboard.wave / 15.0) + 1.0
	shootPct *= waveModifier
	if shootPct > 100:
		shootPct = 100	
	var shootTest = Scoreboard.randi(100)
	if(shootTest < shootPct):
		print ("star chance to shoot % :",shootPct," shootTest:",shootTest)
		var bullet = enemyBullet.instance() as Node2D
		get_parent().add_child(bullet)
		var physBody =get_node("KinematicBody2D")
		if(physBody.isEvolved):
			bullet.global_position = physBody.global_position
		else:
			bullet.global_position = global_position
		var bPhys = bullet.get_node("EnemyBulletPhysics")
		bPhys.direction = (Scoreboard.get_player_position() - global_position ).normalized()
		bullet.rotation = global_position.angle_to_point(Scoreboard.get_player_position())	

			
