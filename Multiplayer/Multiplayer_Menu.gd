extends Control

var connected_players = 0

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	$Device_IP_Address.text = Network.ip_address
	
	Settings.load_settings()
	Settings.p1_act = true 
	if Settings.p1 == 0:
		Settings.p1 = 2
	$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")
	
	$User_Name.placeholder_text = Settings.p1_name

func _on_Join_Server_pressed():
	get_tree().change_scene("res://Multiplayer/Server_browser.tscn")

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	connected_players += 1
	
	#if connected_players == Network.MAX_CLIENTS - 1:

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")
	connected_players -= 1

func instance_player(id) -> void:
	pass


func _on_Server_IP_Address_text_changed(new_text):
	Network.ip_address = new_text


func _on_back_button_pressed():
	get_tree().change_scene("res://Menu.tscn")


func _on_Host_Server_pressed():
	if $User_Name.text != "" or $User_Name.placeholder_text != "":
		Network.create_server()
		if $User_Name.text != "":
			Settings.p1_name = $User_Name.text.substr(0, 10)
		Settings.save_settings()
		get_tree().change_scene("res://Multiplayer/WaitingMap.tscn")


func _on_P1L_pressed():
	if Settings.p1 == 1:
		Settings.p1 = 4
	else:
		Settings.p1 = Settings.p1 - 1
	$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")


func _on_P1R_pressed():
	if Settings.p1 < 4:
		Settings.p1 = Settings.p1 + 1
	else:
		Settings.p1 = 1
	$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")
