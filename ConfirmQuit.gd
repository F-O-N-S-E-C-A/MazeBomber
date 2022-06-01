extends Control



func _on_yes_pressed():
	get_tree().quit()


func _on_no_pressed():
	visible = false
	if get_tree().paused:
		get_parent().find_node("Pause").visible = true
	else: 
		get_parent().find_node("GameOver").visible = true
