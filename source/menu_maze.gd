extends Node2D

var maze
var players = []

func _ready():
	randomize()
	my_init()

func my_init():
	var menu_limit = 17
	maze = load("res://Logic/Maze.gd").new(GlobalVariables.my_width, menu_limit)
	for i in range(GlobalVariables.my_width):
		for j in range(menu_limit, GlobalVariables.my_height):
			var wall = preload("res://World/Wall.tscn").instance()
			wall.set_position(Vector2(i+.5, j+.5) * GlobalVariables.my_scale)
			wall.set_scale(GlobalVariables.scale_vector)
			$YSort.add_child(wall)
	maze.generate_maze()

	initialise_walls()
	
	initialise_player()
	write_title()
	
	
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
				var y = i[1] + word_count
				var pos = Vector2(x+.5, y+.5) * GlobalVariables.my_scale
				wall.set_position(pos)
				wall.set_scale(GlobalVariables.scale_vector)
				wall.calculate_hp(0.7)
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

func initialise_player():
	var player = preload("res://Player/Player.tscn").instance()
	var dir = Vector2(1 % 2, abs(1 % 2 - 1 / 2))
	var aux = GlobalVariables.my_scale * 1.5 * (Vector2.ONE - dir * 2)
	player.set_position(dir * GlobalVariables.my_scale * Vector2(maze.width, maze.height) + aux)
	players.append(preload("res://Player/Player.tscn").instance())
	players.append(player)
	player.my_init(get_keys_for_player(1), get_sprite_for_player(1), players, "2", null)
	player.set_scale(GlobalVariables.scale_vector)
	$YSort.add_child(player)
	var spawner = load("res://Logic/BoomBoxSpawner.gd").new(player.position)
	maze.remove_path(player.position)
	$YSort.add_child(spawner)
	spawner.spawn()
		
func get_keys_for_player(i):
	return ["p" + str(i+1) + "_right",
			"p" + str(i+1) + "_down", 
			"p" + str(i+1) + "_left", 
			"p" + str(i+1) + "_up", 
			"p" + str(i+1) + "_bomb",
			"p" + str(i+1) + "_big_bomb",
			"p" + str(i+1) + "_land_mine",
			"p" + str(i+1) + "_c4"]

func get_sprite_for_player(i):
	return load("res://Player/Player" + str(i+1) + ".png")
	
func game_over():
	pass
	
func is_over():
	pass
