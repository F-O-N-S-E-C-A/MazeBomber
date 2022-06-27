extends Area2D

const player = preload("res://Player/Player.gd")

func _ready():
	WorldObjects.pickupables.append(self)
	if GameModes.multiplayer_online or GameModes.waiting_lobby:
		self.name = Network.getName()

remote func syncPickupBigBomb():
	queue_free()

func pick_up(body):
	body.big_bombs += 1
	body.play_powerup_sound()
	body.updateHUD()
	if GameModes.multiplayer_online:
		rpc("syncPickupBigBomb")
	WorldObjects.pickupables.erase(self)
	queue_free()

func _on_BigBombPowerUp_body_entered(body):
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
