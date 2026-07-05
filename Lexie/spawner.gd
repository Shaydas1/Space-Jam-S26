class_name Spawner_Impl
extends Node

var obstacle_car_scene : PackedScene = preload("res://Lexie/obstacle_car.tscn")

var all_obstacles : Array[ObstacleCar] = []
var available_obstacles : Array[ObstacleCar] = []

var active_obstacles : Array[ObstacleCar] = []

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
