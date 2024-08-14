extends Node2D

func _ready():
	$AnimationPlayer.play("0")

func play_anim(id: int, t=0):
	#phase = id
	$AnimationPlayer.play(str(id))
