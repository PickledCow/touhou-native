extends Node2D

var screen_shake_timer := 0.0
var screen_shake_duration := 1.0
var screen_shake_intensity := 0.0

var origin := Vector2()

var music_started := false
var music_start_frames := 1

# -1: Disabled
# 0: Intro, 1: Outside, 2: Mt Coronet, 3: Lake Spirits
# 4: Peak, 5: Dialogue, 6: Boss, 7: Surprise, 8: Arceus
var debug_section = 1

func _ready():
	DefSys.playfield_root = self
	DefSys.playfield = $playfield
	origin = position
	
	if debug_section != -1:
		match debug_section:
			1:
				$playfield/Outside.start()
			3:
				$playfield/Midboss.start()
	
	
	#call_deferred("after_ready", 15)

func after_ready(frames: int):
	if frames == 0:
		pass
		#$playfield/music.play()
		#$playfield/boss_music_1.play()
	else:
		call_deferred("after_ready", frames - 1)


func get_player_position():
	return $playfield/Player.position

func shake_screen(duration: float, strength: float):
	screen_shake_timer = duration / Engine.iterations_per_second
	screen_shake_intensity = strength + screen_shake_intensity * screen_shake_timer / max(1.0, screen_shake_duration)
	screen_shake_duration = screen_shake_timer


var time_scale = 1.0
var scale_rate_low = 2.0
var scale_rate_high = 16.0

func slowdown(delta):
	var scale_modified = false
	if Input.is_action_pressed("debug_slow"):
		if time_scale > 0.5:
			scale_modified = true
			time_scale -= delta * scale_rate_low
			if time_scale < 0.5: time_scale = 0.5		
	elif Input.is_action_pressed("debug_fast"):
		if time_scale < 4.0:
			scale_modified = true
			time_scale += delta * scale_rate_high
			if time_scale > 4.0: time_scale = 4.0
	else:
		if time_scale < 1.0:
			scale_modified = true
			time_scale += delta * scale_rate_low
			if time_scale > 1.0: time_scale = 1.0
		if time_scale > 1.0:
			scale_modified = true
			time_scale -= delta * scale_rate_high
			if time_scale < 1.0: time_scale = 1.0
			
	if scale_modified:
		$playfield/BulletsEnvironment.set_speed_scale(time_scale)
		Engine.time_scale = time_scale
		$playfield/Music.set_speed(time_scale)


func _process(delta):
	slowdown(delta)
	if music_start_frames > delta:
		music_start_frames -= delta
	elif !music_started:
		pass
		#$playfield/Music/midboss_music.play()
		#music_started = true
		#$playfield/Music/boss_music_1.play()
	
	if screen_shake_timer > 0.0:
		screen_shake_timer -= delta
		if screen_shake_timer <= 0.0:
			position = origin
		else:
			position = origin + Vector2(screen_shake_intensity * randf(), 0.0).rotated(randf()*TAU)
