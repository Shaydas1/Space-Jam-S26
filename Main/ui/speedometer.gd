extends Label

@export var body : Minivan


func _process(delta: float) -> void:
	if body != null:
		text = str(body.forward_speed)
