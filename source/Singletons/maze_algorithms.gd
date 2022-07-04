extends Node

var rowNum = [-1, 0, 0, 1]
var colNum = [0, -1, 1, 0]

func is_valid(row, col, mat):
	return (row >= 0) and (row < len(mat)) and (col >= 0) and (col < len(mat[0]))
	
func shortest_path(mat, src, dest):
	if !(is_valid(src.x, src.y, mat) and is_valid(dest.x, dest.y, mat)):
		return []
	if mat[src.x][src.y] == 1 or mat[dest.x][dest.y] == 1:
		return []

	var visited = init_visited(mat)
	visited[src.x][src.y] = true
	
	var q = []
	q.append([src, 0])
	var expanded = []
	var path = []
	
	
	while len(q) != 0:
		var current = q.pop_front()
		var point = current[0]
		if point.x == dest.x and point.y == dest.y:
			var previous = point
			while len(expanded) != 0:
				var p = expanded.pop_back()
				if p["point"].x == previous.x and p["point"].y == previous.y: 
					path.append(p["point"])
					previous = p["previous"]
			return path
		
		for i in range(4):
			var row = point.x + rowNum[i]
			var col = point.y + colNum[i]
			
			if is_valid(row, col, mat) and mat[row][col] == 0 and not visited[row][col]:
				visited[row][col] = true
				q.append([Vector2(row, col), current[1]+1])
				expanded.append({"point":Vector2(row, col), "previous":point})
				
	return []
	
func shortest_path_distance(mat, src, dest):
	if !(is_valid(src.x, src.y, mat) and is_valid(dest.x, dest.y, mat)):
		return -1
	if mat[src.x][src.y] == 1 or mat[dest.x][dest.y] == 1:
		return -1
	
	var visited = init_visited(mat)
	visited[src.x][src.y] = true
	
	var q = []
	q.append([src, 0])
	
	while len(q) != 0:
		var current = q.pop_front()
		var point = current[0]
		if point.x == dest.x and point.y == dest.y:
			return current[1]
		
		for i in range(4):
			var row = point.x + rowNum[i]
			var col = point.y + colNum[i]
			
			if is_valid(row, col, mat) and mat[row][col] == 0 and not visited[row][col]:
				visited[row][col] = true
				q.append([Vector2(row, col), current[1]+1])
				
	return -1
	
func closest_spawner(mat, src):
	if mat[src.x][src.y]["walls"] == 1:
		return null
	
	var visited = init_visited(mat)
	visited[src.x][src.y] = true
	
	var q = []
	q.append([src, 0])
	
	while len(q) != 0:
		var current = q.pop_front()
		var point = current[0]
		var spawner = mat[point.x][point.y]["spawners"]
		if spawner != null:
			if spawner.boomBoxHere:
				return current[0]
		
		for i in range(4):
			var row = point.x + rowNum[i]
			var col = point.y + colNum[i]
			
			if is_valid(row, col, mat) and mat[row][col]["walls"] == 0 and not visited[row][col] :
				visited[row][col] = true
				q.append([Vector2(row, col), current[1]+1])
				
	return null
	
func closest_coordinate(mat, src, dest):
	if !(is_valid(src.x, src.y, mat) and is_valid(dest.x, dest.y, mat)):
		return null
	if mat[src.x][src.y] == 1 or mat[dest.x][dest.y] == 1:
		return null
	
	var closest_point = src
	
	var visited = init_visited(mat)
	visited[src.x][src.y] = true
	
	var q = []
	q.append([src, 0])
	
	while len(q) != 0:
		var current = q.pop_front()
		var point = current[0]
		if point.x == dest.x and point.y == dest.y:
			return point
		
		for i in range(4):
			var row = point.x + rowNum[i]
			var col = point.y + colNum[i]
			
			if is_valid(row, col, mat) and mat[row][col] == 0 and not visited[row][col]:
				visited[row][col] = true
				q.append([Vector2(row, col), current[1]+1])
				if euc_distance(point, dest) < euc_distance(src, dest):
					closest_point = Vector2(row, col)
				
	return closest_point

	
func point_of_segment(p1, p2, t):
	return Vector2(p1.x + t*(p2.x - p1.x), p1.y + t*(p2.y - p1.y))
	


func is_reachable(mat, src, dest):
	if !(is_valid(src.x, src.y, mat) and is_valid(dest.x, dest.y, mat)):
		return false
	if mat[src.x][src.y] == 1 or mat[dest.x][dest.y] == 1:
		return false
	
	var visited = init_visited(mat)
	visited[src.x][src.y] = true
	
	var q = []
	q.append([src, 0])
	
	while len(q) != 0:
		var current = q.pop_front()
		var point = current[0]
		if point.x == dest.x and point.y == dest.y:
			return true
		
		for i in range(4):
			var row = point.x + rowNum[i]
			var col = point.y + colNum[i]
			
			if is_valid(row, col, mat) and mat[row][col] == 0 and not visited[row][col]:
				visited[row][col] = true
				q.append([Vector2(row, col), current[1]+1])
				
	return false

func safe_spot(mat, src, points):
	if mat[src.x][src.y]["walls"] == 1:
		return null
	
	var safe_spot = src
	
	var visited = init_visited(mat)
	visited[src.x][src.y] = true
	
	var q = []
	q.append([src, 0])
	
	while len(q) != 0:
		var current = q.pop_front()
		var point = current[0]
		
		for i in range(4):
			var row = point.x + rowNum[i]
			var col = point.y + colNum[i]
			
			if is_valid(row, col, mat) and mat[row][col]["walls"] == 0 and not visited[row][col]:
				visited[row][col] = true
				q.append([Vector2(row, col), current[1]+1])
				if not points.has(Vector2(row, col)):
					return Vector2(row, col)
				
	return null

func init_visited(mat):
	var visited = []
	for i in range(len(mat)):
		var lst = []
		for j in range(len(mat[i])):
			lst.append(false)
		visited.append(lst)
	return visited
		
		
func euc_distance(p1, p2):
	return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
