class_name Score
extends Label

@export var minivan : Minivan

func _process(delta: float) -> void:
	text = "Fine:\n" + "$" + str(int(ScoreCounter.score)) 
	
