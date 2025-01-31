extends AudioStreamPlayer3D

var self_audio = preload("res://Scenes/spamplay.tscn")

func spam_play():
	if playing:
		var new_audio = self_audio.instantiate()
		add_child(new_audio)
		new_audio.play()
	else:
		play()
