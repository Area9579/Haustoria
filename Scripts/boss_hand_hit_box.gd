extends Area3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@export var body_to_hurt : Node3D
signal hit
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group('player'):
		#BOSS TAKE DAMAGE HERE AND PLAY ANIMATION
		print('playerhit')
		body.attack(global_position)
		emit_signal('hit')
		collision_shape_3d.disabled = true
		body_to_hurt.hurt()
		

func enable_collision(): #boss enable this wehn stunned plss plss plsss
	collision_shape_3d.disabled = false
