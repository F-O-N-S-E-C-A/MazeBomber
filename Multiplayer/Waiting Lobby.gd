extends Control

var playerlist = []

func _ready():
	addPlayer("Player 1")
	addPlayer("Player 2")
	
	if !get_tree().is_network_server():
		self.get_node("CanvasLayer/Player_List/Button").visible = false

func addPlayer(p):
	get_node("CanvasLayer/Player_List").add_item(p)
	

remote func gameStart():
	GameModes.multiplayer_online()
	get_tree().change_scene("res://World.tscn")

func _on_Button_pressed():
	if get_tree().is_network_server():
		GameModes.multiplayer_online()
		get_tree().change_scene("res://World.tscn")
		rpc("gameStart")
