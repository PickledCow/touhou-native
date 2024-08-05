extends Node2D

var started := false
var t_raw := 0.0
var t_int := 0

func start():
	#pass
	
	get_node("../Music").play_music(1)
	get_node("../../background").play_bg(1)

func _physics_process(delta):
	if !started:
		return
	t_raw += delta * 60.0
	
	while t_int < t_raw:
		t_int += 1
		stage_process(t_int, delta)
	



func stage_process(t, _delta):
	pass
