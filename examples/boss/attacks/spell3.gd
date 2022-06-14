extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add
export(Resource) var bullet_clear_kit

onready var tornado := $tornado
onready var tornado_hitbox := $tornado/Area2D
onready var tornado_anim := $tornadoanim

onready var cloud_anim := $cloudanim
onready var cloudlaunch := $cloudlaunch

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
var red_rain : PoolRealArray
var red_knife : PoolRealArray
var red_fireball : PoolRealArray
var purple_arrowhead : PoolRealArray

var red_bubble : PoolRealArray
var orange_knife_small : PoolRealArray

func attack_init():
	blue_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.BLUE)
	blue_mentos[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	orange_arrow = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROW, DefSys.COLORS_LARGE.ORANGE)
	orange_arrow[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	orange_arrow[Constants.BULLET_DATA_STRUCTURE.LAYER] = DefSys.LAYERS.LARGE_BULLETS - 1
	
	red_rain = DefSys.get_bullet_data(DefSys.BULLET_TYPE.DROPLET, DefSys.COLORS.RED_D)
	red_rain[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.15
	red_knife = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.RED)
	red_knife[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.25
	red_fireball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.RED)
	purple_arrowhead = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROWHEAD, DefSys.COLORS.PURPLE)
	#purple_arrowhead[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	red_bubble = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BUBBLE, DefSys.COLORS_LARGE.RED)
	
	DefSys.background_controller.leave()

var tornado_start_delay := 60
var cycle_time := 480

func attack(t):
	if t >= 0:
		cloudlaunch.position = remilia_position + Vector2(0, -64)
		if (t) == 0:
			cloud_anim.play("entry")
			tornado.hide()
		if (t-tornado_start_delay) % cycle_time == 0:
			lr *= -1;
			tornado.show()
			tornado_anim.play("spawn")
			tornado.position.x = 500 - lr * 475
			DefSys.sfx.play("wind")
		if (t-tornado_start_delay) % cycle_time == 120:
			tornado_hitbox.monitorable = true
		if (t-tornado_start_delay) % cycle_time >= 120 && (t-tornado_start_delay) % cycle_time < 375:
			tornado.position.x += lr * 825.0 / (360 - 120)
		if (t-tornado_start_delay) % cycle_time == 360:
			tornado_hitbox.monitorable = false
			tornado_anim.play("despawn")
		if (t-tornado_start_delay) % cycle_time == 420:
			set_galacta_dest(Vector2(500 + lr * 450, 400), 60)
			#tornado.position.x = 500 + lr * 450
		if t % 180 == 120:
			set_remilia_dest(Vector2(500 + lr * rand_range(50, 400), rand_range(300, 400)), 60)
			
		
		if t >= tornado_start_delay + cycle_time * 4 - 120:
			if t >= tornado_start_delay + cycle_time * 3 && t % 6 == 0: # 0.16
				Bullets.create_shot_a1(bullet_kit_add, Vector2(rand_range(-32, 1032), 0), rand_range(5, 7), PI*0.5 - rand_range(0.1, 0.3) * sin(PI * (t) / float(cycle_time)), red_fireball, false)
			if t % 6 == 3: # 0.16
				Bullets.create_shot_a1(bullet_kit, Vector2(rand_range(-32, 1032), 0), rand_range(6, 8), PI*0.5 - rand_range(0.1, 0.4) * sin(PI * (t) / float(cycle_time)), red_knife, false)
			if t % 3 != 0: # 0.67
				Bullets.create_shot_a1(bullet_kit, Vector2(rand_range(-32, 1032), 0), rand_range(3, 5), PI*0.5 - rand_range(0.1, 0.4) * sin(PI * (t) / float(cycle_time)), red_rain, false)
		elif t >= tornado_start_delay + cycle_time * 2 - 120: #0.95
			if t >= tornado_start_delay + cycle_time * 2 && t % 5 == 0: # 0.2
				Bullets.create_shot_a1(bullet_kit, Vector2(rand_range(-32, 1032), 0), rand_range(6, 7), PI*0.5 - rand_range(0.1, 0.4) * sin(PI * (t) / float(cycle_time)), red_knife, false)
			if t % 4 != 0: # 0.75
				Bullets.create_shot_a1(bullet_kit, Vector2(rand_range(-32, 1032), 0), rand_range(3, 5), PI*0.5 - rand_range(0.1, 0.4) * sin(PI * (t) / float(cycle_time)), red_rain, false)
		elif t >= 120 && t % 5 != 0: # 0.8
			Bullets.create_shot_a1(bullet_kit, Vector2(rand_range(-32, 1032), 0), rand_range(3, 5), PI*0.5 - rand_range(0.1, 0.4) * sin(PI * (t) / float(cycle_time)), red_rain, false)
		
		if t >= 120 && t % 2 == 0:
			DefSys.sfx.play("shoot1")
