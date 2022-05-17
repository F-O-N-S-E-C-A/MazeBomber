extends Area2D

const player = preload("res://Player/Player.gd")

func pick_up(body):
	body.c4 += 1

func _on_BigBombPowerUp_body_entered(body):
	if body is player:
		pick_up(body)
		queue_free()
