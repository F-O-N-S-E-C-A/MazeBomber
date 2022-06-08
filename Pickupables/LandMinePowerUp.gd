extends Area2D

const player = preload("res://Player/Player.gd")

func _ready():
	WorldObjects.pickupables.append(self)

func pick_up(body):
	body.landMines += 1
	body.play_powerup_sound()
	body.updateHUD()

func _on_LandMinePowerUp_body_entered(body):
	if body is player || GameModes.is_an_agent(body):
		pick_up(body)
		queue_free()
		WorldObjects.pickupables.erase(self)
