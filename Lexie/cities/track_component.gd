class_name TrackComponent
extends Node3D

@export var start_location : Node3D 
@export var end_location : Node3D

func start() -> Vector3:
	return start_location.global_position

func end() -> Vector3:
	return end_location.global_position
