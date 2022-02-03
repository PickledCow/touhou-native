extends ColorRect
class_name Warp

onready var AnimPlayer := $AnimationPlayer

func _ready():
	DefSys.warp_effect = self
	material.set_shader_param("size", 0.0)


func warp(position : Vector2, is_player : bool):
	material.set_shader_param("centre", position / DefSys.playfield_size)
	if is_player:
		AnimPlayer.play("player")
