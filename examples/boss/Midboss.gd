extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var started := false
var t_raw := 0.0
var t_int := 0

func start():
	$choreographer.play("Intro")
	started = true

onready var books = [$Books/P]

func _physics_process(delta):
	if !started:
		return
	
	t_raw += delta * 60.0
	
	while t_int < t_raw:
		t_int += 1
		stage_process(t_int, delta)
	

const UXIE_START := 984
const MESPRIT_SETUP := 1890

func stage_process(t, _delta):
	if t < UXIE_START:
		if t == 870:
			pass
		elif t == 888:
			pass
		elif t == 918:
			pass
		elif t == 936:
			pass
		elif t == 966:
			pass
		elif t == 996:
			pass
	
	elif t < MESPRIT_SETUP:
		pass
	
