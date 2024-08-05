extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1

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
	
