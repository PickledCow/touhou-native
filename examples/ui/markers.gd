extends Control

export var fade_distance = 32.0

onready var galacta_marker := $galacta
onready var remilia_marker := $remilia

func _ready():
	DefSys.markers = self

func set_galacta_marker_position(x: float):
	galacta_marker.rect_position.x = x - 32.0
	galacta_marker.modulate.a = 1.0 - max(0.0, abs(x - 500.0) - 500.0) / fade_distance
	
func set_remilia_marker_position(x: float):
	remilia_marker.rect_position.x = x - 32.0
	remilia_marker.modulate.a = 1.0 - max(0.0, abs(x - 500.0) - 500.0) / fade_distance
	
	
