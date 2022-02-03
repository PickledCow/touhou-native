extends Node2D

func _ready():
	DefSys.background_controller = self

func _process(_delta):
	#if Input.is_action_just_pressed("debug2"):
	#	$ViewportContainer/Viewport/huerotate/AnimationPlayer.play("spell")
	#elif Input.is_action_just_pressed("debug3"):
	#	$ViewportContainer/Viewport/huerotate/AnimationPlayer.play_backwards("spell")
	pass
	
func flash():
	$AnimationPlayer.play("flash")
