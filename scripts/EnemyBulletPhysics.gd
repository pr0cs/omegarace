extends KinematicBody2D

var speed = 200 # 200 per second
var direction = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
			print("EnemyBullet collided with ",_collisionResult.collider.name)
			if(_collisionResult.collider.has_method("player_collision")):
				_collisionResult.collider.player_collision(_collisionResult)
		queue_free()

func has_been_shot(unused):
	print("enemy bullet destroyed")
	Scoreboard.enemy_killed(get_parent())
	queue_free()
