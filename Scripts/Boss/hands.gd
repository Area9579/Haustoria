extends Node3D

@onready var left: Area3D = $Left
@onready var right: Area3D = $Right
@onready var attack_timer: Timer = $AttackTimer
@export var attacking: bool = false
@onready var left_animation_player: AnimationPlayer = $Left/AnimationPlayer
@onready var right_animation_player: AnimationPlayer = $Right/AnimationPlayer
var attacking_hand = left
var resting_hand = right

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if attacking:
		pass
	if not attacking:
		left.position = lerp(left.position, Vector3(-10, 0, 0), 0.025)
		left.position = lerp(left.position, Vector3(-10, 0, 0), 0.025)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# create a delay before the start of the next attack
	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	attack_timer.stop()
	# switch which foot is attacking and set correct animation
	if attacking_hand == right:
		left_animation_player.current_animation = "left_swipe"
		attacking_hand = left
		resting_hand = right
	elif attacking_hand == left:
		right_animation_player.current_animation = "right_swipe"
		attacking_hand = right
		resting_hand = left
