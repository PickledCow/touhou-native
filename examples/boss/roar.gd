extends Node2D

export(Resource) var bullet_clear_kit

var t := 0.0

var laser_phase := -1
var laser_duration := 3.0

var spin := 0.0

func _physics_process(delta):
	if laser_phase >= 2 and laser_phase < 6:
		rotation += spin * delta * 60.0
	
	if laser_phase == 0:
		show()
		$laser/AnimationPlayer.play("open")
		DefSys.sfx.play("warning1")
		laser_phase = 1
	elif laser_phase == 1 and t >= 0.6:
		DefSys.sfx.play("charge1")
		laser_phase = 2
	elif laser_phase == 2 and t >= 1.0:
		$laser/AnimationPlayer.play("blast")
		laser_phase = 3
	elif laser_phase == 3 and t >= 1.5:
		DefSys.sfx.play("explode1")
		DefSys.sfx.play("blast1")
		laser_phase = 4
	elif laser_phase == 4 and t >= 2:
		$laser/Area2D.monitorable = true
		$laser/playerbulletclear.monitoring = true
		laser_phase = 5
	elif laser_phase == 5 and t >= 2 + laser_duration:
		$laser/AnimationPlayer.play("close")
		$laser/Area2D.monitorable = false
		$laser/playerbulletclear.monitoring = false
		laser_phase = 6
	elif laser_phase == 6 and t >= 3 + laser_duration:
		hide()
	
	t += delta


func create_bullet_clear(bullet_id):
	var p = Bullets.get_property(bullet_id, "position")
	var s = 80.0
	var c = Color(0.2, 0.3, 0.8, 1.0)
	if !p: return
	Bullets.create_particle(bullet_clear_kit, p, s*0.75, c, Vector2(), false)
	Bullets.create_particle(bullet_clear_kit, p, -s*1.5, c, Vector2(), false)

func _on_playerbulletclear_area_shape_entered(area_rid, _area, area_shape_index, _local_shape_index):
	var bullet_id = Bullets.get_bullet_from_shape(area_rid, area_shape_index)
	create_bullet_clear(bullet_id)
#	call_deferred("delete_bullet", bullet_id)
