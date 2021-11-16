extends Node2D
class_name BulletsSpawner, "res://addons/native_bullets/icons/icon_bullet_properties.svg"
# Simple bullets spawner that uses child nodes as spawning points.
# It sets bullets velocity, position and rotation.


export(bool) var enabled = true
export(Resource) var bullet_kit
export(float, 0.0, 65535.0) var bullets_speed = 100.0
export(float, -512.0, 512.0) var bullets_spawn_distance = 0.0

var c = 0

func _physics_process(delta):
	for spawner in get_children():
		var bullet_rotation = spawner.global_rotation
		var bullet_velocity = Vector2(cos(bullet_rotation), sin(bullet_rotation)) * bullets_speed
		
		
		var bullet = Bullets.obtain_bullet(bullet_kit)
		var xform = Transform2D(0.0, Vector2(0.0, 0.0)).scaled(Vector2(1.0, 0.5) / 64.0).rotated(bullet_rotation+PI*0.5)
		xform.origin = spawner.global_position
		Bullets.set_bullet_property(bullet, "transform", xform)
		Bullets.set_bullet_property(bullet, "velocity", bullet_velocity)
		Bullets.set_bullet_property(bullet, "texture_region", Color(64 * (randi()%16), 64 * (1 + randi()%11), 64, 1))
	
