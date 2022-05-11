extends Control

func _ready():
	pass # Replace with function body.


func _on_restart_button_pressed():
	get_tree().reload_current_scene()


func _on_menu_button_pressed():
	get_tree().change_scene("res://Menu.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
