extends Node2D

var maze
var huds = []

func _ready():
	randomize()
	my_init()

func my_init():
	maze = load("res://Logic/Maze.gd").new(GlobalVariables.my_width, GlobalVariables.my_height)
	maze.generate_maze()
	var n_players = 2
	
	initialise_walls()
	initialise_huds(n_players)
	initialise_players(n_players)
	initialise_lights(12)
	initialise_spawners()
	
	if Settings.fog_of_war:
		$CanvasModulate.set_color(Color(0,0,0))
	else:
		$CanvasModulate.set_color(Color(0.5,0.5,0.5))
	
func initialise_huds(n_players):
	for i in range(n_players):
		huds.append(preload("res://HUD.tscn").instance())
		huds[i].my_init(str(i+1))
		var pos = Vector2(0, 0)
		if i == 0:
			pos = Vector2(0, maze.height - 1) * GlobalVariables.my_scale
		elif i == 1:
			pos = Vector2(maze.width - 7, maze.height - 1) * GlobalVariables.my_scale
		huds[i].set_position(pos - Vector2(0, 2))
		$YSort.add_child(huds[i])
		
func initialise_walls():
	if Settings.random_walls:
		maze.put_walls(.2)
	if Settings.center_room:
		maze.make_room(16, 8, 8, 6)
		
	maze.empty_corners(5)

	var mid_point = Vector2(maze.width/2, maze.height/2) * GlobalVariables.my_scale
	var max_dist = Vector2.ZERO.distance_to(mid_point)
	
	for i in range(maze.width):
		for j in range(maze.height):
			if maze.is_wall(i, j):
				var pos = Vector2(i+.5, j+.5) * GlobalVariables.my_scale
				var wall = preload("res://World/Wall.tscn").instance()
				if maze.is_border_v2(i, j):
					wall.set_border()
				else:
					wall.calculate_hp(1 - pos.distance_to(mid_point)/max_dist)
				wall.set_position(pos)
				wall.set_scale(GlobalVariables.scale_vector)
				$YSort.add_child(wall)

func initialise_players(n_players):
	var players = []
	
	for _i in range(n_players):
		players.append(preload("res://Player/Player.tscn").instance())
		
	for i in range(n_players):
		var dir = Vector2(i % 2, abs(i % 2 - i / 2))
		var aux = GlobalVariables.my_scale * 1.5 * (Vector2.ONE - dir * 2)
		players[i].set_position(dir * GlobalVariables.my_scale * Vector2(maze.width, maze.height) + aux)
		
	for i in range(n_players):
		players[i].my_init(get_keys_for_player(i), get_sprite_for_player(i), players, str(i+1), huds[i])
		players[i].set_scale(GlobalVariables.scale_vector)
		$YSort.add_child(players[i])
		var spawner = load("res://Logic/BoomBoxSpawner.gd").new(players[i].position)
		maze.remove_path(players[i].position)
		$YSort.add_child(spawner)
		spawner.spawn()

func initialise_lights(n_lights):
	var random_positions = maze.get_random_paths(n_lights)
	for pos in random_positions:
		var vec = maze.convert_to_vector(pos)
		var light = preload("res://World/Torch.tscn").instance()
		light.set_position((vec + Vector2(.5, .5)) * GlobalVariables.my_scale)
		light.set_scale(GlobalVariables.scale_vector)
		$YSort.add_child(light)
		
func initialise_spawners():
	for pos in maze.path_positions:
		if Utils.diracs([.05, .95]) == 0:
			var vec = maze.convert_to_vector(pos)
			var spawner = load("res://Logic/BoomBoxSpawner.gd").new((vec + Vector2(.5, .5)) * GlobalVariables.my_scale)
			$YSort.add_child(spawner)
			spawner.spawn()

func get_sprite_for_player(i):
	return load("res://Player/Player" + str(i+1) + ".png")

func get_keys_for_player(i):
	return ["p" + str(i+1) + "_right",
			"p" + str(i+1) + "_down", 
			"p" + str(i+1) + "_left", 
			"p" + str(i+1) + "_up", 
			"p" + str(i+1) + "_bomb",
			"p" + str(i+1) + "_big_bomb",
			"p" + str(i+1) + "_land_mine",
			"p" + str(i+1) + "_c4"]

func game_over():
	hud_is_visible(false)
	$GameOver.visible = true
	if Settings.sound_fx_enabled:
		$gameover_fx.play()
	
func is_over():
	return $GameOver.visible
	
func hud_is_visible(is_visible):
	for h in huds: 
		h.visible(is_visible)
	
