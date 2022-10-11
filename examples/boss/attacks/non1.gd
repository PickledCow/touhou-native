extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := PI*0.5
var sides := 5
var r := 30.0
var lr := 1


var RATES = [12, 9, 7, 6]
var DIV = [18, 30, 30, 36]

var red_fireball : PoolRealArray
var orange_fireball : PoolRealArray

func attack_init():
	red_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.RED)
	orange_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.ORANGE)

func attack(t):
	if t >= 0:
		if t % 210 == 0:
			lr *= -1
			a = -PI / 2 - lr * PI / 3
			sides = 3
			r = 30.0
		if t % 210 < 170:
			if (t % 210) % RATES[DefSys.difficulty] == 0:
				DefSys.sfx.play("shoot2")
				Bullets.create_pattern_a2(bullet_kit_add, Constants.PATTERN_ADV.RINGS, position + Vector2(r, 0).rotated(a), 0, 0, 5, 0.0, a, 2*sides, 1, 1, red_fireball, true)
				
				a += lr * PI / DIV[DefSys.difficulty]
				sides += 1
				r += 10.0
				if t % 210 < 140 && (t % 210) % (RATES[DefSys.difficulty] * 2) == 0:
					Bullets.create_pattern_a2(bullet_kit_add, Constants.PATTERN_ADV.RINGS, position + Vector2(r, 0).rotated(a), 0, 0, 6, 0.0, -a, 1.2*sides, 1, 1, orange_fireball, true)
				
					pass
					#Bullets.create_pattern_a2(bullet_kit_add, Constants.PATTERN_ADV.RINGS, position + Vector2(r, 0).rotated(a), 0, 0, 6.0, 6.0, -a, 1 + (45 / sides), 1, sides, orange_fireball, true)
		
		if t % 210 == 170:
			set_dest(Vector2(rand_range(max(300, position.x - 200), min(700, position.x + 200)), 300), 40)
