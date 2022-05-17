extends Control


func _ready():
	#pass
	$MarginContainer/VBoxContainer/nuke_mode.pressed = Settings.nuke_mode
	$MarginContainer/VBoxContainer/fog_of_war.pressed = Settings.fog_of_war
	$World_settings/MarginContainer2/VBoxContainer/explosion_damage_random.pressed = Settings.explosion_damage_random
	$World_settings/MarginContainer2/VBoxContainer/explosion_time_random.pressed = Settings.explosion_time_random
	$MarginContainer/VBoxContainer/music_slider.value = Settings.music_volume
	$MarginContainer/VBoxContainer/sound_effects_slider.value = Settings.sound_fx_volume

func _on_menu_button_pressed():
	get_tree().change_scene("res://Menu.tscn")


func _on_world_settimgs_button_pressed():
	$World_settings.visible = true


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
	
	
func _on_back_button_pressed():
	$World_settings.visible = false


func _on_explosion_time_random_toggled(button_pressed):
	Settings.explosion_time_random = button_pressed


func _on_explosion_damage_random_toggled(button_pressed):
	Settings.explosion_damage_random = button_pressed



func _on_fog_of_war_toggled(button_pressed):
	Settings.fog_of_war = button_pressed
