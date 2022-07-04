extends Control

func _input(event):
	if event.is_action_pressed("pause") && !get_parent().is_over():
		var pause_state = not get_tree().paused
		get_tree().paused = pause_state
		visible = pause_state
		get_parent().hud_is_visible(!pause_state)
		get_parent().find_node("InGameOptions").save(pause_state)


func _on_quit_button_pressed():
	get_parent().find_node("ConfirmQuit").visible = true
	visible = false

func _on_menu_button_pressed():
	get_tree().change_scene("res://Menu.tscn")
	var pause_state = not get_tree().paused
	get_tree().paused = pause_state
	GameModes.menu()


func _on_options_button_pressed():
	get_parent().find_node("InGameOptions").visible = true
	visible = false
