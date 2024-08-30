extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add
export(Resource) var bullet_kit_sub

var red_fireball : PoolRealArray
var blue_fireball : PoolRealArray
var green_heart : PoolRealArray
var yellow_arrow : PoolRealArray
var cyan_crystal : PoolRealArray
var cyan_crystal_small : PoolRealArray
var purple_fireball : PoolRealArray

var red_orb : PoolRealArray
var orange_orb : PoolRealArray
var yellow_orb : PoolRealArray
var green_orb : PoolRealArray
var cyan_orb : PoolRealArray
var blue_orb : PoolRealArray
var purple_orb : PoolRealArray
var orbs = []

var blue_orb_d : PoolRealArray

var pink_star_large : PoolRealArray
var pink_star : PoolRealArray

var white_ball : PoolRealArray

var max_health : float
var rollover_time := 999.0

func attack_init():
	red_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.RED)
	blue_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.BLUE)
	green_heart = DefSys.get_bullet_data(DefSys.BULLET_TYPE.HEART, DefSys.COLORS_LARGE.GREEN)
	yellow_arrow = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROW, DefSys.COLORS_LARGE.YELLOW)
	cyan_crystal = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ICE_LARGE, DefSys.COLORS_LARGE.CYAN)
	cyan_crystal_small = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ICE, DefSys.COLORS.CYAN)
	purple_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.PURPLE)
	red_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.RED)
	orange_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.ORANGE)
	yellow_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.YELLOW)
	green_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.GREEN)
	cyan_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.CYAN)
	blue_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.BLUE)
	purple_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.PURPLE)
	
	orbs = [red_orb, orange_orb, yellow_orb, green_orb, cyan_orb, blue_orb, purple_orb]
	
	blue_orb_d = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.BLUE_D)
	
	pink_star_large = DefSys.get_bullet_data(DefSys.BULLET_TYPE.STAR_LARGE, DefSys.COLORS_LARGE.PURPLE)
	pink_star = DefSys.get_bullet_data(DefSys.BULLET_TYPE.STAR, DefSys.COLORS.PURPLE)
	
	white_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.WHITE)

var a_0 := 0.0
var a_1 := 0.0

var p_0 := Vector2()

var lr := 1.0

var phase := 0 

var FIRE_DENSITY = [20, 30, 40, 55, 70]
var WATER_DENSITY = [8, 12, 16, 20, 24]
var GRASS_DENSITY = [16, 24, 36, 42, 60]
var GRASS_RATE = [45, 36, 30, 24, 20]

var ELEC_DENSITY = [12, 16, 24, 30, 36]
var ELEC_TIME = [30, 24, 20, 16, 12]

var ICE_RATE = [7, 5, 3, 2, 1]

var PSY_DENSITY = [2, 4, 6, 8, 10]

var DARK_RATE = [1, 2, 3, 4, 5]

var DRAGON_RATE =    [4, 3, 2, 2, 1]
var DRAGON_DENSITY = [2, 2, 2, 3, 2]

var FAIRY_DENSITY = [7, 13, 23, 27, 33]

var NORMAL_DENSITY_START = [40, 60, 80, 100, 120]
var NORMAL_DENSITY_CHANGE = [30, 25, 20, 16, 12]

func attack(t: int):
	if t >= 0:
		if phase == 0:
			# Fire
			if t < 720:
				if t % 20 == 0:
					var density = FIRE_DENSITY[difficulty]
					DefSys.sfx.play("shoot1")
					var bs = Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 64.0, 2.0, randf()*TAU, density, 0.0, red_fireball, true)
					var last_wvel := 0.0
					for i in 10:
						var w_vel := rand_range(-0.006, 0.006) - last_wvel * 0.125
						Bullets.add_transform_bulk(bs, Constants.TRIGGER.TIME, 30 * (i + 1), {"wvel" : w_vel})
						last_wvel = w_vel
			# Water
			elif t >= 720 + 120 and (t < 720 * 2):
				if t % 60 == 0:
					lr *= -1
					a_0 = randf()*TAU
				if t % 60 < 45:
					if t % 2 == 0:
						var density = WATER_DENSITY[difficulty]
						DefSys.sfx.play("shoot1")
						var bs = Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 64.0, 9.0, a_0, density, 0.0, blue_fireball, true)
						Bullets.set_properties_bulk(bs, {"bounce_surfaces": Constants.WALLS.SIDES, "bounce_count": 1})
						a_0 += 0.005 * lr
					
			# Garss
			elif t >= 720 * 2 and (t < 720 * 3 - 30):
				if t % GRASS_RATE[difficulty] == 0:
					lr *= -1
					var density = GRASS_DENSITY[difficulty]
					DefSys.sfx.play("shoot1")
					var bs_1 = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 48.0, 3.0, randf()*TAU, density, 0.0, green_heart, true)
					var bs_2 = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 48.0, 3.0, randf()*TAU, density, 0.0, green_heart, true)
					Bullets.set_properties_bulk(bs_1, {"wvel": 0.005 * lr})
					Bullets.set_properties_bulk(bs_2, {"wvel": -0.005 * lr})
			
			elif t >= 720*3 + 120:
				phase = 1
				max_health = parent.health
	
		else:
			# Normal
			if health < max_health * 2.0 / 8.0 or t >= 10800: 
				if phase == 4:
					phase = 5
					a_0 = 60.0
					
				a_0 -= 1
				
				if a_0 <= 0:
					DefSys.sfx.play("shoot1")
					var prog = 1.0 - health / (max_health * 2.0 / 8.0)
					if t >= 10800:
						prog = 1.0
				#	prog = 1.0
					a_0 = 60 - prog * 50
					var density = int(NORMAL_DENSITY_START[difficulty] + NORMAL_DENSITY_CHANGE[difficulty] * prog)
					
					Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 32.0, 2.0, randf()*TAU, density, 0.0, white_ball, true)
			# Electric
			elif health > max_health * 7.0 / 8.0:
				var speed := 14.0
				var density = ELEC_DENSITY[difficulty]
				var wave_time = ELEC_TIME[difficulty]
				var decel = speed / wave_time
				var jolt := 1.5
				
				if t % 4 == 0:
					if t % 120 == 0:
						a_0 = randf()*TAU
						lr *= -1
					if t % 120 < 90:
						DefSys.sfx.play("shoot1")
						var bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 32.0, speed, a_0, density, 0.0, yellow_arrow, true)
						Bullets.set_bullet_properties_bulk(bs, {"accel": -decel, "max_speed": 0.0})
						Bullets.add_translate_bulk(bs, Constants.TRIGGER.TIME, 1, {"angle": -lr*0.3})
						for i in 5:
							Bullets.add_transform_bulk(bs, Constants.TRIGGER.TIME, int(wave_time + (i * wave_time * 2)), {"speed": speed})
							Bullets.add_translate_bulk(bs, Constants.TRIGGER.TIME, int(wave_time + (i * wave_time * 2)), {"angle": lr * jolt})
							
							Bullets.add_transform_bulk(bs, Constants.TRIGGER.TIME, int(wave_time * 2 + (i * wave_time * 2)), {"speed": speed})
							Bullets.add_translate_bulk(bs, Constants.TRIGGER.TIME, int(wave_time * 2 + (i * wave_time * 2)), {"angle": -lr * jolt})
						a_0 += 0.01 * lr
			# Ice
			elif health > max_health * 6.0 / 8.0:
				if t % 120 == 0:
					set_boss_dest(Vector2(root.get_player_position().x + rand_range(-50, 50), rand_range(200, 300)), 60)
				if t % ICE_RATE[difficulty] == 0:
					DefSys.sfx.play("warning1")
					var x := rand_range(-50.0, 1050.0)
					var a := PI * rand_range(0.45, 0.55)
					var shatter := 30 + randi()%10
					var large = Bullets.create_shot_a1(bullet_kit, Vector2(x, -25.0), 6.0, a, cyan_crystal, true)
					Bullets.add_transform(large, Constants.TRIGGER.TIME, shatter, {"position": Vector2(-1500, -1500)})
					for j in 3:
						var small = Bullets.create_shot_a1(bullet_kit, Vector2(x, -25.0), 6.0, a, cyan_crystal_small, true)
						Bullets.set_property(small, "scale", 0.1)
						Bullets.add_transform(small, Constants.TRIGGER.TIME, shatter, {"scale": 48.0})
						Bullets.add_translate(small, Constants.TRIGGER.TIME, shatter - 1, {"angle": rand_range(-0.2, 0.2), "speed": rand_range(-1, 1)})
			# Psychic
			elif health > max_health * 5.0 / 8.0:
				if t % 120 == 0:
					set_boss_dest(Vector2(root.get_player_position().x + rand_range(-50, 50), rand_range(200, 300)), 60)
				var density = PSY_DENSITY[difficulty]
				var overshoot = 20
				
				if t % 120 == 0:
					a_0 = randf()*1000.0 / density
				if t % 120 == 60:
					a_1 = randf()*1000.0 / density
				
				
				if t % 4 == 0:
					DefSys.sfx.play("shoot1")
					var spin := 0.05
					var freq := 20
					
					var a = root.get_player_position().angle_to_point(position)
					a = PI * 0.5
					
					if t % 120 < 60 + overshoot:
						for x in density + 1:
							var p1 := Vector2(a_0 + x * 1000.0 / density, -20.0)
							
							
							var l = Bullets.create_shot_a1(bullet_kit_add, p1, 5.0, a - (freq * spin), purple_fireball, true)
							Bullets.set_property(l, "wvel", spin)
							
							var lr_local := -1.0
							for i in 20:
								Bullets.add_transform(l, Constants.TRIGGER.TIME, 2 * freq * (i + 1), {"wvel": spin * lr_local})
								
								lr_local *= -1.0
								
					if t % 120 < overshoot or (t % 120 >= 60 and t % 120 < 120 + overshoot):
						for x in density + 1:
							var p2 := Vector2(-a_1 + x * 1000.0 / density, -20.0)
							
							
							var r = Bullets.create_shot_a1(bullet_kit_add, p2, 5.0, a + (freq * spin), purple_fireball, true)
							Bullets.set_property(r, "wvel", -spin)
							
							var lr_local := -1.0
							for i in 20:
								Bullets.add_transform(r, Constants.TRIGGER.TIME, 2 * freq * (i + 1), {"wvel": -spin * lr_local})
								
								lr_local *= -1.0
							
					a_0 += 3
					a_1 += 3
					if a_0 > 1000.0 / density:
						a_0 -= 1000.0 / density
						a_1 -= 1000.0 / density
			# Dark
			elif health > max_health * 4.0 / 8.0:
				if phase == 1:
					phase = 2
					set_boss_dest(Vector2(500, 325), 60)
					a_0 = 90
				a_0 -= 1
				if a_0 <= 0:
					DefSys.sfx.play("shoot1")
					for i in DARK_RATE[difficulty]:
						var s = rand_range(3.0, 5.0)
						var a = randf()*TAU
						Bullets.create_shot_a1(bullet_kit_add, position, s, a, blue_orb, true)
						var bs = Bullets.create_shot_a1(bullet_kit, position, s, a, blue_orb_d, true)
					#	Bullets.set_properties_bulk(bs, {"scale": 72})
						Bullets.set_bullet_property(bs, "scale", 80)
			# Dragon
			elif health > max_health * 3.0 / 8.0:
				if phase == 2:
					phase = 3
					a_0 = 0
				DefSys.sfx.play("shoot1")
				#for i in 2:
				#	Bullets.create_shot_a1(bullet_kit_add, position, rand_range(1.0, 6.0), a_0 + i * TAU / 3.0, orbs[randi()%7], true)
				if t % DRAGON_RATE[difficulty] == 0:
					Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 64.0, rand_range(1.0, 6.0), a_0, DRAGON_DENSITY[difficulty], 0.0, orbs[randi()%7], true)
				
				a_0 += 0.03
			# Fairy
			elif health > max_health * 2.0 / 8.0:
				var density = FAIRY_DENSITY[difficulty]
				if phase == 3:
					phase = 4
					a_0 = 0
				if t % 3 == 0:
					DefSys.sfx.play("warning1")
					if t % 45 < 30:
						#var a = a_0  + i * TAU / 2
					#	Bullets.create_shot_a1(bullet_kit_add, position, rand_range(1.0, 6.0), a_0 + i * TAU / 3.0, orbs[randi()%7], true)
						var bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, -250.0, 4.0, a_0, density, 0.0, pink_star, true)
						Bullets.set_bullet_properties_bulk(bs, {"spin": 0.05})
				if t % 6 == 0:
					if t % 60 >= 30:
						var bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 32.0, 2.0, -a_1, density, 0.0, pink_star_large, true)
						Bullets.set_bullet_properties_bulk(bs, {"spin": -0.05})
					#lr *= -1
					
				a_0 += 0.004
				a_1 += 0.0065
				
