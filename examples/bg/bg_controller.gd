extends Spatial

onready var anim_player = $AnimationPlayer

func _ready():
	anim_player.play("0")


func _on_AnimationPlayer_animation_finished(anim_name):
	var next_animation = str(int(anim_name) + 1)
	if anim_player.has_animation(next_animation):
		anim_player.play(next_animation)
