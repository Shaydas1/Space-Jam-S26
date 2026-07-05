class_name HighwayTrack
extends TrackComponent

@export var centerline : Path3D

func _init():
	track_type = TrackType.Highway

func length():
	return centerline.curve.get_baked_length()
	

func sample_at(dist):
	return centerline.curve.sample_baked(dist) + start()
	

func get_closest_distance(loc: Vector3):
	return centerline.curve.get_closest_offset(loc)
