class_name TrackComponent
extends Node3D

@export var start_location : Node3D 
@export var end_location : Node3D

var track_id : int = -1
var is_active : bool = false

signal loaded
signal unloaded(id : int)

func load_section(id : int):
	track_id = id
	loaded.emit()
	is_active = true


func unload_section():
	unloaded.emit(track_id)
	track_id = -1
	is_active = false
	

func start() -> Vector3:
	return start_location.global_position

func end() -> Vector3:
	return end_location.global_position


func _on_body_entered(body):
	if not is_active:
		return
		
	print("entered load zone", body)
	if body.is_in_group("Player"):
		TrackBuilder.player_entered(track_id)
