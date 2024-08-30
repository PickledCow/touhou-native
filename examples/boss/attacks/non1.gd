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


var DENSITY = [36, 48, 60, 72, 90]
var DENSITY2 = [16, 24, 32, 38, 45]
var ROT = [0.75, 0.58, 0.47, 0.4, 0.32]
var ROT2 = [0.15, 0.14, 0.11, 0.105, 0.1]

var RATE = [4, 4, 3, 3, 3]

var grey_ball : PoolRealArray
var white_ball : PoolRealArray
var grey_snowball : PoolRealArray



func attack_init():
	grey_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.GREY)
	white_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.WHITE)
	grey_snowball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.SNOWBALL, DefSys.COLORS.GREY)
	

func attack(t):
	var CYCLE_TIME = 60*(5*2+7*2+1)
	if t >= 0:
		if false:
			type2(t % CYCLE_TIME)
		elif t % CYCLE_TIME < 60*5*2:
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
				var shift = 45 if u >= CYCLE_TIME else 45
				if u % CYCLE_TIME == 0:
					a = randf()*TAU
					lr *= -1
					#print(p)
				var r = (u % CYCLE_TIME) * 8
				var d = (Vector2(500, 1000) - position).normalized().rotated(deg2rad(-lr*shift))
			#	var f = 0.05 * lr
				var s = 3.0 + 3.0 * (u % CYCLE_TIME) / ACTIVE_TIME
				Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position + d*r, 0.0, s, a + TAU / DENSITY[difficulty], DENSITY[difficulty] * 0.5, 0.0, white_ball, true)
				Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position + d*r, 0.0, s, a, DENSITY[difficulty] * 0.5, 0.0, grey_ball, true)
				DefSys.sfx.play("shoot1")
				a += lr * ROT[difficulty]
		if u % CYCLE_TIME == 60 * 3:
			pass
			#var x = rand_range( max(1000.0*0.3, position.x - 200 * (position.x / 1000.0)), min(1000.0*0.7, position.x + 200 * (1 - position.x / 1000.0))  )
			#var y = rand_range(0.25, 0.35) * 1000.0
			#dest = Vector2(x, y)
					

func type2(u):
	if u >= 0:
		var CYCLE_TIME = 60 * 7
		if u % RATE[difficulty] == 0:
			var ACTIVE_TIME = 60 * 2
			if u % CYCLE_TIME < ACTIVE_TIME:
				#root.shoot1.play()
				if u % CYCLE_TIME == 0:
					lr *= -1
					a = PI * (0.5 - 0.25 * lr)
					a2 = PI * (0.5 + 0.25 * lr)
					p = Vector2(500, 1000)
					alt_col2 = !alt_col2
				if u % (CYCLE_TIME * 2) == 0:
					if difficulty != 3:
						alt_col = !alt_col
						alt_col2 = !alt_col2
				var r = (u % CYCLE_TIME) * 8
				var d1 = (p - position).normalized().rotated(deg2rad(-45))
				var d2 = (p - position).normalized().rotated(deg2rad(45))
				var s = 3
				
				if (u % (RATE[difficulty] * 2)) == 0:
					var c1 = white_ball if alt_col2 else white_ball if alt_col else grey_ball
					var c2 = grey_ball if alt_col2 else white_ball if !alt_col else grey_ball
					Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING,  position + d1*r, 0.0, s, a + TAU / DENSITY2[difficulty], DENSITY2[difficulty] * 0.5, 0.0, c1, true)
					Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING,  position + d1*r, 0.0, s, a, DENSITY2[difficulty] * 0.5, 0.0, c2, true)
					a += PI + lr * ROT2[difficulty]
					DefSys.sfx.play("shoot1")
				elif( u % (RATE[difficulty] * 2))== RATE[difficulty]:
					
					var c1 = white_ball if !alt_col2 else white_ball if alt_col else grey_ball
					var c2 = grey_ball if !alt_col2 else white_ball if !alt_col else grey_ball
					Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING,  position + d2*r, 0.0, s, a2 + TAU / DENSITY2[difficulty], DENSITY2[difficulty] * 0.5, 0.0, c1, true)
					Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING,  position + d2*r, 0.0, s, a2, DENSITY2[difficulty] * 0.5, 0.0, c2, true)
					a2 += PI + lr * ROT2[difficulty]
					DefSys.sfx.play("shoot1")
					alt_col = !alt_col
		if u % CYCLE_TIME == 60 * 3:
			pass
			#var x = rand_range( max(1000.0*0.3, position.x - 200 * (position.x / 000.0)), min(000.0*0.7, position.x + 200 * (1 - position.x / 000.0))  )
			#var y = rand_range(0.25, 0.35) * 000.0
			#dest = Vector2(x, y)

