extends CharacterBody3D


@onready var sprite_3d: AnimatedSprite3D = $Sprite3D

var clickPositionx
var clickPositionz
var frozen = false

const SPEED = 5.0 #where is this being used?
const JUMP_VELOCITY = 4.5


func _ready() -> void:
	moveTowardsMousePosition() #initiates the mouse tracking loop


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


func moveTowardsMousePosition(): #moves the player towards the position of the mouse
	await awaitTimer()
	if (abs(position.x-getMouseWorldPosition().x) > 1.2):
		position.x = move_toward(position.x,getMouseWorldPosition().x,0.06)
	if (abs(position.z-getMouseWorldPosition().z) > 1.2):
		position.z = move_toward(position.z,getMouseWorldPosition().z,0.06)


func awaitTimer(): #this timer determens how frequently to call the player movement function
	await get_tree().create_timer(0.004).timeout
	moveTowardsMousePosition()
	

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
