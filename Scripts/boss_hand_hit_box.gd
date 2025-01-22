extends Area3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

signal hit
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group('player'):
		#BOSS TAKE DAMAGE HERE AND PLAY ANIMATION
		body.attack()
		emit_signal('hit')
		collision_shape_3d.disabled = true

func enable_collision(): #boss enable this wehn stunned plss plss plsss
	collision_shape_3d.disabled = false
