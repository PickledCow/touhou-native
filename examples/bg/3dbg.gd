extends Spatial

onready var anim_player = $AnimationPlayer
onready var geyser_anim_player = $lava/geiser/AnimationPlayer
onready var geyser = $lava/geiser

var phase := 0

var next_geyser_timer := 25.0

func _ready():
	#pass
	anim_player.play("0")

func _process(delta):
	if phase == 2:
		if next_geyser_timer > 0.0:
			next_geyser_timer -= delta
		if next_geyser_timer <= 0.0:
			next_geyser_timer = rand_range(18.0, 25.0)
			geyser_anim_player.play("spout")
			geyser.translation.x = rand_range(-250, 250)
			geyser.translation.z = rand_range(-1800, -1200)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name in [0]:
		var next_animation = str(int(anim_name) + 1)
		if anim_player.has_animation(next_animation):
			anim_player.play(next_animation)

func play_anim(id: int):
	phase = id
	$AnimationPlayer.play(str(id))
