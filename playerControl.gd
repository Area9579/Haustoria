extends Sprite3D

var clickPositionx
var clickPositionz

func _ready() -> void:
	pass
	moveTowardsMousePosition()


func  _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pass


func raycastOnMousePosition():
	var cam = get_viewport().get_camera_3d()
	var mousePos = get_viewport().get_mouse_position()
	var stateInSpace = get_world_3d().direct_space_state
	
	var rayOrigin = cam.project_ray_origin(mousePos)
	var rayEnd = rayOrigin + cam.project_ray_normal(mousePos) * 100
	var rayQuery = PhysicsRayQueryParameters3D.create(rayOrigin,rayEnd)
	rayQuery.collide_with_bodies = true
	
	var resultingRay = stateInSpace.intersect_ray(rayQuery)
	return(resultingRay)


func getMouseWorldPosition():
	var raycastResult = raycastOnMousePosition()
	if raycastResult:
		return raycastResult.position
	return position


func moveTowardsMousePosition():
	await awaitTimer()
	if (abs(position.x-getMouseWorldPosition().x) > 1.2):
		position.x = move_toward(position.x,getMouseWorldPosition().x,0.2)
	if (abs(position.z-getMouseWorldPosition().z) > 1.2):
		position.z = move_toward(position.z,getMouseWorldPosition().z,0.2)


func awaitTimer():
	await get_tree().create_timer(0.03).timeout
	moveTowardsMousePosition()
	
