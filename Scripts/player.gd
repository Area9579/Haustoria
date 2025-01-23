extends CharacterBody3D

@onready var dashCooldown: Timer = $CooldownTimer
@onready var mouseCooldown: Timer = $MouseInputTimer

@onready var sprite_3d: AnimatedSprite3D = $Sprite3D

var clickPositionx
var clickPositionz
var frozen = false

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const BOUNCE_MULTIPLIER = 3.0

var mouseInput: String
var dashCombo = 1
var oldMousePosition: Vector3
var mouseVelocity: Vector2

func _ready() -> void:
	mouseInput = "Left Click"


func _physics_process(delta: float) -> void:
	
	if frozen: return #dont move or anything while in the attack animation
	#below code for jumping
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	if Input.is_action_pressed(mouseInput):
		dragSelf()
	
	if Input.is_action_just_pressed(mouseInput):
		oldMousePosition = getMouseWorldPosition()
		if dashCooldown.is_stopped() and (mouseCooldown.is_stopped() or mouseCooldown.time_left <= 0.15):
			pass
			#mouseCooldown.start()
			#if dashCombo < 1.6:
				#dashCombo += 0.2
	else:
		decelerate(delta)
	if Input.is_action_just_released(mouseInput):
		getMouseVelocity(delta)
		#changeMouseInput(mouseInput)
	move_and_slide()
	rebound()


func raycastOnMousePosition(): #function that greates a raycast from the camera to a space in the 3D world based on the mouse position
	var cam = get_viewport().get_camera_3d()
	var mousePos = get_viewport().get_mouse_position()
	var stateInSpace = get_world_3d().direct_space_state
	
	var rayOrigin = cam.project_ray_origin(mousePos)
	var rayEnd = rayOrigin + cam.project_ray_normal(mousePos) * 100
	var rayQuery = PhysicsRayQueryParameters3D.create(rayOrigin,rayEnd,128)
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


func decelerate(delta):
	velocity.x = lerp(velocity.x,0.0,5 * delta)
	velocity.z = lerp(velocity.z,0.0,5 * delta)

func rebound():
	if get_wall_normal():
		velocity.x += get_wall_normal().x * BOUNCE_MULTIPLIER
		velocity.z += get_wall_normal().z * BOUNCE_MULTIPLIER

func changeMouseInput(mouseClickInput):
	if mouseClickInput == "Left Click":
		mouseInput = "Right Click"
	elif mouseClickInput == "Right Click":
		mouseInput = "Left Click"


func _on_mouse_input_timer_timeout() -> void:
	dashCooldown.start()
	dashCombo = 1


func dragSelf():
	find_child("Sprite3D2").position = Vector3(getGrabPosition().x,find_child("Sprite3D2").position.y,getGrabPosition().y)


func getGrabPosition():
	var directionVector: Vector2 = Vector2(getMouseWorldPosition().x,getMouseWorldPosition().z) - Vector2(position.x,position.z)
	var distance = directionVector.length()
	if distance > 2.5:
		directionVector = directionVector.normalized() * 2.5
		return Vector2(directionVector)
	else:
		return Vector2(getMouseWorldPosition().x-position.x,getMouseWorldPosition().z-position.z)


func getMouseVelocity(delta):
	var dashlength: Vector2 = abs(Vector2(getMouseWorldPosition().x,getMouseWorldPosition().z) - Vector2(position.x,position.z))
	dashlength = abs(getGrabPosition())
	mouseVelocity = -(Vector2(getMouseWorldPosition().x,getMouseWorldPosition().z) - Vector2(oldMousePosition.x,oldMousePosition.z)).normalized()
	velocity.x = mouseVelocity.x * SPEED * dashCombo * dashlength.x
	velocity.z = mouseVelocity.y * SPEED * dashCombo * dashlength.y


func attack(): #put tween position as a parameter
	#might want to tween to the right position to attack and fit the animation.
	frozen = true
	sprite_3d.play('Attack')
	await sprite_3d.animation_finished
	sprite_3d.play('idle')
	frozen = false

#tween to position and freeze function?
