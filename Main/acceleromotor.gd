extends Node2D

@export var body : Minivan

var prev_forward_speed = 0
var acceleration
var original_scale_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Change BarColour to orange
	original_scale_x = get_node("EmptyBar").get_node("Mask").get_node("BarColour").scale.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if body != null:
		acceleration = 0
		if (delta != 0):
			print("MARK1")
			acceleration = (body.forward_speed - prev_forward_speed) / delta
		
		# Set up for next frame
		prev_forward_speed = body.forward_speed
	
	var fractional_acceleration = 100 / acceleration
	print(body.forward_speed)
	print(acceleration)
	print(fractional_acceleration)
	
	# Update the bar
	get_node("EmptyBar").get_node("Mask").get_node("BarColour").scale.x = original_scale_x / fractional_acceleration
