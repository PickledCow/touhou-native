extends Control

export var fade_distance = 32.0

onready var boss_marker := $marker

func _ready():
	DefSys.markers = self
	
func set_marker_position(x: float):
	boss_marker.rect_position.x = x - 32.0
	boss_marker.modulate.a = 1.0 - max(0.0, abs(x - 500.0) - 500.0) / fade_distance
	
	
