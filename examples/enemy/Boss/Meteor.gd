extends "res://examples/enemy/Enemy.gd"

var grey_ball : PoolRealArray
var red_ball : PoolRealArray
var orange_ball : PoolRealArray
var yellow_ball : PoolRealArray
#var balls = [grey_ball, red_ball, orange_ball, yellow_ball]

var grey_mentos : PoolRealArray
var red_mentos : PoolRealArray
var orange_mentos : PoolRealArray
var yellow_mentos : PoolRealArray

var lr := 1.0
var air_detonated := true
var floor_detonated := false

var MENTOS_DENSITY = [3, 4, 5, 6, 7]
var BALL_DENSITY = [2, 3, 3, 4, 5]

var speed_low = [1.7, 1.8, 1.9, 2.0, 2.5]
var speed_mid = [2.25, 2.5, 2.8, 3.25, 3.75]
var speed_high = [3.6, 4.0, 4.5, 5.0, 6.0]

func custom_ready():
	death_delay = 120.0
	
	grey_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.GREY)
	red_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.RED)
	orange_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.ORANGE)
	yellow_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.YELLOW)
	grey_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.GREY)
	red_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.RED)
	orange_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.ORANGE)
	yellow_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.YELLOW)

func _process(delta):
	$Sprite.rotation += PI * delta * lr

func custom_action(t):
	if position.y > 1000.0 or (((position.x - 500.0) * sign(velocity.x) > 500.0)):
	#	print((position.x - 500.0) * sign(velocity.x))
		health = 0.0
		air_detonated = false
		if position.y > 1000.0:
			floor_detonated = true
	
	
func custom_death():
	DefSys.sfx.play("shoot1")
	for i in MENTOS_DENSITY[difficulty]:
		var ci = randi()%4
		var c = grey_ball if ci == 0 else red_ball if ci == 1 else orange_ball if ci == 2 else yellow_ball
		var s = rand_range(speed_mid[difficulty], speed_high[difficulty])
		var a = randf()*TAU if air_detonated else randf()*PI + PI if floor_detonated else randf()*PI - PI * 0.5 * lr
		
		var b = Bullets.create_shot_a1(bullet_kit, position, s, a, c, false)
		
	for i in BALL_DENSITY[difficulty]:
		var ci = randi()%4
		var c = grey_mentos if ci == 0 else red_mentos if ci == 1 else orange_mentos if ci == 2 else yellow_mentos
		var s = rand_range(speed_low[difficulty], speed_mid[difficulty])
		var a = randf()*TAU if air_detonated else randf()*PI + PI if floor_detonated else randf()*PI - PI * 0.5 * lr
		
		var b = Bullets.create_shot_a1(bullet_kit, position, s, a, c, false)
	
	$Sprite.hide()
	monitoring = false
	$Hurtbox.monitorable = false
	$Particles2D.emitting = false
	#position = Vector2(-1000, -1000)


func _on_Hurtbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	queue_free()
