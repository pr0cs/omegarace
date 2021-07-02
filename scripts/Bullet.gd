class_name Bullet extends KinematicBody2D

var speed = 200 # 200 units
var direction = Vector2.ZERO

func _ready():	
	pass
	
func _set_speed(new_speed):
	speed=speed+new_speed

func isBullet()->bool:
	return true

func _physics_process(delta):
	# just test the collision first, we don't want the bullet collision to affect the
	# body it collided withs position
	var _collisionResult = move_and_collide(direction * speed * delta,true,true,true)
	if _collisionResult:
		# if we hit ANYTHING delete this bullet
		if(_collisionResult.collider is StaticBody2D):
			# collided with wall?
			var body:StaticBody2D = _collisionResult.collider;
			if(body.get_parent().has_method("show_bullet_collision")):
				body.get_parent().show_bullet_collision(_collisionResult)
		elif(_collisionResult.collider is KinematicBody2D):
			# collided with any other body, chunkify whatever the bullet hit
			var body:KinematicBody2D = _collisionResult.collider;
			if(body.has_method("has_been_shot")):
				body.has_been_shot(_collisionResult.position)
			else:
				#hit another bullet, either player or enemy, destroy both
				Scoreboard.bullet_to_bullet_collision()
				body.queue_free()
				Scoreboard.shotsHit+=1
		queue_free()
	else:
		# nothing happened in testing collision/movement, let it actually happen
		_collisionResult = move_and_collide(direction * speed * delta)
	
