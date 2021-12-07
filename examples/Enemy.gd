extends Sprite

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var t = 0
var c = 0
var lr = 1

var density = 5

var first_bullet

func _physics_process(delta):
	if t % 2 == 0 && t > 0:
		lr *= -1
		var o = t*t*0.001#PI*0.5 + PI * 0.25 * sin(t*0.15)
		for i in density:
			var angle = o + i * TAU / density
			var speed = 8.0
			var data = PoolRealArray()
			data.resize(9)
			data[0] = 64 * 22			# source x (integer) # (16+8*(c/4))
			data[1] = 64 * 8			# source y (integer) # (24+2*(c%4))
			data[2] = 128				# source width (integer)
			data[3] = 128				# source height (integer)
			data[4] = 64.0				# bullet size [0, inf)
			data[5] = 0.5				# hitbox ratio [0, 1]
			data[6] = 0					# Sprite offset y (integer)
			data[7] = 1					# anim frame, 1 for no animation (integer)
			data[8] = 0					# spin
			var bullet = Bullets.create_shot_a1(bullet_kit, position, speed, angle, data, true)
			#Bullets.add_pattern(bullet, 0, 45.0, {"wvel": 0.1 * lr})
			#Bullets.add_pattern(bullet, 0, 60.0, {"wvel": 0.0})
			#Bullets.add_pattern(bullet, 0, 90.0, {"accel": -0.3, "max_speed": 2.0})
			#Bullets.add_pattern(bullet, 0, 60.0, {"angle": 0.0})
			#var bullet = Bullets.create_shot_a2(bullet_kit_add, position, speed, angle, -speed * 0.1, 100.0, data, true)
			#Bullets.set_bullet_property(bullet, "lifespan", 60.0)
			Bullets.add_translate(bullet, 0, 30, {"speed": 0.0})
			#print(Bullets.get_bullet_property(bullet, "lifetime"))
			if !first_bullet:
				first_bullet = bullet
		c = (c + 1) % 8
	#if t == 240:
	#	bullet_kit.time_scale = 0.334
	t += 1
	#print(Bullets.is_deleted(first_bullet))
	
	if Input.is_action_just_pressed("lessbullet"):
		density = max(density-10, 10)
	if Input.is_action_just_pressed("morebullet"):
		density = min(density+10, 1000)
		
