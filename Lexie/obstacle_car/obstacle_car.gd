class_name ObstacleCar
extends CharacterBody3D

@export var forward_velocity : float = 90
@export var time_to_die : float = 5

@onready var crashed : bool = false

@onready var death_timer : float =  time_to_die

var is_active : bool = false

var fling_vector : Vector3 = Vector3.ONE
@export var fling_speed : float = 100

@export var fling_spin : float = 720

func _ready():
	spawn()

func spawn():
	death_timer = time_to_die
	crashed = false
	
	is_active = true
	
func despawn():
	is_active = false

func start_crashing(hit_direction : Vector3):
	if (crashed): return
	
	fling_vector = (
		- hit_direction.normalized() * 2
		+ transform.basis.y ).normalized()
	
	death_timer = time_to_die
	
	crashed = true

func _physics_process(delta):
	
	if (not crashed):
		velocity = forward_velocity * -(transform.basis.z).normalized()
		
		move_and_slide()
	
	else:
		death_timer -= delta
		
		if death_timer < 0:
			Spawner.unload(self)
			
		else:
			rotate_z(deg_to_rad(fling_spin * delta))
			
			velocity = fling_vector * fling_speed
			move_and_slide()


func _on_area_entered(area):
	if(not is_active or crashed): return
	
	var track_region = area as TrackRegion
	if(track_region != null):
		
		Spawner.you_have_populated(track_region.track.track_id)
		
	var fleet = area as CopTriggerArea
	if (fleet != null):
		start_crashing(fleet.global_position - global_position)
	
		

func _on_body_entered(body):
	if(not is_active or crashed): return
		
	if body.is_in_group("Player"):
		var minivan = body as Minivan
		if(minivan != null):
			minivan.hit_driver()
			start_crashing(minivan.global_position - global_position)
