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
onready var enemyMine = preload("res://scenes/Mine.tscn")
onready var fireTimer = $FireTimer
onready var evolveTimer = $EvolveTimer
onready var mineTimer = $MineTimer
export var fireTimeout:float = 3
export var mineTimeout:float = 10
export var evolveTimeoutFactor:int = 3
signal final_form_evolution(mask_bit,mask_bit_flag)


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
		positionTime=25 # 25 seconds to cross horizontal field, slowest
		positionTime -= Scoreboard.randi_range(1,Scoreboard.wave)
		if(positionTime<1):
			positionTime = 1
		positionTime = positionTime * pct
	else:
		positionTime=15 # 15 seconds to cross vertical field at slowest point
		positionTime -= Scoreboard.randi_range(1,Scoreboard.wave)
		if(positionTime<11):
			positionTime = 11
		positionTime = positionTime * pct
	if(isHyper):
		positionTime = positionTime / 2
	#print("Transition time:",positionTime)
	var trans = Scoreboard.randi(5)
	move_tween.interpolate_property(self, "position",position,target,positionTime,trans,Tween.EASE_OUT)
	move_tween.start()

func _set_body_size(_bs:Vector2):
	body_size = _bs;
func _set_scorebox_rect(sbr:Rect2):
	scoreBox=sbr
	var starSprite = get_node("EnemyKinematicBody2D/StarSprite")
	starSprite.hide()

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
			evolveTimer.start(evolveTimeoutFactor)
	rotation_degrees+=(rotation_speed*evolve_factor *delta)	
	if(fireTimer.is_stopped()):
		# should fireTimeout get shorter as waves go up?  Probably
		var timeout = fireTimeout
		if(Scoreboard.get_current_wavetype()==Scoreboard.WaveType.BLITZ):
			timeout *= 0.5 # blitz waves has enemy firing 50% more often		
		fireTimer.start(timeout)
	if(mineTimer.is_stopped()):
		var mtimeout = mineTimeout
		if(Scoreboard.get_current_wavetype()==Scoreboard.WaveType.BLITZ):
			mtimeout *= 0.5 # blitz waves has enemy mining 50% more often		
		mineTimer.start(mtimeout)
		


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
	var shootPct = 10 # 10% chance every timeout to shoot
	if evolving and not evolved:
		shootPct += 10 # another 10% chance if the enemy is evolving
	if evolved:
		shootPct += 30 # another 30% chance if the enemy is fully evolved
	var waveModifier = (Scoreboard.wave / 15.0) + 1.0
	shootPct *= waveModifier
	if shootPct > 100:
		shootPct = 100	
	var shootTest = Scoreboard.randi(100)
	if(shootTest < shootPct):
		print ("enemy chance to shoot % :",shootPct," shootTest:",shootTest)
		var bullet = enemyBullet.instance() as Node2D
		get_parent().add_child(bullet)
		var physBody =get_node("EnemyKinematicBody2D")
		if(physBody.hasEvolved()):
			bullet.global_position = physBody.global_position
		else:
			bullet.global_position = global_position
		var bPhys = bullet.get_node("EnemyBulletPhysics")
		bPhys.direction = (Scoreboard.get_player_position() - global_position ).normalized()
		bullet.rotation = global_position.angle_to_point(Scoreboard.get_player_position())

func _on_FireTimer_timeout():
	shoot()

func _on_EvolveTimer_timeout():
	if evolved:
		evolveTimer.stop()
		emit_signal("final_form_evolution",1,true)
		evolve_factor = 0 # no longer rotate at node level, rotation now handled at physics level
		fireTimeout /=2
		

func _on_MineTimer_timeout():
	if not evolved:
		var minePct = 10
		var waveModifier = (Scoreboard.wave / 15.0) + 1.0
		minePct *= waveModifier
		if minePct > 100:
			minePct = 100	
		var mineTest = Scoreboard.randi(100)
		print("mine probability:",minePct," actual:",mineTest)
		if(mineTest < minePct):
			var mine = enemyMine.instance() as Node2D
			mine.position = position
			get_parent().add_child(mine)
