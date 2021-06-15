extends Node2D

var velocity = Vector2()
export var rotation_speed = 100
var direction = Vector2.ZERO
var body_size = Vector2.ZERO
var evolve_time:float = 0
var cur_evolve:float=0
var evolving = false
var evolved = false
var evolve_factor = 1
var isHyper:bool = false
var scoreBox:Rect2
var movingDirection = Scoreboard.EnemyDir.LEFT
onready var move_tween = get_node("Tween")
onready var enemyBullet = preload("res://scenes/EnemyBullet.tscn")
onready var fireTimer = $FireTimer
export var fireTimeout:float = 3


func _move(newDirection):
	var ex=0
	var ey=0
	var horizontal:bool=true
	match newDirection:
		Scoreboard.EnemyDir.LEFT:
			ex = Scoreboard.randi_range(body_size.x,scoreBox.position.x-body_size.x)
			ey = Scoreboard.randi_range(scoreBox.end.y+body_size.y,OS.window_size.y-body_size.y)
			if(ex > position.x):
				var temp = Vector2(position.x,position.y)
				position.x = ex
				position.x = ey
				ex=temp.x
				ey=temp.y
		Scoreboard.EnemyDir.UP:
			ex = Scoreboard.randi_range(body_size.x,scoreBox.position.x-body_size.x)
			ey = Scoreboard.randi_range(body_size.y,scoreBox.position.y-body_size.y)
			horizontal=false
			if(ey > position.y):
				var temp = Vector2(position.x,position.y)
				position.x = ex
				position.x = ey
				ex = temp.x
				ey = temp.y
		Scoreboard.EnemyDir.RIGHT:
			ex = Scoreboard.randi_range(scoreBox.end.x+body_size.x,OS.window_size.x-body_size.x)
			ey = Scoreboard.randi_range(body_size.y,scoreBox.position.y-body_size.y)
			if(ex < position.x):
				var temp = Vector2(position.x,position.y)
				position.x = ex
				position.x = ey
				ex=temp.x
				ey=temp.y
		Scoreboard.EnemyDir.DOWN:
			ex = Scoreboard.randi_range(scoreBox.end.x+body_size.x,OS.window_size.x-body_size.x)
			ey = Scoreboard.randi_range(scoreBox.end.y+body_size.y,OS.window_size.y-body_size.y)
			false
			if(ey < position.y):
				var temp = Vector2(position.x,position.y)
				position.x = ex
				position.x = ey
				ex = temp.x
				ey = temp.y
	movingDirection = newDirection
	var target:Vector2 = Vector2(ex,ey)
	var distance = target.distance_to(position)
	var pct=distance / Vector2.ZERO.distance_to(OS.window_size)
	var positionTime
	if(horizontal):
		positionTime=25 # 15 seconds to cross horizontal field, slowest
		positionTime -= Scoreboard.randi_range(1,Scoreboard.wave)
		if(positionTime<1):
			positionTime = 1
		positionTime = positionTime * pct
		if(isHyper):
			positionTime = positionTime / 2
	else:
		positionTime=16 # 8 seconds to cross vertical field
		positionTime -= Scoreboard.randi_range(1,Scoreboard.wave)
		if(positionTime<7):
			positionTime = 7
		positionTime = positionTime * pct
		if(isHyper):
			positionTime = positionTime / 2
	print("Transition time:",positionTime)
	var trans = Scoreboard.randi(5)
	move_tween.interpolate_property(self, "position",position,target,positionTime,trans,Tween.EASE_OUT)
	move_tween.start()

func _set_body_size(_bs:Vector2):
	body_size = _bs;
func _set_scorebox_rect(sbr:Rect2):
	scoreBox=sbr
	var animSprite = get_node("EnemyKinematicBody2D/EnemySprite")
	animSprite.hide()

func setHyper()->void:
	isHyper = true
func _set_evolve_time(_evolve:float):
	evolving=true
	evolve_time=_evolve
	cur_evolve=0
	var animSprite = get_node("EnemyKinematicBody2D/EnemySprite")
	animSprite.show()
	var evolveAnim = get_node("EnemyKinematicBody2D/Evolve")
	evolveAnim.play("Evolving")
	var staticSprite = get_node("EnemyKinematicBody2D/StaticSprite")
	staticSprite.hide()
	
func is_evolving()->bool:
	return evolving

func get_score_value()->int:
	return 5
	
func _process(delta):
	if(evolving and not evolved):
		var pct = 1
		cur_evolve +=delta
		pct =cur_evolve/evolve_time
		if(pct > 1):
			evolved = true
			move_tween.stop_all()
			evolve_factor = 2.5
	rotation_degrees+=(rotation_speed*evolve_factor *delta)	
	if(fireTimer.is_stopped()):
		fireTimer.start(fireTimeout)


func _on_Tween_tween_completed(object, key):
	match movingDirection:
		Scoreboard.EnemyDir.LEFT:
			_move(Scoreboard.EnemyDir.UP)
		Scoreboard.EnemyDir.UP:
			_move(Scoreboard.EnemyDir.RIGHT)
		Scoreboard.EnemyDir.RIGHT:
			_move(Scoreboard.EnemyDir.DOWN)
		Scoreboard.EnemyDir.DOWN:
			_move(Scoreboard.EnemyDir.LEFT)

func shoot():
	if(evolving):
		var bullet = enemyBullet.instance() as Node2D
		get_parent().add_child(bullet)
		bullet.global_position = global_position
		var bPhys = bullet.get_node("EnemyBulletPhysics")
		bPhys.direction = (Scoreboard.get_player_position() - global_position ).normalized()
		bullet.rotation = global_position.angle_to_point(Scoreboard.get_player_position())
		fireTimer.start(fireTimeout)


func _on_FireTimer_timeout():
	shoot()
