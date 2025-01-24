extends CharacterBody3D

@onready var dashCooldown: Timer = $CooldownTimer
@onready var mouseCooldown: Timer = $MouseInputTimer
@onready var ui: Control = $UI
@onready var slime = preload("res://Scenes/ink.tscn")
@onready var sprite_3d: AnimatedSprite3D = $Sprite3D

var clickPositionx
var clickPositionz
var frozen = true

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const BOUNCE_MULTIPLIER = 3.0

var mouseInput: String
var dashCombo = 1
var accel = 1.0

func _ready() -> void:
	mouseInput = "Left Click"

var cutscene = false
var grab_syring = false
@onready var cutscene_point: Marker3D = $"../MainAnimation/DecoyBoss/Hand/Cutscene_Point"
func set_cutscene_true(): cutscene = true
func grab_syringe():
	grab_syring = true
func _physics_process(delta: float) -> void:
	$Limbs.rotation.y = getDirectionVector().angle()
	if frozen: return #dont move or anything while in the attack animation
	spawn_sime()
	#below code for jumping
	if not is_on_floor():
		velocity += get_gravity() * delta
	if grab_syring:
		$"../MainAnimation/DecoyBoss/Hand2/Syringe".global_position = global_position
#region Continuous movement
	if Input.is_action_pressed("Left Click") and cutscene != true:
		var direction = get_viewport().get_mouse_position()
		velocity += Vector3(1,0,0)
#endregion
	if cutscene:
		velocity += (cutscene_point.global_position - global_position) * delta * 20
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
	var rayQuery = PhysicsRayQueryParameters3D.create(rayOrigin,rayEnd)
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


func getDirectionVector():
	var mousePos = Vector2(getMouseWorldPosition().x,getMouseWorldPosition().z)
	var playerVector2 = Vector2(position.x,position.z)
	var degreeAngle = -rad_to_deg(playerVector2.angle_to_point(mousePos))
	var directionVector = Vector2(cos(deg_to_rad(degreeAngle)),sin(deg_to_rad(degreeAngle)))
	return directionVector


func slideTowardsMouse(delta):
	var directionVector: Vector2 = getDirectionVector()
	#this code is for continuous
#region continuous
	accel = lerp(accel,SPEED,10 * delta)
	velocity.x = lerp(velocity.x,directionVector.x * accel, 3 * delta)
	velocity.z = lerp(velocity.z,-directionVector.y * accel, 3 * delta)
#endregion
	
#region impulse
	#velocity.x += directionVector.x * SPEED * dashCombo
	#velocity.z += -directionVector.y * SPEED * dashCombo
#endregion


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

func attack(): #put tween position as a parameter
	#might want to tween to the right position to attack and fit the animation.
	
	frozen = true
	sprite_3d.play('Attack')
	ui.attack_boss()
	await sprite_3d.animation_finished
	sprite_3d.play('Idle')
	frozen = false

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
