extends AudioStreamPlayer3D

@export var custom_audio = 0

var on = false
func play_loop(): 
	stop()
	play()
	on = true
func stop_loop(): on = false
	
func _process(delta: float) -> void:
	if on:
		var tween = get_tree().create_tween()
		tween.tween_property(self, 'volume_db', custom_audio, .1)
	elif !on:
		var tween = get_tree().create_tween()
		tween.tween_property(self, 'volume_db', -80, .3)
