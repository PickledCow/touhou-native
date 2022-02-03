extends Control

func _ready():
	set_as_toplevel(true)
	get_tree().get_root().connect("size_changed", self, "reposition")
	reposition()

func reposition():
	var x_factor := (max(1.0, OS.window_size.x / OS.window_size.y * 9.0 / 16.0))
	var y_factor := (max(1.0, OS.window_size.y / OS.window_size.x * 16.0 / 9.0))
	rect_position = Vector2((1920.0 * x_factor - 1000.0)*0.75+1000.0, 540.0 * y_factor)
