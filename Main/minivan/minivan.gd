class_name Minivan 
extends CharacterBody3D 

@export var tex_center : Texture2D
@export var tex_left : Texture2D
@export var tex_right : Texture2D

@export var sprite : Sprite3D

@export var true_forward_direction : Vector3
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

@export var turn_rate : float

var accel_falloff_rate : float

@onready var forward_speed : float = base_speed
@onready var swerve_speed : float = 0

var angle : float = 0.0
@export var angle_correction_decay : float = 5.0

func update_texture():
	if abs(swerve_speed) < max_swerve_speed/2:
		sprite.texture = tex_center

	elif swerve_speed < 5:
		sprite.texture = tex_right

	elif swerve_speed > 5:
		sprite.texture = tex_left

func _ready() -> void:
	update_texture()

func decay_swerve_speed(delta):
	swerve_speed = lerp(swerve_speed, 0.0, swerve_decay)

	if abs(swerve_speed) < 5:
		swerve_speed = 0


func _process(delta: float) -> void:
	update_texture()


func _physics_process(delta: float) -> void:

	var turn_input = Input.get_axis("turn_left", "turn_right")
	
	rotate_y(-angle)
	
	if turn_input != 0:
		angle += deg_to_rad(-turn_rate * delta * turn_input)
		
	elif abs(angle) > deg_to_rad(0.5):
		angle = lerp(angle, 0.0, angle_correction_decay * delta)
	else:
		angle = 0
	rotate_y(angle)

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

	velocity = forward_speed * -transform.basis.z + swerve_speed * transform.basis.x

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#print("I collided with ", collision.get_collider().name)
	
	#print(forward_speed, swerve_speed)

	decay_swerve_speed(delta)
