extends Node2D

var maze
var players = []
var networkMazeSet = false
var selfPeerID

func _ready():
	randomize()
	my_init()
	#if GameModes.multiplayer_online():
	#	selfPeerID = get_tree().get_network_unique_id()
	#	self.set_network_master(selfPeerID)

remote func syncWall(w):
	$YSort.add_child(w)
	
remote func syncMaze(m):
	networkMazeSet = true
	maze = m

func my_init():
	if GameModes.multiplayer_online():
		if !get_tree().is_network_server():
			while !networkMazeSet:
				continue
			initialise_players(2)
			initialise_lights(12)
			initialise_spawners()
		else:
			maze = load("res://Logic/Maze.gd").new(GlobalVariables.my_width, GlobalVariables.my_height)
			maze.generate_maze()
			
			rpc("syncMaze", maze)
			
			initialise_walls()
			initialise_players(2)
			initialise_lights(12)
			initialise_spawners()
	else:
		maze = load("res://Logic/Maze.gd").new(GlobalVariables.my_width, GlobalVariables.my_height)
		maze.generate_maze()
		
		initialise_walls()
		initialise_players(2)
		initialise_lights(12)
		initialise_spawners()

	if Settings.fog_of_war:
		$CanvasModulate.set_color(Color(0,0,0))
	else:
		$CanvasModulate.set_color(Color(0.5,0.5,0.5))


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
				if GameModes.multiplayer_online():
					if get_tree().is_network_server():
						$YSort.add_child(wall)
						rpc("syncWall", wall)
				else:
					$YSort.add_child(wall)

func initialise_players(n_players):
	for i in range(n_players):
		if GameModes.singlePlayer:
			if i == 0:
				players.append(preload("res://Autonomous_Agent/Autonomous_Agent.tscn").instance())
			else:
				players.append(preload("res://Player/Player.tscn").instance())
		else:
			players.append(preload("res://Player/Player.tscn").instance())

	for i in range(n_players):
		var dir = Vector2(i % 2, abs(i % 2 - i / 2))
		var aux = GlobalVariables.my_scale * 1.5 * (Vector2.ONE - dir * 2)
		players[i].set_position(dir * GlobalVariables.my_scale * Vector2(maze.width, maze.height) + aux)

	for i in range(n_players):
		if GameModes.singlePlayer:
			if i == 0:
				players[i].my_init(get_keys_for_player(i), get_sprite_for_agent(i), players)
				players[i].set_scale(GlobalVariables.scale_vector)
				$YSort.add_child(players[i])
				var spawner = load("res://Logic/BoomBoxSpawner.gd").new(players[i].position)
				maze.remove_path(players[i].position)
				$YSort.add_child(spawner)
				spawner.spawn()
			else:
				players[i].my_init(get_keys_for_player(i), get_sprite_for_player(i), players)
				players[i].set_scale(GlobalVariables.scale_vector)
				$YSort.add_child(players[i])
				var spawner = load("res://Logic/BoomBoxSpawner.gd").new(players[i].position)
				maze.remove_path(players[i].position)
				$YSort.add_child(spawner)
				spawner.spawn()
		else:
			players[i].my_init(get_keys_for_player(i), get_sprite_for_player(i), players)
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
	
func get_sprite_for_agent(i):
	return load("res://Autonomous_Agent/AI" + str(i+1) + ".png")

func get_keys_for_player(i):
	return ["p" + str(i+1) + "_right",
			"p" + str(i+1) + "_down",
			"p" + str(i+1) + "_left",
			"p" + str(i+1) + "_up",
			"p" + str(i+1) + "_bomb",
			"p" + str(i+1) + "_big_bomb"]

func game_over():
	$GameOver.visible = true
	if Settings.sound_fx_enabled:
		$gameover_fx.play()

func is_over():
	return $GameOver.visible
