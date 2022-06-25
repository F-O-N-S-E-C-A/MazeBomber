extends Control

func _ready():
	Settings.load_settings()

	$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")
		
	if Settings.music_enabled:
		$menu_music.volume_db = Settings.music_volume - 25
		$menu_music.play()
		
func _on_menu_button_pressed():
	Settings.save_settings()
	get_tree().change_scene("res://Menu.tscn")
	
func _on_play_button_pressed():
	Settings.save_settings()
	get_tree().change_scene("res://World.tscn")
	


#Player 1 ------------------------------------------------------------------------------------------
func _on_P1R_pressed():
	if Settings.p1 < 4:
		Settings.p1 = Settings.p1 + 1
	else:
		Settings.p1 = 1
	$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")
	
func _on_P1L_pressed():
	if Settings.p1 == 1:
		Settings.p1 = 4
	else:
		Settings.p1 = Settings.p1 - 1
	$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")
