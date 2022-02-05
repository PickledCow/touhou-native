extends Node2D

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add
export(Resource) var bullet_clear_kit
export(Resource) var item_kit

export(NodePath) var player_path
onready var player = get_node(player_path)

var t := 0
var t_global := 0
var dw := 0.0
var lr := 1.0
var a := 0.0


var density := 50

var health := 10000.0
var max_health := 10000.0
var invincible := true
var is_timeout := false
var time_left := 1
var start_delay := 999999999
var attack_type := 0

var galacta_start_position := Vector2()
var galacta_target_position := Vector2()
var galacta_travel_time := 0.0
var galacta_travel_timer := 0.0

var remilia_start_position := Vector2()
var remilia_target_position := Vector2()
var remilia_travel_time := 0.0
var remilia_travel_timer := 0.0

var data: PoolRealArray
var data2: PoolRealArray
var data3: PoolRealArray

var item_data: PoolRealArray
var item_data2: PoolRealArray

onready var galacta := $galacta
onready var remilia := $remilia

onready var bullet_clear := $BulletClear

var attack_prefabs := [ #preload("res://examples/boss/attacks/non1.tscn"), 
						preload("res://examples/boss/attacks/spell1.tscn"), 
						preload("res://examples/boss/attacks/non2.tscn"), 
]
var attacks := []
var current_attack : Attack
var phase := 0

var skip_opening := true

func _ready():
	data = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.ORANGE)
	data[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	data[Constants.BULLET_DATA_STRUCTURE.LAYER] = DefSys.LAYERS.LARGE_BULLETS + 1
	data2 = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.ORANGE)
	data2[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.25
	data3 = DefSys.get_bullet_data(DefSys.BULLET_TYPE.KNIFE, DefSys.COLORS_LARGE.RED)
	data3[Constants.BULLET_DATA_STRUCTURE.SIZE] *= 1.5
	
	for attack in attack_prefabs:
		attacks.append(attack.instance())
	
	

func smooth_interp(x: float):
	return (2.0 - x) * x

func _physics_process(_delta):
	remove_bullets(bullets_to_remove)
	bullets_to_remove.clear()
	DefSys.boss_bar.health = health if attack_type != DefSys.ATTACK_TYPE.TIMEOUT else time_left
	DefSys.boss_bar.set_timer(time_left)
	DefSys.markers.set_galacta_marker_position(galacta.position.x)
	DefSys.markers.set_remilia_marker_position(remilia.position.x)
	# janky opener
	if t_global == 0:
		var attack_types = []
		for i in range(len(attacks) - 1, -1, -1):
			attack_types.append(attacks[i].attack_type)
		DefSys.boss_bar.set_phase_icons(attack_types)
		
		if skip_opening:
			DefSys.boss_bar.entry_anim() 
			t = -120
		else:
			t = -375
	
	if t_global == 350 && !skip_opening:
		DefSys.background_controller.flash()
	if t_global == 375 && !skip_opening:
		galacta.position = Vector2(500, 350)
		#remilia.position.y = 150
		#add_child(attacks[0])
	
	# attack handling
	if t == 0 && phase < len(attacks):
		current_attack = attacks[phase]
		add_child(current_attack)
		health = current_attack.health
		time_left = current_attack.attack_time
		start_delay = current_attack.start_delay
		set_galacta_dest(current_attack.galacta_start_pos, 60)
		set_remilia_dest(current_attack.remilia_start_pos, 60)
		
		var last_attack_type = attack_type
		attack_type = current_attack.attack_type
		var is_spell: bool = (attack_type != DefSys.ATTACK_TYPE.NON)
		DefSys.background_controller.spell(is_spell)
		if is_spell:
			DefSys.boss_bar.declare_spell(current_attack.attack_name, current_attack.scb)
		else:
			DefSys.boss_bar.end_spell()
			
		if attack_type != DefSys.ATTACK_TYPE.TIMEOUT:
			galacta.monitoring = true
			remilia.monitoring = true
			DefSys.boss_bar.max_health = health
			if last_attack_type == DefSys.ATTACK_TYPE.TIMEOUT:
				DefSys.boss_bar.healthbar_timeout(false)
				$darkener.play_backwards("darken")
		else:
			galacta.monitoring = false
			remilia.monitoring = false
			DefSys.boss_bar.max_health = time_left
			if last_attack_type != DefSys.ATTACK_TYPE.TIMEOUT:
				DefSys.boss_bar.healthbar_timeout(true)
				$darkener.play("darken")
				
		DefSys.boss_bar.fill_healthbar()
	
	if t == 15: # JAAAAAAAANK, bullets can't be deleted while spawning in this manner...
		bullet_clear.monitoring = false
	
	if t == start_delay && attack_type != DefSys.ATTACK_TYPE.TIMEOUT:
		invincible = false
	if t >= start_delay:
		time_left -= 1
	
	if time_left % 60 == 0 && time_left <= 600 && time_left != 0:
		DefSys.sfx.play("timer1" if time_left > 180 else "timer2")
	
	
	if (health <= 0.0 || time_left <= 0) && phase < len(attacks):
		invincible = true
		DefSys.sfx.play("explode1")
		DefSys.boss_bar.remove_phase_icon(len(attacks) - phase - 1)
		t = -1
		health = 1.0
		time_left = 1
		phase += 1
		current_attack.queue_free()
		bullet_clear.monitoring = true
	
	
	if galacta_travel_timer < galacta_travel_time:
		galacta_travel_timer += 1.0
		galacta.position = galacta_start_position + (galacta_target_position - galacta_start_position) * smooth_interp(min(1.0, galacta_travel_timer / galacta_travel_time))

	if remilia_travel_timer < remilia_travel_time:
		remilia_travel_timer += 1.0
		remilia.position = remilia_start_position + (remilia_target_position - remilia_start_position) * smooth_interp(min(1.0, remilia_travel_timer / remilia_travel_time))
	
	t += 1
	t_global += 1
	
	
	
func set_galacta_dest(dest: Vector2, frame: float):
	galacta_start_position = galacta.position
	galacta_target_position = dest
	galacta_travel_time = frame
	galacta_travel_timer = 0.0
	
func set_remilia_dest(dest: Vector2, frame: float):
	remilia_start_position = remilia.position
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

func _on_BulletClear_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	create_bullet_clear(bullet_id)
	bullets_to_remove.append(bullet_id)
	
func remove_bullets(bullet_ids):
	for bullet_id in bullet_ids:
		Bullets.delete(bullet_id)
