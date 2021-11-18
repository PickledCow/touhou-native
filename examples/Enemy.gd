extends Sprite

export(Resource) var bullet_kit

var t = 0
var c = 0

var density = 8

func _physics_process(delta):
	if t % 5 == 0:
		var o = t*0.01#*t*0.0005
		for i in density:
			var angle = o + i * TAU / density + PI * 0.5
			#var bullet = Bullets.create_shot_a1(bullet_kit, position, 500, angle, Color(64 * 3, 64 * 4, 64, 1), 32.0)
			var speed = rand_range(300.0, 500.0)
			var data = PoolRealArray()
			data.resize(8)
			data[0] = 64 * (16+8*(c/4))	# source x (integer)
			data[1] = 64 * (24+2*(c%4))	# source y (integer)
			data[2] = 128				# source width (integer)
			data[3] = 128				# source height (integer)
			data[4] = 64.0				# bullet size [0, inf)
			data[5] = 0.3				# hitbox size [0, 1)
			data[6] = 0.0				# hitbox offset y (integer)
			data[7] = 4					# anim frame (integer)
			var bullet = Bullets.create_shot_a2(bullet_kit, position, speed, angle, -speed * 1.0, 100.0, data)
		c = (c + 1) % 8
	t += 1
	
