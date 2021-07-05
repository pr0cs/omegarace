class_name Chunkable extends Node2D

# related scenes
var chunkScene : PackedScene = preload("res://scenes/Chunk.tscn")
var expScene : PackedScene = preload("res://scenes/Explosion.tscn")

# local / shared varibles
var offset_value : float = 25
var pose:String
var explosion

# enemies that use physics for movement MUST return true (star/morphed bodies)
# so that its position is retrieved from the physics body
func usesPhysics()->bool:
	return false

# single character to denote which sprite(s) to use/retrieve ('S' for star/morph 'E' for evolving)
func setPose(poseKey:String)->void:
	pose = poseKey
	
# single character to denote where to retrieve sprite info from ('E or 'S'), see above
func getPose()->String:
	return pose

# assume everything is evolving, Enemy class has own method to determine that
func isEvolving()->bool:
	return true
	
# initial setup, make sure all sprites are off, let the animationPlayer do the work around visibility/opacity
func setBodyInitialVisibility()->void:
	for n in range(1,3):
		var nodeName = "KinematicBody2D/"
		nodeName+=getPose()
		nodeName+="%d"%n
		get_node(nodeName).visible=false

# handle situation where chunkable body has been hit by a bullet
# create an explosion, create sprite chunks by resizing the sprite image down 25%
# then build solid bodies using that new texture to create an effect of the ship being torn to pieces
func on_got_hit(_collision_position):
	var bodyPosition:Vector2 = position
	if(usesPhysics()):
		# if this chunkable object uses physics then its position MUST be retrieved from the physic body
		bodyPosition = get_node("KinematicBody2D").global_position
	explosion = expScene.instance()
	explosion.position = bodyPosition
	get_parent().add_child(explosion) # DEBUG
	explosion.get_node("AnimationPlayer").connect("animation_finished",explosion,"explosion_finished")
	explosion.get_node("AnimationPlayer").play("Explode") # DEBUG\
	Scoreboard.enemy_killed(self)
	var curSprite:Sprite = get_current_enemy_texture()
	var img:Image=null
	if curSprite != null:
		# clamp sprite which is defined as 600x600 but scaled 25% to fit within sprite chunk routine (150x150)
		img = curSprite.texture.get_data()
		img.resize(150,150)
	visible=false
	var offset: Vector2 = Vector2.ZERO
	var chunk_sprite_cut_start = Vector2(0,0)
	for _x in range(0,6):
		for _y in range(0,6):
			var spawn_position = bodyPosition + offset#collision_position+offset
			var sprite_cut = chunk_sprite_cut_start + offset
			var chunk_instance:Chunk = chunkScene.instance()
			var chunk_sprite:Sprite = chunk_instance.get_node("Sprite")
			if(img != null):
				chunk_sprite.texture = ImageTexture.new()
				chunk_sprite.texture.create_from_image(img)
			spawn_position -=Vector2(63,63) # adjust the chunk position so it simulates where the parent originally was before chunking
			get_parent().add_child(chunk_instance)
			chunk_instance.set_cut(sprite_cut)	
			chunk_instance.set_rotation(rotation)
			chunk_instance.position = rotate_point_around_pivot(bodyPosition,rotation,spawn_position)
			offset.y += offset_value
		offset.y =0
		offset.x += offset_value
	#queue_free()
	

# retrieve the current sprite in the playing animation so we can chunk it up
# there is no way to get the actual graphical 'frame' from the animation so we
# have to 'calculate' what the sprite looks like in it's current animation
# so we have something to chunk up
func get_current_enemy_texture()->Sprite:
	var enemyBody:KinematicBody2D = get_node("KinematicBody2D")
	var animation:AnimationPlayer = enemyBody.get_node("Animation")
	var pos:float = round(animation.current_animation_position+0.3)
	if( pos < 1):
		pos = 1
	if(pos > 3):
		pos =3
	var nodeName = getPose()
	nodeName += "%d" % int(pos)
	var curSprite:Sprite = enemyBody.get_node(nodeName)
	return curSprite
	
# math utility, calculate the current position of the current chunk given the parent/source body's angle/position
# without this utility the body will be sheared and not in the correct position so the chunks will look really bad
func rotate_point_around_pivot( pivot:Vector2,  angle:float,  p:Vector2)->Vector2:
	 return Vector2(cos(angle) * (p.x - pivot.x) - sin(angle) * (p.y - pivot.y) + pivot.x,
		  sin(angle) * (p.x - pivot.x) + cos(angle) * (p.y - pivot.y) + pivot.y);
				
