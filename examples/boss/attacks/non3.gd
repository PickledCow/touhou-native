extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add
export(Resource) var bullet_kit_sub

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1

var green_fireball : PoolRealArray
var purple_fireball : PoolRealArray
var green_orb : PoolRealArray
var purple_orb : PoolRealArray


func attack_init():
	green_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.GREEN)
	purple_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.PURPLE)
	green_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.GREEN)
	purple_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.PURPLE)

var RATE = [72,60,48,40,32]
var DENSITY = [20,24,28,32,36]
var SPEED = [3.0,3.5,3.75,4.0,4.5]
var SPIN = [0.0075, 0.00875, 0.009375, 0.01, 0.01125]

func attack(t):
	green_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.PURPLE_D)
	if t >= 0:
		if t % 240 == 0:
			a = randf()*TAU
			
		if t % RATE[difficulty] == 0:
			DefSys.sfx.play("shoot1")
			var a = randf()*TAU
			var bs = Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 48.0, SPEED[difficulty], a, DENSITY[difficulty], 0.0, purple_orb, true)
			Bullets.set_properties_bulk(bs, {"wvel": SPIN[difficulty]})
			bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 48.0, SPEED[difficulty], a, DENSITY[difficulty], 0.0, green_orb, true)
			Bullets.set_properties_bulk(bs, {"wvel": SPIN[difficulty], "scale": 72})
		
		if t % RATE[difficulty] == RATE[difficulty]/2:
			var a = randf()*TAU
			DefSys.sfx.play("shoot1")
			var bs = Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 48.0, SPEED[difficulty], a, DENSITY[difficulty], 0.0, purple_orb, true)
			Bullets.set_properties_bulk(bs, {"wvel": -SPIN[difficulty]})
			bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 48.0, SPEED[difficulty], a, DENSITY[difficulty], 0.0, green_orb, true)
			Bullets.set_properties_bulk(bs, {"wvel": -SPIN[difficulty], "scale": 72})
		
	#	if t % 60 == 15:
	#		var bs = Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 64.0, 5.0, randf()*TAU, 40, 0.0, purple_fireball, true)
		
					#Bullets.create_shot_a1(bullet_kit_sub, p, 8.0 - i * 0.25, PI * 0.5 - a, green_fireball, true)
			#var s = SPEED1[difficulty]
			#Bullets.create_pattern_a1(bullet_kit_sub, Constants.PATTERN.RING, position, 64.0, s, a, DENSITY[difficulty], 0.0, green_orb, true)
			a += 0.01
		
		if position.distance_squared_to(root.get_player_position()) < 100*100:
			if t % 10 == 0:
				DefSys.sfx.play("shoot1")
				Bullets.create_pattern_a1(bullet_kit_sub, Constants.PATTERN.RING, position, 0.0, 10, randf()*TAU, 128, 0.0, green_orb, true)
