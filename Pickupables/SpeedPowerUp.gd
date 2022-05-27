extends Area2D

var player = load("res://Player/Player.gd")
const agent = preload("res://Autonomous_Agent/Autonomous_Agent.gd")
var receiver

func pick_up(body):
	body.speed_up()
	body.play_powerup_sound()

func _on_SpeedPowerUp_body_entered(body):
	if body is player || body is agent:
		pick_up(body)
		queue_free()
