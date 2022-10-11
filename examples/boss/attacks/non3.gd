extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := PI*0.5
var lr := 1
var p = Vector2()

var DENSITY = [16, 26, 27, 28]
var SPEED = [2.2, 2.75, 2.8, 3]
var RATE = [10, 6, 6, 5]
var SPIN = [6, 4, 4.5, 4]

var grey_ball: PoolRealArray

func attack_init():
	grey_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.GREY)
func attack(t):
	if t >= 0:
		var cycle = 240
		if t % cycle == 0:
			p = position
			a = PI/2
		var ACTIVE_TIME = 60 * 2
		if t % cycle < 120:
			if (t % cycle) % RATE[DefSys.difficulty] == 0:
				#root.shoot1.play()
				DefSys.sfx.play("shoot2")
				var d = DENSITY[DefSys.difficulty]
				if t % cycle == 0:
					a = PI/2
					lr *= -1
				var o = Vector2((t % cycle) * 6, 0).rotated(PI/2 + lr * PI/4)
				var o2 = Vector2((t % cycle) * 6, 0).rotated(PI/2 - lr * PI/4)
				var s = SPEED[DefSys.difficulty]
				Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position + o, 0, s, a, d, 0, grey_ball, true)
				Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position + o2, 0, s, a, d, 0, grey_ball, true)
				a += lr * deg2rad(SPIN[DefSys.difficulty])
					
					
		#if t % 240 == (180):
	#		lr *= -1
