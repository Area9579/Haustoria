extends CharacterBody3D

@onready var dashCooldown: Timer = $CooldownTimer
@onready var ui: Control = $UI
@onready var slime = preload("res://Scenes/ink.tscn")
@onready var sprite_3d: AnimatedSprite3D = $Sprite3D
@onready var player_camera: Camera3D = $PlayerCamera

var frozen = false

const SPEED = 1.1 #used for launching speed
const JUMP_VELOCITY = 4.5
const BOUNCE_MULTIPLIER = 5.0 #how much the player bounces off surfaces
const VELOCITY_MULTIPLIER = 15.0 #used to calculate how snappy the drag is

var oldMousePosition: Vector3
var oldGrabPosition: Vector2
var oldPlayerPosition: Vector3
var launchVelocity: Vector3

var state_grabbed = false
var attacking = false
var stunned = false
var cursor_open = load("res://Assets/CursorWOW_optimized.png"	)
var cursor_closed = load("res://Assets/cursor_closed.png")
func _physics_process(delta: float) -> void:
	if !attacking:
		$AnchorPoint2/Marker3D.global_position = global_position
		$Sprite3D.position = Vector3(0,.123,0)
	else:
		$Sprite3D.position = Vector3(randf_range(-.1,.1),.123,randf_range(-.1,.1))
	$Limbs.rotation.y = getDirectionVector().angle()
	
	if frozen: return #dont move or anything while in the attack animation
	spawn_slime()
	
	if Input.is_action_just_pressed("Left Click") and !stunned:
		#all of these variables need to be set before the drag function starts so it has the correct reference
		oldGrabPosition = getGrabPosition()
		oldMousePosition = getMouseWorldPosition()
		oldPlayerPosition = position
		state_grabbed = true
		$Grip.spam_play()
	elif is_on_floor(): #decelerate constantly after initially pressing left click
		decelerate(delta)
		
		
	if state_grabbed: #as you hold the mouse button drag the player
		launch()
		dragSelf(delta)
		global_position.y = lerp(global_position.y, .1, delta * 6)
		$AnchorPoint1.global_position = oldPlayerPosition
		
		Input.set_custom_mouse_cursor(cursor_closed)
	else:
		velocity += get_gravity() * delta * 4
		Input.set_custom_mouse_cursor(cursor_open)
		$AnchorPoint1.global_position = lerp($AnchorPoint1.global_position, global_position, delta * 12)
		
	if Input.is_action_just_released("Left Click") and dashCooldown.is_stopped():
		velocity = launchVelocity
		dashCooldown.start()
		state_grabbed = false
		$Throw.spam_play()
		
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
	velocity.z = lerp(velocity.z,0.0,5 * delta)


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
	velocity.z = lerp(velocity.z,targetPoint.y * VELOCITY_MULTIPLIER * vectorDistance, delta * VELOCITY_MULTIPLIER)


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


func attack(attack_origin): #put tween position as a parameter
	#might want to tween to the right position to attack and fit the animation.
	attacking = true
	var tween = get_tree().create_tween()
	tween.tween_property($AnchorPoint2/Marker3D, 'global_position', attack_origin, 2.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
	frozen = true
	var tweenc = get_tree().create_tween()
	tweenc.tween_property(player_camera, 'fov', 25.0, .5).set_trans(Tween.TRANS_CUBIC)
	sprite_3d.play('Attack')
	ui.attack_boss()
	$CPUParticles3D.emitting = true
	await sprite_3d.animation_finished
	$CPUParticles3D.emitting = false
	var tween2 = get_tree().create_tween()
	tween2.tween_property(player_camera, 'fov', 53.7, .8).set_trans(Tween.TRANS_CUBIC)
	attacking = false
	sprite_3d.play('Idle')
	frozen = false
	
func killed():
	stunned = true

func collect_item(poison_pickedup):
	ui.attack_multiplier += .5
	var text_new = RichTextLabel.new()
	text_new.text = poison_pickedup
	text_new.size_flags_vertical = Control.SIZE_EXPAND_FILL
	$UI/Control/VBoxContainer.add_child(text_new)
	$UI/Control/AnimationPlayer.play("collect_new")


func slow_down(delta):
	velocity = lerp(velocity, Vector3.ZERO, .95)


var can_slime = false
func spawn_slime():
	if can_slime:
		var slime_instance = slime.instantiate()
		add_child(slime_instance)

func _on_slime_cooldown_timeout() -> void:
	can_slime = true

func hurt(direction : Vector3, amount):
	stunned = true
	$Stun.start()
	velocity += direction
	Director.shake_cam(Vector2(direction.normalized().x, direction.normalized().z) * .05)
	ui.take_damage(amount)
	state_grabbed = false
	dashCooldown.stop()

func change_co(current_color):
	ui.change_co(current_color)
	


func _on_stun_timeout() -> void:
	stunned = false
