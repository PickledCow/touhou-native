extends "res://examples/enemy/Enemy.gd"

var ay := 0.05

var firerate = [20, 16, 12, 10, 6]
var speed = [6.0, 7.0, 8.0, 10.0, 13.0]

var cyan_arrow : PoolRealArray
var white_arrow : PoolRealArray

const DEVIATION := 0.5#0.25

var y_stop = [600.0, 650.0, 700.0, 900.0, 1000.0]

var cs

func custom_ready():
	cyan_arrow = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROWHEAD, DefSys.COLORS.CYAN)
	cyan_arrow[4] *= 1.5
	white_arrow = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROWHEAD, DefSys.COLORS.WHITE)
	white_arrow[4] *= 1.5

func custom_action(t):
	if position.y < y_stop[difficulty]:
		if t % firerate[difficulty] == 0:
			DefSys.sfx.play("shoot1")
			var s = speed[difficulty]
			var ang := root.get_player_position().angle_to_point(position)
			var acc := 0.1
			var ms := 20.0
		#	Bullets.create_shot_a2(bullet_kit, position, s, ang, acc, ms, cyan_arrow, true)
			
			Bullets.create_shot_a2(bullet_kit, position, s, ang + DEVIATION, acc, ms, white_arrow, true)
			Bullets.create_shot_a2(bullet_kit, position, s, ang - DEVIATION, acc, ms, white_arrow, true)
			Bullets.create_shot_a2(bullet_kit, position, s, ang + 2 * DEVIATION, acc, ms, cyan_arrow, true)
			Bullets.create_shot_a2(bullet_kit, position, s, ang - 2 *  DEVIATION, acc, ms, cyan_arrow, true)
		
			Bullets.create_shot_a2(bullet_kit, position, s, ang, acc, ms, cyan_arrow, true)
	
	if position.y < -500 or position.y > 1500:
		queue_free()
	
	#DefSys.difficulty
