extends Node3D

@export var left : Sprite3D
@export var right : Sprite3D
@export var front : Sprite3D
@export var back : Sprite3D

@export var back_cutoff_angle : float = 45

func _process(delta: float) -> void:
	var forward: Vector3 = -global_transform.basis.z
	var camera := get_viewport().get_camera_3d()
	var to_camera := global_position.direction_to(camera.global_position)

	var signed_angle = rad_to_deg(forward.signed_angle_to(to_camera, camera.global_transform.basis.y))

	if abs(signed_angle) <= back_cutoff_angle:
		left.visible  = false
		right.visible = false
		front.visible = true
		back.visible  = false

	elif back_cutoff_angle + 90 > signed_angle && signed_angle > back_cutoff_angle:
		left.visible  = true
		right.visible = false
		front.visible = false
		back.visible  = false

	elif -back_cutoff_angle - 90 < signed_angle && signed_angle < -back_cutoff_angle:
		left.visible  = false
		right.visible = true
		front.visible = false
		back.visible  = false

	elif abs(signed_angle) >= back_cutoff_angle + 90:
		left.visible  = false
		right.visible = false
		front.visible = false
		back.visible  = true
