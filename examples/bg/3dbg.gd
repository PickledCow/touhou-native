extends Spatial

onready var anim_player = $AnimationPlayer

var phase := 0

func _ready():
	pass
	#anim_player.play("1")

func _process(_delta):
	pass
	#print($AnimationPlayer.current_animation_position)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name in [0]:
		var next_animation = str(int(anim_name) + 1)
		if anim_player.has_animation(next_animation):
			anim_player.play(next_animation)

func play_anim(id: int):
	phase = id
	$AnimationPlayer.play(str(id))
