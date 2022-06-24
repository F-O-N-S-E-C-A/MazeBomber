extends Area2D

const player = preload("res://Player/Player.gd")
const agent = preload("res://Autonomous_Agent/Autonomous_Agent.gd")

remote func syncMTNTPickup():
	queue_free()

func pick_up(body):
	body.max_bombs += 1
	body.play_powerup_sound()
	if GameModes.multiplayer_online:
		rpc("syncMTNTPickup")
	queue_free()
	
func _on_MultipleTNTPowerUp_body_entered(body):
	if GameModes.multiplayer_online:
		if body is player || body is agent:
			if get_tree().get_network_unique_id() != body.ownerID:
				return
			else:
				pick_up(body)
				return
		return
	
	if body is player || body is agent:
		pick_up(body)



func _on_MultipleTNTPowerUp_body_exited(body):
	if GameModes.multiplayer_online:
		if body is player || body is agent:
			if get_tree().get_network_unique_id() != body.ownerID:
				return
			else:
				pick_up(body)
				return
		return
	
	if body is player || body is agent:
		pick_up(body)
