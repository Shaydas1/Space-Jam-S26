class_name Minivan 
extends CharacterBody3D 

@export var forward_direction : Vector3
@export var right_direction : Vector3

@export var max_forward_speed : float
@export var base_speed : float
@export var min_forward_speed : float

@export var accel_rate : float
@export var break_rate : float
@export var slow_down_rate : float
@export var speed_up_rate : float

@export var max_swerve_speed : float
@export var swerve_decay : float 


var accel_falloff_rate : float

@onready var forward_speed : float = base_speed
@onready var swerve_speed : float = 0


func decay_swerve_speed(delta):
	swerve_speed = lerp(swerve_speed, 0.0, swerve_decay)

	if abs(swerve_speed) < 5:
		swerve_speed = 0


func _physics_process(delta: float) -> void:

	var swerve_input = Input.get_axis("left", "right")

	if swerve_input != 0:
		swerve_speed = max_swerve_speed * swerve_input



	var inp = Input.get_axis("break", "forward")
	
	if inp > 0:
		forward_speed = lerp(forward_speed, max_forward_speed, accel_rate * delta)
	
	elif inp < 0:
		forward_speed = lerp(forward_speed, min_forward_speed, break_rate * delta)

	elif forward_speed > base_speed:
		forward_speed = lerp(forward_speed, base_speed, slow_down_rate * delta)

	elif forward_speed < base_speed:
		forward_speed = lerp(forward_speed, base_speed, speed_up_rate * delta)

	velocity = forward_speed * forward_direction + swerve_speed * right_direction

	move_and_slide()
	print(forward_speed, swerve_speed)


	decay_swerve_speed(delta)
