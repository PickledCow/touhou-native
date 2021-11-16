extends Label


onready var format_string = text


func _process(_delta):
	if is_instance_valid(Bullets):
		text = format_string.format([str(Engine.get_frames_per_second())])
	else:
		text = format_string.format([0])
