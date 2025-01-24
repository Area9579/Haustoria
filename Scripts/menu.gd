extends Node3D

@onready var animation_player: AnimationPlayer = $UI/AnimationPlayer
@onready var jar: AnimatedSprite3D = $Jar

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('Left Click'):
		jar.play(str(int(str(jar.animation)) + 1))
		if int(str(jar.animation)) >= 6: $MainAnimation.play("Start")

func start_level():
	animation_player.play('end')
	
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
