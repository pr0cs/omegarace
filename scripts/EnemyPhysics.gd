extends KinematicBody2D

func has_been_shot(collision_position):
	get_parent().on_got_hit(collision_position)

