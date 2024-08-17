extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1
var alt_col := true
var alt_col2 := false

var p : Vector2

var grey_ball : PoolRealArray
var white_ball : PoolRealArray
var grey_snowball : PoolRealArray

func attack_init():
	grey_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.GREY)
	white_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.WHITE)
	grey_snowball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.SNOWBALL, DefSys.COLORS.GREY)
	

func attack(t):
	var CYCLE_TIME = 60*(5*2+7*2+1)
	if t > 0:
		if t % CYCLE_TIME < 60*5*2:
			type1(t % CYCLE_TIME)
		else:
			type2(t % CYCLE_TIME - 60*(5*2 + 1))
	
					

func type1(u):
	if u >= 0:
		var CYCLE_TIME = 60 * 5
		if u % 5 == 0:
			var ACTIVE_TIME = 60 * 2
			if u % CYCLE_TIME < ACTIVE_TIME:
				#root.shoot1.play()
				var DENSITY = 72
				var shift = 45 if u >= CYCLE_TIME else 45
				if u % CYCLE_TIME == 0:
					a = randf()*TAU
					lr *= -1
					#print(p)
				var r = (u % CYCLE_TIME) * 8
				var d = (Vector2(500, 1000) - position).normalized().rotated(deg2rad(-lr*shift))
			#	var f = 0.05 * lr
				var s = 3.0 + 3.0 * (u % CYCLE_TIME) / ACTIVE_TIME
				Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position + d*r, 0.0, s, a + TAU / DENSITY, DENSITY * 0.5, 0.0, white_ball, true)
				Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position + d*r, 0.0, s, a, DENSITY * 0.5, 0.0, grey_ball, true)
				DefSys.sfx.play("shoot1")
				a += lr * 0.4 #0.06
		if u % CYCLE_TIME == 60 * 3:
			pass
			#var x = rand_range( max(1000.0*0.3, position.x - 200 * (position.x / 1000.0)), min(1000.0*0.7, position.x + 200 * (1 - position.x / 1000.0))  )
			#var y = rand_range(0.25, 0.35) * 1000.0
			#dest = Vector2(x, y)
					

func type2(u):
	if u >= 0:
		var CYCLE_TIME = 60 * 7
		if u % 3 == 0:
			var ACTIVE_TIME = 60 * 2
			if u % CYCLE_TIME < ACTIVE_TIME:
				#root.shoot1.play()
				var DENSITY = 45
				if u % CYCLE_TIME == 0:
					lr *= -1
					a = PI * (0.5 - 0.5 * lr)
					a2 = PI * (0.5 - 0.5 * lr)
					p = Vector2(500, 1000)
					alt_col2 = !alt_col2
				var r = (u % CYCLE_TIME) * 8
				var d1 = (p - position).normalized().rotated(deg2rad(-45))
				var d2 = (p - position).normalized().rotated(deg2rad(45))
				var s = 3
				
				if u % 6 == 0:
					Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING,  position + d1*r, 0.0, s, a + TAU / DENSITY, DENSITY * 0.5, 0.0, white_ball if alt_col2 else white_ball if alt_col else grey_ball, true)
					Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING,  position + d1*r, 0.0, s, a, DENSITY * 0.5, 0.0, grey_ball if alt_col2 else white_ball if !alt_col else grey_ball, true)
					a +=  0.05 * lr + PI
					DefSys.sfx.play("shoot1")
				elif u % 6 == 3:
					Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING,  position + d2*r, 0.0, s, a2 + TAU / DENSITY, DENSITY * 0.5, 0.0, white_ball if !alt_col2 else white_ball if alt_col else grey_ball, true)
					Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING,  position + d2*r, 0.0, s, a2, DENSITY * 0.5, 0.0, grey_ball if !alt_col2 else white_ball if !alt_col else grey_ball, true)
					a2 += 0.05 * lr + PI
					DefSys.sfx.play("shoot1")
					alt_col = !alt_col
		if u % CYCLE_TIME == 60 * 3:
			pass
			#var x = rand_range( max(1000.0*0.3, position.x - 200 * (position.x / 000.0)), min(000.0*0.7, position.x + 200 * (1 - position.x / 000.0))  )
			#var y = rand_range(0.25, 0.35) * 000.0
			#dest = Vector2(x, y)

