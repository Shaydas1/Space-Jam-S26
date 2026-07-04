extends Node3D

@export var city_builder : CityBuilder
@export var layout : CityLayout

func _ready():
	city_builder.build(layout, self)
	
