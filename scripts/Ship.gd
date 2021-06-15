extends Node2D

var bulletScene = preload("res://scenes/Bullet.tscn")
onready var _ship_body = $ShipPhysics
onready var _weapon_position = $ShipPhysics/Weapon
onready var fireTimer = $ShipPhysics/FireTimer
export var fireTimeout:float = 0.2
export var shipRelativeTurnDelta:int=5
var canFire = true

func _unhandled_input(event):
	if (event.is_action_pressed("fire") and canFire):
		var bullet = bulletScene.instance()
		get_parent().add_child(bullet)
		bullet.global_position = _weapon_position.global_position
		bullet._set_speed(_ship_body._get_velocity())
		bullet.direction = (_weapon_position.global_position - _ship_body.global_position ).normalized() #(_ship_body.position - global_position).normalized()
		bullet.rotation = _ship_body.rotation
		canFire=false
		fireTimer.start(fireTimeout)
	elif (event.is_action_pressed("thrust")):
		_ship_body._thrust()
	elif (event.is_action_released("thrust")):
		_ship_body._glide()
	elif (event is InputEventMouseMotion):
		var evt = event as InputEventMouseMotion
		_ship_body._turn_ship(evt.relative.x)


func _on_FireTimer_timeout():
	canFire=true