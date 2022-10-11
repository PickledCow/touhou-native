extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1

var SPEED = [2.5, 3, 3.5, 4]
var DENSITY = [8, 10, 12, 14]
var RATE = [18, 12, 6, 4]
var RATE2 = [16, 12, 9, 8]
var SPIN_TIME = [720, 600, 520, 480]
var SKEW = [-2,-2, -2 ,-2]

var red_flame : PoolRealArray
var orange_flame : PoolRealArray
var big_red_flame : PoolRealArray
var big_orange_flame : PoolRealArray

func attack_init():
	red_flame = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.RED)
	orange_flame = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.ORANGE)
	
	big_red_flame = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.RED)
	big_orange_flame = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.ORANGE)
	big_red_flame[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	big_orange_flame[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5

func attack(t):
	t += 510
	if t >= 0:
		var spin_time = SPIN_TIME[DefSys.difficulty]
		
		if t == 0:
			a = PI*0.5 - lr * PI*0.6
		DefSys.sfx.play("shoot2")
		for i in DENSITY[DefSys.difficulty]:
			var flame: PoolRealArray = red_flame if randi()%2 else orange_flame
			Bullets.create_shot_a1(bullet_kit_add, position, rand_range(20, 30), a + rand_range(-0.05, 0.05), flame, true)
		var spin_amount = TAU / spin_time
		if t > 60 + spin_time / 2:
			a += spin_amount
		elif t > 60:
			a += spin_amount * 2
		if t > 75:
			var sp = SPEED[DefSys.difficulty]
			var count = 0;
			var density = DENSITY[DefSys.difficulty]
			var rate = RATE[DefSys.difficulty]
			var rate2 = RATE2[DefSys.difficulty]
			var st = spin_time
			if t < 60 + spin_time / 2: 
				rate /= 2
				rate2 /= 2
				st /= 2
			if t % (rate2*2) == 0:
				for j in 3:
					var flame: PoolRealArray = big_red_flame if randi()%2 else big_orange_flame
					#var length := rand_range(10, 1000)
					var length = (j * 2.0 + 1) * 400.0 / 14
					var p := position + Vector2(length, 0).rotated(a - lr * (min(length / 25.0, t - 60) * spin_amount))
					#var b = Bullets.create_shot_a1(bullet_kit_add, p, 0, randi()%12 * TAU / 12, flame, true)
					var b = Bullets.create_shot_a1(bullet_kit_add, p, 0, a+PI/2, flame, true)
					Bullets.add_pattern(b, Constants.TRIGGER.TIME, spin_time, {"position": Vector2(2000, 2000)})
					
			if t % (rate2) == 0:
				for j in 7:
					var flame: PoolRealArray = big_red_flame if randi()%2 else big_orange_flame
					#var length := rand_range(10, 1000)
					var length = 350.0 + (j * 1.5 + 1) * 450.0 / 14
					var p := position + Vector2(length, 0).rotated(a - lr * (min(length / 25.0, t - 60) * spin_amount))
					#var b = Bullets.create_shot_a1(bullet_kit_add, p, 0, randi()%12 * TAU / 12, flame, true)
					var b = Bullets.create_shot_a1(bullet_kit_add, p, 0, a+PI/2, flame, true)
					Bullets.add_pattern(b, Constants.TRIGGER.TIME, spin_time, {"position": Vector2(2000, 2000)})
					
			if t % (rate * 2) == 0:
				if t > 75 + spin_time / 2:
					for j in density/2:
						var flame: PoolRealArray = red_flame if randi()%2 else orange_flame
						var old_a = a - spin_time * spin_amount
						var length = (j + 1.25 - lr * 0.25) * 350.0 / density
						var p := position + Vector2(length, 0).rotated(old_a - lr * (min(length / 25.0, t - 60) * spin_amount))
						Bullets.create_shot_a2(bullet_kit, p, 0, -2*old_a, 0.05, sp, flame, true)
						
			if t % rate == 0:
				if t > 75 + spin_time / 2:
					for j in density:
						var flame: PoolRealArray = red_flame if randi()%2 else orange_flame
						var old_a = a - spin_time * spin_amount
						var length = 350.0 + (j + 1.25 - lr * 0.25) * 350.0 / density
						var p := position + Vector2(length, 0).rotated(old_a - lr * (min(length / 25.0, t - 60) * spin_amount))
						Bullets.create_shot_a2(bullet_kit, p, 0, -2.39996322972865332*old_a, 0.05, sp, flame, true)
		if t == spin_time:
			DefSys.sfx.play("warning1")
					
				
				
