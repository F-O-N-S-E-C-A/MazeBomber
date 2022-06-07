extends Control

func _ready():
	$settings/VBoxContainer/music_slider.value = Settings.music_volume
	$settings/VBoxContainer/sound_effects_slider.value = Settings.sound_fx_volume
	$settings/VBoxContainer/static_hud.pressed = Settings.static_hud
	
func _on_back_button_pressed():
	Settings.save_settings()	
	visible = false
	if get_tree().paused:
		get_parent().find_node("Pause").visible = true
		
func _on_music_slider_value_changed(value):
	get_parent().find_node("music").volume_db = value - 25
	Settings.music_volume = value
	if value == $settings/VBoxContainer/music_slider.min_value:
		print("music not playing")
		Settings.music_enabled = false
	else:
		Settings.music_enabled = true
	#emit_signal('music_audio_changed')


func _on_sound_effects_slider_value_changed(value):
	Settings.sound_fx_volume = value
	if value == $settings/VBoxContainer/sound_effects_slider.min_value:
		Settings.sound_fx_enabled = false
	else:
		Settings.sound_fx_enabled = true
		


func _on_static_hud_toggled(button_pressed):
	Settings.static_hud = button_pressed
	get_parent().update_huds()
	
func save(pause):
	Settings.save_settings()	
	if !pause:
		visible = false
