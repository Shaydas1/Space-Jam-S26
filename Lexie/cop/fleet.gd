class_name Fleet
extends CharacterBody3D

@export var forward_speed : float = 110
@export var max_dist_away : float = 50



@export var global_speedup_rate: float = 1.003
@export var speed_cap : float = 400


@export var minivan : Minivan
@export var vol_max : float = -5
@export var vol_min : float = -10

@export var siren : AudioStreamPlayer

var currnet_forward_speed : float
var time_alive : float = 0

func _ready() -> void:
	currnet_forward_speed = forward_speed
	time_alive = 0
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		#TODO: DIE
		var minivan = body as Minivan
		
		minivan.hit_fleet()

func _physics_process(delta: float) -> void:
	time_alive += delta
	currnet_forward_speed = min(
		speed_cap, forward_speed * pow(global_speedup_rate, time_alive))
	
	var dist_away = (global_position.z - minivan.global_position.z)
	
	var vol_scale = pow(clampf(dist_away / max_dist_away, 0, 1), 5)
	
	siren.volume_db = lerp(vol_max, vol_min, vol_scale)
	
	if dist_away > max_dist_away:
		global_position.z = minivan.global_position.z + max_dist_away
		
	velocity = currnet_forward_speed * Vector3(0, 0, -1)
	move_and_slide()
