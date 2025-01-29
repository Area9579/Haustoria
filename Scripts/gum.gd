extends Area3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_overlapping_bodies():
		for i in get_overlapping_bodies():
			if i.has_method('slow_down'):
				i.slow_down(delta)
