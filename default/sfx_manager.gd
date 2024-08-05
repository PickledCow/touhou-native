extends Node
class_name SFX_manager

export var pan_strength := 1.0

var sound_effects := {}
var sfx_queue = []

func _ready():
	DefSys.sfx = self
	for sfx in get_children():
		sound_effects[sfx.name] = sfx

func play(sfx: String) -> void:
	sound_effects[sfx].play()

func process_queue(delta):
	var new_queue = []
	for sfx in sfx_queue:
		sfx[1] -= delta * 60.0
		if sfx[1] <= 0:
			play(sfx[0])
		else:
			new_queue.append(sfx)
	sfx_queue = new_queue

func queue_sfx(sfx: String, time: float) -> void:
	sfx_queue.append([sfx, time])

func _physics_process(delta):
	process_queue(delta)
