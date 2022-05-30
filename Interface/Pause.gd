extends Control

func _input(event):
	if event.is_action_pressed("pause") && !get_parent().is_over():
		var pause_state = not get_tree().paused
		get_tree().paused = pause_state
		visible = pause_state
		get_parent().hud_is_visible(!pause_state)


func _on_quit_button_pressed():
	get_tree().quit()


func _on_menu_button_pressed():
	get_tree().change_scene("res://Menu.tscn")
	var pause_state = not get_tree().paused
	get_tree().paused = pause_state
	GameModes.menu()
