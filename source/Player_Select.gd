extends Control

func _ready():
	Settings.load_settings()
	check_actives()
		
	if Settings.p1_act: #CHANGE THIS
		$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")
		$P1C.text = "-"
	else:
		$P1.texture = null
		$P1L.disabled = true
		$P1R.disabled = true
		$P1C.text = "+"
		
	if Settings.p2_act: #CHANGE THIS
		$P2.texture = load("res://Player/Player" + str(Settings.p2) + "f.png")
		$P2C.text = "-"
	else:
		$P2.texture = null
		$P2L.disabled = true
		$P2R.disabled = true
		$P2C.text = "+"
		
	if Settings.p3_act: #CHANGE THIS
		$P3.texture = load("res://Player/Player" + str(Settings.p3) + "f.png")
		$P3C.text = "-"
	else:
		$P3.texture = null
		$P3L.disabled = true
		$P3R.disabled = true
		$P3C.text = "+"
	
	if Settings.p4_act: #CHANGE THIS
		$P4.texture = load("res://Player/Player" + str(Settings.p4) + "f.png")
		$P4C.text = "-"
	else:
		$P4.texture = null
		$P4L.disabled = true
		$P4R.disabled = true
		$P4C.text = "+"
		
	if Settings.music_enabled:
		$menu_music.volume_db = Settings.music_volume - 25
		$menu_music.play()
		
func _on_menu_button_pressed():
	Settings.save_settings()
	get_tree().change_scene("res://Menu.tscn")
	
func _on_play_button_pressed():
	Settings.save_settings()
	get_tree().change_scene("res://World.tscn")
	
func check_actives():
	var actives = 0
	if Settings.p1_act:
		actives = actives+1
	if Settings.p2_act:
		actives = actives+1
	if Settings.p3_act:
		actives = actives+1
	if Settings.p4_act:
		actives = actives+1
	if actives < 2:
		$play_button.disabled = true
	else:
		$play_button.disabled = false

#Player 1 ------------------------------------------------------------------------------------------
func _on_P1R_pressed():
	if Settings.p1 < 4:
		Settings.p1 = Settings.p1 + 1
	else:
		Settings.p1 = 1
	$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")
	
func _on_P1L_pressed():
	if Settings.p1 == 1:
		Settings.p1 = 4
	else:
		Settings.p1 = Settings.p1 - 1
	$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")
	
func _on_P1C_pressed():
	if Settings.p1_act:
		$P1L.disabled = true
		$P1R.disabled = true
		$P1.texture = null
		Settings.p1_act = false
		$P1C.text = "+"
		check_actives()
	else:
		$P1C.text = "-"
		$P1L.disabled = false
		$P1R.disabled = false
		$P1.texture = load("res://Player/Player" + str(Settings.p1) + "f.png")
		Settings.p1_act = true
		check_actives()
	
#Player 2 ------------------------------------------------------------------------------------------
func _on_P2R_pressed():
	if Settings.p2 < 4:
		Settings.p2 = Settings.p2 + 1
	else:
		Settings.p2 = 1
	$P2.texture = load("res://Player/Player" + str(Settings.p2) + "f.png")
	
func _on_P2L_pressed():
	if Settings.p2 == 1:
		Settings.p2 = 4
	else:
		Settings.p2 = Settings.p2 - 1
	$P2.texture = load("res://Player/Player" + str(Settings.p2) + "f.png")
	
func _on_P2C_pressed():
	if Settings.p2_act:
		$P2L.disabled = true
		$P2R.disabled = true
		$P2.texture = null
		Settings.p2_act = false
		check_actives()
		$P2C.text = "+"
	else:
		$P2L.disabled = false
		$P2R.disabled = false
		$P2.texture = load("res://Player/Player" + str(Settings.p2) + "f.png")
		Settings.p2_act = true
		check_actives()
		$P2C.text = "-"
	
#Player 3 ------------------------------------------------------------------------------------------
func _on_P3R_pressed():
	if Settings.p3 < 4:
		Settings.p3 = Settings.p3 + 1
	else:
		Settings.p3 = 1
	$P3.texture = load("res://Player/Player" + str(Settings.p3) + "f.png")
	
func _on_P3L_pressed():
	if Settings.p3 == 1:
		Settings.p3 = 4
	else:
		Settings.p3 = Settings.p3 - 1
	$P3.texture = load("res://Player/Player" + str(Settings.p3) + "f.png")
	
func _on_P3C_pressed():
	if Settings.p3_act:
		$P3L.disabled = true
		$P3R.disabled = true
		$P3.texture = null
		Settings.p3_act = false
		check_actives()
		$P3C.text = "+"
	else:
		$P3L.disabled = false
		$P3R.disabled = false
		$P3.texture = load("res://Player/Player" + str(Settings.p3) + "f.png")
		Settings.p3_act = true
		check_actives()
		$P3C.text = "-"
	
#Player 4 ------------------------------------------------------------------------------------------
func _on_P4R_pressed():
	if Settings.p4 < 4:
		Settings.p4 = Settings.p4 + 1
	else:
		Settings.p4 = 1
	$P4.texture = load("res://Player/Player" + str(Settings.p4) + "f.png")
	
func _on_P4L_pressed():
	if Settings.p4 == 1:
		Settings.p4 = 4
	else:
		Settings.p4 = Settings.p4 - 1
	$P4.texture = load("res://Player/Player" + str(Settings.p4) + "f.png")
	
func _on_P4C_pressed():
	if Settings.p4_act:
		$P4L.disabled = true
		$P4R.disabled = true
		$P4.texture = null
		Settings.p4_act = false
		check_actives()
		$P4C.text = "+"
	else:
		$P4L.disabled = false
		$P4R.disabled = false
		$P4.texture = load("res://Player/Player" + str(Settings.p4) + "f.png")
		Settings.p4_act = true
		check_actives()
		$P4C.text = "-"

