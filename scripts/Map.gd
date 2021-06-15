extends Node2D

#scenes
var enemyScene = preload("res://scenes/Enemy.tscn")
onready var cold = preload("res://scenes/MapBulletCollider.tscn")
var playerScene = preload("res://scenes/Ship.tscn")

#local vars
var scoreBox:Rect2
var player:Node2D
var enemyArray=[]
var waveEnemyCount:int = 2
var waveEvolveCount:int = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	Scoreboard.randomize()
	# default starting wave / lives are set in the ScoreUI
	compute_scorebox_rect()
	spawn_player()
	spawn_enemies()
	Scoreboard.connect("enemy_killed",self,"check_wave_complete")
	Scoreboard.connect("player_died",self,"respawn_player")

func compute_scorebox_rect():
	var _defaultPos:Vector2 = get_node("ScoreNorthBody/ScoreNorthShape").global_position
	var topBox:SegmentShape2D = get_node("ScoreNorthBody/ScoreNorthShape").shape
	var bottomBox:SegmentShape2D = get_node("ScoreSouthBody/ScoreSouthShape").shape
	var leftBox:SegmentShape2D = get_node("ScoreWestBody/ScoreWestShape").shape
	var rightBox:SegmentShape2D = get_node("ScoreEastBody/ScoreEastShape").shape
	scoreBox = Rect2(topBox.a+_defaultPos,Vector2.ZERO)
	scoreBox = scoreBox.expand(topBox.b+_defaultPos)
	scoreBox = scoreBox.expand(bottomBox.b+_defaultPos)
	scoreBox = scoreBox.expand(bottomBox.b+_defaultPos)
	scoreBox = scoreBox.expand(leftBox.b+_defaultPos)
	scoreBox = scoreBox.expand(leftBox.b+_defaultPos)
	scoreBox = scoreBox.expand(rightBox.b+_defaultPos)
	scoreBox = scoreBox.expand(rightBox.b+_defaultPos)

func _remove_all_bullets() ->void :
	var kids = get_children()
	for kid in kids:
		if "Bullet" in kid.name:
			kid.queue_free()
		
func _on_Timer_timeout():
	_remove_all_bullets()
	# warp to next wave?  some sort of animation
	Scoreboard.wave+=1
	respawn_player()

func respawn_player():
	_remove_all_bullets()
	print("respawn")
	if(!Scoreboard.isGameOver()):
		remove_child(player)
		spawn_player()
		spawn_enemies()
	
func check_wave_complete(destroyedEnemy:Node2D) ->void:
	var enemyCount = enemyArray.size()
	enemyArray.erase(destroyedEnemy)
	if(enemyCount == enemyArray.size()):
		return # no enemy removed, probably a bullet lets ignore it
	print(destroyedEnemy.name," was killed, enemies left:",enemyArray.size())
	if(enemyArray.empty()):
		#respawn enemies and player ship after X number of seconds
		destroyedEnemy.queue_free()
		get_node("WaveRestartTimer").start()
	else:
		if(destroyedEnemy.is_evolving()):
			var minLife = 4
			var maxLife = 10
			var nextEnemy = find_next_non_evolving_enemy()
			if(nextEnemy != null):
				nextEnemy._set_evolve_time(Scoreboard.randi_range(minLife,maxLife))
		destroyedEnemy.queue_free()
			
	
func find_next_non_evolving_enemy() -> Node2D:
	for nextEnemy in enemyArray:
		if(not nextEnemy.is_evolving()):
			return nextEnemy
	return null

func spawn_player():
	player = playerScene.instance() as Node2D
	var playerSpawnPosition:Position2D = get_node("PlayerSpawn")
	player.global_position = playerSpawnPosition.position
	add_child(player)

func spawn_enemy(enemy:Node2D,spriteName:String,wave:int):
	add_child(enemy)
	#var sprite:AnimatedSprite = enemy.get_node(spriteName)
	#var default_size = sprite.frames.get_frame("Evolving",0).get_size() # assume all frames are the same size
	var sprite:Sprite = enemy.get_node(spriteName)
	var default_size = sprite.get_rect().size.x # assume all frames are the same size
	sprite.show()	
	default_size*=(enemy.scale/2) 
	var xpos = Scoreboard.randi_range(default_size.x,OS.window_size.x-default_size.x)
	var ypos = Scoreboard.randi_range(scoreBox.end.y+default_size.y,OS.window_size.y-default_size.y)
	enemy.position.x=xpos;
	enemy.position.y=ypos;
	#_enemy._set_speed(50)#speed should look at wave
	enemy._set_body_size(default_size)
	enemy._set_scorebox_rect(scoreBox)
	enemy._move(Scoreboard.EnemyDir.LEFT)
	enemyArray.append(enemy)
	
func spawn_enemies() -> void :
	for ec in enemyArray:
		remove_child(ec)
	enemyArray.clear()
	var waveType = Scoreboard.get_random_wavetype()
	waveEnemyCount = Scoreboard.wave
	waveEvolveCount = 1
	if(Scoreboard.wave >4):
		waveEvolveCount = 2
	if(waveType == Scoreboard.WaveType.NORMAL or waveType == Scoreboard.WaveType.HYPER):
		waveEnemyCount = Scoreboard.wave
		waveEvolveCount = 2
	elif(waveType == Scoreboard.WaveType.BLITZ):
		waveEnemyCount = Scoreboard.wave
		waveEvolveCount = waveEnemyCount / 2 
	elif(waveType == Scoreboard.WaveType.HORDE):
		waveEnemyCount = 30
		waveEvolveCount = 2
	Scoreboard.set_current_wavetype(waveType)
	if(waveEnemyCount < 6):
		waveEnemyCount = 6
	for e in waveEnemyCount:
		var enemy = enemyScene.instance() as Node2D
		spawn_enemy(enemy,"EnemyKinematicBody2D/StaticSprite",Scoreboard.wave)
		if(waveEvolveCount >0):
			var minLife = 4
			var maxLife = 10
			enemy._set_evolve_time(Scoreboard.randi_range(minLife,maxLife))
			waveEvolveCount-=1
			var animSprite = enemy.get_node("EnemyKinematicBody2D/EnemySprite") as AnimatedSprite
			animSprite.show()

			

############################################################################		
func show_bullet_collision(collisionResult:KinematicCollision2D):
	var body:StaticBody2D = collisionResult.collider;
	var coll = cold.instance()
	var parts = coll.get_node("CollideParticles") as Particles2D
	parts.emitting = true
	if(body.name == "NorthBody" or body.name=="ScoreSouthBody"):
		coll.rotation_degrees = 90
	elif(body.name=="SouthBody" or body.name=="ScoreNorthBody"):
		coll.rotation_degrees = -90
	elif(body.name=="EastBody" or body.name=="ScoreWestBody"):
		coll.rotation_degrees=180
	coll.translate(collisionResult.position)
	get_parent().add_child(coll)
	


