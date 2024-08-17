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

var t_raw := 0.0
var t_int := -1

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

var start_position := Vector2(500, 300)
var target_position := Vector2()
var travel_time := 0.0
var travel_timer := 0.0

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
						preload("res://examples/boss/attacks/spell3.tscn"),
						preload("res://examples/boss/attacks/non2.tscn"),
						preload("res://examples/boss/attacks/spell2.tscn"),
						preload("res://examples/boss/attacks/spell1.tscn"),
]

var attacks := []
var current_attack : Attack
var phase := 0

var skip_opening := true

var disabled := true

var is_first_attack := true


func _ready():
	$Dialogue.root = root

func after_ready():
	for attack in attack_prefabs:
		attacks.append(attack.instance())
		
	var attack_types = []
	for i in range(len(attacks) - 1, -1 if skip_opening else 0, -1):
		attack_types.append(attacks[i].attack_type)
	DefSys.boss_bar.set_phase_icons(attack_types)
	
	if skip_opening:
		DefSys.boss_bar.entry_anim()
		#t = -120
		t_raw = -120.0
		t_int = -121
		DefSys.boss_bar.remove_phase_icon(len(attacks) - phase - 1)
		#phase = 1
	else:
		#t = 0
		t_raw = 0.0
		t_int = -1

func enable():
	after_ready()
	disabled = false

func smooth_interp(x: float):
	return (2.0 - x) * x

func _physics_process(delta):
	if disabled:
		return
	
	boss_position = $Hitbox.position
	
	remove_bullets(bullets_to_remove)
	DefSys.boss_bar.health = health if attack_type != DefSys.ATTACK_TYPE.TIMEOUT else float(time_left)
	DefSys.boss_bar.set_timer(time_left)
	
	t_raw += delta * 60.0
	while t_raw > t_int:
		custom_process(t_int)
		t_int += 1
		#tank_time -= 1
	
	
	if health < 0:
		DefSys.sfx.play("explode1")
		queue_free()
	
#	DefSys.markers.set_galacta_marker_position(galacta.position.x)
	#DefSys.markers.set_remilia_marker_position(remilia.position.x)
	
	# janky opener
	#if t_global == 350 && !skip_opening:
#		DefSys.background_controller.flash()
	#if t_global == 375 && !skip_opening:
		#galacta.position = Vector2(500, 350)
		#remilia.position.y = 150
		#add_child(attacks[0])
#		pass
func custom_process(t: int):
	# attack handling
	if t == 0 && phase < len(attacks):
		current_attack = attacks[phase]
		current_attack.difficulty = DefSys.difficulty
		add_child(current_attack)
		health = current_attack.health
		time_left = current_attack.attack_time
		start_delay = current_attack.start_delay
		set_boss_dest(current_attack.start_pos, 60)
		
		spell_bonus = current_attack.scb
		
		var last_attack_type = attack_type
		attack_type = current_attack.attack_type
		var is_spell: bool = (attack_type != DefSys.ATTACK_TYPE.NON)
		#DefSys.background_controller.spell(is_spell)
		DefSys.background_controller.play_bg(current_attack.bg_flag)
		DefSys.spell_bonus = true
		if is_spell:
			DefSys.boss_bar.declare_spell(current_attack.attack_name, current_attack.scb)
			DefSys.warp_effect.warp((boss_position), false)
			bullet_clear.position = (boss_position)
			bullet_clear.monitoring = true
			bullet_clear.monitorable = true
			bullet_clear_radius = 0
			bullet_clear.get_child(0).shape.radius = 0
			DefSys.sfx.play("blast1")
			DefSys.player.set_hidden_invincibility()
			root.slowdown(1.0)
		else:
			DefSys.boss_bar.end_spell()
			bullet_clear.position = Vector2(500, 500)
			bullet_clear.monitoring = true
			bullet_clear.monitorable = true
			bullet_clear.get_child(0).shape.radius = 1000
			root.slowdown(1.0)
			
		if attack_type != DefSys.ATTACK_TYPE.TIMEOUT:
			$Hitbox.monitorable = true
			DefSys.boss_bar.max_health = health
			if last_attack_type == DefSys.ATTACK_TYPE.TIMEOUT:
				DefSys.boss_bar.healthbar_timeout(false)
				$darkener.play_backwards("darken")
		else:
			$Hitbox.monitorable = false
			DefSys.boss_bar.max_health = time_left
			if last_attack_type != DefSys.ATTACK_TYPE.TIMEOUT:
				DefSys.boss_bar.healthbar_timeout(true)
				$darkener.play("darken")
		
		if not is_first_attack:
			DefSys.boss_bar.fill_healthbar()
			DefSys.boss_bar.remove_phase_icon(len(attacks) - phase - 1)
	
	if t == 60 and is_first_attack:
		is_first_attack = false
		DefSys.boss_bar.remove_phase_icon(len(attacks) - phase - 1)
	
	
	if t < 120:
		bullet_clear_radius += 1000.0 / 60.0
		bullet_clear.get_child(0).shape.radius = bullet_clear_radius
	if t == 120: # JAAAAAAAANK, bullets can't be deleted while spawning in this manner...
		bullet_clear.monitoring = false
		bullet_clear.monitorable = false
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
		t_int = -2
		t_raw = -1.0
		health = 1.0
		time_left = 1
		phase += 1
		current_attack.queue_free()
		bullet_clear.monitoring = true
		bullet_clear.monitorable = true
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
			$Hitbox.monitorable = false
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
			DefSys.warp_effect.warp((boss_position), false)
			DefSys.sfx.play("blast1")
			#remilia.hide()
			#galacta.hide()
			$Hitbox.monitorable = false
			DefSys.background_controller.fade()
			if attack_type != DefSys.ATTACK_TYPE.NON:
				if DefSys.spell_bonus: DefSys.sfx.play("capture1")
	# warning-ignore:integer_division
				for _i in spell_bonus / 2 if DefSys.spell_bonus else 3:
					pass
					#Bullets.create_item(item_kit, DefSys.get_item_data(DefSys.ITEM_TYPE.POINT), galacta.position, rand_range(2,8), randf()*TAU, (randi()%2)*2-1)
					#Bullets.create_item(item_kit, DefSys.get_item_data(DefSys.ITEM_TYPE.POINT), remilia.position, rand_range(2,8), randf()*TAU, (randi()%2)*2-1)
		
			
	if travel_timer < travel_time:
		travel_timer += 1.0
		$Hitbox.position = start_position + (target_position - start_position) * smooth_interp(min(1.0, travel_timer / travel_time))
	
	t += 1
	t_global += 1
	
	
func set_boss_dest(dest: Vector2, frame: float):
	start_position = position
	target_position = dest
	travel_time = frame
	travel_timer = 0.0

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
	if true:
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
	bullets_to_remove.clear()
