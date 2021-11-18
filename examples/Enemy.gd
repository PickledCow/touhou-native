extends Sprite

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var t = 0
var c = 0

var density = 10

func _physics_process(delta):
	if t % 5 == 0:
		var o = t*0.1#*t*0.0005
		for i in density:
			var angle = o + i * TAU / density + PI * 0.5
			var speed = rand_range(300.0, 300.0)
			var data = PoolRealArray()
			data.resize(9)
			data[0] = 64 * 18			# source x (integer) # (16+8*(c/4))
			data[1] = 64 * 0			# source y (integer) # (24+2*(c%4))
			data[2] = 128				# source width (integer)
			data[3] = 128				# source height (integer)
			data[4] = 64.0				# bullet size [0, inf)
			data[5] = 0.3				# hitbox size [0, 1)
			data[6] = 0.0				# hitbox offset y (integer)
			data[7] = 1					# anim frame (integer)
			data[8] = 4					# spin
			var bullet = Bullets.create_shot_a1(bullet_kit, position, speed, angle, data)
			#var bullet = Bullets.create_shot_a2(bullet_kit_add, position, speed, angle, -speed * 1.0, 100.0, data)
			Bullets.set_bullet_property(bullet, "wvel", 0.01)
		c = (c + 1) % 8
	t += 1
	
	
	if Input.is_action_just_pressed("lessbullet"):
		density = max(density-10, 10)
	if Input.is_action_just_pressed("morebullet"):
		density = min(density+10, 1000)
		
