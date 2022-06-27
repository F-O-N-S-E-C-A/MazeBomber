extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameModes.multiplayer_online or GameModes.waiting_lobby:
		self.name = Network.getName()
	

	
