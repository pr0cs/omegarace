extends KinematicBody2D

func has_been_shot(_unused):
	print("enemy mine destroyed")
	Scoreboard.enemy_killed(get_parent())
	get_parent().queue_free()
