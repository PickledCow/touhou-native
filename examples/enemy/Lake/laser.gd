extends Area2D

func interp(x: float, oneshot: bool) -> float:
	var u := min(x, 0.5 if oneshot else 1.0)
	return -(2.0 * u - 1.0) * (2.0 * u - 1.0)

func wave(t: float) -> float:
	var x := max(t, 0.0)
	return sin(FREQ[difficulty]*x)*max(0, min(min(0.5*x, 1), -0.5 * (x - 5)))

var start_position := Vector2(500.0, 0.0)
var direction := Vector2(0.0, 1.0)
var sway_time := 1.0
var sway_timer := 0.0
var oneshot := true

var peaked := false
var t := 0.0

var AMP = [175, 200, 220, 240, 260]
var FREQ = [2.75, 3.0, 3.25, 3.4, 3.6]

var difficulty := 0

func _ready():
	difficulty = DefSys.difficulty


func _physics_process(delta):
	if not peaked:
		position = start_position + 500.0 * interp(sway_timer / sway_time, !oneshot) * direction
	
		sway_timer += delta
	else:
		if t < 5.0:
			position = start_position + Vector2(0.0, wave(t) * AMP[difficulty])
		else:
			position = start_position + 500.0 * interp(0.5 + t - 5, false) * direction
		t += delta
	
	if oneshot and sway_timer > sway_time:
		queue_free()
	elif not oneshot and sway_timer > sway_time * 0.5:
		peaked = true
