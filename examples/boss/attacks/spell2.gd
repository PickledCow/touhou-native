extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add
export(Resource) var bullet_clear_kit

onready var gungnir := $gungnir
onready var warning_laser := $warning

var a := PI
var p : Vector2
var density := 0
var wvel := 0.0
var max_wvel := 0.03
var waccel := 0.0003
var a2 := 0.0
var a3 := PI * 0.5
var a4 := PI * 0.5
var lr := 1
var lr2 := 1
var lr3 := 1

var galacta_dash_timer := 0
var galacta_dash_time := 90
var galacta_dash_time_min := 5
var galacta_target := Vector2(1500, 250)

var remilia_dash_timer := 90
var remilia_dash_time := 90
var remilia_dash_time_min := 30

var blue_mentos : PoolRealArray
var orange_arrow : PoolRealArray
var red_ball : PoolRealArray
var red_fireball : PoolRealArray
var orange_arrowhead : PoolRealArray

var red_bubble : PoolRealArray
var orange_knife_small : PoolRealArray

func attack_init():
	blue_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.BLUE)
	blue_mentos[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	orange_arrow = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROW, DefSys.COLORS_LARGE.ORANGE)
	orange_arrow[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	orange_arrow[Constants.BULLET_DATA_STRUCTURE.LAYER] = DefSys.LAYERS.LARGE_BULLETS - 1
	
	red_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.RED)
	red_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.RED)
	orange_arrowhead = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROWHEAD, DefSys.COLORS.ORANGE)
	orange_arrowhead[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 3.0
	
	
	red_bubble = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BUBBLE, DefSys.COLORS_LARGE.RED)
	

func attack(t):
	if t >= 0:
		if t % 300 == 0:
			lr *= -1
			a = 0.0
			gungnir.monitorable = false
			gungnir.rotation = PI*0.5 - PI * lr * 0.5
			gungnir.position = remilia_position + Vector2(0, -128)
			$AnimationPlayer.play("spawn")
		if t % 300 == 60:
			gungnir.monitorable = true
		if t % 300 >= 60 && t % 300 < 120:
			var angle = parent.player.position.angle_to_point(gungnir.position)
			gungnir.rotation = lerp_angle(gungnir.rotation, angle, 0.25)
			gungnir.position = lerp(gungnir.position, remilia_position + Vector2(0, -420), 0.1)
		if t % 300 == 120:
			DefSys.sfx.play("charge2")
			a = gungnir.rotation
			p = gungnir.position + Vector2(240, 0).rotated(a)
			$warning2.position = p
			$warning2.rotation = a
			$warning2.show()
			density = 3
		if t % 300 == 180:
			DefSys.sfx.play("explode1")			
			$warning2.hide()
		if t % 300 >= 180 :
			gungnir.position += Vector2(70, 0).rotated(a)
			#p += Vector2(70, 0).rotated(a)
			#var o = parent.player.position.angle_to_point(p)
			if t % 2 == 0:
				for i in 4:
					for j in range(6,24):
						var b = Bullets.create_shot_a2(bullet_kit_add, gungnir.position, 0.0, a +PI/4+ i * TAU/4, 0.0, 0.0, red_fireball, true)
						Bullets.set_property(b, "auto_delete", false)
						Bullets.add_transform(b, Constants.TRIGGER.TIME, 30, {"max_speed": j * 0.25, "accel": 0.1 * j / 24.0})
						Bullets.add_transform(b, Constants.TRIGGER.TIME, 120, {"auto_delete": true})
# warning-ignore:narrowing_conversion
			#density = min(density+1, 20)
		
		# Galacta
		if t >= 300:
			if t % 150 == 0:
				warning_laser.position = galacta_position
				a2 = parent.player.position.angle_to_point(galacta_position)
				warning_laser.rotation = a2
				warning_laser.show()
			if t % 150 >= 60 && t % 150 < 90:
				DefSys.sfx.play("shoot1")
				Bullets.create_shot_a1(bullet_kit, galacta_position, 30.0, a2, orange_arrowhead, true)
			if t % 150 == 60:
				warning_laser.hide()
			
		if t % 150 == 90:
			set_galacta_dest(Vector2(500 - rand_range(100, 200) * lr, rand_range(400, 500)), 60)
		if t % 300 == 240:
			set_remilia_dest(Vector2(500 + rand_range(100, 200) * lr, rand_range(300, 400)), 60)
		
		#if t % 300 == 210:
		#	$AnimationPlayer.play_backwards("spawn")
	
