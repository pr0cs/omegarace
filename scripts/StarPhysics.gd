extends KinematicBody2D

export var move_speed = 320
var direction = Vector2.ZERO


func _physics_process(delta):
	rotation+=7.5*delta  #generic fast-ish rotation for star (morphed) enemy
	#test collision
	var collisionResult = move_and_collide(direction*move_speed * delta)
	if(collisionResult):
		#if(collisionResult.collider is KinematicBody2D):
			#if we collide with any kinematic body then don't process the collision and just explode this
			#print("Star collided with:",collisionResult.collider," at position: ",collisionResult.position," ignoring")
			#if(collisionResult.collider.has_method("isBullet")):
			#	collisionResult.collider.queue_free()
			#	has_been_shot(collisionResult.position)
		if (collisionResult.collider is StaticBody2D):
			# if we collide with a static body (wall/scoreboard) continue to process the bounce
	#		collisionResult = move_and_collide(direction*move_speed * delta,true,true,false)
			direction = direction.bounce(collisionResult.normal)
	#else:
		# nothing potential happened, just move it baby
	#	move_and_collide(direction*move_speed * delta)

func has_been_shot(collision_position):
	get_parent().on_got_hit(collision_position)

