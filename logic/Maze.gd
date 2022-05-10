

var width
var height
var current

var directions_1d = []

var path_stack = []
var path_positions = []


func _init(w, h):
	width = w
	height = h
	directions_1d = [1, w, -1, -w]
	var x = floor(Utils.discrete(0, width - 2) / 2) * 2 + 1
	var y = floor(Utils.discrete(0, height - 2) / 2) * 2 + 1
	current = convert_to_position(x, y)
	path_positions = [current]
	path_stack = [current]

func generate_maze():
	while step():
		pass

func step():
	var next_direction = next_available_random_direction()

	if next_direction == 0:	# if at a dead end
		if path_stack.empty():
			return false
		current = path_stack.pop_back()
		return true
	walk(next_direction)
	return true

func walk(dir):
	path_positions.append(current + dir)
	path_positions.append(current + 2*dir)
	current += 2*dir
	path_stack.append(current)

func next_available_random_direction():
	var available_directions = []

	for direction in directions_1d:
		var possible_path = current + 2 * direction
		if is_wall_v2(possible_path) && !is_border(possible_path):
			available_directions.append(direction)
	
	if available_directions.empty():
		return 0
	
	return available_directions[Utils.discrete(0, available_directions.size())]

func remove_path(vector):
	var x = floor(vector.x / GlobalVariables.my_scale)
	var y = floor(vector.y / GlobalVariables.my_scale)
	var pos = convert_to_position(x, y)
	for i in range(path_positions.size()):
		if path_positions[i] == pos:
			path_positions.remove(i)
			return

func is_path(x, y):
	return convert_to_position(x, y) in path_positions

func is_wall(x, y):
	return !convert_to_position(x, y) in path_positions

func is_path_v2(pos):
	return pos in path_positions

func is_wall_v2(pos):
	return !pos in path_positions

func is_border(pos):
	var v = convert_to_vector(pos)
	return v.x == 0 || v.x == width - 1 || v.y == 0 || v.y == height - 1 || pos > width * height || pos < 0

func is_border_v2(i, j):
	return i == 0 || i == width - 1 || j == 0 || j == height - 1

func convert_to_position(x, y):
	return x + y * width

func convert_to_vector(pos):
	return Vector2(int(pos) % width, int(pos) / width)

func empty_corners(s):
	for i in range(0, s):
		for d in [[0, 1], [1, 0]]:
			var posUL = convert_to_position(1 + i * d[0], 1 + i * d[1])
			var posUR = convert_to_position(width - i * d[0] - 2, i * d[1] + 1)
			var posDR = convert_to_position(width - i * d[0] - 2, height - i * d[1] - 2)
			var posDL = convert_to_position(1 + i * d[0], height - i * d[1] - 2)
			path_positions += [posUL, posUR, posDR, posDL]

func make_room(x, y, w, h):
	for i in range(x, x+w):
		for j in range(y, y+h):
			if is_wall(i, j):
				path_positions.append(convert_to_position(i, j))

func put_walls(percent):
	var n = floor(path_positions.size() * percent)
	for _i in range(n):
		path_positions.remove(Utils.discrete(0, path_positions.size()))

func get_random_paths(nPaths):
	assert(nPaths < path_positions.size(), "")
	var paths = []
	for _i in range(nPaths):
		var random_pos = Utils.discrete(0, path_positions.size())
		paths.append(path_positions[random_pos])
		path_positions.remove(random_pos)
	return paths
