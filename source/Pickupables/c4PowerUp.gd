extends Area2D

const player = preload("res://Player/Player.gd")


func _ready():
	WorldObjects.pickupables.append(self)
	if GameModes.multiplayer_online or GameModes.waiting_lobby:
		self.name = Network.getName()

remote func syncC4Pickup(id):
	queue_free()
	var p = get_parent().get_parent().getPlayerByID(id)
	p.c4 += 1

func pick_up(body):
	body.c4 += 1
	body.play_powerup_sound()
	body.updateHUD()
	if GameModes.multiplayer_online:
		rpc("syncC4Pickup", body.ownerID)
	WorldObjects.pickupables.erase(self)
	queue_free()

func _on_c4PowerUp_body_entered(body):
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
