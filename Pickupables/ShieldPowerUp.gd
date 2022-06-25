extends Area2D

const player = preload("res://Player/Player.gd")

func _ready():
	WorldObjects.pickupables.append(self)

remote func syncShieldPickup(id):
	var p = get_parent().get_parent().getPlayerByID(id)
	p.add_shield(25)
	queue_free()

func pick_up(body):
	body.add_shield(25)
	body.play_powerup_sound()
	if GameModes.multiplayer_online:
		rpc("syncShieldPickup", body.ownerID)
	WorldObjects.pickupables.erase(self)
	queue_free()

func _on_ShieldPowerUp_body_entered(body):
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


