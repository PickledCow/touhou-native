extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := 120
var a2 := 180
var lr := 1


var white_arrowhead : PoolRealArray
var grey_arrowhead : PoolRealArray
var blue_arrowhead : PoolRealArray
var teal_arrowhead : PoolRealArray

var white_speed = 8.5
var grey_speed = 7.0
var blue_speed = 9.0
var teal_speed = 9.5


var p : Vector2

func attack_init():
	white_arrowhead = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROWHEAD, DefSys.COLORS.WHITE)
	white_arrowhead[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 2.0
	grey_arrowhead = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROWHEAD, DefSys.COLORS.GREY)
	grey_arrowhead[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 2.0
	
	blue_arrowhead = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROWHEAD, DefSys.COLORS.BLUE)
	teal_arrowhead = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROWHEAD, DefSys.COLORS.TEAL)
	
	bullet_kit.active_rect = Rect2(-400, -400, 1800, 1800)

func attack_end():
	bullet_kit.active_rect = Rect2(-64, -64, 1128, 1128)
	
func attack(t):
	if t >= 0:
		if a == (a2*2/3):
			p = DefSys.player_position
			set_dest(p, a2*2/3)
		if a == 0:
			var bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, p, 0.0, white_speed, randf()*TAU, 20, 0, white_arrowhead, true)
			Bullets.set_properties_bulk(bs, {"wvel": lr * 1.5*PI/90.0, "accel": -0.2, "max_speed": white_speed * 0.5})
			Bullets.add_transform_bulk(bs, Constants.TRIGGER.TIME, 90, {"wvel": 0.0})
			bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, p, 0.0, grey_speed, randf()*TAU, 20, 0, grey_arrowhead, true)
			Bullets.set_properties_bulk(bs, {"wvel": -lr * 1.5*PI/90.0, "accel": -0.2, "max_speed": grey_speed * 0.5})
			Bullets.add_transform_bulk(bs, Constants.TRIGGER.TIME, 90, {"wvel": 0.0})
			bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, p, 0.0, blue_speed, randf()*TAU, 40, 0, blue_arrowhead, true)
			Bullets.set_properties_bulk(bs, {"wvel": -lr * 1.9*PI/90.0, "accel": -0.2, "max_speed": grey_speed * 0.5})
			Bullets.add_transform_bulk(bs, Constants.TRIGGER.TIME, 90, {"wvel": 0.0})
			bs = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, p, 0.0, teal_speed, randf()*TAU, 40, 0, teal_arrowhead, true)
			Bullets.set_properties_bulk(bs, {"wvel": lr * 1.9*PI/90.0, "accel": -0.2, "max_speed": grey_speed * 0.5})
			Bullets.add_transform_bulk(bs, Constants.TRIGGER.TIME, 90, {"wvel": 0.0})
			DefSys.sfx.play("shoot1")
			lr *= -1
					
			a = a2
			a2 -= 5
		a -= 1
