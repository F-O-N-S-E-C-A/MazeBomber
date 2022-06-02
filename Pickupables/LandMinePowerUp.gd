extends Area2D

const player = preload("res://Player/Player.gd")
const agent = preload("res://Autonomous_Agent/Autonomous_Agent.gd")

func pick_up(body):
	body.landMines += 1
	body.play_powerup_sound()
	body.updateHUD()

func _on_LandMinePowerUp_body_entered(body):
	if body is player || body is agent:
		pick_up(body)
		queue_free()
	
