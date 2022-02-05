extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1

var red_bubble : PoolRealArray
var red_mentos : PoolRealArray
var red_ball : PoolRealArray
var orange_knife : PoolRealArray
var orange_knife_small : PoolRealArray

func attack_init():
	red_bubble = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BUBBLE, DefSys.COLORS_LARGE.RED)
	
	red_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.RED)
	red_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.RED)
	
	orange_knife = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.ORANGE)
	orange_knife[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	orange_knife[Constants.BULLET_DATA_STRUCTURE.LAYER] = DefSys.LAYERS.LARGE_BULLETS + 1
	
	orange_knife_small = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.ORANGE)

func attack(t):
	# Galacta
	if t >= 0:
		if t % 90 == 0:
			lr *= -1
			a = PI*0.5 - lr * rand_range(1.15,1.25)
		if t % 1 == 1:
			Bullets.create_shot_a1(bullet_kit, galacta_position, rand_range(6, 20), -PI*0.5 + PI*0.33 * sin(t*0.1), orange_knife, true)
		
		if t % 90 < 60:
			DefSys.sfx.play("warning1")
			#pass
			#var bullets = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 0.0, 10.0, a, 100, 0, data, true)
			var bullet = Bullets.create_shot_a2(bullet_kit, galacta_position + Vector2(96, 0).rotated(a), 6.0, a, -0.3334, 0.0, orange_knife, true)
			Bullets.set_bullet_properties(bullet, {"bounce_count": 1, "bounce_surfaces": Constants.WALLS.DOME})
			Bullets.add_transform(bullet, Constants.TRIGGER.TIME, 36, {"accel": 0.5, "max_speed": 6.0})
			a += 0.12 * lr
		
		# Remilia
		if t % 40 == 0:
			DefSys.sfx.play("shoot1")
			var p = remilia_position
			for l in range(-2, 2):
				var angle = parent.player.position.angle_to_point(remilia_position) + (l+0.5) * 0.75
				Bullets.create_shot_a1(bullet_kit_add, p, 18, angle, red_bubble, true)
				for i in 15:
					Bullets.create_shot_a1(bullet_kit, p, rand_range(12, 18), angle + rand_range(-0.15, 0.15), red_mentos, true)
				for i in 30:
					Bullets.create_shot_a1(bullet_kit, p, rand_range(6, 15), angle + rand_range(-0.2, 0.2), red_ball, true)

		
		# Move
		if (t+1) % 270 == 0:
			set_galacta_dest(Vector2(500 - rand_range(0, 150) * lr, rand_range(325, 370)), 60)
		if (t+1) % 270 == 135:
			set_remilia_dest(Vector2(500 - rand_range(0, 150) * lr, rand_range(150, 250)), 60)
