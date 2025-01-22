extends CharacterBody3D

@onready var feet: Node3D = $Feet
@onready var hands: Node3D = $Hands
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var movement_target = get_node("../Player")

enum States {stunned, feet_attacking, hand_attacking, walking}
const MOVEMENT_SPEED: float = 2.0
var state = States.walking


func _ready():
	navigation_actor_setup.call_deferred()


func _physics_process(delta):
	match state:
		States.walking:
			navigation_physics_procces()
			feet.attacking = false
			hands.attacking = false
		States.stunned:
			feet.attacking = false
			hands.attacking = false
		States.feet_attacking:
			navigation_physics_procces()
			feet.attacking = true
			hands.attacking = true
		States.hand_attacking:
			navigation_physics_procces()
			feet.attacking = false
			hands.attacking = true
			
	move_and_slide()



## Navigation-related functions
func navigation_actor_setup():
	# Adjust nav actor's speed and route layout
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Now that the navigation map is no longer empty, set the movement target.
	navigation_set_movement_target(movement_target.position)

func navigation_set_movement_target(_movement_target: Vector3):
	navigation_agent.set_target_position(_movement_target)

func navigation_physics_procces():
	# set new target position to player position each frame
	navigation_set_movement_target(movement_target.position)
	# 
	if navigation_agent.is_navigation_finished():
		return

	var current_nav_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	# Change current velocity
	velocity = current_nav_agent_position.direction_to(next_path_position) * MOVEMENT_SPEED


## Signals

func _on_feet_proximity_body_entered(body: Node3D) -> void:
	state = States.feet_attacking


func _on_feet_proximity_body_exited(body: Node3D) -> void:
	state = States.hand_attacking


func _on_hand_proximity_body_entered(body: Node3D) -> void:
	state = States.hand_attacking


func _on_hand_proximity_body_exited(body: Node3D) -> void:
	state = States.walking
