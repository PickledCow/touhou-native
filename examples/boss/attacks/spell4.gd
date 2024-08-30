extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := 0.0


var small_gear : PoolRealArray
var large_gear : PoolRealArray
var knife : PoolRealArray

var OFFSET := 120.0

var DENSITY = [8, 10, 12, 16, 18]
var DENSITY2 = [16, 20, 24, 32, 16]

var RATE = [210, 180, 150, 140, 132]
var RATE2 = [72, 60, 50, 45, 36]
var RATE3 = [5, 4, 3, 2, 2]
var RATE4 = [420, 360, 300, 280, 240]
var DURATION = [150, 150, 120, 120, 150]

var SPEED = [8.0, 10.0, 11.0, 12.0, 18.0]

var blue_ball : PoolRealArray
var blue_orb : PoolRealArray

func attack_init():
	small_gear = DefSys.get_bullet_data(DefSys.BULLET_TYPE.GEAR_SMALL, 0)
	large_gear = DefSys.get_bullet_data(DefSys.BULLET_TYPE.GEAR, 0)
	knife = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.GREY)
	blue_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.BLUE)
	blue_orb = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DIVINE_SPIRIT, DefSys.COLORS_DIVINE_SPIRIT.BLUE)

func attack(t: int):
	if t >= 0:
		var os = TAU / DENSITY[difficulty]
		if t % RATE[difficulty] == 0 and false:
			DefSys.sfx.play("shoot1")
			var bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 64.0, 2.0, PI*0.5, DENSITY[difficulty], 0.0, large_gear, true)
			
			Bullets.set_properties_bulk(bs, {"scale": 192.0, "bounce_surfaces": Constants.WALLS.DOME, "bounce_count": 0})
			
			var lr := 1.0
			for i in DENSITY[difficulty]:
				var bullet = bs[i]
				Bullets.set_bullet_property(bullet, "spin", 0.02*lr)
				lr *= -1.0
			
		if t % RATE[difficulty] == RATE[difficulty]/2 and false:
			DefSys.sfx.play("shoot1")
			var bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 64.0, 2.0, PI*0.5 + os * 0.5, DENSITY[difficulty], 0.0, large_gear, true)
	
			Bullets.set_properties_bulk(bs, {"scale": 192.0, "bounce_surfaces": Constants.WALLS.DOME, "bounce_count": 0})
			var lr := 1.0
			for i in DENSITY[difficulty]:
				var bullet = bs[i]
				Bullets.set_bullet_property(bullet, "spin", 0.02*lr)
				lr *= -1.0
		
		
		if t % RATE2[difficulty] == 0:# and t >= RATE[difficulty]:
			DefSys.sfx.play("shoot1")
			var bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 64.0, 4.0, randf()*TAU, DENSITY2[difficulty], 0.0, small_gear, true)
	
			Bullets.set_properties_bulk(bs, {"scale": 96.0, "bounce_surfaces": Constants.WALLS.DOME, "bounce_count": 1})
			
			var lr := 1.0
			for i in DENSITY2[difficulty]:
				var bullet = bs[i]
				Bullets.set_bullet_property(bullet, "spin", 0.06*lr)
				lr *= -1.0
		
		if t % RATE3[difficulty] == 0 and t >= RATE4[difficulty] and t % RATE4[difficulty] < 120:
			DefSys.sfx.play("warning1")
			var p := position + Vector2(randf()*128.0, 0.0).rotated(randf()*TAU)
			var a := root.get_player_position().angle_to_point(p)
			var b = Bullets.create_shot_a2(bullet_kit, p, 2.0, a, 0.5, SPEED[difficulty], knife, true)
			
			Bullets.set_properties(b, {"scale": 164.0, "layer": DefSys.LAYERS.SMALL_BULLETS})
			
		if t % RATE4[difficulty] == DURATION[difficulty]:
			var x := rand_range(450, 550)
			var y := rand_range(250, 325)
			set_boss_dest(Vector2(x, y), 60)
			
		if position.distance_squared_to(root.get_player_position()) < 100*100:
			if t % 10 == 0:
				DefSys.sfx.play("shoot1")
				Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 0.0, 10, randf()*TAU, 128, 0.0, blue_orb, true)
		
