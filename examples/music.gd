extends AudioStreamPlayer

var trigger := false

func _process(delta):
	var p = get_playback_position()
	match DefSys.bgm_flag:
		0:
			if p >= 18.0:
				seek(p - 12.0)
		1:
			if p < 12.0:
				trigger = true
			if p >= 12.0 and trigger:
				seek(p + 6.0)
				trigger = false
				
			if p >= 45.0:
				seek(p - 12.0)
				
		2:
			if p < 39.0:
				trigger = true
			if p >= 39.0 and trigger:
				seek(p + 6.0)
				trigger = false
				
			if p >= 66.0:
				seek(p - 6.0)
				
		3:
			if p < 63.0:
				trigger = true
			if p >= 63.0 and trigger:
				seek(p + 3.0)
				trigger = false
				
				
