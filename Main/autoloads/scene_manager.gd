extends Node2D

enum Screen {
	Start, Game, End
}

var current_screen : Screen = Screen.Start

var screen_map : Dictionary[Screen, PackedScene] = {
	Screen.Start : load("res://main/screens/start.tscn"),
	Screen.Game : load("res://main/screens/game.tscn"),
	Screen.End : load("res://main/screens/end.tscn"),
}

func _swap_screen(screen : Screen):
	var res = screen_map.get(screen)

	if res == null:
		printerr("no PackedScene found for screen")
		return 

	get_tree().change_scene_to_packed(res)

	current_screen = screen


func swap_screen(screen : Screen):
	call_deferred("_swap_screen", screen)


func _ready():
	# swap_screen(current_screen)
	pass
