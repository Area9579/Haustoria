extends Area3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_overlapping_bodies():
		get_overlapping_bodies()[0].slow_down(delta)
