extends Control

export var player_path : NodePath
onready var player = get_node(player_path)

onready var healthbar = $healthbar
onready var healthbar_percent = $healthbar/percent
onready var face = $face
onready var face_low = $facelow
onready var face_hurt = $facehurt

onready var face_animation = $faceanimator

var health := 6

var t := 0.0

func _ready():
	update_healthbar(health)

func _process(delta):
	health = player.lives
	healthbar.value = 0.9 + health
	t += delta
	var dk = 1.0 + 0.2 * (sin(t*16) * 0.5 - 0.5)
	face_low.modulate = Color(1.0, 1.0, 1.0, 1.0/dk) * dk
	face_hurt.modulate = Color(1.0, 1.0, 1.0, 1.0/dk) * (dk if health <= 2 else 1.0)
	

func _on_Player_hit(hp):
	if hp > 2:
		face_animation.play("hurt")
	elif hp == 2:
		face_animation.play("hurt_into_low")
	elif hp >= 0:
		face_animation.play("hurt_low")
	else:
		face_animation.play("hurt_dead")


func _on_healthbar_value_changed(value):
	update_healthbar(value)

func update_healthbar(value):
	healthbar.material.set_shader_param("progress", value / healthbar.max_value)
	# 4 px at min, 450 at 6
	healthbar_percent.rect_position.x = 4 + health * 76
	healthbar_percent.text = str(health) + "/6"
	healthbar_percent.visible = health >= 0
	
