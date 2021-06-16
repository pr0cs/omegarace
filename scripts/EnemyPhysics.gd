extends KinematicBody2D

var hasEvolved=false
export var move_speed = 320
var direction = Vector2.ZERO

func has_been_shot():
	Scoreboard.enemy_killed(self)
	# todo show explosion
	#queue_free()

func hasEvolved()->bool:
	return hasEvolved

func _physics_process(delta):
	if(not hasEvolved):
		return
	rotation+=7.5*delta
	var collisionResult = move_and_collide(direction*move_speed * delta)
	if(collisionResult):
		direction = direction.bounce(collisionResult.normal)


func _on_Enemy_final_form_evolution(mask_bit, mask_bit_flag):
	var animSprite = get_node("EnemySprite")
	animSprite.hide()
	var evolveAnim = get_node("Evolve")
	evolveAnim.stop()
	var staticSprite = get_node("StaticSprite")
	staticSprite.hide()
	var starSprite = get_node("StarSprite")
	starSprite.show()
	var starAnim = get_node("Star")
	starAnim.play("Star")
	#change mask to allow wall collision
	set_collision_mask_bit(mask_bit,mask_bit_flag)
	hasEvolved = true
	direction = (get_parent().global_position - Scoreboard.get_player_position()).normalized() 
	get_parent().rotate(0)
