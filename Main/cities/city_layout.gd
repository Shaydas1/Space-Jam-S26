class_name CityLayout
extends Resource

@export var size : Vector2i

# 2d flattened data
@export var horizontal_streets : Array[bool]
@export var vertical_streets : Array[bool]
@export var junctions : Array[bool]
@export var buildings : Array[int]

# building info
@export var num_buildings : int
@export var building_types : Array[int]


func get_horizontal_street(x : int, y : int) -> bool:
	if (x < 0) or (x >= size.x) or (y < 0) or (y >= size.y + 1):
		return false
	
	return horizontal_streets[x + y * size.x]
	
	
func get_vertical_street(x : int, y : int) -> bool:
	if (x < 0) or (x >= size.x + 1) or (y < 0) or (y >= size.y):
		return false
	
	return vertical_streets[y + x * size.y]



func get_junction(x : int, y : int) -> bool:
	if (x < 0) or (x >= size.x + 1) or (y < 0) or (y >= size.y + 1):
		return false

	return junctions[x + y * (size.x  +1)]


func get_building_at(x : int, y : int) -> int:
	if (x < 0) or (x >= size.x) or (y < 0) or (y >= size.y):
		return false

	return buildings[x + y * size.x]


func get_building_type(id : int) -> int:
	if (id < 0) or (id >= building_types.size()):
		return false

	return building_types[id]
