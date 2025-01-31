extends Node3D

#animate the player taking this item
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var label_3d: Label3D = $AnimatedSprite3D/Label3D
var collected = false
@export_enum('Cyanide','Sulfiric Acid', 'Bleach', 'Arsenic') var poison: String
@onready var org_pos = $AnimatedSprite3D.position.y
var sin = 0
var current_color = Color('ffffff')
func _ready() -> void:
	animated_sprite_3d.play(poison)
	
	#label_3d.top_level = true
	label_3d.text = poison + ' absorbed!'
func _process(delta: float) -> void:
	if !collected:
		sin += delta
		animated_sprite_3d.position.y = (org_pos + sin(sin)) * .3 + .5
func _on_area_3d_body_entered(body: Node3D) -> void:

	
	if body.name == "Player" and !collected:
		$AudioStreamPlayer3D.play()
		$Area3D/CollisionShape3D.disabled = true
		label_3d.show()
		body.collect_item(poison)
		$Sprite3D.hide()
		collected = true
		
		var color
		
		match poison:
			'Cyanide':
				color = Color(0.612, 0.38, 0.259)
			'Sulfiric Acid':
				color = Color('7fdea6')
			'Bleach':
				color = Color("d6d7c6")
			'Arsenic':
				color = Color(0.451, 0.463, 0.42)
		
		current_color = current_color.blend(color)
		body.change_co(current_color)
	
		var tween = get_tree().create_tween()
		tween.tween_property(label_3d, 'modulate:a', 0, 1.0)
		var tween3 = get_tree().create_tween()
		tween3.tween_property(label_3d, 'outline_modulate:a', 0, .9)
		
		var ttween = get_tree().create_tween()
		ttween.tween_property(animated_sprite_3d, 'modulate:a', 0, 1.0)
		var ttween2 = get_tree().create_tween()
		ttween2.tween_property(animated_sprite_3d, 'position', Vector3(0,1.5,0), 1)
		await ttween2.finished
		$AnimatedSprite3D/DropShadow.hide()
