extends Area2D

const player = preload("res://Player/Player.gd")

func pick_up(body):
	body.max_bombs += 1
	body.play_powerup_sound()

func _on_MultipleTNTPowerUp_body_entered(body):
	if body is player:
		pick_up(body)
		queue_free()
