extends "res://examples/enemy/Enemy.gd"

var ball : PoolRealArray
var snowball : PoolRealArray

var started := false

var SPEED = [3.5, 4.0, 5.0, 5.25, 6.0]
var DENSITY = [6, 8, 10, 11, 14]
var RATE = [60, 45, 36, 30, 24]


func custom_ready():
	t_int = -1000
	t_raw = -1000
	
func custom_action(t):
	if started and t % RATE[difficulty] == 0:
		#DefSys.sfx.play("shoot1")
		var ang = randf()*TAU
		var speed = SPEED[difficulty]
		var density = DENSITY[difficulty]
		
		for j in density:
			var a = ang + j / float(density) * TAU
			Bullets.create_shot_a1(bullet_kit, position, speed, a, ball, true)
			Bullets.create_shot_a1(bullet_kit, position, speed, a + 0.1, snowball, true)
			Bullets.create_shot_a1(bullet_kit, position, speed * 0.925, a, ball, true)
			Bullets.create_shot_a1(bullet_kit, position, speed * 0.925, a + 0.1, snowball, true)
		
	if t >= 906:
		queue_free()
