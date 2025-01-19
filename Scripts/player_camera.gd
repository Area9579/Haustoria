extends Camera3D

var defaultZPos: float


func _ready() -> void:
	defaultZPos = position.z #gets the z position of the camera to use as a base to adjust off of


func  _input(event: InputEvent) -> void:
	var mousePos = get_viewport().get_mouse_position()
	if event is InputEventMouseMotion: #calls the function for adjusting the camera location whenever you move the mouse
		adjustCamera(0.1,0.05,mousePos)

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
		newPosX = ((mousePos.x-centerX)/divFactorX)*2
		position.x = newPosX
	if mousePos.y != centerY:
		newPosZ = ((mousePos.y-centerY)/divFactorY)*2
		position.z = newPosZ + defaultZPos
		
