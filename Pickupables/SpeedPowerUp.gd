extends Area2D

var player = load("res://Player/Player.gd")
const agent = preload("res://Autonomous_Agent/Autonomous_Agent.gd")
var receiver

remote func syncSpeedPickup(id):
	var p = get_parent().get_parent().getPlayerByID(id)
	p.speed_up()
	queue_free()

func pick_up(body):
	body.speed_up()
	body.play_powerup_sound()
	if GameModes.multiplayer_online:
		rpc("syncSpeedPickup", body.ownerID)
	queue_free()

func _on_SpeedPowerUp_body_entered(body):
	if GameModes.multiplayer_online:
		if get_tree().get_network_unique_id() != body.ownerID:
			return
		else:
			if body is player || body is agent:
				pick_up(body)
			return
	
	if body is player || body is agent:
		pick_up(body)
		


func _on_SpeedPowerUp_body_exited(body):
	if GameModes.multiplayer_online:
		if get_tree().get_network_unique_id() != body.ownerID:
			return
		else:
			if body is player || body is agent:
				pick_up(body)
			return
	
	if body is player || body is agent:
		pick_up(body)
