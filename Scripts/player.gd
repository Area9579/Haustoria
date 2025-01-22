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
var accel = 1.0


func _ready() -> void:
	mouseInput = "Left Click"


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
	if Input.is_action_just_pressed(mouseInput):
		if dashCooldown.is_stopped() and (mouseCooldown.is_stopped() or mouseCooldown.time_left <= 0.15):
			mouseCooldown.start()
			slideTowardsMouse(delta)
			changeMouseInput(mouseInput)
			if dashCombo < 1.6:
				dashCombo += 0.2
	else:
		decelerate(delta)
	move_and_slide()
	rebound()


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


func slideTowardsMouse(delta):
	var directionVector: Vector2 = getDirectionVector()
	#this code is for continuous
	#accel = lerp(accel,3.0,10 * delta)
	#velocity.x = lerp(velocity.x,directionVector.x * SPEED * accel,0.3)
	#velocity.z = lerp(velocity.z,-directionVector.y * SPEED * accel,0.3)
	
	#this code is for impulse
	velocity.x = directionVector.x * SPEED * dashCombo
	velocity.z = -directionVector.y * SPEED * dashCombo


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
func _physics_process(delta: float) -> void:
	if frozen: return #dont move or anything while in the attack animation
	print(frozen)
	#below code for jumping
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	move_and_slide()
	
func attack(): #put tween position as a parameter
	#might want to tween to the right position to attack and fit the animation.
	frozen = true
	sprite_3d.play('Attack')
	await sprite_3d.animation_finished
	sprite_3d.play('idle')
	frozen = false

#tween to position and freeze function?
