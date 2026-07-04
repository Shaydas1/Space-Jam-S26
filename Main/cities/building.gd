class_name Building
extends Resource 

@export var buildings : Array[PackedScene]
@export var kernel : Array[Vector2i]

@export var bbox : Vector2i

@export var UP : Vector3 = Vector3.UP

var size : int

var cached : bool = false

var kernel_90  : Array[Vector2i] = []
var kernel_180 : Array[Vector2i] = []
var kernel_270 : Array[Vector2i] = []

func compute_kernels():
	if cached: 
		return

	size = kernel.size()

	kernel_90.clear()
	kernel_180.clear()
	kernel_270.clear()

	for e in kernel:
		kernel_90.push_back(Vector2i(-e.y, e.x) + Vector2i(bbox.x - 1, 0))
		kernel_180.push_back(Vector2i(-e.x, -e.y) + Vector2i(bbox.y - 1, bbox.x - 1))
		kernel_270.push_back(Vector2i(e.y, -e.x) + Vector2i(0, bbox.y - 1))

	cached = true

func apply_kernel(layout : CityLayout, id : int, origin : Vector2i, kern) -> bool:
	compute_kernels()
	
	for e in kern:
		var loc = origin + e
		if layout.get_building_at(loc.x, loc.y) != id:
			return false
		
	return true

func orient_building(layout : CityLayout, id : int, origin : Vector2i, new_building : Node3D):    
	if apply_kernel(layout, id, origin, kernel):
		return
	
	elif apply_kernel(layout, id, origin, kernel_180):
		new_building.rotate_y(deg_to_rad(180))
	
	elif apply_kernel(layout, id, origin, kernel_90):
		new_building.rotate_y(deg_to_rad(90))

	elif apply_kernel(layout, id, origin, kernel_270):
		new_building.rotate_y(deg_to_rad(270))
