extends Node2D

var Explosion := preload("res://examples/boss/explosion.tscn")

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add
export(Resource) var bullet_clear_kit
export(Resource) var item_kit

export(NodePath) var player_path
onready var player: Player = get_node(player_path)
onready var root = get_node("../../")

var boss_position = Vector2()

var t := -100
var t_global := 0
var dw := 0.0
var lr := 1.0
var a := 0.0

var menu_timer := 180

var density := 50

var health := 10000.0
var max_health := 10000.0
var invincible := true
var is_timeout := false
var time_left := 1
var start_delay := 999999999
var attack_type := 0
var spell_bonus := 0

var explosion_timer := 5*60
var next_explosion_time := 20
var next_explosion_timer := 20

var galacta_start_position := Vector2()
var galacta_target_position := Vector2()
var galacta_travel_time := 0.0
var galacta_travel_timer := 0.0

var remilia_start_position := Vector2()
var remilia_target_position := Vector2()
var remilia_travel_time := 0.0
var remilia_travel_timer := 0.0

var item_data: PoolRealArray
var item_data2: PoolRealArray

#onready var galacta := $galacta
#onready var remilia := $remilia

#onready var galacta_hitbox := $galacta/hitbox
#onready var remilia_hitbox := $remilia/hitbox

onready var bullet_clear := $BulletClear
var bullet_clear_radius := 0.0

var attack_prefabs := [
						#preload("res://examples/boss/attacks/non1.tscn"),
						preload("res://examples/boss/attacks/spell1.tscn")
]

var attacks := []
var current_attack : Attack
var phase := 0

var skip_opening := true

var disabled := true

func _ready():
	pass
	#disabled = false

func after_ready():
	for attack in attack_prefabs:
		attacks.append(attack.instance())
	var attack_types = []
	for i in range(len(attacks) - 1, -1 if skip_opening else 0, -1):
		attack_types.append(attacks[i].attack_type)
	DefSys.boss_bar.set_phase_icons(attack_types)
	
	if skip_opening:
		DefSys.boss_bar.entry_anim()
		t = -120
		#DefSys.boss_bar.remove_phase_icon(len(attacks) - phase - 1)
		#phase = 1
	else:
		t = -375

func enable():
	after_ready()
	disabled = false

func smooth_interp(x: float):
	return (2.0 - x) * x

func _physics_process(_delta):
	if disabled:
		return
	
	boss_position = $Hitbox.position
	
	remove_bullets(bullets_to_remove)
	bullets_to_remove.clear()
	DefSys.boss_bar.health = health if attack_type != DefSys.ATTACK_TYPE.TIMEOUT else float(time_left)
	DefSys.boss_bar.set_timer(time_left)
#	DefSys.markers.set_galacta_marker_position(galacta.position.x)
	#DefSys.markers.set_remilia_marker_position(remilia.position.x)
	
	# janky opener
	if t_global == 350 && !skip_opening:
		DefSys.background_controller.flash()
	if t_global == 375 && !skip_opening:
		#galacta.position = Vector2(500, 350)
		#remilia.position.y = 150
		#add_child(attacks[0])
		pass
	
	# attack handling
	if t == 0 && phase < len(attacks):
		current_attack = attacks[phase]
		add_child(current_attack)
		health = current_attack.health
		time_left = current_attack.attack_time
		start_delay = current_attack.start_delay
	#	set_boss_dest(current_attack.remilia_start_pos, 60)
		
		spell_bonus = current_attack.scb
		
		var last_attack_type = attack_type
		attack_type = current_attack.attack_type
		var is_spell: bool = (attack_type != DefSys.ATTACK_TYPE.NON)
		#DefSys.background_controller.spell(is_spell)
		DefSys.background_controller.play_bg(current_attack.bg_flag)
		DefSys.spell_bonus = true
		if is_spell:
			DefSys.boss_bar.declare_spell(current_attack.attack_name, current_attack.scb)
			#DefSys.warp_effect.warp((galacta.position + remilia.position) * 0.5, false)
			#bullet_clear.position = (galacta.position + remilia.position) * 0.5
			DefSys.sfx.play("blast1")
		else:
			DefSys.boss_bar.end_spell()
			bullet_clear.position = Vector2(500, 500)
			bullet_clear.get_child(0).shape.radius = 1000
			
		if attack_type != DefSys.ATTACK_TYPE.TIMEOUT:
			#galacta_hitbox.monitorable = true
			#remilia_hitbox.monitorable = true
			DefSys.boss_bar.max_health = health
			if last_attack_type == DefSys.ATTACK_TYPE.TIMEOUT:
				DefSys.boss_bar.healthbar_timeout(false)
				$darkener.play_backwards("darken")
		else:
			#galacta_hitbox.monitorable = false
			#remilia_hitbox.monitorable = false
			DefSys.boss_bar.max_health = time_left
			if last_attack_type != DefSys.ATTACK_TYPE.TIMEOUT:
				DefSys.boss_bar.healthbar_timeout(true)
				$darkener.play("darken")
				
		DefSys.boss_bar.fill_healthbar()
		DefSys.boss_bar.remove_phase_icon(len(attacks) - phase - 1)
	
	if t <= 120:
		bullet_clear_radius += 2000.0 / 120.0
		bullet_clear.get_child(0).shape.radius = bullet_clear_radius
	if t == 120: # JAAAAAAAANK, bullets can't be deleted while spawning in this manner...
		bullet_clear.monitoring = false
		bullet_clear.get_child(0).shape.radius = 0
	
	if t == start_delay && attack_type != DefSys.ATTACK_TYPE.TIMEOUT:
		invincible = false
	if t >= start_delay:
		time_left -= 1
	
	if time_left % 60 == 0 && time_left <= 600 && time_left != 0 && phase < len(attacks):
		DefSys.sfx.play("timer1" if time_left > 180 else "timer2")
	
	
	if (health <= 0.0 || time_left <= 0) && phase < len(attacks):
		invincible = true
		DefSys.sfx.play("explode1")
		t = -1
		health = 1.0
		time_left = 1
		phase += 1
		current_attack.queue_free()
		bullet_clear.monitoring = true
		bullet_clear.get_child(0).shape.radius = 0.0
		if attack_type != DefSys.ATTACK_TYPE.NON && phase != len(attacks):
			#Bullets.create_item(item_kit, DefSys.get_item_data(DefSys.ITEM_TYPE.LIFE), (galacta.position + remilia.position) * 0.5, 6, PI * -0.5, (randi()%2)*2-1)
			if DefSys.spell_bonus: DefSys.sfx.play("capture1")
			DefSys.boss_bar.spell_result(DefSys.spell_bonus)
	# warning-ignore:integer_division
			for _i in spell_bonus / 2 if DefSys.spell_bonus else 3:
				#Bullets.create_item(item_kit, DefSys.get_item_data(DefSys.ITEM_TYPE.POINT), galacta.position, rand_range(2,8), randf()*TAU, (randi()%2)*2-1)
				#Bullets.create_item(item_kit, DefSys.get_item_data(DefSys.ITEM_TYPE.POINT), remilia.position, rand_range(2,8), randf()*TAU, (randi()%2)*2-1)
				pass
		if phase == len(attacks):
			DefSys.boss_bar.hide_healthbar()
			#remilia.monitorable = false
			#galacta.monitorable = false
		#	set_remilia_dest(Vector2(300, 300), 60)
			player.auto_poc = true
			
	if phase == len(attacks):
		if explosion_timer > 0:
			explosion_timer -= 1
			next_explosion_timer -= 1
			if next_explosion_timer <= 0:
				var explosion = Explosion.instance()
				#explosion.position = galacta.position + Vector2(randf()*150, 0).rotated(randf()*TAU)
				add_child(explosion)
				explosion = Explosion.instance()
				#explosion.position = remilia.position + Vector2(randf()*150, 0).rotated(randf()*TAU)
				add_child(explosion)
				next_explosion_time -= 1
				next_explosion_timer = next_explosion_time
				
				DefSys.sfx.play("explode1")
		elif explosion_timer == 0:
			explosion_timer = -1
			#DefSys.warp_effect.warp((galacta.position + remilia.position) * 0.5, false)
			DefSys.sfx.play("blast1")
			#remilia.hide()
			#galacta.hide()
			#remilia.monitoring = false
			#galacta.monitoring = false
			DefSys.background_controller.fade()
			if attack_type != DefSys.ATTACK_TYPE.NON:
				if DefSys.spell_bonus: DefSys.sfx.play("capture1")
	# warning-ignore:integer_division
				for _i in spell_bonus / 2 if DefSys.spell_bonus else 3:
					pass
					#Bullets.create_item(item_kit, DefSys.get_item_data(DefSys.ITEM_TYPE.POINT), galacta.position, rand_range(2,8), randf()*TAU, (randi()%2)*2-1)
					#Bullets.create_item(item_kit, DefSys.get_item_data(DefSys.ITEM_TYPE.POINT), remilia.position, rand_range(2,8), randf()*TAU, (randi()%2)*2-1)
		
			
	
	if galacta_travel_timer < galacta_travel_time:
		galacta_travel_timer += 1.0
		#galacta.position = galacta_start_position + (galacta_target_position - galacta_start_position) * smooth_interp(min(1.0, galacta_travel_timer / galacta_travel_time))

	if remilia_travel_timer < remilia_travel_time:
		remilia_travel_timer += 1.0
		#remilia.position = remilia_start_position + (remilia_target_position - remilia_start_position) * smooth_interp(min(1.0, remilia_travel_timer / remilia_travel_time))
	
	t += 1
	t_global += 1
	
	
func set_boss_dest(dest: Vector2, frame: float):
	#remilia_start_position = remilia.position
	remilia_target_position = dest
	remilia_travel_time = frame
	remilia_travel_timer = 0.0

func _on_area_shape_entered(area_id, _area, area_shape, _local_shape):
	
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	if !invincible:
		health -= Bullets.get_property(bullet_id, "damage")
	DefSys.sfx.play("damage1" if health / max_health > 0.2 else "damage2")
	bullets_to_remove.append(bullet_id)

func create_bullet_clear(bullet_id):
	var p = Bullets.get_property(bullet_id, "position")
	var s = Bullets.get_property(bullet_id, "scale")
	var c = Bullets.get_property(bullet_id, "fade_color")
	if !s: return
	Bullets.create_particle(bullet_clear_kit, p, s*0.75, c, Vector2(), false)
	Bullets.create_particle(bullet_clear_kit, p, -s*1.5, c, Vector2(), false)

var bullets_to_remove = []

func create_piv(p: Vector2):
	var item = Bullets.create_item(item_kit, DefSys.get_item_data(DefSys.ITEM_TYPE.PIV), p, 8, PI*-0.5, (randi()%2)*2-1)
	#Bullets.set_property(item, "grazed", true)
	Bullets.set_magnet_target(item, player)
	

func _on_BulletClear_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	if false:
		var p = Bullets.get_property(bullet_id, "position")
		call_deferred("create_piv", p)
		#create_piv(p)
		#var item = Bullets.create_item(item_kit, DefSys.get_item_data(DefSys.ITEM_TYPE.PIV), p, 8, PI*-0.5, (randi()%2)*2-1)
		#Bullets.set_property(item, "grazed", true)
		#Bullets.set_magnet_target(item, player)
		create_bullet_clear(bullet_id)
	bullets_to_remove.append(bullet_id)
	
func remove_bullets(bullet_ids):
	for bullet_id in bullet_ids:
		Bullets.delete(bullet_id)
