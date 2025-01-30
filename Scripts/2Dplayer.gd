extends CharacterBody3D

@onready var dashCooldown: Timer = $CooldownTimer
@onready var mouseCooldown: Timer = $MouseInputTimer
@onready var ui: Control = $UI
@onready var slime = preload("res://Scenes/ink.tscn")
@onready var sprite_3d: AnimatedSprite3D = $Sprite3D

var clickPositionx
var clickPositionz
var frozen = true
var mouseInput: String
var dashCombo = 1
var accel = 1.0

func _ready() -> void:
	mouseInput = "Left Click"

var cutscene = false
@onready var cutscene_point: Marker3D = $"../MainAnimation/DecoyBoss/Hand/Cutscene_Point"
func set_cutscene_true(): 
	cutscene = true
	var tween = get_tree().create_tween()
	
const SPEED = 1.2 #used for launching speed
const JUMP_VELOCITY = 4.5
const BOUNCE_MULTIPLIER = 5.0 #how much the player bounces off surfaces
const VELOCITY_MULTIPLIER = 15.0 #used to calculate how snappy the drag is

var oldMousePosition: Vector3
var oldGrabPosition: Vector2
var oldPlayerPosition: Vector3
var launchVelocity: Vector3

var state_grabbed = false
var syringe_hold = false

func grab_syringe():
	syringe_hold = !syringe_hold
	
func _physics_process(delta: float) -> void:
	print(frozen)
	$Limbs.rotation.y = getDirectionVector().angle()
	spawn_sime()
	#below code for jumping
	if not is_on_floor():
		velocity += get_gravity() * delta
	if !syringe_hold:
		$SyringeHand.global_position = global_position
#region Continuous movement
	if Input.is_action_just_pressed("Left Click") and !cutscene and !frozen:
		#all of these variables need to be set before the drag function starts so it has the correct reference
		oldGrabPosition = getGrabPosition()
		oldMousePosition = getMouseWorldPosition()
		oldPlayerPosition = position
		state_grabbed = true
	elif is_on_floor() and !frozen: #decelerate constantly after initially pressing left click
		decelerate(delta)

	if state_grabbed: #as you hold the mouse button drag the player
		launch()
		dragSelf(delta)
		global_position.y = lerp(global_position.y, 1.0, delta * 6)
		$Marker3D.global_position = oldPlayerPosition
	else:
		velocity += get_gravity() * delta * 4
		$Marker3D.global_position = lerp($Marker3D.global_position, global_position, delta * 12)
		
	if Input.is_action_just_released("Left Click") and !frozen and !cutscene:
		velocity = launchVelocity
		dashCooldown.start()
		state_grabbed = false
	
#endregion
	if cutscene:
		state_grabbed = false
		velocity += (cutscene_point.global_position - global_position) * delta * 50
		velocity *= .95
	else:
		velocity = lerp(velocity, Vector3.ZERO, delta)
	move_and_slide()

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
		if raycastResult.position.x > position.x: sprite_3d.flip_h = false
		else: sprite_3d.flip_h = true
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
	velocity.z = 0


func rebound(): #this function determines how much force to bounce off surfaces by using BOUNCE_MULTIPLIER
	if get_wall_normal():
		velocity.x += get_wall_normal().x * BOUNCE_MULTIPLIER
		velocity.z += get_wall_normal().z * BOUNCE_MULTIPLIER


func dragSelf(delta): #drags the player around the grabbed point by constantly setting velocity towards where the player should be
	var pointx = oldPlayerPosition.x + oldGrabPosition.x - getGrabPosition().x
	var pointz = oldPlayerPosition.z + oldGrabPosition.y - getGrabPosition().y
	var vectorDistance: float = (Vector2(pointx,pointz)-Vector2(position.x,position.z)).length()/2
	var targetPoint = -rad_to_deg(Vector2(pointx,pointz).angle_to_point(Vector2(position.x,position.z)))
	targetPoint = Vector2(cos(deg_to_rad(targetPoint)),sin(deg_to_rad(targetPoint)))
	velocity.x = lerp(velocity.x, -targetPoint.x * VELOCITY_MULTIPLIER * vectorDistance, delta * VELOCITY_MULTIPLIER)
	velocity.z = 0


func getGrabPosition(): #gets the position of the grabbed point when you click within a circle with a given radius
	var directionVector: Vector2 = Vector2(getMouseWorldPosition().x,getMouseWorldPosition().z) - Vector2(position.x,position.z)
	var distance = directionVector.length()
	var radius: float = 2.5
	if distance > radius:
		directionVector = directionVector.normalized() * radius
		return Vector2(directionVector)
	else:
		return Vector2(getMouseWorldPosition().x-position.x,getMouseWorldPosition().z-position.z)


func launch(): #gets the velocity of the mouse to launch the player in
	launchVelocity = velocity * SPEED
	

func collect_item(poison_pickedup):
	ui.attack_multiplier += 1


func slow_down(delta):
	velocity = lerp(velocity, Vector3.ZERO, delta * 4)


var can_slime = false
func spawn_sime():
	if can_slime:
		var slime_instance = slime.instantiate()
		add_child(slime_instance)

func _on_slime_cooldown_timeout() -> void:
	can_slime = true
