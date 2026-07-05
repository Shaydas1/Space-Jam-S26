extends Label

@export var minivan : Minivan

var start_time
var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_time = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if (minivan.is_dead): return
	var current_time = Time.get_ticks_msec()
	score = round((current_time - start_time) / 100)
	text = "Score:\n" + str(score)
	
