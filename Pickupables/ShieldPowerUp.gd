extends Area2D

const player = preload("res://Player/Player.gd")
const agent = preload("res://Autonomous_Agent/Autonomous_Agent.gd")

func pick_up(body):
	body.add_shield(25)
	body.play_powerup_sound()

func _on_ShieldPowerUp_body_entered(body):
	if body is player || body is agent:
		pick_up(body)
		queue_free()
