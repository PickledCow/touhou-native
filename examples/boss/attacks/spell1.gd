extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add
export(Resource) var bullet_clear_kit

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1
var r := 0.0
var d := 20

var red_bubble : PoolRealArray
var red_mentos : PoolRealArray
var red_ball : PoolRealArray
var orange_knife : PoolRealArray
var orange_knife_small : PoolRealArray

func attack_init():
	red_bubble = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BUBBLE, DefSys.COLORS_LARGE.RED)
	
	red_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.RED)
	red_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.RED)
	
	orange_knife = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.ORANGE)
	orange_knife[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	orange_knife[Constants.BULLET_DATA_STRUCTURE.LAYER] = DefSys.LAYERS.LARGE_BULLETS + 1
	
	orange_knife_small = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.ORANGE)

func attack(t):
	# Galacta
	if t == 0:
		$laser/AnimationPlayer.play("open")
	if t == 6:
		DefSys.sfx.play("warning1")
	if t == 120:
		$laser/AnimationPlayer.play("load")
		DefSys.sfx.play("laser1")
	if t == 210:
		$laser/AnimationPlayer.play("blast")
		DefSys.sfx.play("charge1")
	if t == 330:
		$laser/Area2D.monitorable = true
	if t == 300:
		$laser/bulletclear.monitoring = true
		$laser/playerbulletclear.monitoring = true
		DefSys.sfx.play("sparklong")
		DefSys.sfx.play("explode1")
		DefSys.playfield_root.shake_screen(60, 30)
	
	if t == 300 + 29 * 60:
		$laser/AnimationPlayer.play("close")
		$laser/Area2D.monitorable = false
		$laser/bulletclear.monitoring = false
		$laser/playerbulletclear.monitoring = false
	
	
	if t >= 360:
		if t % 120 == 0:
			DefSys.sfx.play("shoot1")
			d += 1
			a = remilia_position.angle_to_point(parent.player.position) + (PI / d if d % 2 == 0 else 0.0)
			a2 = rand_range(-0.015, 0.015) - PI * lr * 0.35
			lr *= -1
			r = 0.0
			Bullets.create_pattern_a1(bullet_kit_add, Constants.PATTERN.RING, remilia_position, 0, 12.0, a, d, 0, red_bubble, true)
		if t % 7 == 1:
			var bullets = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, remilia_position, r, 0.0, a, d, 0, red_ball, true)
			Bullets.add_translate_bulk(bullets, Constants.TRIGGER.TIME, 0, {"angle": a2})
			Bullets.add_transform_bulk(bullets, Constants.TRIGGER.TIME, 60, {"accel": 0.05, "max_speed": 4.0})
		if t % 7 == 4:
			var bullets = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, remilia_position, r+6.0, 0.0, a, d, 0, red_ball, true)
			Bullets.add_translate_bulk(bullets, Constants.TRIGGER.TIME, 0, {"angle": a2+lr*0.0275*0.5})
			Bullets.add_translate_bulk(bullets, Constants.TRIGGER.TIME, 60, {"speed": -0.025})
			Bullets.add_transform_bulk(bullets, Constants.TRIGGER.TIME, 60, {"accel": 0.05, "max_speed": 4.0})
		a2 += 0.0275 * lr
		r += 12.0


func create_bullet_clear(bullet_id):
	var p = Bullets.get_property(bullet_id, "position")
	var s = 80.0
	var c = Color(0.5, 0.3, 0.8, 1.0)
	if !p: return
	Bullets.create_particle(bullet_clear_kit, p, s*0.75, c, Vector2(), false)
	Bullets.create_particle(bullet_clear_kit, p, -s*1.5, c, Vector2(), false)

func _on_bulletclear_area_shape_interacted(area_rid, _area, area_shape_index, _local_shape_index):
	var bullet_id = Bullets.get_bullet_from_shape(area_rid, area_shape_index)
	create_bullet_clear(bullet_id)

func delete_bullet(bullet_id):
	Bullets.delete(bullet_id)

func _on_playerbulletclear_area_shape_entered(area_rid, _area, area_shape_index, _local_shape_index):
	var bullet_id = Bullets.get_bullet_from_shape(area_rid, area_shape_index)
	create_bullet_clear(bullet_id)
	call_deferred("delete_bullet", bullet_id)
