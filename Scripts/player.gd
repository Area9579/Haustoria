extends CharacterBody3D


const SPEED = 30.0
const JUMP_VELOCITY = 4.5
var accel = 1.0

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	#below code for jumping
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#this code is for continuous
	#if Input.is_action_pressed("Left Click"):
		#var directionVector: Vector2 = getDirectionVector()
		#slideTowardsMouse(directionVector,delta)
	#else:
		#accel = 1.0
		#velocity.x = lerp(velocity.x,0.0,5 * delta)
		#velocity.z = lerp(velocity.z,0.0,5 * delta)
	
	#this code is for impulse
	if Input.is_action_just_pressed("Left Click"):
		var directionVector: Vector2 = getDirectionVector()
		slideTowardsMouse(directionVector,delta)
	else:
		velocity.x = lerp(velocity.x,0.0,5 * delta)
		velocity.z = lerp(velocity.z,0.0,5 * delta)

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
	#this code is for continuous
	#accel = lerp(accel,3.0,10 * delta)
	#velocity.x = lerp(velocity.x,directionVector.x * SPEED * accel,0.3)
	#velocity.z = lerp(velocity.z,-directionVector.y * SPEED * accel,0.3)
	
	#this code is for impulse
	velocity.x = directionVector.x * SPEED
	velocity.z = -directionVector.y * SPEED


func moveTowardsMousePosition(): #moves the playezr towards the position of the mouse
	await awaitTimer()
	if (abs(position.x-getMouseWorldPosition().x) > 1.2):
		position.x = move_toward(position.x,getMouseWorldPosition().x,0.06)
	if (abs(position.z-getMouseWorldPosition().z) > 1.2):
		position.z = move_toward(position.z,getMouseWorldPosition().z,0.06)


func awaitTimer(): #this timer determens how frequently to call the player movement function
	await get_tree().create_timer(0.004).timeout
	moveTowardsMousePosition()
