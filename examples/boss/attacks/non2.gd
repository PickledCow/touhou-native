extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := PI*0.5
var a2 := PI*0.5
var sides := 5
var r := 30.0
var lr := 1


var RATE1 = [8, 6, 5, 4]
var RATE2 = [12, 9, 8, 7]
var DENSITY1 = [16, 20, 24, 28]
var DENSITY2 = [11, 15, 21, 27]
var SPEED1 = [5, 6, 7, 8]
var SPEED2 = [1.75, 2, 2.5, 3]
var SKEW = [1.8, 1.85, 1.85, 1.855]

var blue_fireball : PoolRealArray
var cyan_water : PoolRealArray
var cyan_fireball : PoolRealArray

func attack_init():
	blue_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.BLUE)
	cyan_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.CYAN)
	cyan_water = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DROPLET, DefSys.COLORS.CYAN)

func attack(t):
	if t >= 0:
		var cycle = 210
		if t % cycle == 0:
			a = PI/2 - lr * PI / 2
			a2 = PI/2 + lr * PI / 2
		if t % cycle < 120:
			if (t % cycle) % RATE1[DefSys.difficulty] == 0:
				var d1 = DENSITY1[DefSys.difficulty]
				var s1 = SPEED1[DefSys.difficulty]
				var sk = SKEW[DefSys.difficulty]
				var bs = Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 0, s1, a2, d1, 0,  blue_fireball, true)
				a2 -= lr * TAU/(d1-1) * sk
		if t % cycle < 200:
			if (t % cycle) % RATE2[DefSys.difficulty] == 0:
				var d2 = DENSITY2[DefSys.difficulty]
				var s2 = SPEED2[DefSys.difficulty]
				var bs = Bullets.create_pattern_a2(bullet_kit, Constants.PATTERN_ADV.FAN, position, 0, 0, s2, 0.0, a, d2, 1, 5.0, cyan_water, true)
				a += lr * 5.0/(d2-1) * 1.61803398875
				DefSys.sfx.play("shoot2")
					
		if t % cycle == (179):
			set_dest(Vector2(rand_range(max(300, position.x - 100), min(700, position.x + 100)), 300), 40)
			lr *= -1
