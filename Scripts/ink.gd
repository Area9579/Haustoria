extends Node3D

@onready var decal: Decal = $Decal
@onready var ray_cast_3d: RayCast3D = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector3.ONE * randf_range(.1,.5)
	
	global_position = get_parent().global_position

func _process(delta: float) -> void:
	if ray_cast_3d.is_colliding():
		decal.position = ray_cast_3d.get_collision_point()
	
	decal.modulate.a -= delta * .3
	if decal.modulate.a <= .01:
		queue_free()
