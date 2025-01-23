extends CharacterBody3D

@onready var feet: Node3D = $Feet
@onready var hands: Node3D = $Hands
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var movement_target = get_node("../Player")
@onready var stun_timer: Timer = $StunTimer

enum States {stunned, feet_attacking, hand_attacking, walking}
const MOVEMENT_SPEED: float = 2.0
var state = States.walking


func _ready():
	feet.attack_target = movement_target
	navigation_actor_setup.call_deferred()
	


func _physics_process(delta):
	if stun_timer.time_left > 0:
		state = States.stunned
	
	match state:
		States.walking:
			navigation_physics_procces()
			feet.attacking = false
			hands.attacking = false
		States.stunned:
			velocity = Vector3(0, 0, 0)
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
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Adjust nav actor's speed and route layout
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
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
# Detecting if player is in range for foot attacks
func _on_feet_proximity_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		state = States.feet_attacking


func _on_feet_proximity_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		state = States.hand_attacking
		

# Detecting if player is in range for hand attacks
func _on_hand_proximity_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		state = States.hand_attacking


func _on_hand_proximity_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		state = States.walking

# Detecting traps
func _on_foot_area_entered(area: Area3D) -> void:
	stun_timer.start()


func _on_stun_timer_timeout() -> void:
	state = States.walking
