extends Node3D

@onready var attack_timer: Timer = $AttackTimer # increase to alter delay between stomp attacks
@onready var left: RigidBody3D = $Left # left foot
@onready var right: RigidBody3D = $Right # right foot
@onready var left_animation_player: AnimationPlayer = $Left/AnimationPlayer
@onready var right_animation_player: AnimationPlayer = $Right/AnimationPlayer
@onready var boss: CharacterBody3D = get_parent()
@onready var attack_target # set by "boss" parent node script
@onready var attacking_foot: RigidBody3D = right # stores which foot should be attacking
@onready var resting_foot: RigidBody3D = left # stores which foot isn't attacking
var stunned = false
var attacking_foot_in_bounds = true
var resting_foot_in_bounds = true


func _ready() -> void:
	# initialize feet position in boss position since they're set to top layer
	left.position = boss.position - Vector3(4, 0, 0)
	right.position = boss.position - Vector3(-4, 0, 0)
	# begin animation loop
	right_animation_player.current_animation = "right_stomp"

func _process(delta: float) -> void:
	if stunned: return
	# feet should be stopped while on "cooldown"
	if attack_timer.time_left == 0:
		# keep feet within range of the boss while also following player when within range
		if attacking_foot_in_bounds:
			attacking_foot.position.x = lerp(attacking_foot.position.x, attack_target.position.x, 0.015)
			attacking_foot.position.z = lerp(attacking_foot.position.z, attack_target.position.z, 0.015)
		# make sure non-attacking foot isn't trailing behind and getting lost
		if not resting_foot_in_bounds:
			resting_foot.position.x = lerp(resting_foot.position.x, resting_foot.position.x, 0.015)
			resting_foot.position.z = lerp(resting_foot.position.z, resting_foot.position.z, 0.015)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# create a delay before the start of the next attack
	var direction_to_player = Vector2(global_position.x, global_position.z) - Vector2(attack_target.global_position.x, attack_target.global_position.z)
	
	Director.shake_cam(Vector2(direction_to_player.normalized().x, direction_to_player.normalized().y) * .1)
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	if stunned: return
	attack_timer.stop()
	# switch which foot is attacking and set correct animation
	if attacking_foot == right:
		left_animation_player.current_animation = "left_stomp"
		attacking_foot = left
		resting_foot = right
	elif attacking_foot == left:
		right_animation_player.current_animation = "right_stomp"
		attacking_foot = right
		resting_foot = left

func reset():
	attack_timer.stop()
	if attacking_foot == right:
		left_animation_player.play('left_stomp')
		attacking_foot = left
		resting_foot = right
	elif attacking_foot == left:
		right_animation_player.play('right_stomp')
		attacking_foot = right
		resting_foot = left

# detect if the feet are getting too far from the boss
func _on_feet_bounds_body_exited(body: Node3D) -> void:
	if body == attacking_foot:
		attacking_foot_in_bounds = false
	elif body == resting_foot:
		resting_foot_in_bounds = false

# detect once the feet get close to the boss again
func _on_feet_bounds_body_entered(body: Node3D) -> void:
	if body == attacking_foot:
		attacking_foot_in_bounds = true
	elif body == resting_foot:
		resting_foot_in_bounds = true

func stun():
	stunned = true
	left_animation_player.pause()
	right_animation_player.pause()
