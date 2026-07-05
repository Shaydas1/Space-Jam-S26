extends Node3D

@export var minivan : Minivan

func _ready():
	TrackBuilder.build_initial_highway()
	var start_loc = TrackBuilder.active_track[TrackBuilder.horizon_behind].start()
	minivan.global_position.x = start_loc.x
	minivan.global_position.z = start_loc.z
