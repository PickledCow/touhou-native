extends Sprite

func _ready():
	get_tree().get_root().connect("size_changed", self, "resize")
	resize()

func resize():
	scale = get_viewport_rect().size + Vector2(16, 16)
