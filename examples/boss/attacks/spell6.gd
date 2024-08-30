extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add
export(Resource) var bullet_kit_sub

var a := PI*0.5
var a2 := 0.0


var an := 0.0

var green_fireball : PoolRealArray
var green_orb : PoolRealArray
var purple_orb : PoolRealArray
var blue_ball : PoolRealArray
var blue_mentos : PoolRealArray

var phase := 0

var max_health : float

var t_offset := 0

var DENSITY1 = [3, 4, 5, 6, 7]
var STAGGER = [1.5, 2.25, 2, 2, 2]

var DENSITY2 = [45, 60, 72, 85, 100]

var SPEED = [3.25, 3.75, 4.25, 5.0, 6.0]


var last_orientation := 0

var orientations = [3, 2, 1, 0]
var orientation_index := -1

var hide_location = [Vector2(500, -250), Vector2(500, 1250), Vector2(-250, 500) ,Vector2(1250, 500)]

var pop_up_location = [Vector2(500, 400), Vector2(500, 600), Vector2(400, 500), Vector2(600, 500)]
var burst_location = [Vector2(500, 0), Vector2(500, 1000), Vector2(0, 500), Vector2(1000, 500)]

var accel_line_location = [Vector2(0, -250), Vector2(0, 250), Vector2(-250, 0), Vector2(250, 0)]
var accel_line_rotation = [0.0, PI, -PI * 0.5, PI*0.5]

var aim = [PI * 0.5, -PI * 0.5, 0.0, PI]


func attack_init():
	green_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.GREEN)
	green_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.GREEN)
	purple_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.PURPLE)
	blue_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.BLUE)
	blue_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.BLUE)
	
	max_health = health

func attack(t: int):
	green_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.PURPLE)
	green_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.PURPLE_D)
	purple_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.PURPLE)
	if t >= 0:
		if t % 420 == 0:
			DefSys.sfx.play("charge2")
		
		if t % 420 == 60:
			set_boss_dest(pop_up_location[orientations[(orientation_index) % 4]], 120)
			DefSys.sfx.play("explode1")
			var ang := randf()*TAU 
			for i in 10:
				var bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, burst_location[orientations[(orientation_index) % 8]], 16.0, 8.0 - i * 0.25, ang, DENSITY2[difficulty], 0.0, green_orb, true)
				Bullets.set_properties_bulk(bs, {"scale": 72})
				Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, burst_location[orientations[(orientation_index) % 8]], 16.0, 8.0 - i * 0.25, ang, DENSITY2[difficulty], 0.0, purple_orb, true)
			a = aim[orientations[(orientation_index) % 8]]
			a2 = 0.0
			
			
		if t % 420 == 420 - 90 and t >= 420 - 90:
			set_boss_dest(hide_location[orientations[(orientation_index) % 4]], 120)
			
			orientation_index = (orientation_index + 1) % 4
		
		if t % 420 == 420 - 60 and t >= 420 - 60:
			root.rotate_player(orientations[orientation_index])
			DefSys.sfx.play("warning1")
			$dash.emitting = true

			
		if t % 420 == 58 and t >= 420:
			set_boss_dest(hide_location[orientations[orientation_index]], 1)
			
			
		
		if t % 420 >= 60 and t % 420 < 240:
			if t % 12 == 0:
				if t % 20 <= 20 or true:
					DefSys.sfx.play("shoot1")
					for i in 5:
						var bs = Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 64.0, 3.0 - i * 0.1, a + a2 - PI*1.25 + i*0.015, DENSITY1[difficulty], 0.0, green_fireball, true)
						Bullets.set_properties_bulk(bs, {"wvel": 0.0115})
						Bullets.add_transform_bulk(bs, Constants.TRIGGER.TIME, 120, {"wvel": 0.0})
						bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 64.0, 3.0 - i * 0.1, a + a2 - PI*1.25 + i*0.015, DENSITY1[difficulty], 0.0, green_orb, true)
						Bullets.set_properties_bulk(bs, {"wvel": 0.0115, "scale": 36})
						Bullets.add_transform_bulk(bs, Constants.TRIGGER.TIME, 120, {"wvel": 0.0})
						
						bs = Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 64.0, 3.0 - i * 0.1, a - a2 + PI*1.25 - i*0.015, DENSITY1[difficulty], 0.0, green_fireball, true)
						Bullets.set_properties_bulk(bs, {"wvel": -0.0115})
						Bullets.add_transform_bulk(bs, Constants.TRIGGER.TIME, 120, {"wvel": 0.0})
						bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 64.0, 3.0 - i * 0.1, a - a2 + PI*1.25 - i*0.015, DENSITY1[difficulty], 0.0, green_orb, true)
						Bullets.set_properties_bulk(bs, {"wvel": -0.0115, "scale": 36})
						Bullets.add_transform_bulk(bs, Constants.TRIGGER.TIME, 120, {"wvel": 0.0})
				
					#Bullets.create_pattern_a1(bullet_kit_sub, Constants.PATTERN.RING, position, 64.0, 3.0, a - a2, 1, 0.0, green_fireball, true)
				#	Bullets.create_pattern_a1(bullet_kit_sub, Constants.PATTERN.RING, position, 64.0, 3.0, a - a2, 9, 0.0, green_fireball, true)
			
			a2 += 0.015
		
	$dash.position = -position + accel_line_location[orientations[(orientation_index) % 4]] + Vector2(500, 500)
	$dash.rotation = accel_line_rotation[orientations[(orientation_index) % 4]] 
