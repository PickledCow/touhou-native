extends Node2D

var started := false
var t_raw := 0.0
var t_int := 0

onready var root := get_node("../../")

onready var Starly := preload("res://examples/enemy/Outside/Starly.tscn")
onready var Chatot := preload("res://examples/enemy/Outside/Chatot.tscn")

var debug_t_start := 1000.0

func start():
	started = true
	var start_t = debug_t_start
	t_raw = start_t
	t_int = int(start_t)
	get_node("../Music").play_music(1, start_t / 60.0)
	get_node("../../background").play_bg(1, start_t / 60.0)

func _physics_process(delta):
	if !started:
		return
	t_raw += delta * 60.0
	
	while t_int < t_raw:
		t_int += 1
		stage_process(t_int, delta)
	

const CHATOT := 1120

var lr = 1.0
var lr2 = 1.0

func stage_process(t, _delta):
	# Starly section
	if t >= 60 and t < 60+240:
		if t % 24 == 0:
			var xv = (t - 60)*0.75
			var starly := Starly.instance()
			add_child(starly)
			starly.tank_time = 60
			starly.tank_factor = 2
			starly.velocity = Vector2(5.0, 7)
			starly.position = Vector2(150+xv, -100)
	elif t >= 60+240 and t < 60+240*2:
		if t % 24 == 0:
			var xv = (t - 60-240)*0.75
			var starly := Starly.instance()
			add_child(starly)
			starly.tank_time = 60
			starly.tank_factor = 2
			starly.velocity = Vector2(-5.0, 7)
			starly.position = Vector2(850-xv, -100)
			
	elif t >= 60+240*2 and t < 60+240*3:
		if t % 36 == 0:
			var starly := Starly.instance()
			add_child(starly)
			starly.tank_time = 60
			starly.tank_factor = 2
			starly.velocity = Vector2(5.0, 0)
			starly.position = Vector2(-100, 400)
			
		if t % 36 == 18:
			var starly := Starly.instance()
			add_child(starly)
			starly.tank_time = 60
			starly.tank_factor = 2
			starly.velocity = Vector2(-5.0, 0)
			starly.position = Vector2(1100, 400)
	
	elif t == 880:
		root.show_sign(0)
	
	elif t >= CHATOT and t < CHATOT + 30 * 9:
		if t % 30 == 0:
			var chatot = Chatot.instance()
			add_child(chatot)
			chatot.position = Vector2(-100, 50)
			chatot.velocity = Vector2(10, 1.5)
			chatot.ax = 0.07
			chatot.lr = lr
			chatot.tank_time = 60
			chatot.tank_factor = 3
			
			lr *= -1.0
			
	elif t >= CHATOT + 30 * 10 and t < CHATOT + 30 * (10 + 8):
		if t % 30 == 0:
			var chatot = Chatot.instance()
			add_child(chatot)
			chatot.position = Vector2(1100, 50)
			chatot.velocity = Vector2(-10, 1.5)
			chatot.ax = -0.07
			chatot.lr = lr
			chatot.start_direction = -1.0
			chatot.tank_time = 60
			chatot.tank_factor = 3
			
			lr *= -1.0
			
	elif t >= CHATOT + 30 * (10 + 9) and t < CHATOT + 30 * (10 + 9 + 8):
		if t % 30 == 0:
			var chatot = Chatot.instance()
			add_child(chatot)
			chatot.position = Vector2(500 + lr * 600, 50)
			chatot.velocity = Vector2(-lr * 6, 1.5)
			chatot.ax = 0.0
			chatot.lr = lr * lr2
			chatot.start_direction = -lr
			chatot.tank_time = 60
			chatot.tank_factor = 3
			chatot.reduce_spread = true
			
			lr *= -1.0
		#	if lr == -1.0:
		#		lr2 *= -1.0
	
