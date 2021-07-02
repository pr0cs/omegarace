extends Node2D

func _on_Explosion_animation_finished(anim_name):
	queue_free()
