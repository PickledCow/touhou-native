extends Area2D


export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

export var max_health := 100
onready var health = max_health 


var velocity := Vector2()

var t_raw := 0.0
var t_int := 0

var bullets_to_remove = []

var difficulty = 0
var root: Node2D
var parent: Node2D

var tank_time = 0
var tank_factor = 1

func custom_ready():
	pass

func _ready():
	parent = get_parent()
	root = parent.root
	custom_ready()
	difficulty = DefSys.difficulty

func custom_action(_t):
	pass

func remove_bullets(bullet_ids):
	for bullet_id in bullet_ids:
		Bullets.delete(bullet_id)

func _physics_process(delta):
	remove_bullets(bullets_to_remove)
	bullets_to_remove.clear()
	
	position += velocity * delta * 60.0
	
	
	t_raw += delta * 60.0
	while t_raw > t_int:
		custom_action(t_int)
		t_int += 1
		tank_time -= 1
	
	
	if health < 0:
		DefSys.sfx.play("explode1")
		queue_free()
	

func _on_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	var damage = Bullets.get_property(bullet_id, "damage")
	if tank_time > 0:
		damage /= tank_factor
	health -= damage
	DefSys.sfx.play("damage1" if float(health) / max_health > 0.2 else "damage2")
	bullets_to_remove.append(bullet_id)
