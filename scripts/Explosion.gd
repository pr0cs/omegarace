extends Node2D

# triggered when explosion animation is completed	
func explosion_finished(_unused)->void:
	queue_free()
