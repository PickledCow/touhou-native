extends Node2D
class_name Attack


var boss_position : Vector2

export(DefSys.ATTACK_TYPE) var attack_type = DefSys.ATTACK_TYPE.NON
export var attack_name = ""
export var attack_time = 60 * 30

export var start_pos = Vector2(500, 300)
export var health = 7500
export var start_delay = 120

export var timeout = false
export var no_bg = false

export var scb = 1000000

export var bg_flag = -1

var t_raw = 0.0
var t_int = 0

var difficulty = 0
var root: Root
var parent: Node2D


func attack_init():
	pass

func _ready():
	parent = get_parent()
	root = parent.root
	attack_init()

# warning-ignore:unused_argument
func attack(u):
	pass

func custom_physics_process(delta: float):
	pass
	

func _physics_process(delta):
	position = parent.boss_position
	
#	if t == 0:
#		parent.invincible = false	
	while int(t_raw) > t_int:
		t_int += 1
		attack(t_int - start_delay)
	
	t_raw += 1 * delta * 60.0
	
	custom_physics_process(delta)
