extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := 0.0


var an := 0.0

var blue_fireball : PoolRealArray
var blue_ball : PoolRealArray
var blue_mentos : PoolRealArray

var phase := 0

var max_health : float

var t_offset := 0

var DENSITY1 = [3, 4, 5, 6, 7]
var STAGGER = [1.5, 2.25, 2, 2, 2]

var RATE = [180, 120, 105, 90, 72]
var SPEED = [3.25, 3.75, 4.25, 5.0, 6.0]

func attack_init():
	blue_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.BLUE)
	blue_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.BLUE)
	blue_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.BLUE)
	
	max_health = health

func attack(t: int):
	if t == 0:
		root.warp(1)
		a = PI + 0.4
	if t >= 0:
		if phase == 0:
			var t_end := 180
			if t <= t_end:
				if t % 2 == 0:
					var u := float(t) / t_end
					var p := 1.0 - (u - 1) * (u - 1) * 0.9
					
					var pos := Vector2(0.975, p) * 1000.0
					
					set_boss_dest(pos, 1)
					
					var ang := a - u * 1.2
					DefSys.sfx.play("shoot1")
					for i in 5:
						Bullets.create_shot_a1(bullet_kit_add, pos, 4.0 - i * 0.25, ang, blue_fireball, true)
			if t == t_end:
				set_boss_dest(Vector2(rand_range(350, 650), rand_range(275, 325)), 90)
					
			if t == t_end + 120:
				phase = 1
		
		elif phase == 1:
		#	if t % 60 == 0:
	#			a -= 50
			
			
			
			if t % 2 == 0:
				for i in range(-1, DENSITY1[difficulty] + 1):
					DefSys.sfx.play("shoot1")
					var pos := Vector2(fposmod((i * 1000.0 / DENSITY1[difficulty] + a), 1000.0), 0.0)
					Bullets.create_shot_a1(bullet_kit_add, pos, 6.0, PI*0.5, blue_fireball, true)
			
			if t % 40 < 15:
				if t % 2 == 0:
					for i in range(-1, DENSITY1[difficulty] + 1):
						DefSys.sfx.play("shoot1")
						var pos := Vector2(fposmod((i * 1000.0 / DENSITY1[difficulty] - 1.8*a), 1000.0), 0.0)
						Bullets.create_shot_a1(bullet_kit, pos, 4.0, PI*0.5, blue_ball, true)
					
			a += 3
				
			if t % 120 == 0:
				set_boss_dest(Vector2(rand_range(350, 650), rand_range(275, 325)), 90)
				
			if health < max_health * 0.6:
				#root.warp(2)
				phase = 2
				t_offset = t
		elif phase == 2:
			if t - t_offset == 120:
				root.warp(2)
				phase = 3
				t_offset = t + 1
		
		
		elif phase == 3:
			var u = t - t_offset
			if u % RATE[difficulty] == 0 or u % RATE[difficulty] == 15 or u % RATE[difficulty] == 30:
				DefSys.sfx.play("shoot1")
				Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 64.0, SPEED[difficulty], randf()*TAU, 180, 0.0, blue_fireball, true)
				
				
			if u % RATE[difficulty] == 30:
				#var pos := Vector2( 500 + rand_range(200, 350) * ((randi()%2) * 2 - 1), rand_range(400, 600))
				var pos := Vector2(500, 500) + Vector2(300,0).rotated(an)
				set_boss_dest(pos, RATE[difficulty] / 2)
				an += 137 * TAU/360.0
				
			
