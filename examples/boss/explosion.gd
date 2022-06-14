extends Particles2D

func _ready():
	emitting = true

var t = 0

func _process(delta):
	t += delta
	if t > 3:
		queue_free()
