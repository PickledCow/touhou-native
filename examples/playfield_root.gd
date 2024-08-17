extends Node2D
class_name Root


var screen_shake_timer := 0.0
var screen_shake_duration := 1.0
var screen_shake_intensity := 0.0

var origin := Vector2()

var music_started := false
var music_start_frames := 1

onready var level_signs = get_node("../../UI/LevelSigns")

func show_sign(location):
	level_signs.display_sign(location)


# -1: Disabled
# 0: Intro, 1: Outside, 2: Mt Coronet, 3: Lake Spirits
# 4: Peak, 5: Dialogue, 6: Boss, 7: Surprise, 8: Arceus
var debug_section = 6


func _ready():
	DefSys.playfield_root = self
	DefSys.playfield = $playfield
	origin = position
	
	$playfield/BulletsEnvironment.set_speed_scale(1.0)
	Engine.time_scale = 1.0
	$playfield/Music.set_speed(1.0)
	
	if debug_section == -1:
		pass
	else:
		call_deferred("start_section", debug_section)
	#	start_section(debug_section)
	
	#call_deferred("after_ready", 15)

func start_section(section):
	match section:
		1:
			$playfield/Outside.start()
		2:
			#get_node("playfield/Music").play_music(2)
			#get_node("background").play_bg(2)
			$playfield/Cave.start()
		3:
			$playfield/Midboss.start()
		4:
			get_node("playfield/Music").play_music(4)
			get_node("background").play_bg(4)
			get_node("playfield/Boss/Dialogue").dialogue_started = true
			#$playfield/Midboss.start()
		5:
			get_node("playfield/Music").play_music(5)
			get_node("background").play_bg(5)
			$playfield/Boss.enable()
		6:
			get_node("playfield/Music").play_music(6)
			get_node("background").play_bg(5)
			$playfield/Boss.enable()

func after_ready(frames: int):
	if frames == 0:
		pass
		#$playfield/music.play()
		#$playfield/boss_music_1.play()
	else:
		call_deferred("after_ready", frames - 1)


func get_player_position() -> Vector2:
	return $playfield/Player.position

func shake_screen(duration: float, strength: float):
	screen_shake_timer = duration / Engine.iterations_per_second
	screen_shake_intensity = strength + screen_shake_intensity * screen_shake_timer / max(1.0, screen_shake_duration)
	screen_shake_duration = screen_shake_timer


var time_scale := 1.0
var scale_rate_low := 2.0
var scale_rate_high := 16.0

var target_slowdown := 1.0
var music_slowdown := 1.0


func cheat_slowdown(delta):
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


func slowdown(s: float):
	$playfield/BulletsEnvironment.set_speed_scale(s)
	Engine.time_scale = s
	target_slowdown = s
	#$playfield/Music.set_speed(time_scale)




func _process(delta):
	cheat_slowdown(delta)
	
	var scale_modified := false
	if music_slowdown > target_slowdown:
		music_slowdown -= delta * scale_rate_low
		if music_slowdown < target_slowdown: music_slowdown = target_slowdown
		$playfield/Music.set_speed(music_slowdown)
	elif music_slowdown < target_slowdown:
		music_slowdown += delta * scale_rate_low
		if music_slowdown > target_slowdown: music_slowdown = target_slowdown
		$playfield/Music.set_speed(music_slowdown)
	
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
	
	debug_input()
	#print(DefSys.difficulty)

func debug_input():
	for i in 5:
		if Input.is_action_just_pressed("debug" + str(i + 1)):
			DefSys.difficulty = i

