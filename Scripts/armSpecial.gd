extends Marker3D

@onready var distance_direction: Marker3D = $DistanceDirection
@onready var trail: Marker3D = $Trail
@onready var ik_target: Marker3D = $IKTarget

@onready var distance_to_change = distance_direction.position.length()

var tendons = []
@export var rest_length = 20
@export var squeeze_length = 1
@export var tension = 100
@export var tent_strength = 30 #NEGATIVE HAHAHAHAHAHA >:D
const damping = .96
@export var noise : NoiseTexture3D
@onready var starting_point = randf()
@onready var titler_holder: Path3D = $TitlerHolder
@export var anchor_position : Marker3D

func _ready():
	for i in $TentHolder.get_children(): if i is CharacterBody3D: tendons += [i]
	$TentHolder.top_level = true
	randomize()
	

func _physics_process(delta):
	if (ik_target.global_position - distance_direction.global_position).length() > distance_to_change * 1.6:
		ik_target.global_position = distance_direction.global_position
	
	trail.global_position = anchor_position.global_position
	tendon_puller(delta)
	titler_puller(delta)

func tendon_puller(delta):
	$TentHolder.global_position = global_position
	
	var scale_size = tendons.size()
	for i : CharacterBody3D in tendons:
		i.scale = Vector3(scale_size * .5,1,1)
		scale_size -= 1
		if i != tendons[0]:
			var distance = i.global_position - tendons[tendons.find(i) - 1].global_position
			if distance.length() > rest_length or distance.length() < squeeze_length:
				tendons[tendons.find(i) - 1].velocity += distance * delta * tension
				#var dist_mult = (distance - (Vector3(rest_length, rest_length,rest_length) * distance.normalized())) #somehow gives more weight to the end
				i.velocity -= distance * delta * tension
			
			starting_point += delta
			var noise_point = noise.noise.get_noise_3d(starting_point,starting_point,starting_point)
			
			i.velocity += Vector3.ONE * noise_point * delta * 2
			i.velocity.y = clamp(i.velocity.y, 0, 1)
			i.velocity *= damping
		if i == tendons[0] or i == tendons[-1]:
			if i == tendons[0]: 
				i.velocity = Vector3.ZERO
				i.global_position = global_position
			if i == tendons[-1]: 
				i.velocity -= get_parent().get_parent().velocity * .05
				i.velocity += (trail.global_position - i.global_position) * delta * tent_strength
		if i.global_position != tendons[tendons.find(i) - 1].global_position:
			i.look_at(tendons[tendons.find(i) - 1].global_position + Vector3(0.01,0,0))

func titler_puller(delta):
	#titler_holder.global_position = global_position
	titler_holder.curve.set_point_position(0, titler_holder.to_local(global_position))
	titler_holder.curve.set_point_position(1, titler_holder.to_local(trail.global_position))
