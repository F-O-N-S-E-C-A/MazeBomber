extends Area2D

const player = preload("res://Player/Player.gd")

func _ready():
	WorldObjects.pickupables.append(self)

func pick_up(body):
	body.add_hp(25)
	body.play_powerup_sound()
	
func _on_HPPowerUp_body_entered(body):
	if body is player || GameModes.is_an_agent(body):
		pick_up(body)
		queue_free()
		WorldObjects.pickupables.erase(self)
		if GameModes.is_an_agent(body):
			WorldObjects.pickup_hp_reward += 1
