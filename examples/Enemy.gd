extends Sprite

export(Resource) var bullet_kit

var t = 0
var c = 0

func _physics_process(delta):
	if t % 1 == 0:
		var o = t*t*0.0005
		for i in 60:
			var angle = randf()*TAU# o + i * TAU / 5.0 + PI * 0.5
			var bullet = Bullets.obtain_bullet(bullet_kit)
			var xform = Transform2D(0.0, Vector2(0.0, 0.0)).scaled(Vector2(1.0, 0.5) / 64.0).rotated(angle+PI*0.5)
			xform.origin = position
			Bullets.set_bullet_property(bullet, "transform", xform)
			Bullets.set_bullet_property(bullet, "velocity", Vector2(rand_range(100.0, 500.0), 0).rotated(angle))
			Bullets.set_bullet_property(bullet, "texture_region", Color(64 * 5, 64 * 3, 64, 1))
		c = (c + 1) % 14
	t += 1
