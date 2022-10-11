extends Node2D

var bullet : PoolIntArray
var speed := 0.0

var homing_strength := 3.0

var target : Node2D

var time := 0

func _physics_process(_delta):
	if !target:
		var dist = INF
		var collisions = $Area2D.get_overlapping_areas()
		if collisions:
			target = collisions[0]
			dist = target.global_position.distance_squared_to(global_position)
		for collision in collisions:
			var new_dist = collision.global_position.distance_squared_to(global_position)
			if new_dist < dist:
				dist = new_dist
				target = collision
	if is_instance_valid(target):
		var angle_difference = target.global_position.angle_to_point(global_position) - rotation
		if angle_difference >= PI: angle_difference -= TAU
		if angle_difference <= -PI: angle_difference += TAU
		if abs(angle_difference) <= homing_strength:
			rotation = target.global_position.angle_to_point(global_position)
		elif angle_difference > homing_strength:
			rotation += homing_strength
		else:
			rotation -= homing_strength

	if Bullets.is_deleted(bullet):
		queue_free()
	else:
		position += Vector2(1.0, 0.0).rotated(rotation) * speed
		Bullets.set_bullet_property(bullet, "position", position)
		Bullets.set_bullet_property(bullet, "angle", rotation)
	
	time += 1	
	if time >= 120:
		homing_strength = 0
