extends Control

var connected_players = 0

func _ready():
	$Device_IP_Address.text = Network.ip_address
	
	Settings.load_settings()
	Settings.p1_act = true 
	if Settings.p1 == 0:
		Settings.p1 = 2
	$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")
	
	$User_Name.placeholder_text = Settings.p1_name

func _on_Join_Server_pressed():
	queue_free()
	get_tree().change_scene("res://Multiplayer/Server_browser.tscn")

func instance_player(id) -> void:
	pass


func _on_Server_IP_Address_text_changed(new_text):
	Network.ip_address = new_text


func _on_back_button_pressed():
	queue_free()
	get_tree().change_scene("res://Menu.tscn")


func _on_Host_Server_pressed():
	if $User_Name.text != "" or $User_Name.placeholder_text != "":
		Network.create_server()
		if $User_Name.text != "":
			Settings.p1_name = $User_Name.text.substr(0, 10)
		Settings.save_settings()
		queue_free()
		get_tree().change_scene("res://Multiplayer/Waiting Lobby.tscn")


func _on_P1L_pressed():
	if Settings.p1 == 1:
		Settings.p1 = 4
	else:
		Settings.p1 = Settings.p1 - 1
	$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")


func _on_P1R_pressed():
	if Settings.p1 < 4:
		Settings.p1 = Settings.p1 + 1
	else:
		Settings.p1 = 1
	$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")
