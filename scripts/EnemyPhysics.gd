extends KinematicBody2D

var hasEvolved=false
export var move_speed = 320
var direction = Vector2.ZERO

func has_been_shot():
	print("enemy destroyed")
	Scoreboard.enemy_killed(self)
	# todo show explosion
	#queue_free()

func setEvolved()->void:
	hasEvolved = true
	direction = (get_parent().global_position - Scoreboard.get_player_position()).normalized() 
	get_parent().rotate(0)
	print(direction)
	
func hasEvolved()->bool:
	return hasEvolved

func _physics_process(delta):
	if(not hasEvolved):
		return
	rotation+=7.5*delta
	var collisionResult = move_and_collide(direction*move_speed * delta)
	if(collisionResult):
		if(collisionResult.collider is KinematicBody2D):
			print("Enemy collided with ",collisionResult.collider.name)
			var body:KinematicBody2D = collisionResult.collider;
		else:
			direction = direction.bounce(collisionResult.normal)
		
