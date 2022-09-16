extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1

const SPIN_RATE = TAU / 300.0 * 0.975

var red_flame : PoolRealArray
var ball : PoolRealArray
var orange_flame : PoolRealArray

func attack_init():
	ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.RED)
	red_flame = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.RED)
	orange_flame = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.ORANGE)

func attack(t):
	if t >= 0:
		if t % 540 == 0:
			a = PI*0.5 - lr * PI*0.2
		if t % 540 < 390:
			DefSys.sfx.play("shoot2")
			for i in 4:
				var flame: PoolRealArray = orange_flame if randi()%3 else red_flame
				Bullets.create_shot_a1(bullet_kit_add, position, rand_range(20, 30), a + rand_range(-0.05, 0.05), flame, true)
				
			if t % 540 < 360:
				if t % 540 > 60:
					a += lr * SPIN_RATE
				if t % 540 > 75:
					for i in 2:
						var flame: PoolRealArray = orange_flame if randi()%3 else red_flame
						var length := rand_range(10, 1000)
						var p := position + Vector2(length, 0).rotated(a - lr * (min(length / 25.0, t % 540 - 60) * SPIN_RATE))
						var b = Bullets.create_shot_a1(bullet_kit_add, p, 0, randf()*TAU, flame, true)
						Bullets.add_pattern(b, Constants.TRIGGER.TIME, 300, {"accel": 0.05, "max_speed": 6.0})
					
				
		if t % 540 == 0:
			lr *= -1
				
				
