extends Area2D

const player = preload("res://Player/Player.gd")
var spawner
var my_player

func _ready():
	if GameModes.multiplayer_online or GameModes.waiting_lobby:
		self.name = Network.getName()

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
		if body is player || GameModes.is_an_agent(body):
			if get_tree().get_network_unique_id() != body.ownerID:
				return
			else:
				pick_up(body)
				return
		return

	if body is player || GameModes.is_an_agent(body):
		pick_up(body)


func _process(_delta):
	if GameModes.multiplayer_online:
		var p = get_parent().get_parent().get_parent().getPlayerByID(get_tree().get_network_unique_id())

		if overlaps_body(p):
			pick_up(p)
	else:
		for p in get_parent().get_parent().get_parent().players:
			if overlaps_body(p):
				pick_up(p)
