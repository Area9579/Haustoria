extends Area3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group('player')  and animated_sprite_3d.animation == 'close':
		animated_sprite_3d.play('open')
	
	if body.is_in_group('hand') and animated_sprite_3d.animation != 'close':
		body.stun()
		animated_sprite_3d.play('close')
	
