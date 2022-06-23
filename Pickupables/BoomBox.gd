extends Area2D

const player = preload("res://Player/Player.gd")
const agent = preload("res://Autonomous_Agent/Autonomous_Agent.gd")
var spawner
var my_player

func my_init(s):
	spawner = s

remote func syncPickupBoomBox():
	queue_free()
	spawner.start_timer()

func pick_up(p):
	my_player = p
	if p.number_of_bombs != p.max_bombs:
		p.number_of_bombs = p.max_bombs
		p.play_load_sound()
		if GameModes.multiplayer_online:
			rpc("syncPickupBoomBox")
		queue_free()
		spawner.start_timer()
		p.updateHUD()

func _on_BoomBox_body_entered(body):
	if GameModes.multiplayer_online:
		if get_tree().get_network_unique_id() != body.ownerID:
			return
		else:
			if body is player || body is agent:
				pick_up(body)
			return
			
	if body is player || body is agent:
		pick_up(body)

		
#func _process(_delta):
#	if my_player != null && overlaps_body(my_player):
#		pick_up(my_player)
