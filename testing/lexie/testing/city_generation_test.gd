extends Node3D

@export var city_builder : CityBuilder
@export var layout : CityLayout
@export var parent : Node3D
func _ready():
	city_builder.build(layout, parent)
	
