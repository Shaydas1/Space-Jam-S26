extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gen_city(5, 7) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func gen_city(n: int, m: int) -> void:
	# Building -> road
	# Building at 0,0 has:
	# Road at horizontal 0,0 below
	# Road at arrpos 1,0 above
	# Road at arrpos 0,0 left
	# Road at arrpos 0,1 right
	
	var horizontal_roads: Array[Array]
	horizontal_roads.resize(n + 1)
	for horz_road_row in horizontal_roads:
		horz_road_row.resize(m + 1)
		horz_road_row.fill(true)
	
	var vertical_roads: Array[Array]
	vertical_roads.resize(n + 1)
	for vertical_road_line in vertical_roads:
		vertical_road_line.resize(m + 1)
		vertical_road_line.fill(true)
	
	var intersections: Array[Array]
	intersections.resize(n + 1)
	for intersection_row in intersections:
		intersection_row.resize(m + 1)
		intersection_row.fill(4)
		intersection_row[0] = 3
		intersection_row[m] = 3
	intersections[0].fill(3)
	intersections[n].fill(3)
	
	var buildings: Array[Array] # It's a 3d array. Type definitions being weird.
	buildings.resize(n)
	for building_row in buildings:
		building_row.resize(m)
		var x = ["S", 1]
		building_row.fill(x)
	
	print(buildings)
	
	# Generate 0.75 * n * m random roads to set to false
	# Reject setting to false if:
	# 1. It would create an illegal building
	# 2. It would set an intersection degree to less than 2
	# 3. It would put an L shape "centered" at (1, 1) or (n-1, m-1)
	
	var road_removals: int = 0.75 * (n + 1) * (m + 1)
	var random_gen = RandomNumberGenerator.new()
	var index_types = {"D": 0, "Q": 0, "L": 0}
	for r in range(0, road_removals):
		# 0 is horizontal, 1 is vertical
		var h_or_v = random_gen.randi_range(0, 1)
		var i = random_gen.randi_range(0, n)
		var j = random_gen.randi_range(0, m)
		
		var road_array
		var bp: Array = [i, j] # Building Position
		if h_or_v == 0:
			road_array = horizontal_roads
		else:
			road_array = vertical_roads
		
		# If the road is already gone, dead iteration
		if (road_array[i][j] == false):
			continue
		

		
		# 1. Check for illegal building construction
		# Only applies to non-edge roads
		if (0 < i and i < n and 0 < j and j < m):
			var valid_removal = false
			var matched_buildings: Array
			var index_type
			
			var building_up = buildings.get(bp[0]).get(bp[1])
			var building_up_left = buildings.get(bp[0]).get(bp[1] - 1)
			var building_up_right = buildings.get(bp[0]).get(bp[1] + 1)
			
			var building_down = buildings.get(bp[0] - 1).get(bp[1])
			var building_down_left = buildings.get(bp[0] - 1).get(bp[1] - 1)
			var building_down_right = buildings.get(bp[0] - 1).get(bp[1] + 1)
			
			# Horizontal road case
			if (h_or_v == 0):
				# S to S: create 2x1 shape
				if (building_up[0] == "S" and building_down[0] == "S"):
					valid_removal = true
					matched_buildings = [building_up, building_down]
					index_type = "D"
				
				# D to S: create L shape
				elif (building_up[0] == "S" and building_down[0] == "D"):
					# Check if double goes left
					if (building_down_left == building_down):
						# There is an L, with points up and left
						valid_removal = true
						matched_buildings = [building_up, building_down, building_down_left]
						index_type = "L"
					elif (building_down_right == building_down):
						# There is an L, with points up and right
						valid_removal = true
						matched_buildings = [building_up, building_down, building_down_right]
						index_type = "L"
						
				# Also L shape
				elif (building_up[0] == "D" and building_down[0] == "S"):
					# Check if double goes left
					if (building_up_left == building_up):
						# There is an L, with points up and left
						valid_removal = true
						matched_buildings = [building_up, building_down, building_up_left]
						index_type = "L"
					elif (building_up_right == building_down):
						# There is an L, with points up and right
						valid_removal = true
						matched_buildings = [building_up, building_down, building_up_right]
						index_type = "L"
					
					# S to L: Create 2x2 shape
					elif (building_up[0] == "L" and building_down[0] == "S"):
						pass
					
				# Check for 2x2 shape
				# Check for 3 block L shape
				
			# Vertical road case
			else:
				
				pass
			
			remove_road(i, j, h_or_v, matched_buildings, index_type, buildings, index_types, intersections, road_array)
			

func remove_road(i, j, h_or_v, matched_buildings, index_type, buildings, index_types, intersections, road_array):
	# There is an L, with points up and left
	for building in matched_buildings:
		building[0] = index_type
		building[1] = index_types[index_type]
	index_types[index_type] += 1
	
	road_array[i][j] = false
	# Reduce degree of both connected intersections by 1
	# Horizontal:
	if (h_or_v == 0):
		intersections[i][j] = intersections[i][j] - 1
		intersections[i][j + 1] = intersections[i][j + 1] - 1
	# Vertical:
	else:
		intersections[i][j] = intersections[i][j] - 1
		intersections[i + 1][j] = intersections[i + 1][j] - 1
