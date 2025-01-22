extends Control
#manages health here too

@onready var boss_health: TextureProgressBar = $BossHealth
@onready var player_health: TextureProgressBar = $PlayerHealth

var attack_multiplier = 1

func _process(delta: float) -> void:
	player_health.value += delta * 3
	
	
func attack_boss():
	boss_health.value += 5 * attack_multiplier

func take_damage(damage):
	player_health.value -= damage
	if player_health.value <= 0:
		#add dying here
		pass
