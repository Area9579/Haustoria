extends Camera3D

var defaultZPos: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	defaultZPos = position.z


func  _input(event: InputEvent) -> void:
	var mousePos = get_viewport().get_mouse_position()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pass
	if event is InputEventMouseMotion:
		adjustCamera(0.1,0.05,mousePos)


func adjustCamera(limitX,limitY,mousePos):
	var centerX = get_viewport().size.x/2
	var centerY = get_viewport().size.y/2
	var divFactorX: float = ((centerX*2)/limitX)
	var divFactorY: float = ((centerY*2)/limitY)
	var newPosX: float
	var newPosZ: float
	
	if mousePos.x != centerX:
		newPosX = ((mousePos.x-centerX)/divFactorX)*2
		position.x = newPosX
	if mousePos.y != centerY:
		newPosZ = ((mousePos.y-centerY)/divFactorY)*2
		position.z = newPosZ + defaultZPos
		
