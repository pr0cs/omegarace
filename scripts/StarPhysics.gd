extends KinematicBody2D

export var move_speed = 320
var direction = Vector2.ZERO


func _physics_process(delta):
	rotation+=7.5*delta  #generic fast-ish rotation for star (morphed) enemy
	var collisionResult = move_and_collide(direction*move_speed * delta)
	if(collisionResult):
		if (collisionResult.collider is StaticBody2D):
			direction = direction.bounce(collisionResult.normal)

func has_been_shot(collision_position):
	get_parent().on_got_hit(collision_position)

