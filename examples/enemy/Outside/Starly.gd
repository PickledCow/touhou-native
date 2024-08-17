extends "res://examples/enemy/Enemy.gd"

var ay := 0.05

var firerate = [12, 10, 7, 4, 3]
var speed_min = [5, 5.5, 6, 7, 7.5]
var speed_max = [7, 8, 10, 12, 12.5]

var grey_ball : PoolRealArray
var white_ball : PoolRealArray

var rand_amount := 0.175

var speed_factor := 1.0

var cs

func custom_ready():
	grey_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.GREY)
	white_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.WHITE)
	cs = [grey_ball, white_ball]

func custom_action(t):
#	position.x += lr * speed
#	position.y -= velocity.y
	velocity.y -= ay
	
	if t % firerate[difficulty] == 0 and position.y > 50 and position.x > 50.0 and position.x < 950.0:
		var p : Vector2 = root.get_player_position()
		var ad = rand_range(-rand_amount, rand_amount)
		var s = rand_range(speed_min[difficulty], speed_max[difficulty]) * speed_factor
		var a = ad + p.angle_to_point(position)
		DefSys.sfx.play("shoot1")
		
		var accel = s / 10.0
		var start_speed = s + 5.0
		
		var ra = randf()*TAU
		var d = 12
		var po1 = Vector2(d, 0).rotated(ra)
		var po2 = Vector2(d, 0).rotated(ra + TAU/3)
		var po3 = Vector2(d, 0).rotated(ra - TAU/3)
		
		var c = randi()%2
		var b = Bullets.create_shot_a1(bullet_kit, position+po1, start_speed, a, cs[c], true)
		Bullets.set_properties(b, {"accel": -accel, "max_speed": s})
		c = randi()%2
		b = Bullets.create_shot_a1(bullet_kit, position+po2, start_speed, a, cs[c], true)
		Bullets.set_properties(b, {"accel": -accel, "max_speed": s})
		c = randi()%2
		b = Bullets.create_shot_a1(bullet_kit, position+po3, start_speed, a, cs[c], true)
		Bullets.set_properties(b, {"accel": -accel, "max_speed": s})
	
	if position.y < -200:
		queue_free()
	
	#DefSys.difficulty
