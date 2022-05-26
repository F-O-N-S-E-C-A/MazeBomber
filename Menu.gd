extends Control


func _ready():
	Settings.load_settings()
	if Settings.music_enabled:
		$menu_music.volume_db = Settings.music_volume - 25
		$menu_music.play()



func _on_multiplayer_local_button_button_down():
	get_tree().change_scene("res://World.tscn")


func _on_quit_button_button_down():
	get_tree().quit()


func _on_settings_button_pressed():
	get_tree().change_scene("res://Options_menu.tscn")


func _on_about_button_pressed():
	$About.visible = true
