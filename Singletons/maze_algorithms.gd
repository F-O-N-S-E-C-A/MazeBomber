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
	
		
func init_visited(mat):
	var visited = []
	for i in range(len(mat)):
		var lst = []
		for j in range(len(mat[i])):
			lst.append(false)
		visited.append(lst)
	return visited
		
		
	
