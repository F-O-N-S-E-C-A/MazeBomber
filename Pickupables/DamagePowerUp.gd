extends Area2D

const player = preload("res://Player/Player.gd")
const agent = preload("res://Autonomous_Agent/Autonomous_Agent.gd")

remote func syncDamagePickup(id):
	queue_free()
	var p = get_parent().get_parent().getPlayerByID(id)
	p.damage_multiplier += .1

func pick_up(p):
	p.damage_multiplier += .1
	p.play_powerup_sound()
	if GameModes.multiplayer_online:
		rpc("syncDamagePickup", p.ownerID)
	queue_free()

func _on_DamagePowerUp_body_entered(body):
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



func _on_DamagePowerUp_body_exited(body):
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
