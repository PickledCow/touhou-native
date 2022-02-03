extends Node2D

var screen_shake_timer := 0.0
var screen_shake_duration := 1.0
var screen_shake_intensity := 0.0

var origin := Vector2()

func _ready():
	DefSys.playfield_root = self
	origin = position

func shake_screen(duration: float, strength: float):
	screen_shake_timer = duration / Engine.iterations_per_second
	screen_shake_intensity = strength + screen_shake_intensity * screen_shake_timer / max(1.0, screen_shake_duration)
	screen_shake_duration = screen_shake_timer

func _process(delta):
	if screen_shake_timer > 0.0:
		screen_shake_timer -= delta
		if screen_shake_timer <= 0.0:
			position = origin
		else:
			position = origin + Vector2(screen_shake_intensity * randf(), 0.0).rotated(randf()*TAU)
