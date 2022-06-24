extends Area2D

const player = preload("res://Player/Player.gd")
const agent = preload("res://Autonomous_Agent/Autonomous_Agent.gd")

remote func syncHPPickup(id):
	queue_free()
	var p = get_parent().get_parent().getPlayerByID(id)
	p.add_hp(25)

func pick_up(body):
	body.add_hp(25)
	body.play_powerup_sound()
	if GameModes.multiplayer_online:
		rpc("syncHPPickup", body.ownerID)
	queue_free()
	
func _on_HPPowerUp_body_entered(body):
	if GameModes.multiplayer_online:
		if get_tree().get_network_unique_id() != body.ownerID:
			return
		else:
			if body is player || body is agent:
				pick_up(body)
			return
	
	if body is player || body is agent:
		pick_up(body)



func _on_HPPowerUp_body_exited(body):
	if GameModes.multiplayer_online:
		if get_tree().get_network_unique_id() != body.ownerID:
			return
		else:
			if body is player || body is agent:
				pick_up(body)
			return
	
	if body is player || body is agent:
		pick_up(body)
