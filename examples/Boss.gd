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

var explosion_timer := 0
var next_explosion_time := 20.0
var next_explosion_timer := 20.0

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

var stage := 0

onready var bullet_clear := $BulletClear
var bullet_clear_radius := 0.0

var last_character : int = DefSys.CHARACTER.DIALGA
var character_swapped := false

var character_pos = [ 0, 1, 2, 4, 5, 6, 3]

var attack_prefabs := [
						#preload("res://examples/boss/attacks/non1.tscn"),
						#preload("res://examples/boss/attacks/spell4.tscn"),
					#	preload("res://examples/boss/attacks/non2.tscn"),
					#	preload("res://examples/boss/attacks/spell2.tscn"),
					#	preload("res://examples/boss/attacks/non3.tscn"),
						preload("res://examples/boss/attacks/spell1.tscn"),
]

var attack_prefabs2 := [
						#preload("res://examples/boss/attacks/spell3.tscn"),
						#preload("res://examples/boss/attacks/spell5.tscn"),
						preload("res://examples/boss/attacks/spell6.tscn")
		
]

var attack_prefabs3 := [
						preload("res://examples/boss/attacks/spell7.tscn")
		
]

var attacks := []
var current_attack : Attack
var phase := 0

var skip_opening := true

var disabled := true

var is_first_attack := true


func _ready():
	$Dialogue.root = root

func after_ready(p_stage: int):
	attacks.clear()
	is_first_attack = true
	phase = 0
	stage = p_stage
	
	for attack in (attack_prefabs3 if p_stage == 2 else (attack_prefabs2 if p_stage == 1 else attack_prefabs)):
		attacks.append(attack.instance())
	
	if p_stage == 1:
		t_raw = -1080-60
		t_int = -1081-60
		explosion_timer = 463
		set_boss_dest(Vector2(500, 350), 30)
		$AnimationPlayer.play("transform")
	elif p_stage == 2:
		t_raw = -240
		t_int = -241
		explosion_timer = -1
		#set_boss_dest(Vector2(500, 350), 30)
	#	$AnimationPlayer.play("transform")
		
	
	elif p_stage == 0:
		var attack_types = []
		for i in range(len(attacks) - 1, -1 if skip_opening else 0, -1):
			attack_types.append(attacks[i].attack_type)
		DefSys.boss_bar.set_phase_icons(attack_types)
		DefSys.boss_bar.entry_anim()
		#t = -120
		t_raw = -120.0
		t_int = -121
	#	DefSys.boss_bar.remove_phase_icon(len(attacks) - 1)

func enable(second_phase = false):
	after_ready(second_phase)
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
	
func custom_process(t: int):
	if stage == 1:
	# Explosion
		if explosion_timer > 0:
			explosion_timer -= 1
			next_explosion_timer -= 1
			if next_explosion_timer <= 0:
				next_explosion_timer = next_explosion_time
				next_explosion_time -= 0.5
				var explosion = Explosion.instance()
				explosion.position = boss_position
				add_child(explosion)
				DefSys.sfx.play("explode1")
		
		# Giratina fucks off
		if t == -180:
			set_boss_dest(Vector2(500, -250), 90)
			$Hitbox.monitoring = true
			$Hitbox/hurtbox.monitorable = true
	elif stage == 2:
		# Giratina dies
		if t == -240:
			$Gira.play()
		if t == -210:
			$Hitbox/Fainter.play("faint")
			$Hitbox.monitoring = false
			$Hitbox/hurtbox.monitorable = false
		if t == -150:
			set_boss_dest(Vector2(500, -250), 1)
		
		if t == -149:
			character_swapped = false
			$Hitbox/Control/Sprite.position.y = 150
			$Hitbox.monitoring = true
			$Hitbox/hurtbox.monitorable = true
		
	
	
	if t == -152:
		var attack_types = []
		for i in range(len(attacks) - 1, -1 if skip_opening else 0, -1):
			attack_types.append(attacks[i].attack_type)
		DefSys.boss_bar.set_phase_icons(attack_types)
		DefSys.boss_bar.entry_anim()
		#DefSys.boss_bar.remove_phase_icon(len(attacks) - 1)
	
	if t == -90 and character_swapped:
		$Hitbox/Fainter.play("faint")
		$Hitbox.monitoring = false
		$Hitbox/hurtbox.monitorable = false
	# Move new character:
	if t == -30 and character_swapped:
		set_boss_dest(Vector2(500, -250), 1)
		
	if t == -29 and character_swapped:
		character_swapped = false
		$Hitbox/Control/Sprite.position.y = 150
		$Hitbox.monitoring = true
		$Hitbox/hurtbox.monitorable = true
	
	# attack handling
	if t == 0 && phase < len(attacks):
		current_attack = attacks[phase]
		current_attack.difficulty = DefSys.difficulty
		add_child(current_attack)
		health = current_attack.health
		time_left = current_attack.attack_time
		start_delay = current_attack.start_delay
		set_boss_dest(current_attack.start_pos, 60)
		
		$Hitbox/Control/Sprite.frame = character_pos[current_attack.character]
		
		spell_bonus = current_attack.scb
		
		var last_attack_type = attack_type
		attack_type = current_attack.attack_type
		var is_spell: bool = (attack_type != DefSys.ATTACK_TYPE.NON)
		#DefSys.background_controller.spell(is_spell)
	#	DefSys.background_controller.play_bg(current_attack.bg_flag)
		DefSys.spell_bonus = true
		if is_spell:
			DefSys.boss_bar.declare_spell(current_attack.attack_name, current_attack.scb, attack_type == DefSys.ATTACK_TYPE.FINAL)
			DefSys.warp_effect.warp((boss_position), false)
			bullet_clear.position = (boss_position)
			bullet_clear.monitoring = true
			bullet_clear.monitorable = true
			bullet_clear_radius = 0
			bullet_clear.get_child(0).shape.radius = 0
			DefSys.sfx.play("blast1")
			DefSys.player.set_hidden_invincibility()
			root.slowdown(1.0)
			root.warp(0)
			root.rotate_player(0)
		else:
			DefSys.boss_bar.end_spell()
			bullet_clear.position = Vector2(500, 500)
			bullet_clear.monitoring = true
			bullet_clear.monitorable = true
			bullet_clear.get_child(0).shape.radius = 1000
			root.slowdown(1.0)
			root.warp(0)
			root.rotate_player(0)
			
		if attack_type != DefSys.ATTACK_TYPE.TIMEOUT:
			$Hitbox.monitoring = true
			$Hitbox/hurtbox.monitorable = true
			DefSys.boss_bar.max_health = health
			$Hitbox/Control/Sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
			if last_attack_type == DefSys.ATTACK_TYPE.TIMEOUT:
				DefSys.boss_bar.healthbar_timeout(false)
		else:
			$Hitbox.monitoring = false
			$Hitbox/hurtbox.monitorable = false
			$Hitbox/Control/Sprite.modulate = Color(0.5, 0.5, 0.5, 1.0)
			DefSys.boss_bar.max_health = time_left
			if last_attack_type != DefSys.ATTACK_TYPE.TIMEOUT:
				DefSys.boss_bar.healthbar_timeout(true)
		
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
	
	if t == 120 and phase < len(attacks):
		root.start_section(current_attack.bg_flag)
	
	if t == start_delay && attack_type != DefSys.ATTACK_TYPE.TIMEOUT:
		invincible = false
	if t >= start_delay:
		time_left -= 1
	
	if time_left % 60 == 0 && time_left <= 600 && time_left != 0 && phase < len(attacks):
		DefSys.sfx.play("timer1" if time_left > 180 else "timer2")
	
	if (health <= 0.0 || time_left <= 0) && phase < len(attacks):
		root.slowdown(1.0)
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
			if DefSys.spell_bonus: DefSys.sfx.play("capture1")
			DefSys.boss_bar.spell_result(DefSys.spell_bonus)
			t_int = -151
			t_raw = -150.0
			character_swapped = true
		if phase == len(attacks):
			DefSys.boss_bar.hide_healthbar()
			$Hitbox.monitoring = false
			$Hitbox/hurtbox.monitorable = false
			player.auto_poc = true
			
	if phase == len(attacks):
		#root.slowdown(1.0)
		if stage == 0:
			root.start_section(9)
		elif stage == 1:
			root.start_section(10)
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
			$Hitbox.monitoring = false
			$Hitbox/hurtbox.monitorable = false
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


func face(left := true):
	$Hitbox/Control/Sprite.scale.x = 2.0/3.0 * (-1.0 if left else 1.0)

	
func set_boss_dest(dest: Vector2, frame: float):
	start_position = boss_position
	target_position = dest
	travel_time = frame
	travel_timer = 0.0
	
	face(start_position.x < target_position.x)

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
		if p:
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
