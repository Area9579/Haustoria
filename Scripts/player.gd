extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var accel = 1

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	#below code for jumping
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("Left Click"):
		var directionVector: Vector2 = getDirectionVector()
		slideTowardsMouse(directionVector,delta)
	elif Input.is_action_just_released("Left Click"):
		decelerate(delta)
		accel = 1
		#velocity.x = 0
		#velocity.z = 0
	decelerate(delta)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pass

func raycastOnMousePosition(): #function that greates a raycast from the camera to a space in the 3D world based on the mouse position
	var cam = get_viewport().get_camera_3d()
	var mousePos = get_viewport().get_mouse_position()
	var stateInSpace = get_world_3d().direct_space_state
	
	var rayOrigin = cam.project_ray_origin(mousePos)
	var rayEnd = rayOrigin + cam.project_ray_normal(mousePos) * 100
	var rayQuery = PhysicsRayQueryParameters3D.create(rayOrigin,rayEnd)
	rayQuery.collide_with_bodies = true
	
	var resultingRay = stateInSpace.intersect_ray(rayQuery)
	return(resultingRay)


func getMouseWorldPosition(): #gets a vector3 based on the camera raycast
	var raycastResult = raycastOnMousePosition()
	if raycastResult:
		return raycastResult.position
	return position


func getDirectionVector():
	var mousePos = Vector2(getMouseWorldPosition().x,getMouseWorldPosition().z)
	var playerVector2 = Vector2(position.x,position.z)
	var degreeAngle = -rad_to_deg(playerVector2.angle_to_point(mousePos))
	var directionVector = Vector2(cos(deg_to_rad(degreeAngle)),sin(deg_to_rad(degreeAngle)))
	return directionVector


func slideTowardsMouse(directionVector,delta):
	velocity.x = directionVector.x * SPEED * accel
	velocity.z = -directionVector.y * SPEED * accel
	if accel < 2:
		accel += 3 * delta



func decelerate(delta):
	if velocity.x > 0:
		velocity.x -= 8 * delta
	elif velocity.x < 0:
		velocity.x += 8 * delta
	if velocity.z < 0:
		velocity.z += 8 * delta
	elif velocity.z > 0:
		velocity.z -= 8 * delta


func moveTowardsMousePosition(): #moves the playezr towards the position of the mouse
	await awaitTimer()
	if (abs(position.x-getMouseWorldPosition().x) > 1.2):
		position.x = move_toward(position.x,getMouseWorldPosition().x,0.06)
	if (abs(position.z-getMouseWorldPosition().z) > 1.2):
		position.z = move_toward(position.z,getMouseWorldPosition().z,0.06)


func awaitTimer(): #this timer determens how frequently to call the player movement function
	await get_tree().create_timer(0.004).timeout
	moveTowardsMousePosition()
