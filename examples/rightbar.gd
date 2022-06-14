extends Control

func _ready() -> void:
	set_as_toplevel(true)
	get_tree().get_root().connect("size_changed", self, "reposition")
	reposition()

func reposition() -> void:
	var x_factor := (max(1.0, OS.window_size.x / OS.window_size.y * 9.0 / 16.0))
	var y_factor := (max(1.0, OS.window_size.y / OS.window_size.x * 16.0 / 9.0))
	rect_position = Vector2((1920.0 * x_factor - 1000.0)*0.75+1000.0, 540.0 * y_factor)
	
	
func format_number(number : String) -> String:
	var i := number.length() - 3
	while i > 0:
		number = number.insert(i, ",")
		i = i - 3
	return number
func _process(_delta: float) -> void:
	$score/value.text = format_number(str(DefSys.score))
	$hiscore/value.text = format_number(str(max(1_000_000, DefSys.score)))
# warning-ignore:integer_division
	$piv/value.text = format_number(str(DefSys.piv + (DefSys.graze / 10) * 10))
	$graze/value.text = format_number(str(DefSys.graze))

