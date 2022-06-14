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
var red_fire : PoolRealArray

func attack_init():
	red_bubble = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BUBBLE, DefSys.COLORS_LARGE.RED)
	
	red_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.RED)
	red_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.RED)
	
	orange_knife = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.ORANGE)
	orange_knife[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	orange_knife[Constants.BULLET_DATA_STRUCTURE.LAYER] = DefSys.LAYERS.LARGE_BULLETS + 1
	
	orange_knife_small = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.ORANGE)
	
	red_fire = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.RED)

func attack(t):
	if true:
		if t < 60*4 && t >= 0:
			if t % 120 == 0:
				a2 = parent.player.position.angle_to_point(remilia_position)
			if t % 120 < 45:
				if t % 4 == 0:
					DefSys.sfx.play("shoot1")
					var p = remilia_position
					Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, p, 64, 7.0, a2, 60, 0, red_fire, true)
		if t == 60*5:
			set_remilia_dest(Vector2(500 - rand_range(0, 100) * lr, -500), 60)
		if t >= 60*11:
			# Galacta
			if t % 90 == 0:
				lr *= -1
				a = PI*0.5 - lr * rand_range(1.15,1.25)
			var ang = -PI*0.5 + PI*0.33 * sin(t*0.1)
			Bullets.create_shot_a1(bullet_kit, galacta_position + Vector2(128, 0).rotated(ang), rand_range(9, 10), ang, orange_knife, true)
			
			DefSys.sfx.play("warning1")
			#pass
			#var bullets = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 0.0, 10.0, a, 100, 0, data, true)
			if t >= 60*11:
				if t % 4 != 0:
					Bullets.create_shot_a1(bullet_kit, Vector2(rand_range(-100, 1100), -64), rand_range(6.0, 8.0), PI*0.5 + rand_range(-1,1) * 0.025 + PI*0.2 * sin(t*0.025), orange_knife, true)
			#Bullets.set_bullet_properties(bullet, {"bounce_count": 1, "bounce_surfaces": Constants.WALLS.DOME})
			#Bullets.add_transform(bullet, Constants.TRIGGER.TIME, 36, {"accel": 0.5, "max_speed": 6.0})
			a += 0.12 * lr
			
			# Remilia
			if t % 120 < 45:
				if t % 120 == 0:
					a2 = parent.player.position.angle_to_point(remilia_position)
				if t % 4 == 0:
					DefSys.sfx.play("shoot1")
					var p = remilia_position
					Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, p, 64, 7.0, a2, 30, 0, red_fire, true)
		
			# Move
			if (t+1) % 270 == 0:
				set_galacta_dest(Vector2(500 - rand_range(0, 100) * lr, rand_range(325, 370)), 60)
			if (t+1) % 270 == 135:
				set_remilia_dest(Vector2(500 - rand_range(0, 100) * lr, rand_range(150, 250)), 60)

		if t == 60*9:
			set_galacta_dest(Vector2(500 - rand_range(0, 100) * lr, rand_range(325, 370)), 60)
			set_remilia_dest(Vector2(500 - rand_range(0, 100) * lr, rand_range(150, 250)), 60)
			parent.invincible = false
		
