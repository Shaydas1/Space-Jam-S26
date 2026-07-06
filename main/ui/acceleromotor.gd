extends Node2D

@export var body : Minivan

var max_speed = 200
var original_scale_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Change BarColour to orange
	original_scale_x = get_node("EmptyBar").get_node("Mask").get_node("BarColour").scale.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var fractional_speed = 0
	if body != null:
		fractional_speed = body.forward_speed / max_speed
		
	# Update the bar
	get_node("EmptyBar").get_node("Mask").get_node("BarColour").scale.x = original_scale_x * fractional_speed
