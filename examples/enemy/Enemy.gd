extends Area2D


export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

export var max_health := 100
onready var health = max_health 


var velocity := Vector2()

var t_raw := 0.0
var t_int := -1

var bullets_to_remove = []

var difficulty = 0
var root: Root
var parent: Node2D

var tank_time = 0
var tank_factor = 1

var death_delay := 0.0
var marked_for_death := false

var died := false

func custom_ready():
	pass

func _ready():
	parent = get_parent()
	root = parent.root
	custom_ready()
	difficulty = DefSys.difficulty

func custom_action(_t):
	pass

func custom_physics_process(_delta: float):
	pass

func custom_death():
	pass

func remove_bullets(bullet_ids):
	for bullet_id in bullet_ids:
		Bullets.delete(bullet_id)

func _physics_process(delta):
	custom_physics_process(delta)
	
	remove_bullets(bullets_to_remove)
	bullets_to_remove.clear()
	
	position += velocity * delta * 60.0
	
	
	t_raw += delta * 60.0
	while t_raw > t_int:
		custom_action(t_int)
		t_int += 1
		tank_time -= 1
	
	
	if health <= 0 and not died:
		died = true
		DefSys.sfx.play("explode1")
		marked_for_death = true
		custom_death()
	
	if marked_for_death:
		if death_delay <= 0.0:
			queue_free()
		death_delay -= delta * 60.0
	

func _on_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	var damage = Bullets.get_property(bullet_id, "damage")
	if tank_time > 0:
		damage /= tank_factor
	health -= damage
	DefSys.sfx.play("damage1" if float(health) / max_health > 0.2 else "damage2")
	bullets_to_remove.append(bullet_id)
