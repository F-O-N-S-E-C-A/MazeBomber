extends Area2D

const player = preload("res://Player/Player.gd")

func pick_up(body):
	body.add_hp(25)
	body.play_powerup_sound()
	
func _on_HPPowerUp_body_entered(body):
	if body is player:
		pick_up(body)
		queue_free()

