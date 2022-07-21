extends Control

export var fade_distance = 32.0

func _ready():
	DefSys.markers = self

func set_marker_position(x: float):
	rect_position.x = 460.0 + x - 72.0*0.5
	modulate.a = 1.0 - max(0.0, abs(x - 500.0) - 500.0) / fade_distance
	
