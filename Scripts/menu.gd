extends Node3D

@onready var animation_player: AnimationPlayer = $UI/AnimationPlayer
@onready var jar: AnimatedSprite3D = $Jar
@onready var _2d_player: CharacterBody3D = $"2DPlayer"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('Left Click'):
		jar.play(str(int(str(jar.animation)) + 1))
		$"2DPlayer".velocity += Vector3(6,6,0)
		if int(str(jar.animation)) >= 6 and _2d_player.frozen != false:
			$Jar/Jar.process_mode = Node.PROCESS_MODE_DISABLED
			
			$Jar/LabelClick.freeze = false
			$Jar/LabelClick.apply_impulse(Vector3(9,9,0))
			$Jar/LabelClick.show()
			$Label3D.hide()
			$Jar/LabelClick/Label3D.show()
			_2d_player.velocity += Vector3(9,9,0)
			await get_tree().create_timer(.5).timeout
			_2d_player.frozen = false
func start_anim():
	$MainAnimation.play("Start")
func start_level():
	animation_player.play('end')
	
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
