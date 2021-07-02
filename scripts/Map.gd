extends Node2D


#scenes
var enemyScene=preload("res://scenes/Enemy.tscn")
onready var cold = preload("res://scenes/MapBulletCollider.tscn")
var playerScene = preload("res://scenes/Ship.tscn")
var chunkScene : PackedScene = preload("res://scenes/Chunk.tscn")
var warpScene : PackedScene = preload("res://scenes/Warp.tscn")
var teleportScene : PackedScene = preload("res://scenes/Teleport.tscn")
var shipExplodeScene : PackedScene = preload("res://scenes/ShipExplosion.tscn")

#local vars
var scoreBox:Rect2
var player:Ship
var enemyArray=[]
var colliderArray=[]
var waveEnemyCount:int = 2
var waveEvolveCount:int = 1
var nebulaShader:ShaderMaterial
var warp:Node2D
var explosionParticles = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Scoreboard.randomize()
	var nebula:Sprite = get_node("Nebula")
	nebulaShader = nebula.material
	# default starting wave / lives are set in the ScoreUI
	compute_scorebox_rect()
	respawn_player("start")
	Scoreboard.connect("enemy_killed",self,"check_wave_complete")
	Scoreboard.connect("player_died",self,"animate_death")

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
		#print(kid.name)
		if "Bullet" in kid.name:
			kid.queue_free()
		
func _on_Wave_Timer_timeout():
	cleanup_colliders()
	_remove_all_bullets()
	warp = warpScene.instance()
	warp.position = Scoreboard.get_player_position()
	warp.rotation_degrees = Scoreboard.rotation-180.0
	add_child(warp)
	if(player!=null):
		player.queue_free()
	warp.visible = true
	var warpAnimation:AnimationPlayer = warp.get_node("WarpAnimation")
	warpAnimation.connect("animation_finished",self,"finished_wave")
	warpAnimation.play("Warp")
	
func finished_wave(_animation)->void:
	if(warp!=null):
		warp.queue_free()
	Scoreboard.wave+=1
	explosionParticles=null;
	respawn_player("start")
	
func start_next_wave(_animation)->void:
	warp.queue_free()
	start_new_wave()

func setNebulaScene()->void:
	nebulaShader.set_shader_param("x_offset",0)
	nebulaShader.set_shader_param("y_offset",0)
	nebulaShader.set_shader_param("nebula_seed",Scoreboard.randi_range(4,50))
	nebulaShader.set_shader_param("star_density",Scoreboard.randi_range(2,15))
	var vpSize = Scoreboard.randi_range(150,800)
	var vp = Vector2(vpSize,vpSize)
	nebulaShader.set_shader_param("viewport_size",vp)
	
func respawn_player(_unused)->void:
	if(explosionParticles!=null):
		explosionParticles.queue_free()
	var cr:ColorRect = get_node("CanvasLayer/ShockwaveLayer")
	cr.visible=false
	_remove_all_bullets()
	if(Scoreboard.isGameOver()):
		return # player is dead, should be showing game over scoreboard here
	setNebulaScene()
	spawn_enemies()
	var playerSpawnPosition:Position2D = get_node("PlayerSpawn")
	warp = warpScene.instance()
	warp.position = playerSpawnPosition.position
	add_child(warp)
	warp.visible = true
	var warpAnimation:AnimationPlayer = warp.get_node("WarpAnimation")
	warpAnimation.connect("animation_finished",self,"start_next_wave")
	warpAnimation.play("WarpIn")
	
func start_new_wave():
	_remove_all_bullets()
	if(!Scoreboard.isGameOver()):
		spawn_player()
	
func check_wave_complete(destroyedEnemy:Node2D) ->void:
	cleanup_colliders()
	if(destroyedEnemy.has_method("doesnt_affect_wave")):
		return;
	var enemyCount = enemyArray.size()
	enemyArray.erase(destroyedEnemy)
	if(enemyCount == enemyArray.size()):
		return # no enemy removed, probably a bullet lets ignore it
	print(destroyedEnemy.name," was killed, enemies left:",enemyArray.size())
	if(enemyArray.empty()):
		#respawn enemies and player ship after X number of seconds
		destroyedEnemy.queue_free()
		player.prepare_to_warp()
		get_node("WaveRestartTimer").start()
	else:
		if(destroyedEnemy.isEvolving()):
			var minLife = 4
			var maxLife = 10
			var nextEnemy = find_next_non_evolving_enemy()
			if(nextEnemy != null):
				nextEnemy._set_evolve_time(Scoreboard.randi_range(minLife,maxLife))
		destroyedEnemy.queue_free()
			
	
func find_next_non_evolving_enemy() -> Node2D:
	for nextEnemy in enemyArray:
		if(not nextEnemy.isEvolving()):
			return nextEnemy
	return null

func spawn_player():
	player = playerScene.instance() as Node2D
	var playerSpawnPosition:Position2D = get_node("PlayerSpawn")
	player.global_position = playerSpawnPosition.position
	add_child(player)

func spawn_enemy(enemy:Node2D,spriteName:String,position:Vector2):
	add_child(enemy)
	var sprite:Sprite = enemy.get_node(spriteName)
	var default_size = sprite.get_rect().size.x # assume all frames are the same size
	default_size*=(enemy.scale/2) 
	enemy.position.x=position.x;
	enemy.position.y=position.y;
	enemy._set_body_size(default_size)
	enemy._set_scorebox_rect(scoreBox)
	enemy._move(Scoreboard.EnemyDir.LEFT)
	enemyArray.append(enemy)
	enemy.connect("enemy_evolved",self, "update_enemy_array")

func update_enemy_array(original,new)->void:
	var enemyCount = enemyArray.size()
	enemyArray.erase(original)
	if(enemyCount == enemyArray.size()):
		print("This should never happen!")
		return 
	enemyArray.append(new)

func animate_death()->void:
	var cr:ColorRect = $CanvasLayer/ShockwaveLayer
	var ap:AnimationPlayer = $CanvasLayer/Shockwave
	var vpSize = get_viewport().size
	var sposition = Vector2((Scoreboard.get_player_position().x/vpSize.x)*2.0-0.5 , (Scoreboard.get_player_position().y/vpSize.y))
	var shaderMat:ShaderMaterial = cr.material
	shaderMat.set_shader_param("center",sposition)
	cr.visible=true
	ap.connect("animation_finished",self,"respawn_player")
	if(player!=null):
		explosionParticles = shipExplodeScene.instance()
		explosionParticles.position = Scoreboard.get_player_position()
		explosionParticles.rotation_degrees = Scoreboard.rotation - 180.0
		var img:Image=null
		var sprite:Sprite=null;
		sprite = player.getSprite()
		img = sprite.texture.get_data()
		img.resize(150,150)
		var shipTexture:Texture = ImageTexture.new()
		shipTexture.create_from_image(img)
		explosionParticles.get_node("Destruction").initialize(shipTexture)
		explosionParticles.get_node("Explosion").play("Explode")
		add_child(explosionParticles)
		player.queue_free()
		player=null
	ap.play("Shockwave")
	

	
func teleport_enemy_in(evolver:bool) -> void:
	var teleporter = teleportScene.instance()
	var sprite:Sprite = teleporter.get_node("Enemy")
	var default_size = sprite.get_rect().size.x 
	default_size*=(sprite.scale/2)
	# set up default spawn in position for enemy
	var vpSize = OS.window_size
	vpSize = get_viewport().size
	var xpos = Scoreboard.randi_range(default_size.x,vpSize.x-default_size.x)
	var ypos = Scoreboard.randi_range(scoreBox.end.y+default_size.y,vpSize.y-default_size.y)
	teleporter.position.x=xpos;
	teleporter.position.y=ypos;
	add_child(teleporter)
	teleporter.connect("enemy_teleported",self,"enemy_teleported_in")
	teleporter.teleport_enemy_in(evolver)


func enemy_teleported_in(teleportedEnemy)->void:
	var enemyPosition = teleportedEnemy.position
	#remove_child(teleportedEnemy)
	teleportedEnemy.get_node("TeleportAnimation").stop()
	var enemy:Enemy = enemyScene.instance()
	if(Scoreboard.get_current_wavetype()==Scoreboard.WaveType.HYPER):
		enemy.setHyper()
	spawn_enemy(enemy,"KinematicBody2D/E1",enemyPosition)
	if(teleportedEnemy.evolver):
		var minLife = 4
		var maxLife = 10
		enemy._set_evolve_time(Scoreboard.randi_range(minLife,maxLife))
		waveEvolveCount-=1
		var animation:AnimationPlayer = enemy.get_node("KinematicBody2D/Animation")
		animation.play("Evolve")
	else:
		var animation:AnimationPlayer = enemy.get_node("KinematicBody2D/Animation")
		animation.play("Static")
	teleportedEnemy.queue_free()
	

func spawn_enemies() -> void :
	for ec in enemyArray:
		ec.queue_free()
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
		waveEnemyCount = Scoreboard.randi_range(Scoreboard.wave,25)
		waveEvolveCount = 2
	Scoreboard.set_current_wavetype(waveType)
	if(waveEnemyCount < 6):
		waveEnemyCount = 6
	#waveEnemyCount=1#DEBUG
	for e in waveEnemyCount:
		teleport_enemy_in((waveEvolveCount >0))
		waveEvolveCount-=1

func bullet_collision()->void:
	$BulletCollideAudio.play()

############################################################################		
func show_bullet_collision(collisionResult:KinematicCollision2D):
	get_node("WallHitAudio").play()
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
	colliderArray.append(coll)
	add_child(coll)
	
func cleanup_colliders():
	# this is needed because godot has no notion of 
	# a signal for 'one shot' particles, so you have no idea
	# if the particles are actually finished
	if(!colliderArray.empty()):
		var removedArray=[]
		for c in colliderArray:
			var parts = c.get_node("CollideParticles") as Particles2D
			if(!parts.emitting):
				c.queue_free()
				removedArray.append(c)
		for collider in removedArray:
			colliderArray.erase(collider)
			

func _process(delta):
	var xofs = nebulaShader.get_shader_param("x_offset")
	xofs+=delta*2.4
	var yofs = nebulaShader.get_shader_param("y_offset")
	yofs+=delta*4.3	
	nebulaShader.set_shader_param("x_offset",xofs)
	nebulaShader.set_shader_param("y_offset",yofs)

