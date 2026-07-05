class_name Minivan 
extends CharacterBody3D 

@export var tex_center : Texture2D
@export var tex_left : Texture2D
@export var tex_right : Texture2D

@export var sprite : Sprite3D

@export var true_forward_direction : Vector3
@export var right_direction : Vector3

@export var max_forward_speed : float
var current_max_forward_speed : float
@export var base_speed : float
var current_base_speed : float
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

signal speeding_up
signal slowing_down
signal high_speed
signal low_speed

var is_dead = false

@export var die_timer : Timer
@export var explosion : AnimatedSprite3D

@export var speedlines : ColorRect

@export var score : float

@export var global_speedup_rate: float = 1.005
@export var speed_cap : float = 400

var time_alive : float 

func animation_finished():
	explosion.visible = false

func die_timer_timeout():
	SceneManager.swap_screen(SceneManager.Screen.End)

func hit_driver():
	forward_speed = min(forward_speed * 0.6, base_speed * 0.1)
	if not get_node("Bonk").playing:
			get_node("Bonk").play()

func hit_fleet():
	is_dead = true
	die_timer.start()
	explosion.visible = true
	sprite.visible = true
	explosion.play()
	get_node("Bonk").play()
	sprite.rotate_z(deg_to_rad(180))

func update_texture():
	if abs(swerve_speed) < max_swerve_speed/2:
		sprite.texture = tex_center

	elif swerve_speed < 5:
		sprite.texture = tex_right
		sprite.flip_h = true

	elif swerve_speed > 5:
		sprite.texture = tex_left
		sprite.flip_h = false

func _ready() -> void:
	update_texture()
	die_timer.timeout.connect(die_timer_timeout)
	explosion.visible = false
	explosion.animation_finished.connect(animation_finished)
	
	current_max_forward_speed = max_forward_speed
	current_base_speed = base_speed
	
	time_alive = 0

func decay_swerve_speed(_delta):
	swerve_speed = lerp(swerve_speed, 0.0, swerve_decay)

	if abs(swerve_speed) < 5:
		swerve_speed = 0


func _process(delta: float) -> void:
	
	
	update_texture()
	
	var density = 1
	
	if is_dead or forward_speed < (base_speed  + max_forward_speed) / 2:
		density = 0
	else:
		density = lerp(0.0, 1.0, forward_speed / max_forward_speed)
		
	
	speedlines.material.set_shader_parameter("line_density", density)

	if not is_dead:
		score += 5 * pow(forward_speed/ base_speed, 2) * delta

func _update_angle(new_angle):
	rotate_y(-angle)
	angle = new_angle
	rotate_y(angle)


func _physics_process(delta: float) -> void:
	
	time_alive += delta
	
	current_base_speed = min(
		speed_cap, base_speed * pow(global_speedup_rate, time_alive))
	
	current_max_forward_speed = min(
		speed_cap * 2, max_forward_speed * pow(global_speedup_rate, time_alive))
		
	if(is_dead): return

	var turn_input = Input.get_axis("turn_left", "turn_right")
	
	
	if turn_input != 0:
		_update_angle(angle + deg_to_rad(-turn_rate * delta * turn_input))
		
	elif abs(angle) > deg_to_rad(0.5):
		_update_angle(lerp(angle, 0.0, angle_correction_decay * delta))
	else:
		_update_angle(0)

	var swerve_input = Input.get_axis("left", "right")

	if swerve_input != 0:
		swerve_speed = max_swerve_speed * swerve_input

	var inp = Input.get_axis("break", "forward")
	
	if inp > 0:
		forward_speed = lerp(forward_speed, current_max_forward_speed, accel_rate * delta)
		# Start playing engine noise
		if not get_node("Engine").playing:
			get_node("Engine").play()
		speeding_up.emit()
	
	elif inp < 0:
		if forward_speed > min_forward_speed:
			forward_speed = lerp(forward_speed, min_forward_speed, break_rate * delta)
		# Start playing break noise
		if not get_node("Brake").playing:
			get_node("Brake").play()
		slowing_down.emit()
		
	elif forward_speed > current_base_speed:
		forward_speed = lerp(forward_speed, current_base_speed, slow_down_rate * delta)
		# Stop playing engine and break noises
		get_node("Engine").stop()
		get_node("Brake").stop()
		slowing_down.emit()

	elif forward_speed < current_base_speed:
		forward_speed = lerp(forward_speed, current_base_speed, speed_up_rate * delta)
		# Stop playing engine and break noises
		get_node("Engine").stop()
		get_node("Brake").stop()
		speeding_up.emit()

	velocity = forward_speed * -transform.basis.z + swerve_speed * transform.basis.x
	
	if forward_speed >= 190:
		high_speed.emit()
	
	if forward_speed <= 90:
		low_speed.emit()

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)

		var collision_angle = acos(transform.basis.z.dot(collision.get_normal()))
		
		if collision_angle < deg_to_rad(30):
			SceneManager.swap_screen(SceneManager.Screen.End)
		elif forward_speed > min_forward_speed * 0.8:
			forward_speed = clamp(lerp(forward_speed, min_forward_speed * 0.8, 5 * delta), min_forward_speed * 0.8, INF)
	
	#print(forward_speed, " ", -transform.basis.z)

	decay_swerve_speed(delta)
