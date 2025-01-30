extends Node3D
var sin = 0
@onready var org_pos = position.y
@export var scale_move = .5
func _process(delta: float) -> void:
	sin += delta
	position.y = (org_pos + sin(sin)) * scale_move + .5
