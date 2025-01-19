extends Camera3D

var defaultZPos: float

func _ready() -> void:
	defaultZPos = position.z #sets this variable as a base of what the z position for the camera was


func  _input(event: InputEvent) -> void:
	var mousePos = get_viewport().get_mouse_position()
	if event is InputEventMouseMotion: #adjusts the camera whenever you move the mouse
		adjustCamera(0.5,0.15,mousePos)


func adjustCamera(limitX,limitY,mousePos):
	#both of these variables get the center of the screen for both the x and y axis in 2D
	var centerX = get_viewport().size.x/2
	var centerY = get_viewport().size.y/2
	#both of these variables get a float based on the viewport size to divide the inputs by
	#the limits are how far away the camera is allowed to go at the maximum
	var divFactorX: float = ((centerX*2)/limitX)
	var divFactorY: float = ((centerY*2)/limitY)
	var newPosX: float
	var newPosZ: float
	#the below code just does some basic math to move the camera further based on how far away your mouse is to the border of the screen
	if mousePos.x > centerX:
		newPosX = ((mousePos.x-centerX)/divFactorX)*2
		position.x = newPosX
	elif mousePos.x < centerX:
		newPosX = ((mousePos.x-centerX)/divFactorX)*2
		position.x = newPosX
	if mousePos.y > centerY:
		newPosZ = ((mousePos.y-centerY)/divFactorY)*2
		position.z = newPosZ + defaultZPos
	elif mousePos.y < centerY:
		newPosZ = ((mousePos.y-centerY)/divFactorY)*2
		position.z = newPosZ + defaultZPos
