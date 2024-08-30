extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add


#onready var Roar := preload("res://examples/boss/roar.tscn")

onready var roar := $roar
onready var roar2 := $roar2

var a1 := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1
var alt_col := true
var alt_col2 := false

var p : Vector2

var rate = [40, 36, 30, 25, 20]
var speed = [5.5, 6, 6.5, 7, 8]

var SPAWN_TIMES = [0, 60 * 4]
var SPIN := 0.01
var CYCLE := 720
var TRANSFORM_TIME := 120.0

var START_ANGLE := -PI*0.1

var DENSITY := [2, 3, 5, 8, 10]

var red_fireball : PoolRealArray
var orange_fireball : PoolRealArray
var yellow_fireball : PoolRealArray
var green_fireball : PoolRealArray
var cyan_fireball : PoolRealArray
var blue_fireball : PoolRealArray
var purple_fireball : PoolRealArray

var red_ball : PoolRealArray
var orange_ball : PoolRealArray
var yellow_ball : PoolRealArray
var green_ball : PoolRealArray
var cyan_ball : PoolRealArray
var blue_ball : PoolRealArray
var purple_ball : PoolRealArray

var fireballs : Array
var balls : Array

var direction_flipped := false

func attack_init():
	red_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.RED)
	orange_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.ORANGE)
	yellow_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.YELLOW)
	green_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.GREEN)
	cyan_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.CYAN)
	blue_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.BLUE)
	purple_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.PURPLE)
	
	red_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.RED)
	orange_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.ORANGE)
	yellow_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.YELLOW)
	green_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.GREEN)
	cyan_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.CYAN)
	blue_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.BLUE)
	purple_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.PURPLE)
	
	fireballs = [red_fireball, orange_fireball, yellow_fireball, green_fireball, cyan_fireball, blue_fireball, purple_fireball]
	balls = [red_ball, orange_ball, yellow_ball, green_ball, cyan_ball, blue_ball, purple_ball]
	

func attack(t):
	if t == 0:
		parent.face(true)
	if t >= 0:
		if t % CYCLE == 0:
			a1 = START_ANGLE
			roar.laser_phase = 0
			roar.spin = SPIN
			roar.rotation = START_ANGLE
			roar.t = 0.0
		if t % CYCLE == 90:
			root.slowdown(0.5)
		elif t % CYCLE == 300:
			root.slowdown(1.0)
		
		if t % CYCLE >= 36:
			a1 += SPIN
		
		if t % CYCLE >= 90 and t % CYCLE < 280:
			DefSys.sfx.play("warning1")
			if !direction_flipped and a1 > PI*0.5:
				direction_flipped = true
				parent.face(false)
			for i in DENSITY[difficulty]:
				var a := rand_range(-0.1, 0.1) + a1
				var speed := rand_range(1.75, 2.5)
				var f_c = fireballs[int(min(6.0, (t % CYCLE - 90.0) / 210.0 * 8))]
				var b_c = balls[int(min(6.0, (t % CYCLE - 90.0) / 210.0 * 8))]
				
				if a > PI * 0.25 and a < PI * 0.75: # Ground
					var angle := rand_range(PI, TAU)
					var x := 500.0 + 500.0 / tan(a)
					var fireball = Bullets.create_shot_a1(bullet_kit_add, Vector2(x, 1000.0), speed, angle, f_c, true)
					Bullets.add_pattern(fireball, Constants.TRIGGER.TIME, TRANSFORM_TIME, {"position": Vector2(-1000, -1000)})
					var ball = Bullets.create_shot_a1(bullet_kit, Vector2(x, 1000.0), speed, angle, b_c, false)
					Bullets.set_bullet_property(ball, "scale", 0.01)
					Bullets.add_pattern(ball, Constants.TRIGGER.TIME, TRANSFORM_TIME, {"scale": 32.0})
				else:
					var angle := randf()*PI + (PI*0.5 if a < PI*0.5 else - PI*0.5) 
					var y := 500.0 + 500.0 * tan(a)
					var fireball = Bullets.create_shot_a1(bullet_kit_add, Vector2(1000.0 if a < PI*0.5 else 0.0, y), speed, angle, f_c, true)
					Bullets.add_pattern(fireball, Constants.TRIGGER.TIME, TRANSFORM_TIME, {"position": Vector2(-1000, -1000)})
					var ball = Bullets.create_shot_a1(bullet_kit, Vector2(1000.0 if a < PI*0.5 else 0.0, y), speed, angle, b_c, false)
					Bullets.set_bullet_property(ball, "scale", 0.01)
					Bullets.add_pattern(ball, Constants.TRIGGER.TIME, TRANSFORM_TIME, {"scale": 32.0})
			
		if t % CYCLE == CYCLE / 2:
			a2 = PI + START_ANGLE
			roar2.laser_phase = 0
			roar2.spin = SPIN
			roar2.rotation = PI + START_ANGLE
			roar2.t = 0.0
		if t % CYCLE == CYCLE / 2 + 90:
			root.slowdown(0.5)
			direction_flipped = false
		elif t % CYCLE == CYCLE / 2 + 300:
			root.slowdown(1.0)
			direction_flipped = false
			
		if t % CYCLE >= 36 + CYCLE / 2:
			a2 += SPIN
		
		if t % CYCLE >= 90 + CYCLE / 2 and t % CYCLE < 280 + CYCLE / 2:
			if !direction_flipped and a2 - PI > PI*0.5:
				direction_flipped = true
				parent.face(true)
			
			DefSys.sfx.play("warning1")
			for i in DENSITY[difficulty]:
				var a := rand_range(-0.1, 0.1) + a2 - PI
				var speed := rand_range(1.75, 2.5)
				var f_c = fireballs[int(min(6.0, (t % CYCLE - 90.0 - CYCLE / 2) / 210.0 * 8))]
				var b_c = balls[int(min(6.0, (t % CYCLE - 90.0 - CYCLE / 2) / 210.0 * 8))]
				
				if a > PI * 0.25 and a < PI * 0.75: # Ceiling
					var angle := randf()*PI
					var x := 500.0 - 500.0 / tan(a)
					var fireball = Bullets.create_shot_a1(bullet_kit_add, Vector2(x, 0.0), speed, angle, f_c, true)
					Bullets.add_pattern(fireball, Constants.TRIGGER.TIME, TRANSFORM_TIME, {"position": Vector2(-1000, -1000)})
					var ball = Bullets.create_shot_a1(bullet_kit, Vector2(x, 0.0), speed, angle, b_c, false)
					Bullets.set_bullet_property(ball, "scale", 0.01)
					Bullets.add_pattern(ball, Constants.TRIGGER.TIME, TRANSFORM_TIME, {"scale": 32.0})
				else:
					var angle := randf()*PI - (PI*0.5 if a < PI*0.5 else - PI*0.5) 
					var y := 500.0 - 500.0 * tan(a)
					var fireball = Bullets.create_shot_a1(bullet_kit_add, Vector2(0.0 if a < PI*0.5 else 1000.0, y), speed, angle, f_c, true)
					Bullets.add_pattern(fireball, Constants.TRIGGER.TIME, TRANSFORM_TIME, {"position": Vector2(-1000, -1000)})
					var ball = Bullets.create_shot_a1(bullet_kit, Vector2(0.0 if a < PI*0.5 else 1000.0, y), speed, angle, b_c, false)
					Bullets.set_bullet_property(ball, "scale", 0.01)
					Bullets.add_pattern(ball, Constants.TRIGGER.TIME, TRANSFORM_TIME, {"scale": 32.0})
					
