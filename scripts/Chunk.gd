class_name Chunk extends RigidBody2D

onready var sprite:Sprite = $Sprite

var chunk_size : Vector2 = Vector2(25,25)

func set_cut(cut_position) -> void:
	sprite.region_rect = Rect2(cut_position,chunk_size)
	var parts:AnimationPlayer = get_node("Exploding")
	parts.play("Exploding")


func _on_Exploding_animation_finished(anim_name):
	queue_free()
