extends CharacterBody3D

@onready var boss: CharacterBody3D = get_parent()
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_target: CharacterBody3D
var attacking: bool = false
var old_attacking: bool = false
var swipe_target_position

enum AttackPhase {first, second, third, fourth, fifth, silly}
var attack_phase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_phase = AttackPhase.fifth


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(attack_phase, " timer is ", attack_timer.time_left)
	if attacking != old_attacking:
		attack_timer.start(0.1)
	old_attacking = attacking
	
	match attack_phase:
		AttackPhase.first:
			# state is set to first while not attacking, so we need to double check
			# to make sure this behavior is needed
			if attacking:
				# track attacking hand to player position
				#self.position.y = 7
				self.position.x = lerp(self.position.x, attack_target.position.x, 0.3)
				self.position.z = lerp(self.position.z, attack_target.position.z, 0.3)
			elif not attacking:
				# reset hand position
				self.position = lerp(self.position, boss.position, 1)
		AttackPhase.second:
			# slam hand down and get player position
			swipe_target_position = (attack_target.position - self.position) * Vector3(5, 0, 5)
		AttackPhase.third:
			# pause for player dodge
			pass
		AttackPhase.fourth:
			# swipe hand accross ground towards previous player position
			self.velocity = lerp(self.velocity, swipe_target_position, 0.05)
			
		AttackPhase.fifth:
			self.velocity = Vector3(0, 0, 0)
			# raise hand
			self.position = lerp(position, boss.position, delta * 5)
			
	
	move_and_slide()


func _on_attack_timer_timeout() -> void:
	attack_timer.stop()
	# stop loop at first phase if player exits attack range
	# (allows for attack to finish before cycling out of attack mode)
	if not attacking and attack_phase == AttackPhase.fifth:
		attack_phase = AttackPhase.fifth
	elif attacking:
		# all of these lines execute only once per state, so functions that don't need to be executed
		# each frame will be here
		match attack_phase:
			AttackPhase.first:
				# slam hand down and gets player position
				attack_timer.start(1.75)
				animation_player.play('hand_attack')
				attack_phase = AttackPhase.second
				
			AttackPhase.second:
				# hand pauses for player to dodge
				attack_timer.start(0.5)
				look_at(attack_target.global_position)
				global_rotation *= Vector3(0,1,0)
				attack_phase = AttackPhase.third
			AttackPhase.third:
				# hand accelerates towards previous player position
				attack_timer.start(2.5)
				attack_phase = AttackPhase.fourth
			AttackPhase.fourth:
				# hand resets to boss position
				attack_timer.start(1.0)
				animation_player.play('hand_lift')
				
				attack_phase = AttackPhase.fifth
			AttackPhase.fifth:
				# track attacking hand to player position
				attack_timer.start(3)
				attack_phase = AttackPhase.first
				print('test')
			AttackPhase.silly:
				pass
		
func reset():
	$Sprite3D.play("default")
	animation_player.play('hand_lift')
	
	
	attack_timer.stop()
	attack_phase = AttackPhase.first
	attack_timer.start(3)
	attacking = true

func stun():
	velocity = Vector3.ZERO
	attack_phase = AttackPhase.silly
	attack_timer.stop()
	attacking = false
	get_parent().stun()
	$Sprite3D.play("stunned")
