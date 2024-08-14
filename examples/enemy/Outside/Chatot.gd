extends "res://examples/enemy/Enemy.gd"

var ax := 0.1

var firerate = [90, 80, 72, 60, 52]
var spread = [8, 8, 8, 9, 9]
var reduced_spread = [8, 8, 8, 8, 8]
var density = [16, 24, 40, 60, 69]

var reduce_spread := false

var red_note : PoolRealArray
var purple_note : PoolRealArray
var blue_note : PoolRealArray
var yellow_note : PoolRealArray

var cs

var spin_rate = 0.00225

var lr := 1.0


var start_direction = 1.0

func custom_ready():
	red_note = DefSys.get_bullet_data(DefSys.BULLET_TYPE.NOTE, DefSys.COLORS_NOTE.RED)
	purple_note = DefSys.get_bullet_data(DefSys.BULLET_TYPE.NOTE, DefSys.COLORS_NOTE.PURPLE)
	blue_note = DefSys.get_bullet_data(DefSys.BULLET_TYPE.NOTE, DefSys.COLORS_NOTE.BLUE)
	yellow_note = DefSys.get_bullet_data(DefSys.BULLET_TYPE.NOTE, DefSys.COLORS_NOTE.YELLOW)
	cs = [red_note, purple_note, blue_note, yellow_note]

func custom_action(t):
#	position.x += lr * speed
#	position.y -= velocity.y
	velocity.x -= ax
	
	scale.x = sign(velocity.x)
	
	var f = 60
	
	if t % f == 0 and position.y > 50 and position.x > 50.0 and position.x < 950.0 and start_direction == sign(velocity.x):
		DefSys.sfx.play("note"+str(randi()%3+1))
		var ar := randf()*TAU
		var sr := 4.0
		#var bullet = Bullets.create_shot_a1(bullet_kit, position, 4.0, a, cs[randi()%4], true)
		#Bullets.set_bullet_properties(bullet, {"rotation": -a+PI/2, "wvel": 0.01, "spin": -0.01})
		var ci := DefSys.last_chatot_color
		while ci == DefSys.last_chatot_color or ci == DefSys.last_chatot_color_2:
			ci = randi()%4
		DefSys.last_chatot_color_2 = DefSys.last_chatot_color
		DefSys.last_chatot_color = ci
		var c = cs[ci]
		#Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 0.0, s, a + TAU / DENSITY, DENSITY * 0.5, 0.0, c, true)
		var d = density[difficulty]
		for i in d:
			var spr = spread[difficulty] if not reduce_spread else reduced_spread[difficulty]
			for j in spr:
				var s = sr - j * 0.075
				var a = ar + j * 0.005 * lr
				var bullet = Bullets.create_shot_a1(bullet_kit, position, s, a + i *  TAU / d, c, true)
				Bullets.set_bullet_properties(bullet, {"rotation": -a+PI/2 -i *TAU / d, "wvel": lr * spin_rate, "spin": -lr * spin_rate})
			
		lr *= -1.0
		
		
	if position.y < -200 or position.x < -200 or position.x > 1200:
		queue_free()
	
	#DefSys.difficulty
