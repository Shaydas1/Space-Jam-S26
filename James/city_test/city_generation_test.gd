extends Node3D

@export var city_builder : CityBuilder
@export var layout : CityLayout

func _ready():
	layout.test()
	city_builder.build(layout, self)
	
