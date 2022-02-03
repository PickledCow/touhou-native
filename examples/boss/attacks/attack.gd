extends Node2D

var galacta_position : Vector2
var remilia_position : Vector2

export(DefSys.ATTACK_TYPE) var attack_type = DefSys.ATTACK_TYPE.NON
export var attack_name = ""
export var attack_time = 60 * 30

export var galacta_start_pos = Vector2(500, 300)
export var remilia_start_pos = Vector2(500, 300)
export var health = 7500
export var start_delay = 120

export var timeout = false
export var no_bg = false

export var scb = 1000000

export var bg_flag = 0

var t_raw = 0

var difficulty = 0
var root: Node2D
var parent: Node2D


func attack_init():
	pass

func _ready():
	parent = get_parent()
	attack_init()

func attack(u):
	pass

func _process(delta):
	galacta_position = parent.galacta.position
	remilia_position = parent.remilia.position
	
	var t = t_raw - start_delay
	attack(t)
	
	t_raw += 1

func set_galacta_dest(dest: Vector2, frame: float):
	parent.galacta_start_position = galacta_position
	parent.galacta_target_position = dest
	parent.galacta_travel_time = frame
	parent.galacta_travel_timer = 0.0
	
func set_remilia_dest(dest: Vector2, frame: float):
	parent.remilia_start_position = remilia_position
	parent.remilia_target_position = dest
	parent.remilia_travel_time = frame
	parent.remilia_travel_timer = 0.0
