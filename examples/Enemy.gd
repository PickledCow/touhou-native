extends Sprite

export(Resource) var bullet_kit

var t = 0
var c = 0

var density = 30

func _physics_process(delta):
	if t % 1 == 0:
		var o = t*t*0.0005
		for i in density:
			var angle = o + i * TAU / density + PI * 0.5
			#var bullet = Bullets.create_shot_a1(bullet_kit, position, 500, angle, Color(64 * 3, 64 * 4, 64, 1), 32.0)
			var speed = rand_range(300.0, 500.0)
			var bullet = Bullets.create_shot_a2(bullet_kit, position, speed, angle, -speed * 1.0, 100.0, Color(64 * 3, 64 * 4, 64, 1), 32.0)
			Bullets.set_bullet_property(bullet, "hitbox_scale", 0.1)
		c = (c + 1) % 14
	t += 1
	
	if Input.is_action_just_pressed("lessbullet"):
		density = max(density - 5, 5)
	if Input.is_action_just_pressed("morebullet"):
		density = min(density + 5, 100)
