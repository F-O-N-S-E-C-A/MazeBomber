extends Area2D

const player = preload("res://Player/Player.gd")

func pick_up(p):
	p.damage_multiplier += .1

func _on_DamagePowerUp_body_entered(body):
	if body is player:
		pick_up(body)
		queue_free()
