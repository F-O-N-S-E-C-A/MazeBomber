extends Control

var playerlist = []

func _ready():
	addPlayer("Player 1")
	addPlayer("Player 2")

func addPlayer(p):
	get_node("CanvasLayer/Player_List").add_item(p)
	
