extends ItemList


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_item("Random Agent")
	self.add_item("Deliberative Agent")
	self.add_item("Deep Q-Learning Agent")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	if self.is_selected(0):
		GameModes.agent = load("res://Autonomous_Agent/RandomAgent/random_agent.tscn").instance()
		GameModes.agentSprite = load("res://Autonomous_Agent/AI1.png")
	elif self.is_selected(1):
		GameModes.agent = load("res://Autonomous_Agent/deliberative_agent/deliberative_agent.tscn").instance()
		GameModes.agentSprite = load("res://Autonomous_Agent/deliberative_agent/AI1.png")
	elif self.is_selected(2):
		GameModes.agent = load("res://Autonomous_Agent/imitation_learning/imitation_learning.tscn").instance()
		GameModes.agentSprite = load("res://Autonomous_Agent/imitation_learning/AI1.png")
	
	GameModes.singleplayer()
	get_tree().change_scene("res://World.tscn")
