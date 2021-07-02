extends Node2D

onready var tween:Tween = get_node("LightTween")
onready var light:Light2D = get_node("Light2D")
var explosionScene=preload("res://scenes/MineExplosion.tscn")

func _ready():
	tween.interpolate_property(light, "energy",1,2.5,2,Tween.EASE_IN_OUT,Tween.EASE_OUT)
	tween.start()

	
func get_score_value()->int:
	Scoreboard.minesDestroyed+=1
	Scoreboard.shotsHit+=1
	return 3

func doesnt_affect_wave()->bool:
	return true

func _on_LightTween_tween_completed(object, key):
	if(light.energy >1):
		tween.interpolate_property(light, "energy",5.5,1,2,Tween.EASE_IN_OUT,Tween.EASE_OUT)
	else:
		tween.interpolate_property(light, "energy",1,5.5,2,Tween.EASE_IN_OUT,Tween.EASE_OUT)
	tween.start()

func showExplosion() ->void:
	tween.stop_all()
	visible = false
	var explode = explosionScene.instance()
	explode.position = position
	get_parent().add_child(explode)
	explode.get_node("Explosion").play("Explode")
	
