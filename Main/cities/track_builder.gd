class_name TrackBuilder_Impl
extends Node

var highway_scene : PackedScene = preload("res://main/city_tiles/roads/6_lane_highway.tscn")


var horizon_ahead : int = 5
var horizon_behind : int = 5

var all_highway_sections : Array[TrackComponent] = []
var available_highway_sections : Array[TrackComponent] = []

var active_track : Array[TrackComponent] = []
var min_track_id : int = 0 # smallest active index, if it == to the next, then nothing is loaded
var next_track_id : int = 0 # one more than the largest

var player_track : int = -1

signal player_entered_track(id : int)

func reset():
	all_highway_sections = []
	available_highway_sections = []
	active_track = []
	min_track_id = 0
	next_track_id = 0
	player_track = -1

func get_track(id):
	return active_track.get(id - min_track_id)

func build_initial_highway():
	for i in range(1 + horizon_ahead + horizon_behind):
		_append_component(_get_highway())


func _make_new_highway():
	var hw = highway_scene.instantiate()
	all_highway_sections.append(hw)
	available_highway_sections.append(hw)


func _get_highway():
	if available_highway_sections.is_empty():
		_make_new_highway()
		
	var hw = available_highway_sections.pop_front()
	
	if hw == null:
		print("bad suck die")
		
	return hw
		

func _append_component(section : TrackComponent):
	var id = next_track_id
	next_track_id += 1
	min_track_id = min(min_track_id, id)
	section.load_section(id)

	if active_track.is_empty():
		get_tree().current_scene.add_child(section)
		section.global_position = -section.start()
		active_track.append(section)
		
	else:
		get_tree().current_scene.add_child(section)
		section.global_position = active_track.back().end() - section.start()
		
		#print((active_track.back().end()))
		active_track.append(section)
		


func _pop_component():
	if active_track.is_empty():
		return
		
	var section = active_track.pop_front()
	#print("removing ", section.track_id)
	
	# increment to point at the next one
	# will do the empty behavior correctly
	min_track_id += 1
	
	section.unload_section()
	section.global_position = Vector3.ZERO
	
	if section.get_parent():
		section.get_parent().remove_child(section)
	
	# reuse it if its highway
	if all_highway_sections.has(section):
		available_highway_sections.push_back(section)

	else:
		section.queue_free()
			

#func extend_track():
	#_append_component(_get_highway())
	#cull_track()
	

func exited_section(id):
	# cull to the back horizon
	while not active_track.is_empty() and active_track.front().track_id < id - horizon_behind:
		active_track.pop_front()
		min_track_id = active_track[0].track_id


func player_entered(id):
	# when the player enters a section, 
	player_track = max(id, player_track)
	player_entered_track.emit(player_track)
	
	# add sections untill there are enough infront
	while not (next_track_id > player_track + horizon_ahead):
		# todo choose randomly
		_append_component(_get_highway())
		
	# remove sections untill there aren't too many behind
	while min_track_id < player_track - horizon_behind:
		_pop_component()
		
	Spawner.player_in(player_track)

	#print("player in ", player_track, " active range (", min_track_id, ", ", next_track_id - 1, ")")
