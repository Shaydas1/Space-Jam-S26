class_name CityBuilder
extends Resource

@export var street : PackedScene

@export var building_1x1 : Building
@export var building_1x2 : Building
@export var building_2x2 : Building
@export var building_L : Building

var building_types : Array[Building] 

@export var junction_cross : PackedScene
@export var junction_T : PackedScene
@export var junction_line : PackedScene
@export var junction_L : PackedScene

@export var street_width: float
@export var street_length: float

func junction_pos(x, y):
	return Vector3(
		x * (street_width + street_length),
		0,  
		y * (street_width + street_length))

func building_tile_pos(x, y):
	return Vector3(
		x * (street_width + street_length) + (street_width + street_length) / 2, 
		0,
		y * (street_width + street_length) + (street_width + street_length) / 2
	)

func build(layout : CityLayout, parent : Node3D):
	# parent 
	
	building_types = [
		building_1x1,
		building_1x2,
		building_2x2,
		building_L
	]

	# spawn all junctions
	for x in range(0, layout.size.x + 1):
		for y in range(0, layout.size.y + 1):

			if layout.get_junction(x, y):
				# TODO: Choose correctly
				var to_inst = junction_cross

				var new_junction = to_inst.instantiate()
				parent.add_child(new_junction)
				new_junction.position = junction_pos(x, y)
			else:
				print("skipped", x, y)
	# spawn all streets
	for x in range(0, layout.size.x + 1):
		for y in range(0, layout.size.y + 1):
			if layout.get_horizontal_street(x, y):
				var new_street = street.instantiate()
				new_street.position = Vector3.ZERO
				new_street.rotate_y(deg_to_rad(90))
				parent.add_child(new_street)
				new_street.position = 0.5 * (junction_pos(x, y) + junction_pos(x + 1, y)) 

			if layout.get_vertical_street(x, y):
				var new_street = street.instantiate()
				parent.add_child(new_street)
				new_street.position = 0.5 * (junction_pos(x, y) + junction_pos(x, y + 1))
	
	# spawn all the buildings

	var mins : Array[Vector2i] = []
	var maxs : Array[Vector2i] = []
	
	mins.resize(layout.num_buildings)
	mins.fill(layout.size - Vector2i.ONE)

	maxs.resize(layout.num_buildings)
	maxs.fill(Vector2i.ZERO)
		
	# compute bounding box of each building
	for x in range(0, layout.size.x):
		for y in range(0, layout.size.y):
			var id = layout.get_building_at(x, y)
			mins[id].x = min(x, mins[id].x)
			mins[id].y = min(y, mins[id].y)
			maxs[id].x = max(x, maxs[id].x)
			maxs[id].y = max(y, maxs[id].y)

	# instantiate each building
	for id in range(0, layout.num_buildings):
		var building : Building = building_types[layout.get_building_type(id)]
		
		var new_building : Node3D = building.buildings[0].instantiate()
		parent.add_child(new_building)

		new_building.position = Vector3.ZERO
		building.orient_building(layout, id, mins[id], new_building)       
		
		new_building.position = 0.5 * (
			building_tile_pos(mins[id].x, mins[id].y) + 
			building_tile_pos(maxs[id].x, maxs[id].y))
		
