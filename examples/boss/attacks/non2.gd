extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1

var blue_fireball : PoolRealArray
var blue_ball : PoolRealArray
var blue_orb : PoolRealArray

func attack_init():
	blue_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.BLUE)
	blue_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.BLUE)
	blue_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.BLUE)
	
var CYCLE = [90,72,60,48,40]
var PULSE = [45,36,36,30,28]
var RATE1 = [8,6,6,4,3]
var RATE2 = [4,3,3,2,2]
var DENSITY = [16,18,24,30,36]
var SPEED1 = [3.5,4.5,5.0,6.0,7.0]
var SPEED2 = [6.0,7.0,8.0,9.25,12.0]
var SPIN1 = [0.03, 0.025, 0.025, 0.02, 0.02]
var SPIN2 = [0.02, 0.015, 0.015, 0.01, 0.01]

func attack(t):
	if t >= 0:
		if t % CYCLE[difficulty] == 0:
			a = randf()*TAU
			
		if t % CYCLE[difficulty] < PULSE[difficulty] and t % RATE1[difficulty] == 0:
			DefSys.sfx.play("shoot1")
			var s = SPEED1[difficulty]
			Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 64.0, s, a, DENSITY[difficulty], 0.0, blue_fireball, true)
			a += SPIN1[difficulty]
		
		var m = (CYCLE[difficulty] + PULSE[difficulty]) / 2
		
		if t % CYCLE[difficulty] == m-PULSE[difficulty] / 2:
			a2 = randf()*TAU
			
		if (t % CYCLE[difficulty] < m+PULSE[difficulty] / 2 - CYCLE[difficulty] or t % CYCLE[difficulty] >= m-PULSE[difficulty] / 2) and t % RATE2[difficulty] == 0:
			if t >= 30:
				DefSys.sfx.play("shoot1")
				var s = SPEED2[difficulty]
				Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 96.0, s, a2, DENSITY[difficulty], 0.0, blue_ball, true)
				a2 -= SPIN2[difficulty]
			
		if position.distance_squared_to(root.get_player_position()) < 100*100:
			if t % 10 == 0:
				DefSys.sfx.play("shoot1")
				Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 0.0, 10, randf()*TAU, 128, 0.0, blue_orb, true)
		
