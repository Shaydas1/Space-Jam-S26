class_name TrackBuilder_Impl
extends Node

var highway_scene : PackedScene = preload("res://Lexie/highway/highway.tscn")

var number_highway_sections : int = 5
var horizon_behind : int = 3 + number_highway_sections

var all_highway_sections : Array[TrackComponent] = []
var available_highway_sections : Array[TrackComponent] = []

var active_track : Array[TrackComponent] = []


func build_debug():
	for i in range(5):
		_append_component(_get_highway())


func _ready():
	for i in range(0, number_highway_sections):
		_make_new_highway()
	

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
	
	print(section.global_position, section.get_parent())
	
	if active_track.is_empty():
		get_tree().current_scene.add_child(section)
		section.global_position = -section.start()
		active_track.append(section)
		
	else:
		get_tree().current_scene.add_child(section)
		section.global_position = active_track.back().end() - section.start()
		
		print((active_track.back().end()))
		active_track.append(section)
		
	print(section.global_position, section.get_parent())
		

func cull_track():
	# remove all but the last component
	for i in range(0, active_track.size() - horizon_behind):
		print("removing", i)
		var section = active_track.pop_front()
		
		if section.get_parent():
			section.get_parent().remove_child(section)
		
		# reuse it if its highway
		if all_highway_sections.has(section):
			section.global_position = Vector3.ZERO
			available_highway_sections.push_back(section)

		else:
			section.queue_free()
			

func extend_track():
	_append_component(_get_highway())
	cull_track()
	
	
		
