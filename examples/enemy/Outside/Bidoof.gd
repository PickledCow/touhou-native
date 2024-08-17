extends "res://examples/enemy/Enemy.gd"

var ay := 0.05

var firerate = [200, 150, 120, 100, 60]
var speed = [4.0, 4.25, 4.5, 5.0, 7.0]
var shots = 0.0

var density = [12, 18, 24, 30, 36]

var spread = [4, 5, 5, 5, 6]

var blue_fireball : PoolRealArray
const DEVIATION := 0.5#0.25

var y_stop = [500.0, 550.0, 600.0, 700.0, 800.0]

var lr := 1.0
var spin := 0.012


var cs

func custom_ready():
	blue_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.BLUE)
	#blue_fireball[4] *= 1.5
	

func custom_action(t):
	if position.y < y_stop[difficulty] and t >= 0:
		if t % firerate[difficulty] == 50:
			var angle = randf()*TAU
			DefSys.sfx.play("shoot1")
			for i in spread[difficulty]:
				var a = angle + i * spin * lr
				var s = speed[difficulty] - i*0.15
				Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, position, 0, s, a, density[difficulty], 0.0, blue_fireball, true)
			#Bullets.create_shot_a2(bullet_kit, position, s, ang, acc, ms, blue_fireball, true)
	
	if position.y < -500 or position.y > 1500:
		queue_free()
	
	#DefSys.difficulty
