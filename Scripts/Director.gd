extends Node

var fullscreen := false 

var score = 0 
var done = false

var music = preload('res://Assets/fart copy.wav')
@onready var new_player = AudioStreamPlayer.new()
signal shake

func _ready() -> void:
	Engine.max_fps = 60
	
	add_child(new_player)
	new_player.stream = music
	new_player.volume_db = -30.0

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	if !new_player.playing:
		new_player.play()
	if Input.is_action_just_pressed("fullscreen"):
		if !fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			fullscreen = true
		else:
			fullscreen = false
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if Input.is_action_just_pressed('restart'):
		get_tree().reload_current_scene()

func shake_cam(direction):
	shake.emit(1, direction)
