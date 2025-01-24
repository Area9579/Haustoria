extends Control
#manages health here too

@onready var boss_health: TextureProgressBar = $BossHealth
@onready var player_health: TextureProgressBar = $PlayerHealth
@onready var animation_player: AnimationPlayer = $"../UI2/AnimationPlayer"

var player_health_total = 70.0
var boss_health_total = 0.0

var attack_multiplier = 1

func _process(delta: float) -> void:
	player_health_total += delta
	
	player_health.value = round(player_health_total)
	boss_health.value = round(boss_health_total)
	
	
func attack_boss():
	boss_health_total += (player_health_total * .1) * attack_multiplier
	player_health_total -= player_health_total * .3
	if boss_health_total >= 100:
		#prob wait a bit do some animations and take over his body
		#do the await
		animation_player.play('end')
		await animation_player.animation_finished
		get_tree().change_scene_to_file("res://Scenes/EndScene.tscn")

func take_damage(damage):
	player_health.value -= damage
	if player_health.value <= 0:
		#add dying here
		pass
