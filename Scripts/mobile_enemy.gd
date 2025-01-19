extends CharacterBody3D

## pretty much all of this is the default code that godot
## gives for their navigation tutorial

var movement_speed: float = 2.0

@onready var movement_target = get_node("../Player")
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	actor_setup.call_deferred()


func actor_setup():
	await get_tree().physics_frame
	set_movement_target(movement_target.position)

func set_movement_target(_movement_target: Vector3):
	navigation_agent.set_target_position(_movement_target)


func _physics_process(delta):
	look_at(movement_target.position)
	# set new target position to player position each frame
	set_movement_target(movement_target.position)
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()
