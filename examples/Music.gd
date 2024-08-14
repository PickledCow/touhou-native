extends Node

func play_music(phase, start=0.0):
	match phase:
		1:
			$outside_music.play(start)
		2:
			$cave_music.play(start)
		3:
			$midboss_music.play(start)
		4:
			$preboss_music.play(start)
		5:
			$boss_music_1.play(start)
		6:
			$boss_music_2.play(start)

func set_speed(scale):
	for node in get_children():
		node.pitch_scale = scale
