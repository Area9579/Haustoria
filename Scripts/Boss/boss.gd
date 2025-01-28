extends CharacterBody3D

# "feet" and "hands" refers to the parent node to the actual physical feet and hands
@onready var feet: Node3D = $Feet
@onready var hand: Node3D = $Hand
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var movement_target = get_node("../Player")
@onready var stun_timer: Timer = $StunTimer

const MOVEMENT_SPEED: float = 2.0

enum States {stunned, hand_attacking, walking}
var state = States.walking


func _ready():
	
	feet.attack_target = movement_target # pass through target node to child
	hand.attack_target = movement_target # pass through target node to child
	navigation_actor_setup.call_deferred() # call this function at end of other _ready() functions
	


func _physics_process(delta):
	
	# stunned state while timer running
	if stun_timer.time_left > 0:
		state = States.stunned
	if $"Hand Proximity".has_overlapping_bodies():
		for i in $"Hand Proximity".get_overlapping_bodies():
			if i.is_in_group('player'):
				state = States.hand_attacking
	
	# simple state machine just to keep things a little cleaner
	match state:
		States.walking:
			navigation_physics_procces()
			hand.attacking = false
			feet.stunned = false
		States.stunned:
			
			velocity = Vector3(0, 0, 0)
			hand.attacking = false
			feet.stunned = true
		States.hand_attacking:
			navigation_physics_procces()
			hand.attacking = true
			
			
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
	
	if navigation_agent.is_navigation_finished():
		return # stop function here if target is reached

	var current_nav_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	# Change current velocity
	velocity = current_nav_agent_position.direction_to(next_path_position) * MOVEMENT_SPEED
	


## Signals (a lot of this is unused)
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

func stun():
	stun_timer.start()

func _on_stun_timer_timeout() -> void:
	state = States.walking
	hand.attacking = false
	feet.stunned = false
	hand.reset()
	feet.reset()

# Detecting incoming damage from player from any child hitbox
func _on_hitbox_body_entered(body: Node3D) -> void: #feet
	if body.has_method('hurt'):
		body.hurt(Vector3(randf_range(-7,7),0,randf_range(-7,7)) * 2, 10)

func _on_hand_attack_body_entered(body: Node3D) -> void:
	if body.has_method('hurt'):
		body.hurt($Hand.velocity + Vector3(randf_range(-.5,.5),0,randf_range(-.5,.5)) * 4, 10)
