extends Control

var playerlist = {}
var connected_players = 0

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	if !get_tree().is_network_server():
		self.get_node("CanvasLayer/Player_List/Button").visible = false
	else:
		addPlayer(1, Settings.p1_name, Settings.p1)
		add_child(Network.advertiser)

func addPlayer(id, nick, skin):
	playerlist[id] = [nick, skin]
	get_node("CanvasLayer/Player_List").add_item(nick)
	rpc("syncPlayers", playerlist)
	
remote func syncPlayers(pl):
	playerlist = pl
	for p in playerlist.keys():
		get_node("CanvasLayer/Player_List").add_item(pl[p][0])

remote func gameStart():
	GameModes.multiplayer_online()
	get_tree().change_scene("res://World.tscn")

func _on_Button_pressed():
	if get_tree().is_network_server():
		GameModes.multiplayer_online()
		get_tree().change_scene("res://World.tscn")
		rpc("gameStart")

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	connected_players += 1
	
	
	#if connected_players == Network.MAX_CLIENTS - 1:

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")
	connected_players -= 1

remote func register_player(nick, skin):
	addPlayer(get_tree().get_rpc_sender_id(), nick, skin)

func _connected_to_server() -> void:
	rpc_id(1, "register_player", Settings.p1_name, Settings.p1)

func _on_back_button_pressed():
	get_tree().change_scene("res://Multiplayer/Multiplayer_Menu.tscn")
