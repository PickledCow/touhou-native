extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add
export(Resource) var bullet_clear_kit

var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1

var phase = 0

var mini_hp := 7500.0
var enemies_on_screen := 1

onready var mace_knight := $maceknight
var mace_hp : float
var maces := []
var mace_speed := 6
var mace_density = 12

onready var meiling := $meiling
var meiling_hp : float
var meiling_entry := -1
var meiling_a := 0.0
var meiling_lr := 1
var meiling_start_position: Vector2
var meiling_target_position: Vector2
var meiling_travel_time: float
var meiling_travel_timer: float

var blue_mentos : PoolRealArray
var orange_arrow : PoolRealArray
var blue_ball : PoolRealArray
var red_needle : PoolRealArray

var red_bubble : PoolRealArray
var orange_knife_small : PoolRealArray

func attack_init():
	blue_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.BLUE)
	blue_mentos[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	orange_arrow = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ARROW, DefSys.COLORS_LARGE.ORANGE)
	orange_arrow[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	orange_arrow[Constants.BULLET_DATA_STRUCTURE.LAYER] = DefSys.LAYERS.LARGE_BULLETS - 1
	
	blue_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL_OUTLINE, DefSys.COLORS.BLUE)
	red_needle = DefSys.get_bullet_data(DefSys.BULLET_TYPE.ICE, DefSys.COLORS.RED)
	red_needle[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	
	
	red_bubble = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BUBBLE, DefSys.COLORS_LARGE.RED)
	
	orange_knife_small = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.ORANGE)

	mace_hp = mini_hp
	meiling_hp = mini_hp
	
	
	
func create_bullet_clear(bullet_id):
	var p = Bullets.get_property(bullet_id, "position")
	var s = Bullets.get_property(bullet_id, "scale")
	var c = Bullets.get_property(bullet_id, "fade_color")
	if !s: return
	Bullets.create_particle(bullet_clear_kit, p, s*0.75, c, Vector2(), false)
	Bullets.create_particle(bullet_clear_kit, p, -s*1.5, c, Vector2(), false)

func attack(t):
	remove_bullets(bullets_to_remove)
	parent.health = max(0.0, mace_hp) + max(0.0, meiling_hp)
	if t == 0:
		parent.invincible = true
		for _i in 2:
			maces.append(Bullets.create_shot_a1(bullet_kit, Vector2(-100, -100), 0.0, a, blue_mentos, true))
	# fuck off
	if (t) == 120:
		set_galacta_dest(Vector2(-500, -1500), 90)
	if (t) == 120:
		set_remilia_dest(Vector2(1500, -1500), 90)
	# mace knight
	if t == 150:
		phase = max(1, phase)
		enemies_on_screen = 1
	if phase >= 1:
		if mace_hp > 0.0:
			var r = max(400.0, 1000 - t*3)
			mace_knight.position = Vector2(500, 600) + Vector2(r, 0).rotated(t * 0.015+PI*0.5)
			if t >= 180 && t % 45 == 0:
				var a = parent.player.position.angle_to_point(mace_knight.position)
				var ball = Bullets.create_shot_a1(bullet_kit, mace_knight.position, mace_speed, a, blue_mentos, true)
				create_bullet_clear(maces[0])
				Bullets.delete(maces[0])
				maces[0] = maces[1]
				maces[1] = ball
				var o = randf()*TAU
				for i in mace_density:
					var p = mace_knight.position + Vector2(36, 0).rotated(o + i * TAU / mace_density)
					var tip = Bullets.create_shot_a1(bullet_kit, p, mace_speed, a, orange_arrow, true)
					Bullets.set_property(tip, "rotation", (o + i * TAU / mace_density - a))
					Bullets.add_transform(tip, Constants.TRIGGER.TIME, 90, {"rotation": 0.0, "speed": 6.0, "accel": -0.25, "max_speed": 5.0})
					Bullets.add_translate(tip, Constants.TRIGGER.TIME, 90, {"angle": (o + i * TAU / mace_density - a)})
		elif mace_hp != -99999.0:
			DefSys.sfx.play("explode1")
			mace_hp = -99999.0
			mace_knight.position.x = -500
			enemies_on_screen -= 1
	# Meiling
	if meiling_entry == -1 && (enemies_on_screen == 0):
		phase = max(2, phase)
		mace_speed = 5
		mace_density = 8
		meiling_entry = t
		
	if phase >= 2:
		if meiling_hp > 0.0:
			var u = t - meiling_entry - 60
			if u == -60:
				set_meiling_dest(Vector2(500, 350), 60)
			elif u >= 0:
				if u % 180 == 0:
					meiling_a = randf()*TAU
					meiling_lr *= -1
				if u % 180 < 90:
					if u % 8 == 0:
						Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, meiling.position, 16.0, 6.0, meiling_a, 30, 0, red_needle, true)
					meiling_a += 0.25 * meiling_lr
				if u % 180 == 60:
					set_meiling_dest(Vector2(rand_range(450, 550), rand_range(200, 500)), 15)
				if u % 180 == 120:
					Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, meiling.position, 16.0, 4.0, randf()*TAU, 60, 0, blue_ball, true)
			
		elif meiling_hp != -99999.0:
			DefSys.sfx.play("explode1")
			meiling_hp = -99999.0
			meiling.position.x = - 500
			enemies_on_screen -= 1
	
	if meiling_travel_timer < meiling_travel_time:
		meiling_travel_timer += 1.0
		meiling.position = meiling_start_position + (meiling_target_position - meiling_start_position) * smooth_interp(min(1.0, meiling_travel_timer / meiling_travel_time))


func smooth_interp(x: float):
	return (2.0 - x) * x
func set_meiling_dest(dest: Vector2, frame: float):
	meiling_start_position = meiling.position
	meiling_target_position = dest
	meiling_travel_time = frame
	meiling_travel_timer = 0.0
	
var bullets_to_remove = []
	
func remove_bullets(bullet_ids):
	for bullet_id in bullet_ids:
		Bullets.delete(bullet_id)

func _on_maceknight_area_shape_entered(area_id, _area, area_shape, _local_shape_index):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	mace_hp -= Bullets.get_property(bullet_id, "damage") * 1.5
	DefSys.sfx.play("damage1" if mace_hp / mini_hp > 0.2 else "damage2")
	create_bullet_clear(bullet_id)
	bullets_to_remove.append(bullet_id)

func _on_meiling_area_shape_entered(area_id, _area, area_shape, _local_shape_index):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	meiling_hp -= Bullets.get_property(bullet_id, "damage") * 0.75
	DefSys.sfx.play("damage1" if meiling_hp / mini_hp > 0.2 else "damage2")
	create_bullet_clear(bullet_id)
	bullets_to_remove.append(bullet_id)
