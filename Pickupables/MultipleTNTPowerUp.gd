extends Area2D

const player = preload("res://Player/Player.gd")
const agent = preload("res://Autonomous_Agent/Agent Template/Template.gd")

func _ready():
	WorldObjects.pickupables.append(self)

func pick_up(body):
	body.max_bombs += 1
	body.play_powerup_sound()

func _on_MultipleTNTPowerUp_body_entered(body):
	if body is player || GameModes.is_an_agent(body):
		pick_up(body)
		queue_free()
		WorldObjects.pickupables.erase(self)
