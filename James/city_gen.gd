extends Node

# NOTE: Currently, it's technically possible for a dead end to be generated
# on the outside edge if a 2x2 is created adjacent to the edge.
# Requires a specific scenario to occur. Leaving for now, seems low prio.
# To solve: Make a method for deleting a *pair* of streets for the 2x2 creation.
# then all 3 relevant intersections can be checked at once to avoid that case.

# Until then, the jank solution of just having 2x2 creation utterly ignore intersection
# degree requirements is being used.  ¯\_(ツ)_/¯.

# STILL TODO:
# - Fix 2x2's
# - Add random exits


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#test_gen_city()
	gen_city(5, 7)
	
	
func test_gen_city():
	var n = 5
	var m = 7
	# Test Sequences. Format: [h_or_v, i, j]
	var testing = true
	# L, points down and right
	var L_down_right_seq_1 = [[0, 2, 2], [1, 2, 3]]
	var L_down_right_seq_2 = [[1, 2, 3], [0, 2, 2]]
	# L, points down and left
	var L_down_left_seq_1 = [[0, 2, 2], [1, 2, 2]]
	var L_down_left_seq_2 = [[0, 2, 2], [1, 2, 2]]
	# L, points up and right
	var L_up_right_seq_1 = [[0, 2, 2], [1, 1, 3]]
	var L_up_right_seq_2 = [[0, 2, 2], [1, 1, 3]]
	# L, points up and left
	var L_up_left_seq_1 = [[0, 2, 2], [1, 1, 2]]
	var L_up_left_seq_2 = [[0, 2, 2], [1, 1, 2]]
	
	# 2x2 tests
	# L, points down and right
	var sqr_bottom_right_1 = [[0, 2, 2], [1, 2, 3], [0, 2, 3]]
	var sqr_bottom_right_2 = [[0, 2, 2], [1, 2, 3], [1, 1, 3]]
	# L, points down and left
	var sqr_bottom_left_1 = [[0, 2, 2], [1, 2, 2], [0, 2, 1]]
	var sqr_bottom_left_2 = [[0, 2, 2], [1, 2, 2], [1, 1, 2]]
	# L, points up and right
	var sqr_top_right_1 = [[0, 2, 2], [1, 1, 3], [0, 2, 3]]
	var sqr_top_right_2 = [[0, 2, 2], [1, 1, 3], [1, 2, 3]]
	# L, points up and left
	var sqr_up_left_1 = [[0, 2, 2], [1, 1, 2], [0, 2, 1]]
	var sqr_up_left_2 = [[0, 2, 2], [1, 1, 2], [1, 2, 2]]
	
	# var test_seq = L_down_right_seq_1
	var shape_test_seqs = [L_down_right_seq_1, L_down_right_seq_2, L_down_left_seq_1, L_down_left_seq_2,
	L_up_right_seq_1, L_up_right_seq_2, L_up_left_seq_1, L_up_left_seq_2,
	sqr_bottom_right_1, sqr_bottom_right_2, sqr_bottom_left_1, sqr_bottom_left_2, 
	sqr_top_right_1, sqr_top_right_2, sqr_up_left_1, sqr_up_left_2]
	
	var shape_test_seq_names = ["L_down_right_seq_1", "L_down_right_seq_2", "L_down_left_seq_1", "L_down_left_seq_2",
	"L_up_right_seq_1", "L_up_right_seq_2", "L_up_left_seq_1", "L_up_left_seq_2",
	"sqr_bottom_right_1", "sqr_bottom_right_2", "sqr_bottom_left_1", "sqr_bottom_left_2", 
	"sqr_top_right_1", "sqr_top_right_2", "sqr_up_left_1", "sqr_up_left_2"]
	
	
	var horz_intersection_deg_seq_1 = [[1, 0, 0], [0, 1, 0]]
	var vert_intersection_deg_seq_1 = [[0, 0, 0], [1, 0, 1]]
	
	var intersection_deg_test_seq = [horz_intersection_deg_seq_1, vert_intersection_deg_seq_1]
	
	var intersection_deg_seq_names = ["horz_intersection_deg_seq_1", "vert_intersection_deg_seq_1"]
	
	for t in range(0, shape_test_seqs.size()):
		print(shape_test_seq_names[t])
		gen_city(5, 7, shape_test_seqs[t])
	
	for t in range(0, intersection_deg_test_seq.size()):
		print(intersection_deg_seq_names[t])
		gen_city(5, 7, intersection_deg_test_seq[t])

func gen_city(n: int, m: int, test_seq = null):
	# Building -> road
	# Building at 0,0 has:
	# Road at horizontal 0,0 below
	# Road at arrpos 1,0 above
	# Road at arrpos 0,0 left
	# Road at arrpos 0,1 right
	
	var horizontal_roads: Array[Array]
	horizontal_roads.resize(n + 1)
	for horz_road_row in horizontal_roads:
		horz_road_row.resize(m)
		horz_road_row.fill(true)
	
	var vertical_roads: Array[Array]
	vertical_roads.resize(n)
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
	for buildings_row in buildings:
		buildings_row.resize(m)
		for j in range(0, m):
			buildings_row[j] = ["S", 1]
		
	# Generate 0.75 * n * m random roads to set to false
	# Reject setting to false if:
	# 1. It would create an illegal building
	# 2. It would set an intersection degree to less than 2
	# 3. It would put an L shape "centered" at (1, 1) or (n-1, m-1)
	var road_removals: int = 0.75 * (n + 1) * (m + 1)
	var random_gen = RandomNumberGenerator.new()
	var index_types = {"D": 0, "Q": 0, "L": 0}
	
	var testing = false
	if test_seq:
		testing = true
	
	for r in range(0, road_removals):
		# 0 is horizontal, 1 is vertical
		var h_or_v = random_gen.randi_range(0, 1)
		
		var road_array
		var i
		var j
		var n_boundary
		var m_boundary
		if testing:
			if (r >= test_seq.size()):
				break
			h_or_v = test_seq[r][0]
			i = test_seq[r][1]
			j = test_seq[r][2]
			if h_or_v == 0:
				road_array = horizontal_roads
				n_boundary = n
				m_boundary = m - 1
			elif h_or_v == 1:
				road_array = vertical_roads
				n_boundary = n - 1
				m_boundary = m
		elif h_or_v == 0:
			road_array = horizontal_roads
			# Index of boundary line
			n_boundary = n
			m_boundary = m - 1
			i = random_gen.randi_range(0, n)
			j = random_gen.randi_range(0, m - 1)
		else:
			road_array = vertical_roads
			n_boundary = n - 1
			m_boundary = m
			i = random_gen.randi_range(0, n - 1)
			j = random_gen.randi_range(0, m)
		
		var bp: Array = [i, j] # Building Position
		
		# If the road is already gone, dead iteration
		if (road_array[i][j] == false):
			continue
		
		# 1. Check for illegal building construction
		# Only applies to non-edge roads
		
		if (0 < i and i < n_boundary and 0 < j and j < m_boundary):
			var valid_removal = false
			var matched_buildings: Array
			var index_type
			var ignore_deg_req = false
			
			# Horizontal road case
			if (h_or_v == 0):
				var building_up = buildings.get(bp[0]).get(bp[1])
				var building_up_left = buildings.get(bp[0]).get(bp[1] - 1)
				var building_up_right = buildings.get(bp[0]).get(bp[1] + 1)
				
				var building_down = buildings.get(bp[0] - 1).get(bp[1])
				var building_down_left = buildings.get(bp[0] - 1).get(bp[1] - 1)
				var building_down_right = buildings.get(bp[0] - 1).get(bp[1] + 1)
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
						print("L, up and left")
					elif (building_down_right == building_down):
						# There is an L, with points up and right
						valid_removal = true
						matched_buildings = [building_up, building_down, building_down_right]
						index_type = "L"
						print("L, up and right")
						
				# Also L shape
				elif (building_up[0] == "D" and building_down[0] == "S"):
					# Check if double goes left
					if (building_up_left == building_up):
						# There is an L, with points down and left
						valid_removal = true
						matched_buildings = [building_up, building_down, building_up_left]
						index_type = "L"
						print("L, down and left")
					elif (building_up_right == building_up):
						# There is an L, with points down and right
						valid_removal = true
						matched_buildings = [building_up, building_down, building_up_right]
						index_type = "L"
						print("L, down and right")
					
				# S to L: Create 2x2 shape
				elif (building_up[0] == "S" and building_down[0] == "L"):
					# Check for S in top left corner of 2x2
					if (building_down == building_up_right):
						valid_removal = true
						matched_buildings = [building_up, building_down, building_up_right, building_down_right]
						index_type = "Q"
						
						# We need an additional removal, to skip a U shape and go straight to a 2x2
						remove_road(i, j + 1, 1, matched_buildings, index_type, buildings, index_types, intersections, road_array, ignore_deg_req)
					
					# Check for S in top right corner of 2x2
					elif (building_down == building_up_left):
						valid_removal = true
						matched_buildings = [building_up, building_down, building_up_left, building_down_left]
						index_type = "Q"
						
						# We need an additional removal, to skip a U shape and go straight to a 2x2
						remove_road(i, j, 1, matched_buildings, index_type, buildings, index_types, intersections, road_array, ignore_deg_req)
				
				# S to L: Create 2x2 shape
				elif (building_up[0] == "L" and building_down[0] == "S"):
					# Check for S in bottom left corner of 2x2
					if (building_up == building_down_right):
						valid_removal = true
						matched_buildings = [building_up, building_down, building_up_right, building_down_right]
						index_type = "Q"
						
						# We need an additional removal, to skip a U shape and go straight to a 2x2
						remove_road(i - 1, j - 1, 1, matched_buildings, index_type, buildings, index_types, intersections, road_array, ignore_deg_req)
					
					# Check for S in bottom right corner of 2x2
					elif (building_up == building_down_left):
						valid_removal = true
						matched_buildings = [building_up, building_down, building_up_left, building_down_left]
						index_type = "Q"
						
						# We need an additional removal, to skip a U shape and go straight to a 2x2
						remove_road(i - 1, j, 1, matched_buildings, index_type, buildings, index_types, intersections, road_array, ignore_deg_req)
			# Vertical road case
			else:
				var building_right = buildings.get(bp[0]).get(bp[1])
				var building_right_up = buildings.get(bp[0] + 1).get(bp[1])
				var building_right_down = buildings.get(bp[0] - 1).get(bp[1])
				
				var building_left = buildings.get(bp[0]).get(bp[1] - 1)
				var building_left_up = buildings.get(bp[0] + 1).get(bp[1] - 1)
				var building_left_down = buildings.get(bp[0] - 1).get(bp[1] - 1)
				# S to S: create 2x1 shape
				if (building_right[0] == "S" and building_left[0] == "S"):
					valid_removal = true
					matched_buildings = [building_right, building_left]
					index_type = "D"
				
				# D to S: create L shape
				elif (building_right[0] == "S" and building_left[0] == "D"):
					# S is on the right
					
					# Check if double goes down
					if (building_left_down == building_left):
						# There is an L, with points right and down
						valid_removal = true
						matched_buildings = [building_right, building_left, building_left_down]
						index_type = "L"
					elif (building_left_up == building_left):
						# There is an L, with points right and up
						valid_removal = true
						matched_buildings = [building_right, building_left, building_left_up]
						index_type = "L"
						
				# Also L shape
				elif (building_right[0] == "D" and building_left[0] == "S"):
					# S is on the left
					
					# Check if double goes left
					if (building_right_down == building_right):
						# There is an L, with points left and down
						valid_removal = true
						matched_buildings = [building_right, building_left, building_right_down]
						index_type = "L"
					elif (building_right_up == building_right):
						# There is an L, with points left and up
						valid_removal = true
						matched_buildings = [building_right, building_left, building_right_up]
						index_type = "L"
					
				# S to L: Create 2x2 shape
				elif (building_right[0] == "S" and building_left[0] == "L"):
					# Check for S in right top corner of 2x2
					if (building_left == building_right_down):
						valid_removal = true
						matched_buildings = [building_right, building_left, building_right_down, building_left_down]
						index_type = "Q"
						
						# We need an additional removal, to skip a U shape and go straight to a 2x2
						remove_road(i, j, 0, matched_buildings, index_type, buildings, index_types, intersections, road_array, ignore_deg_req)
					
					# Check for S in right bottom corner of 2x2
					elif (building_left == building_right_up):
						valid_removal = true
						matched_buildings = [building_right, building_left, building_right_up, building_left_up]
						index_type = "Q"
						
						# We need an additional removal, to skip a U shape and go straight to a 2x2
						remove_road(i + 1, j, 0, matched_buildings, index_type, buildings, index_types, intersections, road_array, ignore_deg_req)
				
				# S to L: Create 2x2 shape
				elif (building_right[0] == "L" and building_left[0] == "S"):
					# Check for S in left bottom corner of 2x2
					if (building_right == building_left_up):
						valid_removal = true
						matched_buildings = [building_right, building_left, building_right_up, building_left_up]
						index_type = "Q"
						
						# We need an additional removal, to skip a U shape and go straight to a 2x2
						remove_road(i + 1, j - 1, 0, matched_buildings, index_type, buildings, index_types, intersections, road_array, ignore_deg_req)
					
					# Check for S in left top of 2x2
					elif (building_right == building_left_down):
						valid_removal = true
						matched_buildings = [building_right, building_left, building_right_down, building_left_down]
						index_type = "Q"
						
						# We need an additional removal, to skip a U shape and go straight to a 2x2
						remove_road(i, j - 1, 0, matched_buildings, index_type, buildings, index_types, intersections, road_array, ignore_deg_req)
				
			if (valid_removal):
				remove_road(i, j, h_or_v, matched_buildings, index_type, buildings, index_types, intersections, road_array, ignore_deg_req)
		
		print(r)
		print([i, j])
		print("vert" if h_or_v else "horz")
		# We are counting 0, 0 as bottom right... so rows need to be in reverse order!
		var out_buildings = buildings.duplicate()
		out_buildings.reverse()
		for building_row in out_buildings:
			print(building_row)
		print(index_types)
		print()

func remove_road(i, j, h_or_v, matched_buildings, index_type, buildings, index_types, intersections, road_array, ignore_deg_req = false):
	# First, check intersection degree.
	# Reduce degree of both connected intersections by 1
	# Horizontal:
	if (h_or_v == 0):
		if (intersections[i][j] - 1 < 2 or intersections[i][j + 1] - 1 < 2):
			return false
		intersections[i][j] = intersections[i][j] - 1
		intersections[i][j + 1] = intersections[i][j + 1] - 1
	# Vertical:
	else:
		if (intersections[i][j] - 1 < 2 or intersections[i + 1][j] - 1 - 1 < 2):
			return false
		intersections[i][j] = intersections[i][j] - 1
		intersections[i + 1][j] = intersections[i + 1][j] - 1
	
	for building in matched_buildings:
		building[0] = index_type
		building[1] = index_types[index_type]
	index_types[index_type] += 1
	
	road_array[i][j] = false
	return true
	
