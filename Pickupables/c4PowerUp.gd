extends Area2D

const player = preload("res://Player/Player.gd")
const agent = preload("res://Autonomous_Agent/Autonomous_Agent.gd")

remote func syncC4Pickup():
	queue_free()

func pick_up(body):
	body.c4 += 1
	body.play_powerup_sound()
	body.updateHUD()
	if GameModes.multiplayer_online:
		rpc("syncC4Pickup")
	queue_free()

func _on_c4PowerUp_body_entered(body):
	if GameModes.multiplayer_online:
		if get_tree().get_network_unique_id() != body.ownerID:
			return
		else:
			if body is player || body is agent:
				pick_up(body)
			return
	
	
	if body is player || body is agent:
		pick_up(body)
