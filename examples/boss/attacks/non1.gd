extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1

var blue_knife : PoolRealArray

func attack_init():
	blue_knife = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.BLUE)
	blue_knife[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	blue_knife[Constants.BULLET_DATA_STRUCTURE.LAYER] = DefSys.LAYERS.LARGE_BULLETS + 1

func attack(t):
	if t >= 0:
		if t % 3 == 0:
			DefSys.sfx.play("shoot2")
			var bullets = Bullets.create_pattern_a2(bullet_kit, Constants.PATTERN_ADV.CHEVRON, position, 64.0, 48.0, 5.5, 5.5, parent.player.position.angle_to_point(position) + a, 3, 1, 0.1, blue_knife, true)
			Bullets.set_properties_bulk(bullets, { "bounce_count": 0, "bounce_surfaces": Constants.WALLS.DOME })
			a += 2.39996322972865332
		if t % 120 == 0:
			set_dest(Vector2(500 - rand_range(0, 150) * lr, rand_range(350, 450)), 60)
			lr *= -1
				
				
