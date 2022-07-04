extends Control

func _ready():
	pass

remote func syncRestart():
	Network.syncNumber = 0
	WorldObjects.kill()
	GameModes.dead_players = []
	GameModes.agent = load("res://Autonomous_Agent/deliberative_agent/deliberative_agent.tscn").instance()
	get_tree().change_scene("res://World.tscn")

func _on_restart_button_pressed():
	Network.syncNumber = 0
	WorldObjects.kill()
	GameModes.dead_players = []
	GameModes.agent = load("res://Autonomous_Agent/deliberative_agent/deliberative_agent.tscn").instance()
	if GameModes.multiplayer_online:
		rpc("syncRestart")
	get_tree().change_scene("res://World.tscn")
	

func _on_menu_button_pressed():
	get_tree().change_scene("res://Menu.tscn")
	GameModes.menu()
	


func _on_quit_button_pressed():
	get_parent().find_node("ConfirmQuit").visible = true
	visible = false


func _on_restart_pressed():
	WorldObjects.kill()
	GameModes.dead_players = []
	GameModes.agent = load("res://Autonomous_Agent/deliberative_agent/deliberative_agent.tscn").instance()
	get_tree().change_scene("res://World.tscn")
