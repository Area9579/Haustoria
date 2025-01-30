extends Camera3D

var defaultZPos: float


func _ready() -> void:
	defaultZPos = position.z #gets the z position of the camera to use as a base to adjust off of
	Director.shake.connect(add_trauma)

func  _input(event: InputEvent) -> void:
	var mousePos = get_viewport().get_mouse_position()
#	if event is InputEventMouseMotion: #calls the function for adjusting the camera location whenever you move the mouse
	#	adjustCamera(0.1,0.05,mousePos)

#this function moves the camera ahead of the player by the limits when the mouse position gets towards the viewport borders
func adjustCamera(limitX,limitY,mousePos): 
	#these two variables get the center position of the viewport
	var centerX = get_viewport().size.x/2
	var centerY = get_viewport().size.y/2
	#these two variables get a float to divide the viewport position by
	var divFactorX: float = ((centerX*2)/limitX)
	var divFactorY: float = ((centerY*2)/limitY)
	var newPosX: float
	var newPosZ: float
	#both of these just do some math so that the center of the viewport is equal to 0 and the edges are equal to the limit, then set the position there
	if mousePos.x != centerX:
		newPosX = ((mousePos.x-centerX)/divFactorX)*2 + get_parent().global_position.x
		position.x = newPosX
		
	if mousePos.y != centerY:
		newPosZ = ((mousePos.y-centerY)/divFactorY)*2  + get_parent().global_position.z
		position.z = newPosZ + defaultZPos
	position.y = 7.277


var decay := .8 #How quickly shaking will stop [0,1].
var max_offset := Vector2(480*.01,272*.01) #this reduces how much your camera can shake
var max_roll = 0.01 #Maximum rotation in radians (use sparingly).
@onready var noise = preload("res://Assets/cam_noise.tres")

var noise_y = 0 #Value used to move through the noise
var trauma := 0.0 #Current shake strength
var trauma_pwr := 2 #Trauma exponent. Use [2,3]

var tension = 2 #this simulates the camera going back to its orignal position like an elastic spring
var damp = .1 #this changes how fast your camera resets to its original state
const target_pos = Vector2.ZERO # where to reset your position back to, its a variable that never changes
var shake_pos = Vector2.ZERO #this gets changed to simulate an offset 
var velocity = Vector2.ZERO #changes how fast your offset changes

#black out area you were just in thats part of the gameplay
func transition(point : Vector2): #ig just position
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, 'position', point + Vector2(160, 90), .5)

func _process(delta):
	var mousePos = get_viewport().get_mouse_position()
	adjustCamera(0.1,0.05,mousePos)
	#global_position = (get_parent().global_position * Vector3(1,0,1)) + Vector3(0,7.277, 4.245)
	if trauma: 
		trauma = max(trauma - decay * delta, 0)
		shake()
	var displacement = (target_pos - shake_pos) * delta    #distance to center
	velocity += (displacement * tension) - (velocity * damp)
	shake_pos += velocity
	h_offset = shake_pos.x #this is the property that moves the camera
	v_offset = shake_pos.y

# shake the screen
func attacked(randValue):
	add_trauma(1, Vector2.RIGHT)

func add_trauma(amount : float, direction : Vector2): #this function starts everything
	trauma = min(trauma + amount, 1.0) #for the regular camera shake motion
	velocity += direction #for the spring camera motion
	#noise.seed = randi()

func shake(): #you can kinda ignore this
	var amt = pow(trauma, trauma_pwr)
	#print(noise.get_noise_2d(noise.seed*2,noise_y))
	noise_y += 1
	rotation.z = max_roll * amt * noise.get_noise_2d(noise.seed,noise_y)
	h_offset = max_offset.x * amt * noise.get_noise_2d(noise.seed*2,noise_y)
	v_offset = max_offset.y * amt * noise.get_noise_2d(noise.seed*3,noise_y)

func freeze_frame(time : float, speed : float):
	Engine.time_scale = speed
	await get_tree().create_timer(time, true, false, true).timeout
	Engine.time_scale = 1

func change_y(y_to_change):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, 'position:y', y_to_change, 1)
