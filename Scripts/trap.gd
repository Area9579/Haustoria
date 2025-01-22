extends Area3D

@onready var enabledSprite: CompressedTexture2D = preload("res://Assets/LightningBolt.png")
@onready var disabledSprite: CompressedTexture2D = preload("res://Assets/LightningBolt2.png")
@onready var sprite: Sprite3D = $TrapSprite

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.name == "Player":
			if Input.is_action_just_pressed("Interact"):
				sprite.texture = enabledSprite
		elif body.name == "MobileEnemy" and sprite.texture == enabledSprite:
			sprite.texture = disabledSprite
