extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_start_button_pressed() -> void:
	SceneManager.swap_screen(SceneManager.Screen.Game)
