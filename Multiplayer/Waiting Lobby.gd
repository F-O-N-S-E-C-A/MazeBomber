extends Control

var playerlist = []
var connected_players = 0

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	if !get_tree().is_network_server():
		self.get_node("CanvasLayer/Player_List/Button").visible = false
	else:
		addPlayer("Player 1(Server)")

func addPlayer(p):
	playerlist.append(p)
	get_node("CanvasLayer/Player_List").add_item(p)
	rpc("syncPlayers", playerlist)
	
remote func syncPlayers(playerlist):
	playerlist = []
	for p in playerlist:
		playerlist.append(p)
		get_node("CanvasLayer/Player_List").add_item(p)

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
	if get_tree().is_network_server():
		addPlayer("Player" + str(id))
	
	#if connected_players == Network.MAX_CLIENTS - 1:

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")
	connected_players -= 1
