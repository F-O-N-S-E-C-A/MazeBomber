extends Area2D

var player = load("res://Player/Player.gd")
var receiver

func _ready():
	WorldObjects.pickupables.append(self)

func pick_up(body):
	body.speed_up()
	body.play_powerup_sound()

func _on_SpeedPowerUp_body_entered(body):
	if body is player || GameModes.is_an_agent(body):
		pick_up(body)
		queue_free()
		WorldObjects.pickupables.erase(self)
		if GameModes.is_an_agent(body):
			WorldObjects.pickup_xp_reward += 1

func kill():
	queue_free()
