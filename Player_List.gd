extends ItemList


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_item("Random Agent")
	self.add_item("Deliberative Agent")
	self.add_item("Deep Q-Learning Agent")
	self.add_item("Random VS Random")
	self.add_item("Random VS Deliberative")
	self.add_item("Random VS Deep Q-Learning")
	self.add_item("Deliberative VS Deliberative")
	self.add_item("Deliberative VS Deep Q Learning")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	if self.is_selected(0):
		GameModes.agent = load("res://Autonomous_Agent/RandomAgent/random_agent.tscn").instance()
		GameModes.agentSprite = load("res://Autonomous_Agent/AI1.png")
		GameModes.player = load("res://Player/Player.tscn").instance()
		GameModes.playerSprite = load("res://Player/Player2.png")
	elif self.is_selected(1):
		GameModes.agent = load("res://Autonomous_Agent/deliberative_agent/deliberative_agent.tscn").instance()
		GameModes.agentSprite = load("res://Autonomous_Agent/deliberative_agent/AI1.png")
		GameModes.player = load("res://Player/Player.tscn").instance()
		GameModes.playerSprite = load("res://Player/Player2.png")
	elif self.is_selected(2):
		GameModes.agent = load("res://Autonomous_Agent/deep_rl_agent/deep_rl_agent.tscn").instance()
		GameModes.agentSprite = load("res://Autonomous_Agent/deep_rl_agent/AI1.png")
		GameModes.player = load("res://Player/Player.tscn").instance()
		GameModes.playerSprite = load("res://Player/Player2.png")
	elif self.is_selected(3):
		GameModes.agent = load("res://Autonomous_Agent/RandomAgent/random_agent.tscn").instance()
		GameModes.agentSprite = load("res://Autonomous_Agent/AI1.png")
		GameModes.player = load("res://Autonomous_Agent/RandomAgent/random_agent.tscn").instance()
		GameModes.playerSprite = load("res://Autonomous_Agent/AI1.png")
	elif self.is_selected(4):
		GameModes.agent = load("res://Autonomous_Agent/RandomAgent/random_agent.tscn").instance()
		GameModes.agentSprite = load("res://Autonomous_Agent/AI1.png")
		GameModes.player = load("res://Autonomous_Agent/deliberative_agent/deliberative_agent.tscn").instance()
		GameModes.playerSprite = load("res://Autonomous_Agent/deliberative_agent/AI1.png")
	elif self.is_selected(5):
		GameModes.player = load("res://Autonomous_Agent/RandomAgent/random_agent.tscn").instance()
		GameModes.playerSprite = load("res://Autonomous_Agent/AI1.png")
		GameModes.agent = load("res://Autonomous_Agent/imitation_learning/imitation_learning.tscn").instance()
		GameModes.agentSprite = load("res://Autonomous_Agent/imitation_learning/AI1.png")
	elif self.is_selected(6):
		GameModes.agent = load("res://Autonomous_Agent/deliberative_agent/deliberative_agent.tscn").instance()
		GameModes.agentSprite = load("res://Autonomous_Agent/deliberative_agent/AI1.png")
		GameModes.player = load("res://Autonomous_Agent/deliberative_agent/deliberative_agent.tscn").instance()
		GameModes.playerSprite = load("res://Autonomous_Agent/deliberative_agent/AI1.png")
	elif self.is_selected(7):
		GameModes.player = load("res://Autonomous_Agent/deliberative_agent/deliberative_agent.tscn").instance()
		GameModes.playerSprite = load("res://Autonomous_Agent/deliberative_agent/AI1.png")
		GameModes.agent = load("res://Autonomous_Agent/imitation_learning/imitation_learning.tscn").instance()
		GameModes.agentSprite = load("res://Autonomous_Agent/imitation_learning/AI1.png")
		
	GameModes.singleplayer()
	get_tree().change_scene("res://World.tscn")
