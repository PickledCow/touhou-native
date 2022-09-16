extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1

var red_flame : PoolRealArray
var ball : PoolRealArray
var orange_flame : PoolRealArray

func attack_init():
	ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.RED)
	red_flame = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.RED)
	orange_flame = DefSys.get_bullet_data(DefSys.BULLET_TYPE.FIREBALL, DefSys.COLORS_LARGE.ORANGE)

func attack(t):
	if t >= 0:
		if t % 3 == 0:
			DefSys.sfx.play("shoot2")
			#var bullets = Bullets.create_pattern_a2(bullet_kit, Constants.PATTERN_ADV.CHEVRON, position, 64.0, 48.0, 5.5, 5.5, parent.player.position.angle_to_point(position) + a, 3, 1, 0.1, orange_flame, true)
			Bullets.create_shot_a1(bullet_kit_add, position, 10, a, red_flame, true)
			#Bullets.set_properties_bulk(bullets, { "bounce_count": 0, "bounce_surfaces": Constants.WALLS.DOME })
			a += 2.39996322972865332
		if t % 120 == 0:
			set_dest(Vector2(500 - rand_range(0, 150) * lr, rand_range(350, 450)), 60)
			lr *= -1
				
				
