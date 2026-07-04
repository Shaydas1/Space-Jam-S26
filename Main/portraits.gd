extends Node2D

var allowed_portraits = ["Cat", "Cop", "Girl", "DriverGrapple",
	"DriverSpeedDrop", "DriverSpeedLow", "DriverSpeedMax", "DriverSpeedUp"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	switch_portrait("Cat")
	for allowed_portrait in allowed_portraits:
		get_node(allowed_portrait).scale.x *= 3
		get_node(allowed_portrait).scale.y *= 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func switch_portrait(portrait: String):
	for allowed_portrait in allowed_portraits:
		get_node(allowed_portrait).stop()
		get_node(allowed_portrait).hide()
	if portrait in allowed_portraits:
		get_node(portrait).show()
		get_node(portrait).play("default")
