extends KinematicBody2D

var speed = 200 # 200 per second
var direction = Vector2.ZERO

func _ready():	
	pass
	
func _set_speed(new_speed):
	speed=speed+new_speed
	
func _physics_process(delta):
	var _collisionResult = move_and_collide(direction * speed * delta)
	if _collisionResult:
		#queue_free()
		if(_collisionResult.collider is StaticBody2D):
			var body:StaticBody2D = _collisionResult.collider;
			if(body.get_parent().has_method("show_bullet_collision")):
				body.get_parent().show_bullet_collision(_collisionResult)
		elif(_collisionResult.collider is KinematicBody2D):
			print("Bullet collided with ",_collisionResult.collider.name)
			var body:KinematicBody2D = _collisionResult.collider;
			if(body.has_method("has_been_shot")):
				#hit an enemy
				body.has_been_shot()
			else:
				#hit another bullet, either player or enemy, destroy both
				body.queue_free()
				print("shot the shot")
		queue_free()
	
