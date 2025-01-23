extends Control
#manages health here too

@onready var boss_health: TextureProgressBar = $BossHealth
@onready var player_health: TextureProgressBar = $PlayerHealth

var player_health_total = 70.0
var boss_health_total = 0.0

var attack_multiplier = 1

func _process(delta: float) -> void:
	player_health_total += delta
	
	player_health.value = round(player_health_total)
	boss_health.value = round(boss_health_total)
	
	
func attack_boss():
	boss_health_total += 5 * attack_multiplier

func take_damage(damage):
	player_health.value -= damage
	if player_health.value <= 0:
		#add dying here
		pass
