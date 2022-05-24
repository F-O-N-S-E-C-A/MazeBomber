extends Control

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	$Device_IP_Address.text = Network.ip_address

func _on_Join_Server_pressed():
	if $User_Name.text != "":
		Network.join_server()


func _on_Create_Server_pressed():
	if $User_Name.text != "":
		Network.create_server()

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")

func instance_player(id) -> void:
	pass
