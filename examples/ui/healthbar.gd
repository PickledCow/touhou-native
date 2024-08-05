extends Control

export var player_path : NodePath
onready var player = get_node(player_path)

onready var healthbar := $HP/healthbar
onready var healthbar_percent := $HP/percent
onready var player_name := $Lv/name

const MAX_HP_COLOR = "73ffad"
const LOW_HP_COLOR = "ffbf00"
const CRITICAL_HP_COLOR = "f25130"

var health := 10

var t := 0.0

func _ready():
	update_healthbar(health)
	DefSys.health_bar = self

func _process(delta):
	health = player.lives
	healthbar.value = health
	t += delta

func _on_healthbar_value_changed(value):
	update_healthbar(value)

func update_healthbar(_value):
	#healthbar.material.set_shader_param("progress", value / healthbar.max_value)
	# 4 px at min, 450 at 6
	#healthbar_percent.rect_position.x = 4 + health * 76
	healthbar.modulate = MAX_HP_COLOR if health >= 6 else LOW_HP_COLOR if health >= 3 else CRITICAL_HP_COLOR
	healthbar_percent.text = str(health) + "/10"
	healthbar_percent.visible = health >= 0
	
func set_name(name: String):
	player_name.text = name
