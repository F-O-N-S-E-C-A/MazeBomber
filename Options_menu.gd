extends Control


func _on_menu_button_pressed():
	get_tree().change_scene("res://Menu.tscn")


func _on_world_settimgs_button_pressed():
	get_tree().change_scene("res://World_settings.tscn")


func _on_music_slider_value_changed(value):
	Settings.music_volume = value
	if value == -50:
		Settings.music_enabled = false
	else:
		Settings.music_enabled = true


func _on_sound_effects_slider_value_changed(value):
	Settings.sound_fx_volume = value
	if value == -50:
		Settings.sound_fx_enabled = false
	else:
		Settings.sound_fx_enabled = true


func _on_nuke_mode_toggled(button_pressed):
	Settings.nuke_mode = button_pressed
