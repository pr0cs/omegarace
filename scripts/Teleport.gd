class_name EnemyTeleporter extends Node2D

signal enemy_teleported(teleporter)

var evolver:bool

func teleport_enemy_in(isAnEvolver:bool)->void:
	evolver = isAnEvolver
	var length = Scoreboard.randf_range(.4,2.5)
	get_node("TeleportAnimation").play("Teleport",-1,length,false)
	
func _on_TeleportAnimation_animation_finished(anim_name):
	emit_signal("enemy_teleported",self)
