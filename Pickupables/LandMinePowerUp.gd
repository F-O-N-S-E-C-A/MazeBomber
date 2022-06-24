extends Area2D

const player = preload("res://Player/Player.gd")
const agent = preload("res://Autonomous_Agent/Autonomous_Agent.gd")

remote func syncLandMinePickup():
	queue_free()

func pick_up(body):
	body.landMines += 1
	body.play_powerup_sound()
	body.updateHUD()
	if GameModes.multiplayer_online:
		rpc("syncLandMinePickup")
	queue_free()
	
func _on_LandMinePowerUp_body_entered(body):
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


func _on_LandMinePowerUp_body_exited(body):
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
