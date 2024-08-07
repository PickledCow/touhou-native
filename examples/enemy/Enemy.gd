extends Area2D

export var max_health := 100
onready var health := max_health 

var t_raw := 0.0
var t_int := 0

var bullets_to_remove = []

func custom_ready():
	pass

func _ready():
	custom_ready()

func custom_action(delta, t):
	pass

func remove_bullets(bullet_ids):
	for bullet_id in bullet_ids:
		Bullets.delete(bullet_id)

func _physics_process(delta):
	remove_bullets(bullets_to_remove)
	bullets_to_remove.clear()
	
	t_raw += delta
	while int(t_raw) > t_int:
		custom_action(delta, t_raw)
		t_int += 1
	

func _on_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	health -= Bullets.get_property(bullet_id, "damage")
	DefSys.sfx.play("damage1" if health / max_health > 0.2 else "damage2")
	bullets_to_remove.append(bullet_id)
