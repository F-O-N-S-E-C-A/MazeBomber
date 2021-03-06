extends Control

func _ready():
	get_tree().network_peer = null
	Settings.load_settings()
	if Settings.music_enabled:
		$menu_music.volume_db = Settings.music_volume - 25
		$menu_music.play()

func _on_multiplayer_local_button_button_down():
	GameModes.dead_players = []
	GameModes.multiplayer_local()
	#get_tree().change_scene("res://World.tscn")
	get_tree().change_scene("res://Player_Select.tscn")
	GameModes.multiplayer_local()

func _on_quit_button_button_down():
	$ConfirmQuit.visible = true


func _on_settings_button_pressed():
	get_tree().change_scene("res://Options_menu.tscn")


func _on_about_button_pressed():
	$About.visible = true


func _on_single_player_button_button_down():
	GameModes.singleplayer()
	GameModes.dead_players = []
	WorldObjects.kill()
	GameModes.agent = load("res://Autonomous_Agent/deliberative_agent/deliberative_agent.tscn").instance()
	get_tree().change_scene("res://Single_Select.tscn")

func _on_yes_pressed():
	get_tree().quit()


func _on_no_pressed():
	$ConfirmQuit.visible = false


func _on_multiplayer_online_button_button_down():
	get_tree().change_scene("res://Multiplayer/Multiplayer_Menu.tscn")
	GameModes.dead_players = []
