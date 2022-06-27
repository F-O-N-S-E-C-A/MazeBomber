extends Node

const DEFAULT_PORT = 1999
const MAX_CLIENTS = 10

var client = null
var server = null

var advertiser = null
var listener = null

var syncNumber = 0

var ip_address = "127.0.0.1"

func _ready():
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") or ip.begins_with("1") and not ip.ends_with(".1"):
			ip_address = ip

	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")

func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
	advertiser = load("res://Multiplayer/Server_advertiser.tscn").instance()

func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	
func _connected_to_server() -> void:
	print("Successfully connected to the server")

func _server_disconnected() -> void:
	print("Disconnected from the server")

func _connection_failed() -> void:
	print("Connecion Failed")
	
func getName():
	syncNumber += 1
	return "syncVar" + str(syncNumber)
