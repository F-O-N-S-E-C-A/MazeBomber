extends Area2D

var player = load("res://Player/Player.gd")
var receiver


func _ready():
	WorldObjects.pickupables.append(self)

remote func syncSpeedPickup(id):
	var p = get_parent().get_parent().getPlayerByID(id)
	p.speed_up()
	queue_free()

func pick_up(body):
	body.speed_up()
	body.play_powerup_sound()
	if GameModes.multiplayer_online:
		rpc("syncSpeedPickup", body.ownerID)
	WorldObjects.pickupables.erase(self)
	queue_free()

func _on_SpeedPowerUp_body_entered(body):
	if GameModes.multiplayer_online:
		if body is player || GameModes.is_an_agent(body):
			if get_tree().get_network_unique_id() != body.ownerID:
				return
			else:
				pick_up(body)
				return
		return

	if body is player || GameModes.is_an_agent(body):
		pick_up(body)



func _on_SpeedPowerUp_body_exited(body):
	if GameModes.multiplayer_online:
		if body is player || GameModes.is_an_agent(body):
			if get_tree().get_network_unique_id() != body.ownerID:
				return
			else:
				pick_up(body)
				return
		return

if body is player || GameModes.is_an_agent(body):
		pick_up(body)
