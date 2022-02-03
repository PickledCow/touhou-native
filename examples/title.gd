extends TextureRect

var following := false
var drag_start_pos := Vector2()
var maximise_on_drop := false
var snap_margin := 0.0
var pre_maximise_size := Vector2(1280, 720+32)

func _ready():
	set_as_toplevel(true)
	get_tree().get_root().connect("size_changed", self, "resize")
	resize()

func resize():
	rect_size = Vector2(get_viewport_rect().size.x, 32)


func _on_title_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = !following
			drag_start_pos = get_local_mouse_position()

func _process(_delta):
	if following:
		#OS.window_maximized = false
		OS.window_size = pre_maximise_size
		OS.set_window_position(OS.window_position + get_global_mouse_position() - drag_start_pos)
		maximise_on_drop = OS.window_position.y <= snap_margin
	elif maximise_on_drop:
		maximise_on_drop = false
		#OS.window_maximized = true
		pre_maximise_size = OS.window_size
		OS.window_size = OS.max_window_size
		OS.window_position = Vector2(0,0)
