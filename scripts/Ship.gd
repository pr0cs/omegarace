class_name Ship extends Node2D

var bulletScene = preload("res://scenes/Bullet.tscn")
onready var shipBody = $ShipPhysics
onready var weaponPosition = $ShipPhysics/Weapon
onready var fireTimer = $ShipPhysics/FireTimer
export var fireTimeout:float = 0.2 # user cannot spam fire, 0.2 sec delay on being able to shoot again
var canFire:bool = true
signal player_collision(position,rotation,kinebody2d)

func _unhandled_input(event):
	if (event.is_action_pressed("fire") and canFire):
		$ShipShootAudio.play()
		Scoreboard.shotsFired+=1
		var bullet = bulletScene.instance()
		get_parent().add_child(bullet)
		bullet.global_position = weaponPosition.global_position
		bullet._set_speed(shipBody._get_velocity())
		bullet.direction = (weaponPosition.global_position - shipBody.global_position ).normalized() #(_ship_body.position - global_position).normalized()
		bullet.rotation = shipBody.rotation
		canFire=false
		fireTimer.start(fireTimeout)
	elif (event.is_action_pressed("thrust")):
		$ShipThrustAudio.play()
		shipBody._thrust()
	elif (event.is_action_released("thrust")):
		$ShipThrustAudio.stop()
		shipBody._glide()
	elif (event is InputEventMouseMotion):
		var evt = event as InputEventMouseMotion
		shipBody._turn_ship(evt.relative.x)


func _on_FireTimer_timeout():
	canFire=true

func prepare_to_warp():
	shipBody.prepare_to_warp()

func getSprite()->Sprite:
	return shipBody.get_node("ShipSprite")
