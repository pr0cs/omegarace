extends KinematicBody2D

onready var _animated_sprite = $ShipSprite
onready var _engine_particles = $Engine
#onready var shipExplosion: PackedScene = preload("res://scenes/ShipExplosion.tscn")

var velocity = Vector2()
export var move_speed = 250
export var max_ship_velocity = 1000
export var deceleration_factor = 0.3

var rotate_speed = 0
var thrusting = false
var explosion;


# external funcs
func _thrust():
	thrusting = true
func _glide():
	thrusting = false
	
func _get_velocity():
	return velocity.length()
	
func prepare_to_warp():
	deceleration_factor = 1.5

func _turn_ship(relative:int):
	#print(relative)
	if abs(relative)>5:
		rotate_speed+=relative/3.0
		if(rotate_speed>500):
			rotate_speed=500
		elif(rotate_speed<-500):
			rotate_speed=-500
		
			
func _fly_ship(delta):
	#dampen rotation
	if(rotate_speed >0.5):
		rotate_speed -= (50 * delta)
	if rotate_speed <0.5:
		rotate_speed += (50 * delta)
	rotation_degrees += rotate_speed * delta
	Scoreboard.rotation = rotation_degrees

	# Calculate the direction the player is facing
	var forward_face_direction = Vector2(cos(rotation), sin(rotation))
	# Modify velocity after calculating the direction the player is facing.
	if (thrusting):
		var newVect:Vector2 = (forward_face_direction * move_speed * delta)
		var newVel:Vector2 = velocity - newVect
		#print("Thrust:",newVel.length())
		if(newVel.length()<max_ship_velocity):
			velocity -= forward_face_direction * move_speed * delta;
		_engine_particles.show()
	else:
		_engine_particles.hide()
		velocity -= velocity * deceleration_factor * delta


func _process(delta):
	_fly_ship(delta)
	Scoreboard.set_player_position(global_position)
	
func _physics_process(delta):
	var collisionResult = move_and_collide(velocity * delta)
	if(collisionResult):
		if(collisionResult.collider is KinematicBody2D):
			print("Player collided with ",collisionResult.collider.name)
			#var body:KinematicBody2D = collisionResult.collider;
			# we can assume that ANY sort of collision at this point
			# will have some sort of effect on the player
			player_collision(collisionResult)
			#emit_signal("player_died")
		else:
			velocity = velocity.bounce(collisionResult.normal)
			# stop ship from rotating otherwise it can get "stuck"
			# rotating against the same surface in the next frame
			rotate_speed=0


func player_collision(_collisionResult:KinematicCollision2D)->void:
	#explosion = shipExplosion.instance()
	#get_parent().add_child(explosion)
	#var explodeAnim:AnimationPlayer = explosion.get_node("AnimationPlayer")
	#explodeAnim.connect("animation_finished",self,"remove_explosion")
	#explosion.get_node("AnimationPlayer").play("Explode")
	# Display explosion?
	
	print ("Show ship explosion")	
	Scoreboard.lives -=1
	
