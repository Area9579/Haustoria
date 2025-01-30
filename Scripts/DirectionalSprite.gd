extends AnimatedSprite3D

func change_direction(direction: Vector2):
	direction = direction.normalized()
	if direction.x > 0:
		flip_h = true
	else: flip_h = false
	
	if direction.y > .5:
		frame = 0
	elif direction.y > -.1:
		frame = 1
	elif direction.y > -.5:
		frame = 2
	else:
		frame = 3
