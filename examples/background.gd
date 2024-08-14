extends Node2D

var bg : Node
var bg_phase = 0

func _ready():
	DefSys.background_controller = self
	change_scale(DefSys.bg_scale)
	if DefSys.is_3d:
		bg = get_node("BG/Viewport/3dbg")
		get_node("BG/Viewport/2dbg").queue_free()
	else:
		bg = get_node("BG/Viewport/2dbg")
		get_node("BG/Viewport/3dbg").queue_free()
	#bg = DefSys.background_node.instance()
	#$BG/Viewport.add_child(bg)
	#$BG/Viewport.move_child(bg, 0)

func change_scale(sc: int):
	var s = sc if DefSys.is_3d else 100
	$BG.rect_size = Vector2(1064.0, 1064.0) * (s * 0.01)
	$BG.rect_scale = Vector2(1.0, 1.0) / (s * 0.01)
	$BG/Viewport.size = Vector2(1064.0, 1064.0) * (s * 0.01)
	#$BG/Viewport/over.rect_scale = Vector2(1.0, 1.0) * (s * 0.01)
	#$BG/Viewport/spriteover.scale = Vector2(1.0, 1.0) * (s * 0.01)

func _process(_delta):
	#if Input.is_action_just_pressed("debug2"):
	#	$ViewportContainer/Viewport/huerotate/AnimationPlayer.play("spell")
	#elif Input.is_action_just_pressed("debug3"):
	#	$ViewportContainer/Viewport/huerotate/AnimationPlayer.play_backwards("spell")
	pass
	
func flash():
	$AnimationPlayer.play("flash")

func suck():
	$AnimationPlayer.play("suck")
	
func leave():
	$AnimationPlayer.play("leave")

func fade():
	$AnimationPlayer.play("fade")

func spell(is_spell := true):
	if !$AnimationPlayer.is_playing():
		if is_spell:
			if bg_phase == 1:
				$AnimationPlayer.play("spell")
			elif bg_phase == 2:
				$AnimationPlayer.play("spell2")
		else:
			if is_spell:
				if bg_phase == 1:
					$AnimationPlayer.play_backwards("spell")
				elif bg_phase == 2:
					$AnimationPlayer.play_backwards("spell2")
			
func play_bg(id: int, t_start=0.0):
	if id >= 0:
		bg_phase = id
		bg.play_anim(id, t_start)
		


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade":
		get_tree().change_scene("res://examples/mainmenu.tscn")
