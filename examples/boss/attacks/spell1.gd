extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

#var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1
var alt_col := true
var alt_col2 := false

var p : Vector2

var grey_ball : PoolRealArray
var red_ball : PoolRealArray
var orange_ball : PoolRealArray
var yellow_ball : PoolRealArray
#var balls = [grey_ball, red_ball, orange_ball, yellow_ball]

var grey_mentos : PoolRealArray
var red_mentos : PoolRealArray
var orange_mentos : PoolRealArray
var yellow_mentos : PoolRealArray
#var snowballs = [grey_snowball, red_snowball, orange_snowball, yellow_snowball]

var orange_bubble : PoolRealArray

func attack_init():
	grey_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.GREY)
	red_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.RED)
	orange_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.ORANGE)
	yellow_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.YELLOW)
	grey_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.GREY)
	red_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.RED)
	orange_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.ORANGE)
	yellow_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.YELLOW)
	
	orange_bubble = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BUBBLE, DefSys.COLORS_LARGE.ORANGE)

func attack(t):
	if t >= 0:
		if t % 25 == 0:
			var y = rand_range(-72, 1000)
			var p1 = Vector2(rand_range(0, 1000), -50)
			var p2 = Vector2(500 - lr * 564, y)
			var s = 12.0
			var a = PI*(0.5 - 0.25 * lr) 
			var b1 = Bullets.create_shot_a1(bullet_kit_add, p1, s, a, orange_bubble, false)
			var b2 = Bullets.create_shot_a1(bullet_kit_add, p2, s, a, orange_bubble, false)
			var tm2 = int(max(1.0, 1.414 * (1000.0 - y) / s + 1.0))

			Bullets.set_bullet_properties(b1, {"scale": 128.0*1.25})
			Bullets.set_bullet_properties(b2, {"scale": 128.0*1.25})
		
			for i in 8:
				var ci = randi()%4
				var c = grey_ball if ci == 0 else red_ball if ci == 1 else orange_ball if ci == 2 else yellow_ball
				var s0 = rand_range(4.0, 6.0)
				var a0 = randf()*PI + PI
				
				var b = Bullets.create_shot_a1(bullet_kit, p2, s, a, c, false)
				Bullets.set_bullet_properties(b, {"scale": 0.1})
				Bullets.add_pattern(b, Constants.TRIGGER.TIME, tm2, {"speed": s0, "angle": a0, "scale": 32.0})
				
			for i in 4:
				var ci = randi()%4
				var c = grey_mentos if ci == 0 else red_mentos if ci == 1 else orange_mentos if ci == 2 else yellow_mentos
				var s0 = rand_range(2.0, 5.0)
				var a0 = randf()*PI + PI
				
				var b = Bullets.create_shot_a1(bullet_kit, p2, s, a, c, false)
				Bullets.set_bullet_properties(b, {"scale": 0.1})
				Bullets.add_pattern(b, Constants.TRIGGER.TIME, tm2, {"speed": s0, "angle": a0, "scale": 64.0})
			DefSys.sfx.queue_sfx("shoot1", tm2)
			
			#var x = rand_range(-50, 1050)
			#var p = Vector2(x, 1000)
			#for i in 20:
			#	var ci = randi()%4
			#	var c = grey_ball if ci == 0 else red_ball if ci == 1 else orange_ball if ci == 2 else yellow_ball
			#	var s0 = rand_range(4.0, 6.0)
			#	var a0 = randf()*PI + PI
				
			#	Bullets.create_shot_a1(bullet_kit, p, s0, a0, c, true)
				
				
				
