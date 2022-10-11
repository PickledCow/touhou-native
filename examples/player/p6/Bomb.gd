extends Area2D

var player_bullet_kit
var Explosion := preload("res://examples/boss/explosion.tscn")

var velocity := Vector2()
var timer := 30

var bounce_time := 2
var bounce_timer := 0
var bounced := false

func _physics_process(delta):
	position += velocity
	var overlaps := get_overlapping_areas()
	if !bounced && len(overlaps) > 0:
		bounced = true
		DefSys.sfx.play("item")
		bounce_timer = bounce_time
		timer /= 2
		var n : Vector2 = (overlaps[0].get_parent().position - position).normalized()
		velocity = 0.5 * (velocity - 2 * (velocity.dot(n)) * n)
		position += velocity
	timer -= 1
	bounce_timer -= 1
	if timer <= 0:
		DefSys.sfx.play("explode1")
		var bd = DefSys.null_bullet_data
		bd[4] = 360.0 # bullet size [0, inf)
		bd[5] = 1 	 # hitbox ratio [0, 1]
		var bullet = Bullets.create_shot_a1(player_bullet_kit, position, 0.0, 0.0, bd, false)
		var crit := bounced && bounce_timer >= 0
		Bullets.set_bullet_properties(bullet, {"damage": 2400 if crit else 800, "damage_type": 1 if crit else 0})
		Bullets.add_transform(bullet, Constants.TRIGGER.TIME, 2, {"position": Vector2(2000, 2000)})
		var explosion = Explosion.instance()
		explosion.position = position
		get_parent().add_child(explosion)
		queue_free()
		
