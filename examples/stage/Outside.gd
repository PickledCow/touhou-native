extends Node2D

var started := false
var t_raw := 0.0
var t_int := 0

onready var root := get_node("../../")

onready var Starly := preload("res://examples/enemy/Outside/Starly.tscn")
onready var Chatot := preload("res://examples/enemy/Outside/Chatot.tscn")
onready var Wingull := preload("res://examples/enemy/Outside/Wingull.tscn")
onready var Bidoof := preload("res://examples/enemy/Outside/Bidoof.tscn")

var debug_t_start := 0.0

func start():
	started = true
	var start_t = debug_t_start
	t_raw = start_t
	t_int = int(start_t)
	get_node("../../background").play_bg(1, start_t / 60.0)
	call_deferred("start_music", 1, start_t / 60.0)

func start_music(id, start_t = 0):
	get_node("../Music").play_music(id, start_t)

func _physics_process(delta):
	if !started:
		return
	t_raw += delta * 60.0
	
	while t_int < t_raw:
		t_int += 1
		stage_process(t_int, delta)
	

const CHATOT := 1120
const STARLY := 2220
const WINGULL := 2500
const WINGULL_END := 2500 + 20 * (9+2)
const BIDOOF := 2900
const END := 3500
const END_REAL := 4080

var bidoof_index := 0
var bidoof_y := 0.0

const BIDOOF_X = [300, -1, 700, -1, 500, 250, 500, 750]
const BIDOOF_COUNT = [4, 0, 4, 0, 3, 3, 3, 3]

const BIDOOF_NOISE := 150
const BIDOOF_MARGIN := 100

var bidoof_offset := 0.0

var lr = 1.0
var lr2 = 1.0

func stage_process(t, _delta):
	# Starly section
	if t < CHATOT:
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
	
	# Chatot section
	elif t < STARLY:
		if t >= CHATOT and t < CHATOT + 30 * 9:
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
	
	# Second Starly
	elif t < WINGULL:
		
		if t - STARLY < 120:
			if t % 24 == 0:
				var starly := Starly.instance()
				add_child(starly)
				starly.tank_time = 60
				starly.tank_factor = 2
				starly.velocity = Vector2(5.0, -2.5)
				starly.position = Vector2(-100, 600)
				starly.rand_amount = PI * 0.5
				starly.speed_factor = 0.5
				
			if t % 24 == 18:
				var starly := Starly.instance()
				add_child(starly)
				starly.tank_time = 60
				starly.tank_factor = 2
				starly.velocity = Vector2(-5.0, -2.5)
				starly.position = Vector2(1100, 600)
				starly.rand_amount = PI * 0.5
				starly.speed_factor = 0.5
	
	
	# Wingull section
	# 
	elif t < WINGULL_END:
		if (t - WINGULL) % 10 == 10:
			var i = (t - WINGULL) / 20.0 + 1
			var x = (9 - abs(i - 9)) * 100.0
			var wingull = Wingull.instance()
			add_child(wingull)
			wingull.position = Vector2(x, -150)
			wingull.velocity = Vector2(0, 10)
			
			if i != 5 and i != 13 :
				x = 1000.0 - ((9 - abs(i - 9)) * 100.0)
				wingull = Wingull.instance()
				add_child(wingull)
				wingull.position = Vector2(x, -150)
				wingull.velocity = Vector2(0, 10)
				
			
		if (t - WINGULL) % 10 == 0:
			var i = (t - WINGULL) / 20.0 + 1
			var x = (1 + abs(4-abs(i-9))) * 100.0
			var wingull = Wingull.instance()
			add_child(wingull)
			wingull.position = Vector2(x, -150)
			wingull.velocity = Vector2(0, 10)
			
			if i != 1 and i != 9 :
				x = 1000.0 - (1 + abs(4-abs(i-9))) * 100.0
				wingull = Wingull.instance()
				add_child(wingull)
				wingull.position = Vector2(x, -150)
				wingull.velocity = Vector2(0, 10)	
			
	elif t >= BIDOOF and t < END:
		var u = t - BIDOOF
		
		if u % (15 * 4) == 15 * 4 - 1:
			bidoof_index += 1
			bidoof_y = 0.0
			bidoof_offset = rand_range(-BIDOOF_NOISE, BIDOOF_NOISE)
		
		if bidoof_index < 8 and u % (15*4) < 15*BIDOOF_COUNT[bidoof_index] - 1:
			if u % 15 == 0:
				var bidoof := Bidoof.instance()
				add_child(bidoof)
				
				var x = 0.0
				bidoof.position = Vector2(BIDOOF_X[bidoof_index] + bidoof_offset, -100 - bidoof_y)
				bidoof.velocity = Vector2(0, 4)
				bidoof.lr = lr
				bidoof.tank_time = 60
				bidoof.tank_factor = 2
				
				bidoof_offset += rand_range(BIDOOF_MARGIN, BIDOOF_NOISE * 2 - BIDOOF_MARGIN)
				if bidoof_offset > BIDOOF_NOISE:
					bidoof_offset -= BIDOOF_NOISE * 2
				bidoof_y += 36.0
			
				lr *= -1
	elif t == 4200:
		root.start_section(2)
