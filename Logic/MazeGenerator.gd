extends Node2D

var maze
var players = []
var selfPeerID = null
var sprites = []
var huds = []

func _ready():
	Settings.load_settings()
	if Settings.p1_act:
		sprites.append(Settings.p1)
	if Settings.p2_act:
		sprites.append(Settings.p2)
	if Settings.p3_act:
		sprites.append(Settings.p3)
	if Settings.p4_act:
		sprites.append(Settings.p4)
	randomize()
	my_init()

	if GameModes.multiplayer_online:
		selfPeerID = get_tree().get_network_unique_id()

func getPlayerByID(id):
	for player in players:
		if player.ownerID == id:
			return player
	return null

remote func syncWall(b, pos, hp):
	var wall = preload("res://World/Wall.tscn").instance()
	wall.set_position(pos)
	wall.set_scale(GlobalVariables.scale_vector)

	if b:
		wall.set_border()
	else:
		wall.health = hp
	wall.set_texture()

	$YSort.add_child(wall)

remote func syncLight(pos):
	var vec = maze.convert_to_vector(pos)
	var light = preload("res://World/Torch.tscn").instance()
	light.set_position((vec + Vector2(.5, .5)) * GlobalVariables.my_scale)
	light.set_scale(GlobalVariables.scale_vector)
	$YSort.add_child(light)

remote func syncSpawner(pos):
	var vec = maze.convert_to_vector(pos)
	var spawner = load("res://Logic/BoomBoxSpawner.gd").new((vec + Vector2(.5, .5)) * GlobalVariables.my_scale)
	$YSort.add_child(spawner)
	spawner.spawn()

remote func syncPlayer(id):
	players.append(preload("res://Player/Player.tscn").instance())
	var i = len(players) - 1
	var dir = Vector2(i % 2, abs(i % 2 - i / 2))
	var aux = GlobalVariables.my_scale * 1.5 * (Vector2.ONE - dir * 2)
	players[i].ownerID = id

	players[i].set_position(dir * GlobalVariables.my_scale * Vector2(maze.width, maze.height) + aux)
	if get_tree().get_network_unique_id() == id:
		players[i].my_init(get_keys_for_multiplayer("multiplayer"), get_sprite_for_player(i%2), players, str(i+1), huds[0])
	else:
		players[i].my_init(get_keys_for_multiplayer("multiplayer"), get_sprite_for_player(i%2), players, str(i+1), null)
	#players[i].my_init(get_keys_for_player(0), get_sprite_for_player(i%2), players, str(i+1), null)
	players[i].set_scale(GlobalVariables.scale_vector)
	$YSort.add_child(players[i])
	var spawner = load("res://Logic/BoomBoxSpawner.gd").new(players[i].position)
	maze.remove_path(players[i].position)
	$YSort.add_child(spawner)
	spawner.spawn()

remote func init_huds_everyone(n):
	huds.append(initialise_hud("bottom_right"))

func my_init():
	if GameModes.multiplayer_online:
		if !get_tree().is_network_server():
			maze = load("res://Logic/Maze.gd").new(GlobalVariables.my_width, GlobalVariables.my_height)
			#maze.generate_maze()
		else:
			maze = load("res://Logic/Maze.gd").new(GlobalVariables.my_width, GlobalVariables.my_height)
			maze.generate_maze()

			OS.delay_msec(1500)

			initialise_walls()
			#initialise_huds(1)
			rpc("init_huds_everyone", 1)
			initialise_players(len(get_tree().get_network_connected_peers())+1)
			initialise_lights(12)
			initialise_spawners()

	else:
		maze = load("res://Logic/Maze.gd").new(GlobalVariables.my_width, GlobalVariables.my_height)
		maze.generate_maze()

		initialise_walls()
		if not GameModes.singlePlayer:
			initialise_huds(sprites.size())
		initialise_players(sprites.size())
		initialise_lights(12)
		initialise_spawners()


	if Settings.music_enabled:
			$music.volume_db = Settings.music_volume - 25
			$music.play()

	if Settings.fog_of_war:
		$CanvasModulate.set_color(Color(0,0,0))
	else:
		$CanvasModulate.set_color(Color(0.5,0.5,0.5))

	if GameModes.multiplayer_online:
		if get_tree().is_network_server():
			rpc("syncFogOfWar", Settings.fog_of_war)

remote func syncFogOfWar(b):
	if b:
		$CanvasModulate.set_color(Color(0,0,0))
	else:
		$CanvasModulate.set_color(Color(0.5,0.5,0.5))

func initialise_huds(n_players):
	for i in range(n_players):
		if i == 0:
			huds.append(initialise_hud("top_left"))
		elif i == 1:
			huds.append(initialise_hud("bottom_right"))
		elif i == 2:
			huds.append(initialise_hud("top_right"))
		elif i == 3:
			huds.append(initialise_hud("bottom_left"))
			

func initialise_hud(location):
		var hud = preload("res://HUD.tscn").instance()
		var pos = Vector2(0, 0)
		if location == "bottom_left":
			pos = Vector2(0, maze.height - 1) * GlobalVariables.my_scale
		elif location == "bottom_right":
			pos = Vector2(maze.width - 7, maze.height - 1) * GlobalVariables.my_scale
		elif location == "top_left":
			pos = Vector2(0, 0) * GlobalVariables.my_scale
		elif location == "top_right":
			pos = Vector2(maze.width - 7, 0) * GlobalVariables.my_scale
		elif location == "bottom_middle":
			pos = Vector2(maze.width/2 - 3, maze.height - 1) * GlobalVariables.my_scale
		hud.set_position(pos - Vector2(0, 1))
		$YSort.add_child(hud)
		return hud


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

				if GameModes.multiplayer_online:
					if get_tree().is_network_server():
						$YSort.add_child(wall)
						rpc("syncWall", maze.is_border_v2(i, j), pos, wall.health)
				else:
					$YSort.add_child(wall)
					WorldObjects.walls.append(wall)
func initialise_players(n_players):
	var ids = []
	if GameModes.multiplayer_online:
		if get_tree().is_network_server():
			ids.append(1)
		for p in get_tree().get_network_connected_peers():
			ids.append(p)
	if GameModes.singlePlayer:
		n_players = 2

	for i in range(n_players):
		if GameModes.singlePlayer:
			if i == 0:
				players.append(GameModes.agent)
				WorldObjects.agent = players[0]
			else:
				players.append(preload("res://Player/Player.tscn").instance())
				WorldObjects.player = players[1]
		else:
			players.append(preload("res://Player/Player.tscn").instance())
			if GameModes.multiplayer_online:
				players[i].ownerID = ids[i]

		var dir = Vector2(i % 2, abs(i % 2 - i / 2))
		var aux = GlobalVariables.my_scale * 1.5 * (Vector2.ONE - dir * 2)

		players[i].set_position(dir * GlobalVariables.my_scale * Vector2(maze.width, maze.height) + aux)
	
		if GameModes.singlePlayer:
			if i == 0:
				players[i].my_init(get_keys_for_player(i), get_sprite_for_agent(0), players)
				players[i].set_scale(GlobalVariables.scale_vector)
				$YSort.add_child(players[i])
				var spawner = load("res://Logic/BoomBoxSpawner.gd").new(players[i].position)
				maze.remove_path(players[i].position)
				$YSort.add_child(spawner)
				WorldObjects.spawners.append(spawner)
				spawner.spawn()
			else:
				var hud = initialise_hud("bottom_right")
				huds.append(hud)
				players[i].my_init(get_keys_for_player(1), get_sprite_for_player(0), players, "2", hud)
				players[i].set_scale(GlobalVariables.scale_vector)
				$YSort.add_child(players[i])
				var spawner = load("res://Logic/BoomBoxSpawner.gd").new(players[i].position)
				maze.remove_path(players[i].position)
				$YSort.add_child(spawner)
				WorldObjects.spawners.append(spawner)
				spawner.spawn()
		else:
			#IP
			if GameModes.multiplayer_online:
				if get_tree().get_network_unique_id() == ids[i]:
					var hud = initialise_hud("bottom_right")
					huds.append(hud)
					players[i].my_init(get_keys_for_multiplayer("multiplayer"), get_sprite_for_player(i%2), players, str(i+1), hud)
				else:
					players[i].my_init(get_keys_for_multiplayer("multiplayer"), get_sprite_for_player(i%2), players, str(i+1), null)
			else:
				players[i].my_init(get_keys_for_player(i), get_sprite_for_player(i), players, str(i+1), huds[i])
			players[i].set_scale(GlobalVariables.scale_vector)
			$YSort.add_child(players[i])
			var spawner = load("res://Logic/BoomBoxSpawner.gd").new(players[i].position)
			maze.remove_path(players[i].position)
			$YSort.add_child(spawner)
			spawner.spawn()
			if GameModes.multiplayer_online:
				rpc("syncPlayer", ids[i])
	GameModes.players = players


func initialise_lights(n_lights):
	var random_positions = maze.get_random_paths(n_lights)
	for pos in random_positions:
		var vec = maze.convert_to_vector(pos)
		var light = preload("res://World/Torch.tscn").instance()
		light.set_position((vec + Vector2(.5, .5)) * GlobalVariables.my_scale)
		light.set_scale(GlobalVariables.scale_vector)

		if GameModes.multiplayer_online:
			if get_tree().is_network_server():
				$YSort.add_child(light)
				rpc("syncLight", pos)
		else:
			$YSort.add_child(light)

func initialise_spawners():
	for pos in maze.path_positions:
		if Utils.diracs([.05, .95]) == 0:
			var vec = maze.convert_to_vector(pos)
			var spawner = load("res://Logic/BoomBoxSpawner.gd").new((vec + Vector2(.5, .5)) * GlobalVariables.my_scale)

			if GameModes.multiplayer_online:
				if get_tree().is_network_server():
					$YSort.add_child(spawner)
					spawner.spawn()
					rpc("syncSpawner", pos)
			else:
				$YSort.add_child(spawner)
				WorldObjects.spawners.append(spawner)
				spawner.spawn()

func get_sprite_for_player(i):
	return load("res://Player/Player" + str(sprites[i]) + ".png")

func get_sprite_for_agent(i):
	return load("res://Autonomous_Agent/AI1" + ".png")

func get_keys_for_multiplayer(i):
	return [i + "_right",
			i + "_down",
			i + "_left",
			i + "_up",
			i + "_bomb",
			i + "_big_bomb",
			i + "_land_mine",
			i + "_c4"]

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
	if GameModes.winner() != null:
		if GameModes.singlePlayer:
			if GameModes.winner().player == "2":
				$GameOver/Label.text = "You won!"
			else:
				$GameOver/Label.text = "You lost!"
		elif GameModes.multiplayer_online:
			if GameModes.winner() == getPlayerByID(get_tree().get_network_unique_id()):
				$GameOver/Label.text = "You won!"
			else:
				$GameOver/Label.text = "You lost!"
		else:
			$GameOver/Label.text = str("Player ", str(GameModes.winner().player), " won!")
	GameModes.players = []
	
	hud_is_visible(false)
	$GameOver.visible = true
	if Settings.sound_fx_enabled:
		$gameover_fx.play()

func is_over():
	return $GameOver.visible

func hud_is_visible(is_visible):
	for h in huds:
		h.visible(is_visible)

func update_huds():
	for h in huds:
		h.updateLabels()
