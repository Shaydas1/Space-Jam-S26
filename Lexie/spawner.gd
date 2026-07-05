class_name Spawner_Impl
extends Node

var obstacle_car_scene : PackedScene = preload("res://Lexie/obstacle_car/obstacle_car.tscn")

var all_obstacles : Array[ObstacleCar] = []
var available_obstacles : Array[ObstacleCar] = []

var active_obstacles : Array[ObstacleCar] = []

var furthest_populated_hw : int = -1

var spawn_ahead = 3


var spawn_wave_max = 5
var spawn_wave_min = 2
var spawn_wave_per_segment = 5

var cars_per_wave = 6
var spawn_adjacent_seperation = (-9.486 - -15.6)
var first_car_offset = -15.6 

func you_have_populated(ind):
	furthest_populated_hw = max(furthest_populated_hw, ind)

func player_in(player_index):
	var from = max(furthest_populated_hw, player_index) + 1
	var up_to = player_index + spawn_ahead
	
	#print("player in ", player_index, " spawning (", from, ", ", up_to, ")")
	
	for cur in range(from, up_to + 1):
		print(cur)
		var hw = TrackBuilder.get_track(cur) as HighwayTrack
		
		# we somehow hit the end or a city 
		if (hw == null): 
			break
			
		furthest_populated_hw = max(furthest_populated_hw, cur)
		print("spawning for ", cur)
		spawn_segement(hw.start(), hw.end())
		


func spawn_segement(start, end):
	print("start seg")
	for i in range(spawn_wave_per_segment):
		
		var center = lerp(end, start, float(i)/float(spawn_wave_per_segment + 1))
		print(center)
		var indices : Array[int] = []
		for ind in range(cars_per_wave):
			indices.append(ind)
		
		indices.shuffle()
		
		var count = randi_range(spawn_wave_min, spawn_wave_max)
		
		for ind in range(cars_per_wave - count):
			indices.pop_back()
		# assume we offset along the x axis
		print("chose ", count)
		var jitter = randf_range(
			-spawn_adjacent_seperation * 0.25, 
			spawn_adjacent_seperation * 0.25)
		
		for ind in indices:
			
			var loc_x = jitter + first_car_offset + spawn_adjacent_seperation * ind
			
			loc_x = clampf(
				loc_x, 
				first_car_offset, 
				first_car_offset + spawn_adjacent_seperation * (cars_per_wave - 1))
			
			spawn_at(
				(loc_x)
				* Vector3(1, 0, 0) 
				+ center)

func spawn_at(pos :Vector3):
	var obs = _get_obstacle()
	
	get_tree().current_scene.add_child(obs)
	obs.global_position = pos
	obs.global_position.y = 2.231
	active_obstacles.append(obs)
	obs.spawn()

func _make_new_obstacle():
	var hw = obstacle_car_scene.instantiate()
	all_obstacles.append(hw)
	available_obstacles.append(hw)


func _get_obstacle():
	if available_obstacles.is_empty():
		_make_new_obstacle()
		
	var hw = available_obstacles.pop_front()
	
	if hw == null:
		print("bad suck die")
		
	return hw

func unload(obstacle : ObstacleCar):
	obstacle.despawn()
	obstacle.global_position = Vector3.ZERO
	
	if(obstacle.get_parent()):
		obstacle.get_parent().remove_child(obstacle)
	
	active_obstacles.erase(obstacle)
	available_obstacles.append(obstacle)
