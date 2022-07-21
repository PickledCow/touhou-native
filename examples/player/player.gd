extends Area2D
class_name Player

var Turret = preload("res://examples/player/p3/Turret.tscn")

export(Resource) var player_bullet_kit
export(Resource) var player_bullet_kit_add
export(Resource) var bullet_clear_kit
export(Resource) var item_text_kit
export(Resource) var graze_partlcle_kit

export(NodePath) var enemy_path
onready var Enemy = get_node(enemy_path)

onready var pid : int = DefSys.player_id

# Sniper mechanics
var sniper := false

var scoped := false
var just_unscoped := false
var sniper_max_charge_time := 30
var sniper_charge_timer := 0
onready var scope_sprite = $Scope
onready var gunshot = $Gunshot
var scope_position: Vector2
var scope_horizontal_priority = 0
var scope_vertical_priority = 0
var scope_move_speed = 24.0
var scoped_move_speed = .1
onready var reload_bar = $Bar
onready var progress = $Bar/Progress
var reload_timer = 0
var reload_time = 60
var reloaded := true
var just_reloaded := false
var reload_failed := false

# Engineer mechanics
var engineer := false
var turret_active := false
onready var turret = $Turret
onready var turret_healthbar = $Turret/healthbar/TextureProgress
onready var turret_buildbar = $Turret/buildbar/TextureProgress
var turret_position = Vector2()
var turret_max_health = [3, 4, 5]
var turret_health = 0
var turret_iframes = 30
var turret_iframe_timer = 0
var turret_power = 0


# Movement
export(float, 0, 1000) var speed = 500.0
export(float, 0, 1000) var focus_speed = 200.0
var velocity = Vector2()
enum HORIZONTAL_PRIORITY { LEFT, RIGHT }
var horizontal_priority = 0
enum VERTICAL_PRIORITY { UP, DOWN }
var vertical_priority = 0

# States
var is_focused := false
var auto_poc := false
var power = 0

# Vitals
var lives := 6999999999999999
var hit := false
var dead := false
var invincible_time := 180.0
var invincible_timer := 0.0
var game_over_timer := 120

# Bullet clear
var clear_time := 42.0
var clear_timer := 0.0
var clear_radius := 700.0

# Animation
var anim_timer := 0.0
var anim_time := 0.1
var anim_frame := 0
var facing := 1
onready var sprite = $Sprite

onready var bullet_clear_box = $bulletclearbox
onready var bullet_clear_box_shape = $bulletclearbox/CollisionShape2D
var bullets_to_remove = []

onready var hitbox1 = $focus
onready var hitbox2 = $focus2
onready var hitbox_anim = $focusanimation

# Shooting
enum PLAYER_BULLET_INDEX { REIMU_MAIN, REIMU_HOMING, MARISA_MAIN, MARISA_MISSILE, SNIPER_GARBAGE }
var player_bullets = [ PoolRealArray([0, 0, 192, 192, 144, 0.25, 47, 1, 0, 0, 0, 0, 0, 0, 0]),
						PoolRealArray([128, 192, 128, 128, 96, 0.375, 0, 1, 0, 0, 0, 0, 0, 0, 0]),
						PoolRealArray([0, 192, 128, 128, 96, 0.375, 0, 1, 0, 0, 0, 0, 0, 0, 0]),
						PoolRealArray([128, 0, 192, 192, 128, 0.25, 52, 2, 0, 0, 0, 0, 0, 0, 0]),
						PoolRealArray([256, 192, 64, 64, 64, 0.25, 0, 0, 0, 0, 0, 0, 0, 0, 0]) 
]
var custom_bullet := preload("res://examples/player/homing.tscn")

var shooters_unfocus = []
var shooters_focus = []

var option_positions_unfocus = []
var option_positions_focus = []

var option_interp = 0.0 # 0 unfocus 1 focus
var option_travel_speed = 0.15

onready var option_sprites = [get_node("options/0"), get_node("options/1"), get_node("options/2"), get_node("options/3"), get_node("options/0"), get_node("options/1")]

class Shooter:
	var fire_rate = 3
	var start_delay = 0
	var fire_timer = 0
	
	var damage = 10
	var offset = Vector2(0,0)
	var angle = -PI/2
	var angle_spread = 0.0
	var speed = 50
	var accel = 0
	var max_speed = 0
	var homing_strength = 0.0
	
	var sprite
	var kit
	var option = 0
	var sfx
	
var shoot_sfx = ["playershoot", "playermissile"]

# Data
var names = ["Reimu", "Marisa", "Sniper", "Engineer"]

func _ready():
	var tex = load("res://examples/player/p"+str(pid)+"/pl.png")
	$Sprite.texture = tex
	for option in option_sprites:
		option.texture = tex
	
	var shot_data_file = File.new()
	shot_data_file.open("res://examples/player/p"+str(pid)+"/shot.json", File.READ)
	var shot_data = JSON.parse(shot_data_file.get_as_text()).result
	shot_data_file.close()
	
	for power in shot_data["option_pos"]["unfocused"]:
		var arr = [Vector2()]
		for option in power:
			arr.append(Vector2(option["x"], option["y"]))
		option_positions_unfocus.append(arr)
	for power in shot_data["option_pos"]["focused"]:
		var arr = [Vector2()]
		for option in power:
			arr.append(Vector2(option["x"], option["y"]))
		option_positions_focus.append(arr)
			
	for power in shot_data["shooters"]["unfocused"]:
		var arr = []
		for shooter_data in power:
			var shooter = create_shooter(shooter_data)
			arr.append(shooter)
		shooters_unfocus.append(arr)
	for power in shot_data["shooters"]["focused"]:
		var arr = []
		for shooter_data in power:
			var shooter = create_shooter(shooter_data)
			arr.append(shooter)
		shooters_focus.append(arr)
		
	speed = 10.0 if pid == 1 else 9.0
	
	call_deferred("after_ready")
	
	match pid:
		2:
			sniper = true
		3:
			engineer = true	
	
func create_shooter(shooter_data):
	var shooter = Shooter.new()
	shooter.fire_rate = shooter_data["fire_rate"]
	shooter.start_delay = shooter_data["start_delay"]
	shooter.damage = shooter_data["damage"]
	shooter.option = shooter_data["option"]
	shooter.offset = Vector2(shooter_data["offset_x"], shooter_data["offset_y"])
	shooter.angle = shooter_data["angle"]
	shooter.angle_spread = shooter_data["angle_spread"]
	shooter.speed = shooter_data["speed"]
	shooter.sprite = shooter_data["sprite"]
	shooter.kit = player_bullet_kit if !shooter_data["additive"] else player_bullet_kit_add
	shooter.accel = shooter_data["accel"]
	shooter.max_speed = shooter_data["max_speed"]
	shooter.homing_strength = shooter_data["homing_strength"]
	shooter.sfx = shooter_data["sfx"]
	return shooter

func after_ready():
	DefSys.health_bar.set_name(names[pid])
	DefSys.health_bar.set_player_face(pid)



func _process(delta):
	#var last_position = position
	hitbox1.rotation += 2.0 * delta
	hitbox2.rotation -= 2.0 * delta
	
	if Input.is_action_just_pressed("focus"):
		hitbox_anim.stop()
		hitbox_anim.play("focus")
	elif !Input.is_action_pressed("focus"):
		hitbox1.visible = false
		hitbox2.visible = false
	
	anim_timer += delta
	if anim_timer >= anim_time:
		anim_frame += 1
		anim_timer -= anim_time	
	if anim_frame >= 120:
		anim_frame -= 120
	
	if velocity.x == 0.0:
		sprite.frame = int(anim_frame) % 4
	elif velocity.x < 0.0:
		facing = -1
		sprite.frame = 4 + int(anim_frame) % 4
	else:
		facing = 1
		sprite.frame = 4 + int(anim_frame) % 4
	
	sprite.scale.x = facing * abs(sprite.scale.x)
	
	if invincible_timer:
# warning-ignore:integer_division
		sprite.modulate = Color(0, 0, 1) if (int(invincible_timer) / 6) % 2 == 1 else Color(1,1,1)
		
	for option in option_sprites:
		option.rotation -= 2.0 * delta
		if option.rotation <= 0.0: option.rotation += TAU

func move():
	velocity = Vector2()
	
	if Input.is_action_just_pressed("left"):
		horizontal_priority = HORIZONTAL_PRIORITY.LEFT
	elif Input.is_action_just_pressed("right"):
		horizontal_priority = HORIZONTAL_PRIORITY.RIGHT
	if Input.is_action_just_pressed("up"):
		vertical_priority = VERTICAL_PRIORITY.UP
	elif Input.is_action_just_pressed("down"):
		vertical_priority = VERTICAL_PRIORITY.DOWN
	
	if Input.is_action_pressed("left") && !(horizontal_priority == HORIZONTAL_PRIORITY.RIGHT && Input.is_action_pressed("right")):
		velocity.x = -1
	elif Input.is_action_pressed("right") && !(horizontal_priority == HORIZONTAL_PRIORITY.LEFT && Input.is_action_pressed("left")):
		velocity.x = 1
	if Input.is_action_pressed("up") && !(vertical_priority == VERTICAL_PRIORITY.DOWN && Input.is_action_pressed("down")):
		velocity.y = -1
	elif Input.is_action_pressed("down") && !(vertical_priority == VERTICAL_PRIORITY.UP && Input.is_action_pressed("up")):
		velocity.y = 1
	
	is_focused = Input.is_action_pressed("focus")
	
	var prev_scope = scoped
	scoped = is_focused && Input.is_action_pressed("shoot")
	just_unscoped = prev_scope && !scoped
	
	if(velocity.length() > 0):
		velocity = velocity.normalized() * ((scoped_move_speed if (scoped && sniper) else focus_speed) if is_focused else speed)
	
	position += velocity
	position.x = clamp(position.x, 24, 1000 - 24)
	position.y = clamp(position.y, 60, 1000 - 30)
	
	get_node("itempoc/CollisionShape2D").disabled = position.y > 400 && !auto_poc

#var t = 0

func shoot():
	if Input.is_action_just_pressed("shoot"):
		if !engineer:
			for s in shooters_focus[power]:
				s.fire_timer = s.fire_rate + s.start_delay
			for s in shooters_unfocus[power]:
				s.fire_timer = s.fire_rate + s.start_delay
		else:
			place_sentry()
			
	if Input.is_action_pressed("shoot") && !engineer:
		var shooters = shooters_focus[power] if is_focused else shooters_unfocus[power]
		for s in shooters:
			s.fire_timer -= 1
			if s.fire_timer <= 0:
				s.fire_timer = s.fire_rate
				DefSys.sfx.play(shoot_sfx[s.sfx])
				var option_pos = option_positions_unfocus[power][s.option] * (1 - option_interp) + option_positions_focus[power][s.option] * option_interp
				var bullet_data = player_bullets[s.sprite]
				var angle = s.angle + rand_range(-1.0, 1.0) * s.angle_spread
				var p = position + s.offset.rotated(angle + PI*0.5) + option_pos
				if s.homing_strength == 0.0:
					var bullet = Bullets.create_shot_a2(s.kit, p, s.speed, angle, s.accel, s.max_speed, bullet_data, false)
					Bullets.set_bullet_properties(bullet, {"damage": s.damage})
				else:
					var bullet = Bullets.create_shot_a1(s.kit, p, 0.0, angle, bullet_data, false)
					Bullets.set_bullet_properties(bullet, {"damage": s.damage})
					var cb = custom_bullet.instance()
					cb.position = p
					cb.rotation = angle
					cb.bullet = bullet
					cb.speed = s.speed
					cb.homing_strength = s.homing_strength
					DefSys.playfield.add_child(cb)
	elif engineer && turret_active:
		turret.position = turret_position - position
		turret_iframe_timer -= 1
		if (turret_position - position).length_squared() <= 300*300:
			var prev_power = int(turret_power)
			turret_power = min(2, turret_power + 0.003)
			if int(turret_power) > prev_power:
				turret_health += 1
				DefSys.sfx.play("powerup")
			turret_health = min(turret_max_health[turret_power], turret_health + 0.005)
			turret_buildbar.value = float(turret_power + 1) / 3
			turret_healthbar.value = float(turret_health) / turret_max_health[turret_power]
		if turret_active:
			var shooters = shooters_unfocus[int(turret_power)]
			for s in shooters:
				s.fire_timer -= 1
				if s.fire_timer <= 0:
					s.fire_timer = s.fire_rate
					DefSys.sfx.play(shoot_sfx[s.sfx])
					var bullet_data = player_bullets[s.sprite]
					var angle = Enemy.position.angle_to_point(turret_position)
					var p = turret_position + s.offset.rotated(angle)
					if s.homing_strength == 0.0:
						var bullet = Bullets.create_shot_a2(s.kit, p, s.speed, angle, s.accel, s.max_speed, bullet_data, false)
						Bullets.set_bullet_properties(bullet, {"damage": s.damage})
					else:
						var bullet = Bullets.create_shot_a1(s.kit, p, 0.0, angle, bullet_data, false)
						Bullets.set_bullet_properties(bullet, {"damage": s.damage})
						var cb = custom_bullet.instance()
						cb.position = p
						cb.rotation = angle
						cb.bullet = bullet
						cb.speed = s.speed
						cb.homing_strength = s.homing_strength
						DefSys.playfield.add_child(cb)
	if sniper:
		if reloaded:
			scope_sprite.visible = scoped
			if Input.is_action_just_pressed("focus") || Input.is_action_just_pressed("shoot") || just_reloaded:
				scope_sprite.modulate.a = 0.0
				sniper_charge_timer = 0
				scope_position = Vector2.ZERO
			if scoped:
				sniper_charge_timer = min(sniper_charge_timer + 1, sniper_max_charge_time)
				
				scope_sprite.modulate.a = clamp(float(sniper_charge_timer - 5) / (sniper_max_charge_time - 15), 0.0, 0.9)
				scope_sprite.scale = Vector2.ONE * (1.0 + 2.0 * (1.0 - float(sniper_charge_timer) / sniper_max_charge_time))
				scope_sprite.rotation = scope_position.angle()	
				
				scope_position += velocity * scope_move_speed / scoped_move_speed
				scope_sprite.position = scope_position
				
			if just_unscoped:
				if sniper_charge_timer >= 10:
					gunshot.play()
					var bd = DefSys.null_bullet_data
					bd[4] = 256.0 # bullet size [0, inf)
					bd[5] = 1 	 # hitbox ratio [0, 1]
					var bullet = Bullets.create_shot_a1(player_bullet_kit, position + scope_position, 0.0, 0.0, bd, false)
					Bullets.set_bullet_properties(bullet, {"damage": 900})
					Bullets.add_transform(bullet, Constants.TRIGGER.TIME, 2, {"position": Vector2(2000, 2000)})
					bd[4] = 32.0 # bullet size [0, inf)
					bd[13] = 1	 # damage type
					bullet = Bullets.create_shot_a1(player_bullet_kit, position + scope_position, 0.0, 0.0, bd, false)
					Bullets.set_bullet_properties(bullet, {"damage": 800, "damage_type": 1})
					Bullets.add_transform(bullet, Constants.TRIGGER.TIME, 2, {"position": Vector2(2000, 2000)})
					reloaded = false
					reload_timer = 0
					$Bar.visible = true
					
			just_reloaded = false
		else:
			reload_timer += 1
			progress.value = float(reload_timer) / reload_time
			var active_reloaded = false
			if (Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("focus")) && !reload_failed:
				if (reload_timer >= 30 && reload_timer <= 45):
					active_reloaded = true
				else:
					reload_failed = true
					$Failshot.play()
			if (reload_timer >= reload_time) || active_reloaded:
				if active_reloaded:
					$ActiveReload.play()
				reloaded = true
				progress.value = 0.0
				reload_timer = 0
				$Bar.visible = false
				just_reloaded = true
				reload_failed = false
			
func place_sentry():
	if (turret_position - position).length_squared() <= 300*300 && turret_active: # Teleport instead of rebuild
		pass
	else:
		turret_power = 0
		turret_health = turret_max_health[0]
		turret_healthbar.value = float(turret_health) / turret_max_health[turret_power]
	
	turret_position = position
	turret_active = true
	turret.set_deferred("monitorable", true)
	turret.set_deferred("monitoring", true)
	turret.visible = true
			
func destroy_turret():
	turret_active = false
	turret.set_deferred("monitorable", false)
	turret.set_deferred("monitoring", false)
	turret.visible = false
	turret_power = 0
		
func _physics_process(_delta):
	remove_bullets(bullets_to_remove)
	bullets_to_remove.clear()
	
	if lives >= 0:
		move()
		
		if is_focused && option_interp < 1.0:
			option_interp += option_travel_speed
			if option_interp > 1.0:
				option_interp = 1.0
		elif !is_focused && option_interp > 0.0:
			option_interp -= option_travel_speed
			if option_interp < 0.0:
				option_interp = 0.0
		for i in len(option_positions_unfocus[power])-1:
			option_sprites[i].position = option_positions_unfocus[power][i+1] * (1 - option_interp) + option_positions_focus[power][i+1] * option_interp
		
		shoot()
		
	if hit && invincible_timer <= 0.0:
		DefSys.spell_bonus = false
		DefSys.sfx.play("death")
		DefSys.boss_bar.fail_spell()
		bullet_clear_box.monitoring = true
		lives -= 1
		if lives == 2 || lives == 0:
			DefSys.sfx.play("lowhealth")
		#emit_signal("hit", lives)
		DefSys.health_bar.animate_face(true, lives)
		invincible_timer = invincible_time
		DefSys.warp_effect.warp(position, true)
		clear_timer = clear_time
		if lives < 0:
			hide()
	if invincible_timer > 0.0:
		invincible_timer -= 1.0
	if clear_timer > 0.0:
		clear_timer -= 1.0
		bullet_clear_box_shape.shape.radius = clear_radius * (1.0 - clear_timer / clear_time)
		if clear_timer <= 0.0:
			bullet_clear_box.monitoring = false
			bullet_clear_box_shape.shape.radius = 0.0
	hit = false
	if lives < 0:
		game_over_timer -= 1
	if game_over_timer == 0:
		DefSys.pause_menu.game_over()
		game_over_timer = -1

func create_bullet_clear(bullet_id):
	var p = Bullets.get_property(bullet_id, "position")
	var s = Bullets.get_property(bullet_id, "scale")
	var c = Bullets.get_property(bullet_id, "fade_color")
	if !s: return
	Bullets.create_particle(bullet_clear_kit, p, s*0.75, c, Vector2(), false)
	Bullets.create_particle(bullet_clear_kit, p, -s*1.5, c, Vector2(), false)

func _on_area_shape_entered(area_id, _area, area_shape, _local_shape):
	if !hit:
		hit = true
		var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
		create_bullet_clear(bullet_id)
		call_deferred("remove_bullet", bullet_id)

func _on_itemcollection_area_shape_entered(area_id, _area, area_shape, _local_shape):
	DefSys.sfx.play("item")
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	match Bullets.get_property(bullet_id, "damage_type"):
		DefSys.ITEM_TYPE.POINT:
# warning-ignore:integer_division
			var max_value = DefSys.piv + (DefSys.graze / 10) * 10
			var p = Bullets.get_property(bullet_id, "position")
			var value = max_value
			if !Bullets.get_property(bullet_id, "fading"):
				value *= min(1.0, 1.0 - (min(p.y, position.y) - 350.0) / 1300.0)
			DefSys.score += value
			var c = Color(value, 0, 1 if value == max_value else 0, 0)
			Bullets.create_particle(item_text_kit, p, 16, c, Vector2(0, -0.1), true)
		DefSys.ITEM_TYPE.PIV:
			DefSys.piv += 10
		DefSys.ITEM_TYPE.LIFE:
			lives += 1
			if lives > 6: lives = 6
			DefSys.health_bar.animate_face(false, lives)
			DefSys.sfx.play("extend")
			
	call_deferred("remove_item", bullet_id)

func _on_itempoc_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	Bullets.set_property(bullet_id, "grazed", true)
	Bullets.set_property(bullet_id, "fading", true)
	Bullets.set_magnet_target(bullet_id, self)
	
func remove_bullets(bullet_ids):
	for bullet_id in bullet_ids:
		Bullets.delete(bullet_id)
	
func remove_bullet(bullet_id):
	Bullets.delete(bullet_id)

func remove_item(bullet_id):
	Bullets.delete(bullet_id)


func _on_grazebox_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	Bullets.set_property(bullet_id, "grazed", true)
	DefSys.graze += 1
	DefSys.sfx.play("graze")
	Bullets.create_particle(graze_partlcle_kit, position, rand_range(12,18), Color(1.0, 1.0, 1.0, 1.0), Vector2(rand_range(0.3, 0.6), 0.0).rotated(randf()*TAU), false)

func _on_itembox_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	Bullets.set_property(bullet_id, "grazed", true)
	Bullets.set_magnet_target(bullet_id, self)

func _on_bulletclearbox_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	create_bullet_clear(bullet_id)
	bullets_to_remove.append(bullet_id)
	#call_deferred("remove_bullet", bullet_id)


func _on_enemybox_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	hit = true


func _on_Turret_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	create_bullet_clear(bullet_id)
	call_deferred("remove_bullet", bullet_id)
	if turret_iframe_timer <= 0:
		turret_health -= 1
		turret_healthbar.value = float(turret_health) / turret_max_health[turret_power]
		turret_iframe_timer = turret_iframes
		if turret_health <= 0:
			destroy_turret()
