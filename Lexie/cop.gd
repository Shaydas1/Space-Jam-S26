class_name Cop
extends Node3D
 
var distance = 0

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("cop hit player")
