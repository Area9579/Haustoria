extends Node3D

# attacking state and target set by "boss" script
@export var attacking: bool = false # true if player is within range
@onready var attack_target
@onready var left_animation_player: AnimationPlayer = $Left/AnimationPlayer
@onready var right_animation_player: AnimationPlayer = $Right/AnimationPlayer
@onready var left: RigidBody3D = $Left
@onready var right: RigidBody3D = $Right
@onready var attack_timer: Timer = $AttackTimer
@onready var attacking_foot: RigidBody3D = right # stores which foot should be attacking
@onready var resting_foot: RigidBody3D = left
@onready var boss: CharacterBody3D = get_parent()


func _process(delta: float) -> void:
	# starts/stops attacking process
	if attacking and attack_timer.is_stopped():
		attack_timer.start()
		# prompts attack when player initially enters area, boss would have
		# a small delay in attack when player initially gets close otherwise
		_on_attack_timeout()
	# stop attacks if player is out of range
	if not attacking and attack_timer.is_stopped() == false:
		attack_timer.stop()
		left_animation_player.stop()
		right_animation_player.stop()
	
	# moves currently attacking foot towards player location
	if attacking:
		left.top_level = true
		right.top_level = true
		# Move attacking foot toward player as it lifts
		var attack_target_local = (attack_target.position)
		attacking_foot.position.x = lerp(attacking_foot.position.x, attack_target_local.x, 0.015)
		attacking_foot.position.z = lerp(attacking_foot.position.z, attack_target_local.z, 0.015)
	else:
		left.top_level = false
		right.top_level = false
		left.position = lerp(left.position, Vector3(4, 0, 0), 0.05)
		right.position = lerp(right.position, Vector3(-4, 0, 0), 0.05)
	


func _on_attack_timeout() -> void:
	# prompts attack from correct foot and switches animation
	if attacking_foot == right:
		left_animation_player.current_animation = "left_stomp"
		right_animation_player.stop()
		attacking_foot = left
		resting_foot = right
	elif attacking_foot == left:
		right_animation_player.current_animation = "right_stomp"
		left_animation_player.stop()
		attacking_foot = right
		resting_foot = left


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	return
	if attacking_foot == right:
		left_animation_player.current_animation = "left_stomp"
		right_animation_player.stop()
		attacking_foot = left
		resting_foot = right
	elif attacking_foot == left:
		right_animation_player.current_animation = "right_stomp"
		left_animation_player.stop()
		attacking_foot = right
		resting_foot = left
