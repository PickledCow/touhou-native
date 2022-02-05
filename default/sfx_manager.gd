extends Node
class_name SFX_manager

onready var death := $death
onready var lowhealth := $lowhealth
onready var shoot1 := $shoot1
onready var shoot2 := $shoot2
onready var shoot3 := $shoot3
onready var warning1 := $warning1
onready var warning2 := $warning2
onready var warning3 := $warning3


var sound_effects := {}

func _ready():
	DefSys.sfx = self
	for sfx in get_children():
		sound_effects[sfx.name] = sfx

func play(sfx: String):
	sound_effects[sfx].play()
