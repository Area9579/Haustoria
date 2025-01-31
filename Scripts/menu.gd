extends Node3D

@onready var animation_player: AnimationPlayer = $UI/AnimationPlayer
@onready var jar: AnimatedSprite3D = $Jar
@onready var _2d_player: CharacterBody3D = $"2DPlayer"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('Left Click'):
		jar.play(str(int(str(jar.animation)) + 1))
		$"2DPlayer".velocity += Vector3(6,6,0)
		if _2d_player.frozen: Director.shake_cam(Vector2(1,.5) * .1)
		if int(str(jar.animation)) >= 5 and _2d_player.frozen != false:
			jar.scale = Vector3.ONE * .5
			$Jar/Jar.process_mode = Node.PROCESS_MODE_DISABLED
			Director.shake_cam(Vector2(3,3) * .1)
			
			$Jar/LabelClick.freeze = false
			$Jar/LabelClick.apply_impulse(Vector3(6,6,0))
			$Jar/LabelClick.show()
			
			$Jar/LabelClick2.freeze = false
			$Jar/LabelClick2.apply_impulse(Vector3(15,15,0))
			$Jar/LabelClick2.show()
			
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
