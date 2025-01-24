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
const VELOCITY_MULTIPLIER = 30.0

var oldMousePosition: Vector3
var oldGrabPosition: Vector2
var oldPlayerPosition: Vector3
var oldMouseVelocity: Vector3



func _physics_process(delta: float) -> void:
	
	if frozen: return #dont move or anything while in the attack animation
	#below code for jumping
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	if Input.is_action_just_pressed("Left Click"):
		#all of these variables need to be set before the drag function starts so it has the correct reference
		oldGrabPosition = getGrabPosition()
		oldMousePosition = getMouseWorldPosition()
		oldPlayerPosition = position
		if dashCooldown.is_stopped(): #the dash cooldown still needs to be reimplemented
			#this is a visual for debugging (we'll remove this later)
			find_child("Sprite3D2").position = Vector3(getGrabPosition().x,find_child("Sprite3D2").position.y,getGrabPosition().y)
			#mouseCooldown.start()
	else: #decelerate constantly when not actively moving using left click
		decelerate(delta)
	if Input.is_action_pressed("Left Click"): #
		oldMouseVelocity = getMouseWorldPosition()
		dragSelf()
	
	#move using velocity and check to bounce off surfaces
	move_and_slide()
	rebound()


func raycastOnMousePosition(): #function that greates a raycast from the camera to a space in the 3D world based on the mouse position
	var cam = get_viewport().get_camera_3d()
	var mousePos = get_viewport().get_mouse_position()
	var stateInSpace = get_world_3d().direct_space_state
	
	var rayOrigin = cam.project_ray_origin(mousePos)
	var rayEnd = rayOrigin + cam.project_ray_normal(mousePos) * 100
	var rayQuery = PhysicsRayQueryParameters3D.create(rayOrigin,rayEnd,128) #this last parameter determines which collision layer to hit
	rayQuery.collide_with_bodies = true
	
	var resultingRay = stateInSpace.intersect_ray(rayQuery)
	return(resultingRay)


func getMouseWorldPosition(): #gets a vector3 based on the camera raycast
	var raycastResult = raycastOnMousePosition()
	if raycastResult:
		return raycastResult.position
	return position


func getDirectionVector(): #this gets a vector2 in the direction of the mouse from the player position
	var mousePos = Vector2(getMouseWorldPosition().x,getMouseWorldPosition().z)
	var playerVector2 = Vector2(position.x,position.z)
	var degreeAngle = -rad_to_deg(playerVector2.angle_to_point(mousePos))
	var directionVector = Vector2(cos(deg_to_rad(degreeAngle)),sin(deg_to_rad(degreeAngle)))
	return directionVector


func decelerate(delta): #this function changes the velocity to always approach zero
	velocity.x = lerp(velocity.x,0.0,5 * delta)
	velocity.z = lerp(velocity.z,0.0,5 * delta)


func rebound(): #this function determines how much force to bounce off surfaces by using BOUNCE_MULTIPLIER
	if get_wall_normal():
		velocity.x += get_wall_normal().x * BOUNCE_MULTIPLIER
		velocity.z += get_wall_normal().z * BOUNCE_MULTIPLIER


func _on_mouse_input_timer_timeout() -> void: #need to reinplement this
	dashCooldown.start()


func dragSelf(): #drags the player around the grabbed point and then tracks the mouse velocity until released
	find_child("Sprite3D2").position = Vector3(getGrabPosition().x,find_child("Sprite3D2").position.y,getGrabPosition().y)
	position.x = oldPlayerPosition.x + oldGrabPosition.x - getGrabPosition().x
	position.z = oldPlayerPosition.z + oldGrabPosition.y - getGrabPosition().y
	
	var mouseVelocity = (oldMouseVelocity - getMouseWorldPosition())
	velocity = -mouseVelocity * VELOCITY_MULTIPLIER


func getGrabPosition(): #gets the position of the grabbed point when you click within a circle with a given radius
	var directionVector: Vector2 = Vector2(getMouseWorldPosition().x,getMouseWorldPosition().z) - Vector2(position.x,position.z)
	var distance = directionVector.length()
	var radius: float = 2.5
	if distance > radius:
		directionVector = directionVector.normalized() * radius
		return Vector2(directionVector)
	else:
		return Vector2(getMouseWorldPosition().x-position.x,getMouseWorldPosition().z-position.z)


func attack(): #put tween position as a parameter
	#might want to tween to the right position to attack and fit the animation.
	frozen = true
	sprite_3d.play('Attack')
	await sprite_3d.animation_finished
	sprite_3d.play('idle')
	frozen = false

#tween to position and freeze function?
