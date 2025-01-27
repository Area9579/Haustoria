extends Node3D

@onready var boss: CharacterBody3D = get_parent()
@onready var hand: CharacterBody3D = $Hand
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_player: AnimationPlayer = $Hand/AnimationPlayer
@export var attacking: bool = false
@onready var attack_target
var swipe_target_position

enum AttackPhase {first, second, third, fourth, fifth}
var attack_phase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_phase = AttackPhase.first
	attack_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match attack_phase:
		AttackPhase.first:
			# state is set to first while not attacking, so we need to double check
			# to make sure this behavior is needed
			if attacking:
				# track attacking hand to player position
				hand.position.y = 7
				hand.position.x = lerp(hand.position.x, attack_target.position.x, 0.025)
				hand.position.z = lerp(hand.position.z, attack_target.position.z, 0.025)
			elif not attacking:
				# reset hand position
				hand.position = lerp(hand.position, boss.position, 0.025)
		AttackPhase.second:
			# slam hand down and get player position
			swipe_target_position = attack_target.position
		AttackPhase.third:
			# pause for player dodge
			pass
		AttackPhase.fourth:
			# swipe hand accross ground towards previous player position
			var swipe_target_position = to_global(swipe_target_position - hand.position) * Vector3(1, 0, 1)
			#hand.position = lerp(hand.position, target_position, 0.05)
			hand.velocity = lerp(hand.velocity, swipe_target_position, 2)
			
		AttackPhase.fifth:
			# raise hand
			hand.position = lerp(hand.position, boss.position + Vector3(0, 10, 0), 0.025)
	
	hand.move_and_slide()


func _on_attack_timer_timeout() -> void:
	attack_timer.stop()
	print("state change: ", attack_phase)
	if not attacking:
		attack_phase = AttackPhase.first
	elif attacking:
		# all of these lines execute only once per state, so functions that don't need to be executed
		# each frame will be here
		match attack_phase:
			AttackPhase.first:
				attack_timer.start(3)
				animation_player.current_animation = "left_swipe"
				attack_phase = AttackPhase.second
			AttackPhase.second:
				attack_timer.start(3)
				attack_phase = AttackPhase.third
			AttackPhase.third:
				attack_timer.start(3)
				attack_phase = AttackPhase.fourth
			AttackPhase.fourth:
				print(hand.position)
				attack_timer.start(2)
				attack_phase = AttackPhase.fifth
			AttackPhase.fifth:
				attack_timer.start(3)
				attack_phase = AttackPhase.first
		
		
