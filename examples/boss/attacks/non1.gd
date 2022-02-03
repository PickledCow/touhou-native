extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

const wave_offsets := [60,		150, 	240,	300,	315,	330,	345,	415,	425,	435,	445,	455,	495,	501,	507,	513,	519,	525]
onready var waves := [$wave0,	$wave1,	$wave0,	$wave2,	$wave6,	$wave3,	$wave4,	$wave5, $wave7,	$wave8,	$wave9,	$wave10,$wave11,$wave12,$wave13,$wave14,$wave15,$wave16]

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1

var red_bubble : PoolRealArray
var blue_mentos : PoolRealArray
var orange_knife : PoolRealArray

func attack_init():
	red_bubble = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BUBBLE, DefSys.COLORS_LARGE.RED)
	
	blue_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.BLUE)
	
	orange_knife = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.ORANGE)
	orange_knife[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	orange_knife[Constants.BULLET_DATA_STRUCTURE.LAYER] = DefSys.LAYERS.LARGE_BULLETS + 1

func attack(t):
	if t >= 0:
		if t == 0:
			parent.galacta.monitoring = false
			for wave in waves:
				wave.hide()
		if t <= 700:
			for i in len(waves):
				if t < wave_offsets[i] || t >= wave_offsets[i] + 180:
					continue
				var wave = waves[i]
				var sprites = wave.get_node("sprites").get_children()
				if t == wave_offsets[i]:
					DefSys.sfx.play("charge2")
					wave.show()
					for l in sprites:
						l.scale.x = 0.25
				if t <= wave_offsets[i] + 8:
					wave.modulate.a = (t - wave_offsets[i]) / 8.0
				if t == wave_offsets[i] + 59:
					for l in sprites:
						l.get_node("strike").emitting = true
						l.get_node("strike/spark").emitting = true
				if t == wave_offsets[i] + 60:
					DefSys.sfx.play("explode1")
					wave.get_node("Area2D").monitorable = true
					DefSys.playfield_root.shake_screen(24.0, 20.0 * pow(len(sprites), 0.33))
					for l in sprites:
						l.scale.x = 1.5
				if t < wave_offsets[i] + 120:
					if t % 4 == 0:
						for l in sprites:
							l.frame = (l.frame + randi()%3 + 1) % 4
					if t >= wave_offsets[i] + 80:
						wave.modulate.a = 1.0 - (t - (wave_offsets[i] + 80)) / 30.0
				if t == wave_offsets[i] + 75:
					wave.get_node("Area2D").monitorable = false
				if t == wave_offsets[i] + 180:
					wave.queue_free()
					
		if t == 600:
			set_remilia_dest(Vector2(500.0, 250), 45)
			set_galacta_dest(Vector2(500.0, 400), 45)
			parent.galacta.monitoring = true
			DefSys.boss_bar.max_health = parent.max_health
			parent.health = parent.max_health
			DefSys.boss_bar.entry_anim()
		if t >= 645:
			if t % 2 == 0:
				DefSys.sfx.play("shoot1")
				Bullets.create_shot_a1(bullet_kit_add, remilia_position, 5.5, a, red_bubble, true)
				a += 2.39996322972865332
			Bullets.create_shot_a1(bullet_kit, remilia_position + Vector2(96.0+3.0, 0.0).rotated(a2), 4.0, a2, blue_mentos, true)
			a2 += 2.39996322972865332
			#Bullets.create_shot_a1(bullet_kit, remilia_position + Vector2(96.0, 0.0).rotated(a2), 5.5, a2, blue_mentos, true)
			#a2 += 2.39996322972865332
			
			if t % 16 == 0:
				DefSys.sfx.play("shoot2")
				#Bullets.create_shot_a1(bullet_kit, remilia_position, 5.0, a2, blue_mentos, true)
				#var bullets = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.ARC, galacta_position, 64.0, 5.5, a3, 5, 0.09, orange_knife, true)
				var bullets = Bullets.create_pattern_a2(bullet_kit, Constants.PATTERN_ADV.CHEVRON, galacta_position, 72.0, 48.0, 5.5, 5.5, a3, 5, 1, 0.09, orange_knife, true)
				Bullets.set_properties_bulk(bullets, { "bounce_count": 2, "bounce_surfaces": Constants.WALLS.DOME })
				a3 -= 2.39996322972865332
			
			if t % 120 == 0:
				set_galacta_dest(Vector2(500 - rand_range(0, 150) * lr, rand_range(350, 450)), 60)
			if t % 120 == 60:
				#et_remilia_dest(Vector2(500 - rand_range(0, 150) * lr, rand_range(200, 300)), 60)
				lr *= -1
				
				
