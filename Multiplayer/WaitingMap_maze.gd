extends Node2D

var maze
var players = []
var playerList = {}
var playersInfo = {}
var connected = false

	
remote func syncPlayers(pl):
	for p in pl.keys():
		var new = true
		for p1 in playerList.keys():
			if p == p1:
				new = false
		if new:
			add_player(p, pl[p][1], pl[p][2])
			print(playerList)

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	#connected_players += 1

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")
	#connected_players -= 1

remote func register_player(nick, skin):
	add_player(get_tree().get_rpc_sender_id(), nick, skin)
	rpc("syncPlayers", playerList)
	
func _connected_to_server() -> void:
	rpc_id(1, "register_player", Settings.p1_name, Settings.p1)

func _ready():
	Network.syncNumber = 0
	randomize()
	GameModes.waiting_lobby()
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	if !get_tree().is_network_server():
		get_parent().get_node("Start_Game").visible = false
		client_init()
	else:
		add_child(Network.advertiser)
		server_init()

func client_init():
	maze = load("res://Logic/Maze.gd").new(GlobalVariables.my_width, GlobalVariables.my_height)
	maze.generate_maze()
	
	initialise_walls()
	write_title()
	
	
func server_init():
	maze = load("res://Logic/Maze.gd").new(GlobalVariables.my_width, GlobalVariables.my_height)
	for i in range(GlobalVariables.my_width):
		for j in range(GlobalVariables.my_height - 0,GlobalVariables.my_height):
			var wall = preload("res://World/Wall.tscn").instance()
			wall.set_position(Vector2(i+.5, j+.5) * GlobalVariables.my_scale)
			wall.set_scale(GlobalVariables.scale_vector)
			$YSort.add_child(wall)
	maze.generate_maze()

	initialise_walls()
	write_title()
	
	add_player(1, Settings.p1_name, Settings.p1)

func write_title():
	var M = [[1,1],[1,2],[1,3],[1,4],[1,5],[2,2],[3,3],[4,2],[5,1],[5,2],[5,3],[5,4],[5,5]]
	var A = [[1,2],[1,3],[1,4],[1,5],[2,1],[3,1],[2,3],[3,3],[4,2],[4,3],[4,4],[4,5]]
	var Z = [[1,1],[2,1],[3,1],[4,1],[3,2],[2,3],[1,4],[1,5],[2,5],[3,5],[4,5]]
	var E = [[1,1],[2,1],[3,1],[4,1],[1,2],[1,3],[1,4],[1,5],[2,3],[3,3],[2,5],[3,5],[4,5]]
	var B = [[1,1],[2,1],[3,1],[1,2],[1,3],[1,4],[1,5],[2,3],[3,3],[2,5],[3,5],[4,2],[4,4]]
	var O = [[1,2],[1,3],[1,4],[2,1],[3,1],[4,2],[4,3],[4,4],[2,5],[3,5]]
	var R = [[1,1],[2,1],[3,1],[1,2],[1,3],[1,4],[1,5],[2,3],[3,3],[4,2],[3,4],[4,5]]
	var title_wall = [[M,A,Z,E],[B,O,M,B,E,R]]
	
	var letter_count = 9
	var word_count = 2
	for word in title_wall:
		for letter in word:
			for i in letter:
				var wall = preload("res://World/Wall.tscn").instance()
				var x = i[0] + letter_count
				var y = 3 + i[1] + word_count
				var pos = Vector2(x+.5, y+.5) * GlobalVariables.my_scale
				wall.set_position(pos)
				wall.set_scale(GlobalVariables.scale_vector)
				wall.health = 100
				wall.set_border()
				$YSort.add_child(wall)
			letter_count+=5
			if letter == M:
				letter_count += 1
		word_count += 6
		letter_count = 4

func initialise_walls():
	#maze.put_walls(.2)
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
					wall.set_position(pos)
					wall.set_scale(GlobalVariables.scale_vector)
					$YSort.add_child(wall)

remote func add_player(id, nick, skin):
	var player = load("res://Player/Player.tscn").instance()
	var dir = Vector2(1 % 2, abs(1 % 2 - 1 / 2))
	var aux = GlobalVariables.my_scale * 1.5 * (Vector2.ONE - dir * 2)
	player.set_position(GlobalVariables.my_scale * Vector2(maze.width/2, maze.height/2) + Vector2(rand_range(0, 10), rand_range(0,10)))
	playerList[id] = [player, nick, skin]
	playersInfo[id] = [nick, skin]
	player.my_init(get_keys_for_multiplayer("multiplayer"), get_sprite_for_player(skin), players, "2", null)
	player.set_scale(GlobalVariables.scale_vector)
	player.get_node("Nickname").text = nick
	player.get_node("Nickname").visible = true
	player.number_of_bombs = 1000
	player.big_bombs = 1000
	player.c4 = 1000
	player.landMines = 1000
	
	playerList[id][0].ownerID = id
	playerList[id][0].name = "Player" + str(id)
	playerList[id][0].selfPeerID = get_tree().get_network_unique_id()
	$YSort.add_child(player)
	maze.remove_path(player.position)
		
func get_keys_for_player(i):
	return ["p" + str(i+1) + "_right",
			"p" + str(i+1) + "_down", 
			"p" + str(i+1) + "_left", 
			"p" + str(i+1) + "_up", 
			"p" + str(i+1) + "_bomb",
			"p" + str(i+1) + "_big_bomb",
			"p" + str(i+1) + "_land_mine",
			"p" + str(i+1) + "_c4"]
			
func get_keys_for_multiplayer(i):
	return [i + "_right",
			i + "_down",
			i + "_left",
			i + "_up",
			i + "_bomb",
			i + "_big_bomb",
			i + "_land_mine",
			i + "_c4"]

func get_sprite_for_player(i):
	return load("res://Player/Player" + str(i) + ".png")
	
func game_over():
	pass
	
func is_over():
	pass

remote func gameStart():
	GameModes.multiplayer_online()
	Network.players = playersInfo
	get_tree().change_scene("res://World.tscn")

func _on_Start_Game_pressed():
	if get_tree().is_network_server():
		Network.players = playersInfo
		GameModes.multiplayer_online()
		get_tree().change_scene("res://World.tscn")
		rpc("gameStart")

func _on_Back_pressed():
	GameModes.menu()
	get_tree().change_scene("res://Menu.tscn")
