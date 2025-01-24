extends Node3D

@onready var animation_player: AnimationPlayer = $UI/AnimationPlayer
@onready var jar: AnimatedSprite3D = $Jar
@onready var _2d_player: CharacterBody3D = $"2DPlayer"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('Left Click'):
		jar.play(str(int(str(jar.animation)) + 1))
		if int(str(jar.animation)) >= 6 and _2d_player.frozen != false:
			_2d_player.frozen = false
			_2d_player.velocity += Vector3(6,6,0)
func start_anim():
	$MainAnimation.play("Start")
func start_level():
	animation_player.play('end')
	
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
