extends Node3D

#animate the player taking this item
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var label_3d: Label3D = $Label3D

@export_enum('Cyanide','Sulfiric Acid', 'Nitrate') var poison: String

func _ready() -> void:
	animated_sprite_3d.play(poison)
	
	label_3d.top_level = true
	label_3d.global_position = global_position
	label_3d.text = poison + ' get!'

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		$Area3D/CollisionShape3D.disabled = true
		label_3d.show()
		body.collect_item(poison)
		$AnimatedSprite3D.hide()
		$Sprite3D.hide()
	
	
	var tween = get_tree().create_tween()
	tween.tween_property(label_3d, 'modulate:a', 0, 1.0)
	var tween3 = get_tree().create_tween()
	tween3.tween_property(label_3d, 'outline_modulate:a', 0, .9)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(label_3d, 'position', label_3d.position + Vector3(0,1.5,0), 1)
