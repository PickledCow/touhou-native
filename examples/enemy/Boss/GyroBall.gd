extends "res://examples/enemy/Enemy.gd"

var lr := 1.0
var air_detonated := true
var floor_detonated := false

var MENTOS_DENSITY = [3, 4, 5, 6, 7]
var BALL_DENSITY = [2, 3, 3, 4, 5]

var speed_low = [1.7, 1.8, 1.9, 2.0, 2.5]
var speed_mid = [2.25, 2.5, 2.8, 3.25, 3.75]
var speed_high = [3.6, 4.0, 4.5, 5.0, 6.0]

var MIN_MAX_SPEED := 15.0
var MAX_MAX_SPEED := 25.0
var MAX_SPEED_DELTA := 0.0
var max_speed := 15.0
var min_speed := 5.0

var MIN_ACCEL := 0.8
var MAX_ACCEL := 1.0
var ACCEL_DELTA := 0.0
var accel := 0.8

var wall_energy_factor := 0.8
var energy_factor := 2.0

const RADIUS := 96.0

var onscreen := false

var collided = []

func custom_ready():
	pass

func _process(delta):
	$Sprite.rotation += PI * delta * lr


func custom_action(t):
	var player := DefSys.player

	
	#var dist := max(50.0 * 50.0, (position - player.position).length_squared())
	var dist := 100.0

	var dir := (position - player.position).normalized()
	
	velocity -= accel * dir
	
	if velocity.length_squared() > max_speed * max_speed:
		velocity = velocity.normalized() * max_speed
	
#	print(position)

func custom_physics_process(delta: float):
	if onscreen:
		if position.x < RADIUS:
			velocity.x *= -wall_energy_factor
			position.x = RADIUS * 2.0 - position.x
			max_speed = MIN_MAX_SPEED
			accel = MIN_ACCEL
		elif position.x > 1000.0 - RADIUS:
			velocity.x *= -wall_energy_factor
			position.x = (1000.0 - RADIUS) * 2.0 - position.x
			max_speed = MIN_MAX_SPEED
			accel = MIN_ACCEL
		if position.y < RADIUS:
			velocity.y *= -wall_energy_factor
			position.y = RADIUS * 2.0 - position.y
			max_speed = MIN_MAX_SPEED
			accel = MIN_ACCEL
		elif position.y > 1000.0 - RADIUS:
			velocity.y *= -wall_energy_factor
			position.y = (1000.0 - RADIUS) * 2.0 - position.y
			max_speed = MIN_MAX_SPEED
			accel = MIN_ACCEL
	else:
		if position.y > RADIUS:
			onscreen = true
	if velocity.length_squared() > max_speed * max_speed:
		velocity = velocity.normalized() * max_speed
		
		
	for gyro in get_overlapping_areas():
		if gyro in collided:
			continue
		
		var d : float = (gyro.position - position).length()
		var a : float = atan2(gyro.position.y - position.y, gyro.position.x - position.x)
		
		var overlap : float = (RADIUS * 2.0 - d)
		
		var local_self_velocity := velocity.rotated(-a)
		var local_other_velocity : Vector2 = gyro.velocity.rotated(-a)
		
		var temp := local_self_velocity.x
		local_self_velocity.x = local_other_velocity.x * energy_factor
		local_other_velocity.x = temp * energy_factor
		
		if abs(local_self_velocity.x) < min_speed:
			local_self_velocity.x = min_speed * sign(local_self_velocity.x)
		if abs(local_other_velocity.x) < min_speed:
			local_other_velocity.x = min_speed * sign(local_other_velocity.x)
		
		velocity = local_self_velocity.rotated(a)
		gyro.velocity = local_other_velocity.rotated(a)
		
		var v := velocity.length_squared()
		var gv : float = gyro.velocity.length_squared() 
		
		if v > max_speed * max_speed:
			velocity = velocity.normalized() * max_speed
		if gv > max_speed * max_speed:
			gyro.velocity = gyro.velocity.normalized() * max_speed
			
		position -= Vector2(overlap * 0.5, 0.0).rotated(a)
		gyro.position += Vector2(overlap * 0.5, 0.0).rotated(a)
		
		max_speed = min(MAX_MAX_SPEED, max_speed + MAX_SPEED_DELTA)
		accel = min(MAX_ACCEL, accel + ACCEL_DELTA)
		
		gyro.collided.append(self)
	
	collided.clear()
	


