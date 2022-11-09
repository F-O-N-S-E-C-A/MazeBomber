extends Area2D

const player = preload("res://Player/Player.gd")

func _ready():
	WorldObjects.pickupables.append(self)

func pick_up(body):
	body.big_bombs += 1
	body.play_powerup_sound()
	body.updateHUD()

func _on_BigBombPowerUp_body_entered(body):
	if body is player || GameModes.is_an_agent(body):
		if GameModes.is_an_agent(body):
			WorldObjects.pickup_bombs_reward += 1
		pick_up(body)
		queue_free()
		WorldObjects.pickupables.erase(self)
	
