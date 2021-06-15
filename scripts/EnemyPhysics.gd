extends KinematicBody2D


func has_been_shot():
	print("enemy destroyed")
	Scoreboard.enemy_killed(self)
	# todo show explosion
	#queue_free()

