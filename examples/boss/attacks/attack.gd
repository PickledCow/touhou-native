extends Node2D
class_name Attack


var galacta_position : Vector2
var remilia_position : Vector2

export(DefSys.ATTACK_TYPE) var attack_type = DefSys.ATTACK_TYPE.NON
export var attack_name = ""
export var attack_time = 60 * 30

export var start_pos = Vector2(500, 300)
export var health = 7500
export var start_delay = 120

export var timeout = false
export var no_bg = false

export var scb = 1000000

export var bg_flag = 0
export var bgm_flag = 0

var t_raw = 0

var root: Node2D
var parent: Node2D


func attack_init():
	pass
	
func attack_end():
	pass

func _ready():
	parent = get_parent()
	attack_init()

# warning-ignore:unused_argument
func attack(u):
	pass

func _physics_process(_delta):
	position = parent.position
	
	var t = t_raw - start_delay
#	if t == 0:
#		parent.invincible = false
	attack(t)
	
	t_raw += 1

func set_dest(dest: Vector2, frame: float):
	parent.start_position = position
	parent.target_position = dest
	parent.travel_time = frame
	parent.travel_timer = 0.0
