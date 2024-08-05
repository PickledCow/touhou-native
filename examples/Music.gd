extends Node

func play_music(phase):
	match phase:
		1:
			$outside_music.play()
		2:
			$cave_music.play()
		3:
			$midboss_music.play()
		4:
			$preboss_music.play()
		5:
			$boss_music_1.play()
		6:
			$boss_music_2.play()

func set_speed(scale):
	for node in get_children():
		node.pitch_scale = scale
