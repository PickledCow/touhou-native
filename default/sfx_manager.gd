extends Node
class_name SFX_manager

export var pan_strength := 1.0

var sound_effects := {}

func _ready():
	DefSys.sfx = self
	for sfx in get_children():
		sound_effects[sfx.name] = sfx

func play(sfx: String) -> void:
	sound_effects[sfx].play()
