extends Control



func _on_back_button_pressed():
	get_tree().change_scene("res://Options_menu.tscn")


func _on_explosion_time_random_toggled(button_pressed):
	Settings.explosion_time_random = button_pressed


func _on_explosion_damage_random_toggled(button_pressed):
	Settings.explosion_damage_random = button_pressed
