extends Control

func _ready():
	pass

func _on_restart_button_pressed():
	WorldObjects.kill()
	GameModes.dead_players = []
	GameModes.agent = load("res://Autonomous_Agent/deliberative_agent/deliberative_agent.tscn").instance()
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
