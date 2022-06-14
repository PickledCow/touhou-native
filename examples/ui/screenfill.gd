extends Sprite

func _ready():
	visible = !DefSys.transluscent
	get_tree().get_root().connect("size_changed", self, "resize")
	resize()

func resize():
	var ratio = get_viewport_rect().size.y / get_viewport_rect().size.x * (16.0 / 9.0)
	scale = Vector2(1.2, 1.2) * max(1.0, max(ratio, 1.0 / ratio))
	position.y = 0.5 * 1080 * max(1.0, ratio)
	position.x = 0.5 * 1920 * max(1.0, 1.0/ratio)
