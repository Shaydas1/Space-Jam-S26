extends Label

@export var body : Minivan


func _process(delta: float) -> void:
    text = str(body.forward_speed)