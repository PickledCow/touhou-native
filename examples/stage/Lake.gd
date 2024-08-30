extends Node2D

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add


onready var Laser := preload("res://examples/enemy/Lake/laser.tscn")
onready var BigLaser := preload("res://examples/enemy/Lake/biglaser.tscn")


var started := false
var t_raw := 0.0
var t_int := 0

onready var root := get_node("../../")

onready var books := [$D, $HG, $P, $SS, $Pt, $LA]

var difficulty := 0

var blue_ball : PoolRealArray
var blue_snowball : PoolRealArray
var purple_ball : PoolRealArray
var purple_snowball : PoolRealArray
var grey_ball : PoolRealArray
var grey_snowball : PoolRealArray
var orange_ball : PoolRealArray
var orange_snowball : PoolRealArray
var white_ball : PoolRealArray
var white_snowball : PoolRealArray
var cyan_ball : PoolRealArray
var cyan_snowball : PoolRealArray
var yellow_ball : PoolRealArray
var yellow_snowball : PoolRealArray
	
var balls : Array
var snowballs : Array

var raindrop : PoolRealArray
var pink_star : PoolRealArray

var laser_seed : PoolRealArray

var debug_t_start := 0

func start():
	started = true
	var start_t = debug_t_start
	t_raw = start_t
	t_int = int(start_t)
	get_node("../../background").play_bg(3, start_t / 60.0)
	call_deferred("start_music", 3, start_t / 60.0)
	$choreographer.play("Intro")
	$choreographer.seek(start_t / 60.0, true)
	difficulty = DefSys.difficulty
	
	blue_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.BLUE)
	purple_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.PURPLE)
	grey_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.GREY)
	orange_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.ORANGE)
	white_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.WHITE)
	cyan_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.CYAN_D)
	yellow_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.YELLOW)
	
	blue_snowball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.SNOWBALL, DefSys.COLORS.BLUE)
	purple_snowball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.SNOWBALL, DefSys.COLORS.PURPLE)
	grey_snowball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.SNOWBALL, DefSys.COLORS.GREY)
	orange_snowball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.SNOWBALL, DefSys.COLORS.ORANGE)
	white_snowball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.SNOWBALL, DefSys.COLORS.WHITE)
	cyan_snowball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.SNOWBALL, DefSys.COLORS.CYAN_D)
	yellow_snowball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.SNOWBALL, DefSys.COLORS.YELLOW)
	#[$D, $HG, $P, $SS, $Pt, $LA]
	balls = [blue_ball, orange_ball, purple_ball, white_ball, grey_ball, cyan_ball]
	snowballs = [blue_snowball, orange_snowball, purple_snowball, white_snowball, grey_snowball, cyan_snowball]
	for i in 6:
		var book = books[i]
		book.ball = balls[i]
		book.snowball = snowballs[i]
		book.tank_time = 99999
		book.tank_factor = 99999
		
	raindrop = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DROPLET, DefSys.COLORS.CYAN)
	pink_star = DefSys.get_bullet_data(DefSys.BULLET_TYPE.STAR_LARGE, DefSys.COLORS_LARGE.RED)

	laser_seed = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.BLUE)

func start_music(id, start_t = 0):
	get_node("../Music").play_music(id, start_t)

func _physics_process(delta):
	if !started:
		return
	t_raw += delta * 60.0
	
	while t_int < t_raw:
		t_int += 1
		stage_process(t_int, delta)
	
const UXIE_START := 984
const MESPRIT_SETUP := 1890
const MESPRIT_START := 2196
const AZELF_SETUP := 3102
const AZELF_START := 3400
const AZELF_LEAVE := 4560
const END := 5220

var BOOK_SPEED = [3.5, 4.0, 5.0, 5.25, 6.0]
var BOOK_DENSITY = [6, 8, 10, 11, 14]
var BOOK_RATE = [60, 45, 36, 30, 24]

var book_speed = []

var RAIN_RATE = [3, 3, 1, 1, 1]
var RAIN_SKIP_RATE = [0, 0, 2, 6, 0]
var RAIN_SPEED = [8.0, 10.0, 11.0, 13.0, 15.0]
var RAIN_STAR_RATE = [6, 5, 4, 3, 2]
var RAIN_STAR_SPEED = [9.0, 10.0, 11.0, 12.0, 14.0]

var rain_skip_counter = 0

var lr := 1.0

var LASER_SPREAD := 5

var LASER_GAP = [80, 60, 50, 40, 20]

var BIG_LASER_SCALE = [0.85, 0.9, 0.95, 1.0, 1.25]
var LASER_DURATION = [0.7, 0.8, 0.9, 1.0, 1.1]

var floor_index := 0
var celing_index := 0

func stage_process(t: int, _delta):
	if t < UXIE_START:
		if t == 870 - 60:
			books[0].visible = true
			books[0].monitoring = true
		elif t == 888 - 60:
			books[1].visible = true
			books[1].monitoring = true
		elif t == 918 - 60:
			books[2].visible = true
			books[2].monitoring = true
		elif t == 936 - 60:
			books[3].visible = true
			books[3].monitoring = true
		elif t == 966 - 60:
			books[4].visible = true
			books[4].monitoring = true
		elif t == 996 - 60:
			books[5].visible = true
			books[5].monitoring = true
	
	# Uxie shoot
	elif t < MESPRIT_SETUP:
		if t == UXIE_START:
			for book in books:
				book.started = true
				book.tank_time = 0
				book.t_raw = 0.0
				book.t_int = -1
		
		
		if (t - UXIE_START) % BOOK_RATE[difficulty] == 0:
			DefSys.sfx.play("shoot1")
			var ang = randf()*TAU
			var speed = BOOK_SPEED[difficulty]
			var density = BOOK_DENSITY[difficulty]
			var pos = $Uxie.position
			
			for j in density:
				var a = ang + j / float(density) * TAU
				Bullets.create_shot_a1(bullet_kit, pos, speed, a, yellow_ball, true)
				Bullets.create_shot_a1(bullet_kit, pos, speed, a + 0.1, yellow_snowball, true)
				Bullets.create_shot_a1(bullet_kit, pos, speed * 0.925, a, yellow_ball, true)
				Bullets.create_shot_a1(bullet_kit, pos, speed * 0.925, a + 0.1, yellow_snowball, true)
	
	# Mesprit shoot
	elif t >= MESPRIT_START and t < AZELF_SETUP:
		rain_skip_counter += 1
		if rain_skip_counter == RAIN_SKIP_RATE[difficulty]:
			rain_skip_counter = 0
		else:
			DefSys.sfx.play("shoot1")
			if t % RAIN_RATE[difficulty] == 0:
				var ang = PI* 0.5
				var speed = RAIN_SPEED[difficulty]
				var x = rand_range(0.0, 1000.0)
				for i in 6:
					var b = Bullets.create_shot_a1(bullet_kit, Vector2(x, -20), 0.0, ang, raindrop, true)
					Bullets.add_transform(b, Constants.TRIGGER.TIME, i+1, {"speed": speed})
			
			if t % RAIN_STAR_RATE[difficulty] == 0:
				var pos = $Mesprit.position + Vector2(rand_range(0.0, 150.0), 0.0).rotated(randf()*TAU)
				var ang = root.get_player_position().angle_to_point(pos)
				var speed = rand_range(0.4, 1.0) * RAIN_STAR_SPEED[difficulty]
				var b = Bullets.create_shot_a1(bullet_kit, pos, speed, ang, pink_star, true)
				Bullets.set_bullet_property(b, "spin", rand_range(0.05, 0.15) * lr)
				lr *= -1.0
	
	if t == AZELF_START - 25:
		Bullets.create_shot_a1(bullet_kit_add, $Azelf.position, 10.0, -PI*0.5, laser_seed, true)
		DefSys.sfx.play("shoot1")
		DefSys.sfx.play("warning1")
	
	elif t >= AZELF_START and t < END:
		var u := t - AZELF_START
		# Top
		if u == 0:
			var laser_m := Laser.instance()
			DefSys.sfx.play("laser1")
			laser_m.start_position = Vector2(500, 0)
			laser_m.direction = Vector2(0, 1)
			laser_m.oneshot = true
			add_child(laser_m)
		elif u < LASER_SPREAD * 10:
			if u % LASER_SPREAD == 0:
				DefSys.sfx.play("laser1")
				var x := (u / float(LASER_SPREAD)) * 50.0
				var laser_l := Laser.instance()
				laser_l.start_position = Vector2(500 + x, 0)
				laser_l.direction = Vector2(0, 1)
				laser_l.oneshot = true
				add_child(laser_l)
				var laser_r := Laser.instance()
				laser_r.start_position = Vector2(500 - x, 0)
				laser_r.direction = Vector2(0, 1)
				laser_r.oneshot = true
				add_child(laser_r)
		
		# Walls
		elif u < LASER_SPREAD * 30:
			if u % LASER_SPREAD == 0:
				DefSys.sfx.play("laser1")
				var y := (u / float(LASER_SPREAD) - 10.0) * 50.0
				var laser_l := Laser.instance()
				laser_l.start_position = Vector2(0, y)
				laser_l.direction = Vector2(1, 0)
				laser_l.oneshot = true
				laser_l.rotation = -PI*0.5
				add_child(laser_l)
				var laser_r := Laser.instance()
				laser_r.start_position = Vector2(1000, y)
				laser_r.direction = Vector2(-1, 0)
				laser_r.oneshot = true
				laser_r.rotation = PI*0.5
				add_child(laser_r)
		
		# Floor	
		elif u < LASER_SPREAD * 40:
			if u % LASER_SPREAD == 0:
				DefSys.sfx.play("laser1")
				var x := (u / float(LASER_SPREAD) - 30.0) * 50.0
				var laser_l := Laser.instance()
				laser_l.start_position = Vector2(0 + x, 1000 + LASER_GAP[difficulty])
				laser_l.direction = Vector2(0, -1)
				laser_l.oneshot = false
				laser_l.rotation = -PI
				laser_l.t = (u - LASER_SPREAD * (50 - floor_index)) / 60.0
				add_child(laser_l)
				var laser_r := Laser.instance()
				laser_r.start_position = Vector2(1000 - x, 1000 + LASER_GAP[difficulty])
				laser_r.direction = Vector2(0, -1)
				laser_r.oneshot = false
				laser_r.rotation = PI
				laser_r.t = (u - LASER_SPREAD * (50 - 20 + floor_index)) / 60.0
				add_child(laser_r)
				
				floor_index += 1
		elif u == LASER_SPREAD * 40:
			var laser_m := Laser.instance()
			DefSys.sfx.play("laser1")
			laser_m.start_position = Vector2(500, 1000 + LASER_GAP[difficulty])
			laser_m.direction = Vector2(0, -1)
			laser_m.oneshot = false
			laser_m.rotation = PI
			laser_m.t = (u - LASER_SPREAD * (50 - 10)) / 60.0
			add_child(laser_m)
		
		# Ceiling
		if u == LASER_SPREAD * 35:
			var laser_m := Laser.instance()
			DefSys.sfx.play("laser1")
			laser_m.start_position = Vector2(500, -LASER_GAP[difficulty])
			laser_m.direction = Vector2(0, 1)
			laser_m.oneshot = false
			laser_m.t = (u - LASER_SPREAD * (50 - 10)) / 60.0
			add_child(laser_m)
		elif u > LASER_SPREAD * 35 and u <= LASER_SPREAD * 45:
			if u % LASER_SPREAD == 0:
				DefSys.sfx.play("laser1")
				var x := (u / float(LASER_SPREAD) - 35.0) * 50.0
				var laser_l := Laser.instance()
				laser_l.start_position = Vector2(500 + x, -LASER_GAP[difficulty])
				laser_l.direction = Vector2(0, 1)
				laser_l.oneshot = false
				laser_l.t = (u - LASER_SPREAD * (50 - 11 - celing_index)) / 60.0
				add_child(laser_l)
				var laser_r := Laser.instance()
				laser_r.start_position = Vector2(500 - x, -LASER_GAP[difficulty])
				laser_r.direction = Vector2(0, 1)
				laser_r.oneshot = false
				laser_r.t = (u - LASER_SPREAD * (50 - 9 + celing_index)) / 60.0
				add_child(laser_r)
				
				celing_index += 1
		
		# Big laser
		#print(t)
		
		var offset = 90
		
		if t == 4017-offset or t == 4320-offset:
			var laser_t = BigLaser.instance()
			laser_t.rotation = PI*0.5
			laser_t.position = Vector2(200, 25)
			laser_t.scale *= BIG_LASER_SCALE[difficulty]
			laser_t.laser_duration = LASER_DURATION[difficulty]
			add_child(laser_t)
			var laser_b = BigLaser.instance()
			laser_b.rotation = -PI*0.5
			laser_b.position = Vector2(800, 975)
			laser_b.scale *= BIG_LASER_SCALE[difficulty]
			laser_b.laser_duration = LASER_DURATION[difficulty]
			add_child(laser_b)
			var laser_l = BigLaser.instance()
			laser_l.rotation = 0.0
			laser_l.position = Vector2(25, 200)
			laser_l.scale *= BIG_LASER_SCALE[difficulty]
			laser_l.laser_duration = LASER_DURATION[difficulty]
			add_child(laser_l)
			var laser_r = BigLaser.instance()
			laser_r.rotation = PI
			laser_r.position = Vector2(975, 800)
			laser_r.scale *= BIG_LASER_SCALE[difficulty]
			laser_r.laser_duration = LASER_DURATION[difficulty]
			add_child(laser_r)
		elif t == 4168-offset:
			var laser_nw = BigLaser.instance()
			laser_nw.rotation = PI*0.25
			laser_nw.position = Vector2(50, 50)
			laser_nw.scale *= BIG_LASER_SCALE[difficulty] * 1.25
			laser_nw.laser_duration = LASER_DURATION[difficulty]
			add_child(laser_nw)
			var laser_ne = BigLaser.instance()
			laser_ne.rotation = PI*0.75
			laser_ne.position = Vector2(950, 50)
			laser_ne.scale *= BIG_LASER_SCALE[difficulty] * 1.25
			laser_ne.laser_duration = LASER_DURATION[difficulty]
			add_child(laser_ne)
		elif t == 4472-offset:
			var laser_t = BigLaser.instance()
			laser_t.rotation = PI*0.5
			laser_t.position = Vector2(500, 25)
			laser_t.scale *= BIG_LASER_SCALE[difficulty] * 1.6
			laser_t.laser_duration = LASER_DURATION[difficulty]
			add_child(laser_t)
			var laser_l = BigLaser.instance()
			laser_l.rotation = 0.0
			laser_l.position = Vector2(25, 500)
			laser_l.scale *= BIG_LASER_SCALE[difficulty] * 1.6
			laser_l.laser_duration = LASER_DURATION[difficulty]
			add_child(laser_l)

	if t == END:
		root.start_section(4)



