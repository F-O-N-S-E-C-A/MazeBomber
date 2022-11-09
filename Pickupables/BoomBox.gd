extends Area2D

const player = preload("res://Player/Player.gd")
var spawner
var my_player

func my_init(s):
	spawner = s

func pick_up(p):
	my_player = p
	if p.number_of_bombs != p.max_bombs:
		p.number_of_bombs = p.max_bombs
		p.play_load_sound()
		queue_free()
		spawner.start_timer()
		p.updateHUD()
	
	
func _on_BoomBox_body_entered(body):
	if body is player || GameModes.is_an_agent(body):
		pick_up(body)
		if GameModes.is_an_agent(body):
			WorldObjects.pickup_bombs_reward += 1
		
func _process(_delta):
	if my_player != null && overlaps_body(my_player):
		pick_up(my_player)
