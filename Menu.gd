extends Control


func _ready():
	pass



func _on_multiplayer_local_button_button_down():
	get_tree().change_scene("res://World.tscn")


func _on_quit_button_button_down():
	get_tree().quit()

