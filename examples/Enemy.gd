extends Sprite

export(Resource) var bullet_kit

var t = 0
var c = 0

func _physics_process(delta):
	if t % 1 == 0:
		var o = t*t*0.0005
		for i in 6:
			var angle = randf()*TAU# o + i * TAU / 5.0 + PI * 0.5
			#var bullet = Bullets.create_shot_a1(bullet_kit, position.x, position.y, rand_range(300.0, 500.0), angle, Color(64 * 5, 64 * 3, 64, 1), 32.0)
			var speed = rand_range(300.0, 500.0)
			var bullet = Bullets.create_shot_a2(bullet_kit, position.x, position.y, speed, angle, -speed * 0.5, 100.0, Color(64 * c, 64 * 3, 64, 1), 32.0)
		c = (c + 1) % 14
	t += 1
