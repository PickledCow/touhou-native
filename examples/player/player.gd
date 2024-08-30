extends Area2D
class_name Player

export(Resource) var player_bullet_kit
export(Resource) var player_bullet_kit_add
export(Resource) var bullet_clear_kit
export(Resource) var item_text_kit
export(Resource) var graze_partlcle_kit

onready var pid : int = DefSys.player_id


# Movement
export(float, 0, 1000) var speed = 500.0
export(float, 0, 1000) var focus_speed = 200.0
var velocity := Vector2()
var external_velocity := Vector2()
enum HORIZONTAL_PRIORITY { LEFT, RIGHT }
var horizontal_priority = 0
enum VERTICAL_PRIORITY { UP, DOWN }
var vertical_priority = 0

# States
var is_focused := false
var auto_poc := false
var warpable := 0
enum ORIENTATION { UP, DOWN, LEFT, RIGHT}
var orientation : int = ORIENTATION.UP

# Vitals
var lives := 10
var hit := false
var dead := false
var invincible_time := 180.0
var invincible_timer := 0.0
var game_over_timer := 120

var hidden_invincible_timer := 0.0
var hidden_invincible_time := 120.0

# Bullet clear
var clear_time := 42.0
var clear_timer := 0.0
var clear_radius := 700.0

# Animation
var anim_timer := 0.0
var anim_time := 0.1
var anim_frame := 0
var facing := 1
onready var sprites = [$Sprite, $L_copy/Sprite, $R_copy/Sprite, $U_copy/Sprite, $D_copy/Sprite, $LU_copy/Sprite, $RU_copy/Sprite, $LD_copy/Sprite, $RD_copy/Sprite]

onready var bullet_clear_box = $bulletclearbox
onready var bullet_clear_box_shape = $bulletclearbox/CollisionShape2D
var bullets_to_remove = []

onready var hitboxes1 = [$focus, $L_copy/focus, $R_copy/focus, $U_copy/focus, $D_copy/focus, $LU_copy/focus, $RU_copy/focus, $LD_copy/focus, $RD_copy/focus]
onready var hitboxes2 = [$focus2, $L_copy/focus2, $R_copy/focus2, $U_copy/focus2, $D_copy/focus2, $LU_copy/focus2, $RU_copy/focus2, $LD_copy/focus2, $RD_copy/focus2]
onready var hitbox_anim = $focusanimation

# Shooting
enum PLAYER_BULLET_INDEX { REIMU_MAIN, REIMU_HOMING, MARISA_MAIN, MARISA_MISSILE }
var player_bullets = [ PoolRealArray([0, 0, 192, 192, 144, 0.25, 47, 1, 0, 0, 0, 0, 0, 0, 0]),
						PoolRealArray([128, 192, 128, 128, 96, 0.375, 0, 1, 0, 0, 0, 0, 0, 0, 0]),
						PoolRealArray([0, 192, 128, 128, 96, 0.375, 0, 1, 0, 0, 0, 0, 0, 0, 0]),
						PoolRealArray([128, 0, 192, 192, 128, 0.25, 52, 2, 0, 0, 0, 0, 0, 0, 0]) 
]
var custom_bullet := preload("res://examples/player/homing.tscn")

var option_prev_pos = [Vector2(), Vector2(), Vector2(), Vector2()]

var shooters_unfocus = []
var shooters_focus = []

var option_positions_unfocus = [Vector2()]
var option_positions_focus = [Vector2()]

var option_interp = 0.0 # 0 unfocus 1 focus
var option_travel_speed = 0.15

onready var option_sprites = [	get_node("options/0"), get_node("options/1"), get_node("options/2"), get_node("options/3"),
								get_node("L_copy/options/0"), get_node("L_copy/options/1"), get_node("L_copy/options/2"), get_node("L_copy/options/3"), 
								get_node("R_copy/options/0"), get_node("R_copy/options/1"), get_node("R_copy/options/2"), get_node("R_copy/options/3"),
								get_node("U_copy/options/0"), get_node("U_copy/options/1"), get_node("U_copy/options/2"), get_node("U_copy/options/3"),
								get_node("D_copy/options/0"), get_node("D_copy/options/1"), get_node("D_copy/options/2"), get_node("D_copy/options/3"),
								get_node("LU_copy/options/0"), get_node("LU_copy/options/1"), get_node("LU_copy/options/2"), get_node("LU_copy/options/3"),
								get_node("RU_copy/options/0"), get_node("RU_copy/options/1"), get_node("RU_copy/options/2"), get_node("RU_copy/options/3"),
								get_node("LD_copy/options/0"), get_node("LD_copy/options/1"), get_node("LD_copy/options/2"), get_node("LD_copy/options/3"),
								get_node("RD_copy/options/0"), get_node("RD_copy/options/1"), get_node("RD_copy/options/2"), get_node("RD_copy/options/3"),
							]

class Shooter:
	var fire_rate = 3
	var start_delay = 0
	var fire_timer = 0
	
	var damage = 10
	var offset = Vector2(0,0)
	var angle = -PI/2
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
var names = ["Reimu", "Marisa"]

func _ready():
	var tex = load("res://examples/player/p"+str(pid)+"/pl.png")
	$Sprite.texture = tex
	for option in option_sprites:
		option.texture = tex
	
	var shot_data_file = File.new()
	shot_data_file.open("res://examples/player/p"+str(pid)+"/shot.json", File.READ)
	var shot_data = JSON.parse(shot_data_file.get_as_text()).result
	shot_data_file.close()
	
	for option in shot_data["option_pos"]["unfocused"]:
		option_positions_unfocus.append(Vector2(option["x"], option["y"]))
	for option in shot_data["option_pos"]["focused"]:
		option_positions_focus.append(Vector2(option["x"], option["y"]))
			
	for shooter_data in shot_data["shooters"]["unfocused"]:
		var shooter = create_shooter(shooter_data)
		shooters_unfocus.append(shooter)
	for shooter_data in shot_data["shooters"]["focused"]:
		var shooter = create_shooter(shooter_data)
		shooters_focus.append(shooter)
	
	speed = 10.0 if pid == 1 else 9.0
	DefSys.player = self
	call_deferred("after_ready")
	
func create_shooter(shooter_data):
	var shooter = Shooter.new()
	shooter.fire_rate = shooter_data["fire_rate"]
	shooter.start_delay = shooter_data["start_delay"]
	shooter.damage = shooter_data["damage"]
	shooter.option = shooter_data["option"]
	shooter.offset = Vector2(shooter_data["offset_x"], shooter_data["offset_y"])
	shooter.angle = shooter_data["angle"]
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
	#DefSys.health_bar.set_player_face(pid)
	#set_warp(true)


func set_hidden_invincibility():
	hidden_invincible_timer = hidden_invincible_time

func set_warp(enable: int):
	warpable = enable
	$L_copy.visible = enable > 0
	$R_copy.visible = enable > 0
	
	$U_copy.visible = enable == 2
	$D_copy.visible = enable == 2
	$LU_copy.visible = enable == 2
	$LD_copy.visible = enable == 2
	$RU_copy.visible = enable == 2
	$RD_copy.visible = enable == 2

func set_orientation(new_orientation: int):
	#print(orientation)
	match orientation:
		ORIENTATION.UP:
			match new_orientation:
				ORIENTATION.LEFT:
					$rotate.play("u2l")
				ORIENTATION.RIGHT:
					$rotate.play("u2r")
				ORIENTATION.DOWN:
					$rotate.play("u2d")
		ORIENTATION.LEFT:
			match new_orientation:
				ORIENTATION.UP:
					$rotate.play_backwards("u2l")
				ORIENTATION.RIGHT:
					$rotate.play("l2r")
				ORIENTATION.DOWN:
					$rotate.play_backwards("d2l")
		ORIENTATION.RIGHT:
			match new_orientation:
				ORIENTATION.UP:
					$rotate.play_backwards("u2r")
				ORIENTATION.LEFT:
					$rotate.play_backwards("l2r")
				ORIENTATION.DOWN:
					$rotate.play_backwards("d2r")
		ORIENTATION.DOWN:
			match new_orientation:
				ORIENTATION.LEFT:
					$rotate.play("d2l")
				ORIENTATION.RIGHT:
					$rotate.play("d2r")
				ORIENTATION.UP:
					$rotate.play_backwards("u2d")
	orientation = new_orientation

func _process(delta):
	#var last_position = position
	for hitbox1 in hitboxes1:
		hitbox1.rotation += 2.0 * delta
	for hitbox2 in hitboxes2:
		hitbox2.rotation -= 2.0 * delta
	
	if Input.is_action_just_pressed("focus"):
		hitbox_anim.stop()
		hitbox_anim.play("focus")
	elif !Input.is_action_pressed("focus"):
		for hitbox1 in hitboxes1:
			hitbox1.visible = false
		for hitbox2 in hitboxes2:
			hitbox2.visible = false
	
	anim_timer += delta
	if anim_timer >= anim_time:
		anim_frame += 1
		anim_timer -= anim_time	
	if anim_frame >= 120:
		anim_frame -= 120
	
	for sprite in sprites:
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

func move(delta):
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
	
	if(velocity.length() > 0):
		velocity = velocity.normalized() * (focus_speed if is_focused else speed)
	
	position += (velocity + external_velocity) * delta * 60.0
	
	if warpable > 0:
		if position.x > 1000.0:
			position.x -= 1000.0
		elif position.x < 0.0:
			position.x += 1000.0
			
		if warpable == 2:
			if position.y > 1000.0:
				position.y -= 1000.0
			elif position.y < 0.0:
				position.y += 1000.0
		else:
			position.y = clamp(position.y, 24, 1000 - 24)
	else:
		position.x = clamp(position.x, 24, 1000 - 24)
		position.y = clamp(position.y, 24, 1000 - 24)
		
	
	get_node("itempoc/CollisionShape2D").disabled = position.y > 400 && !auto_poc
	
	#print(external_velocity)
	
	external_velocity += external_velocity * delta * -10.0
	if external_velocity.length_squared() < 1.0:
		external_velocity = Vector2(0,0)

#var t = 0

func shoot(delta):
	if Input.is_action_just_pressed("shoot"):
		for s in shooters_focus:
			s.fire_timer = s.fire_rate + s.start_delay
		for s in shooters_unfocus:
			s.fire_timer = s.fire_rate + s.start_delay
			
	if Input.is_action_pressed("shoot"):
		var shooters = shooters_focus if is_focused else shooters_unfocus
		for s in shooters:
			s.fire_timer -= 1 * delta * 60.0
			while s.fire_timer <= 0:
				s.fire_timer += s.fire_rate
				DefSys.sfx.play(shoot_sfx[s.sfx])
				var option_pos = option_positions_unfocus[s.option] * (1 - option_interp) + option_positions_focus[s.option] * option_interp
				var p = position + (s.offset + option_pos).rotated($Sprite.rotation)
				
				if warpable:
					if p.x > 1000.0:
						p.x -= 1000.0
					elif p.x < 0.0:
						p.x += 1000.0
				
				
				var bullet_data = player_bullets[s.sprite]
				if s.homing_strength == 0.0 or true:
					var bullet = Bullets.create_shot_a2(s.kit, p, s.speed, s.angle + $Sprite.rotation, s.accel, s.max_speed, bullet_data, false)
					Bullets.set_bullet_properties(bullet, {"damage": s.damage})
					if warpable > 0:
						bullet = Bullets.create_shot_a2(s.kit, p + Vector2(1000.0, 0.0), s.speed, s.angle, s.accel, s.max_speed, bullet_data, false)
						Bullets.set_bullet_properties(bullet, {"damage": s.damage})
						bullet = Bullets.create_shot_a2(s.kit, p - Vector2(1000.0, 0.0), s.speed, s.angle, s.accel, s.max_speed, bullet_data, false)
						Bullets.set_bullet_properties(bullet, {"damage": s.damage})
						
						if warpable == 2:
							bullet = Bullets.create_shot_a2(s.kit, p + Vector2(0.0, 1000.0), s.speed, s.angle, s.accel, s.max_speed, bullet_data, false)
							Bullets.set_bullet_properties(bullet, {"damage": s.damage})
							bullet = Bullets.create_shot_a2(s.kit, p + Vector2(1000.0, 1000.0), s.speed, s.angle, s.accel, s.max_speed, bullet_data, false)
							Bullets.set_bullet_properties(bullet, {"damage": s.damage})
							bullet = Bullets.create_shot_a2(s.kit, p + Vector2(-1000.0, 1000.0), s.speed, s.angle, s.accel, s.max_speed, bullet_data, false)
							Bullets.set_bullet_properties(bullet, {"damage": s.damage})
				else:
					var bullet = Bullets.create_shot_a1(s.kit, p, 0.0, s.angle, bullet_data, false)
					Bullets.set_bullet_properties(bullet, {"damage": s.damage})
					var cb = custom_bullet.instance()
					cb.position = p
					cb.rotation = s.angle
					cb.bullet = bullet
					cb.speed = s.speed
					cb.homing_strength = s.homing_strength
					DefSys.playfield.add_child(cb)

func _physics_process(delta):
	remove_bullets(bullets_to_remove)
	bullets_to_remove.clear()
	
	if lives >= 0:
		move(delta)
		
		if is_focused && option_interp < 1.0:
			option_interp += option_travel_speed * delta * 60.0
			if option_interp > 1.0:
				option_interp = 1.0
		elif !is_focused && option_interp > 0.0:
			option_interp -= option_travel_speed * delta * 60.0
			if option_interp < 0.0:
				option_interp = 0.0
		for i in 4:
			option_sprites[i].position = option_positions_unfocus[i+1] * (1 - option_interp) + option_positions_focus[i+1] * option_interp
			
			option_sprites[i+4].position = option_positions_unfocus[i+1] * (1 - option_interp) + option_positions_focus[i+1] * option_interp
			option_sprites[i+8].position = option_positions_unfocus[i+1] * (1 - option_interp) + option_positions_focus[i+1] * option_interp
			
			
			option_sprites[i+12].position = option_positions_unfocus[i+1] * (1 - option_interp) + option_positions_focus[i+1] * option_interp
			option_sprites[i+16].position = option_positions_unfocus[i+1] * (1 - option_interp) + option_positions_focus[i+1] * option_interp
			option_sprites[i+20].position = option_positions_unfocus[i+1] * (1 - option_interp) + option_positions_focus[i+1] * option_interp
			option_sprites[i+24].position = option_positions_unfocus[i+1] * (1 - option_interp) + option_positions_focus[i+1] * option_interp
			option_sprites[i+28].position = option_positions_unfocus[i+1] * (1 - option_interp) + option_positions_focus[i+1] * option_interp
			option_sprites[i+32].position = option_positions_unfocus[i+1] * (1 - option_interp) + option_positions_focus[i+1] * option_interp
		
		shoot(delta)
	
	if $enemybox.get_overlapping_areas():
		hit = true
	
	if hit && invincible_timer <= 0.0 and hidden_invincible_timer <= 0.0:
		DefSys.spell_bonus = false
		DefSys.sfx.play("death")
		DefSys.boss_bar.fail_spell()
		bullet_clear_box.monitoring = true
		lives -= 1
		if lives == 2:
			DefSys.sfx.play("lowhealth")
		#emit_signal("hit", lives)
		#DefSys.health_bar.animate_face(true, lives)
		invincible_timer = invincible_time
		DefSys.warp_effect.warp(position, true)
		clear_timer = clear_time
		if lives < 1:
			lives = 1
			#hide()
	if hidden_invincible_timer > 0.0:
		hidden_invincible_timer -= delta * 60.0
	if invincible_timer > 0.0:
		invincible_timer -= 1.0 * delta * 60.0
	if clear_timer > 0.0:
		clear_timer -= 1.0 * delta * 60.0
		bullet_clear_box_shape.shape.radius = clear_radius * (1.0 - clear_timer / clear_time)
		if clear_timer <= 0.0:
			bullet_clear_box.monitoring = false
			bullet_clear_box_shape.shape.radius = 0.0
	hit = false
	if lives < 0:
		game_over_timer -= 1 * delta * 60.0
	if game_over_timer <= 0:
		DefSys.pause_menu.game_over()
		game_over_timer = -1 * delta * 60.0

func create_bullet_clear(bullet_id):
	var p = Bullets.get_property(bullet_id, "position")
	var s = Bullets.get_property(bullet_id, "scale")
	var c = Bullets.get_property(bullet_id, "fade_color")
	if !s: return
	Bullets.create_particle(bullet_clear_kit, p, s*0.75, c, Vector2(), false)
	Bullets.create_particle(bullet_clear_kit, p, -s*1.5, c, Vector2(), false)
	#Bullets.create_particle(graze_partlcle_kit, position, rand_range(12,18), Color(1.0, 1.0, 1.0, 1.0), Vector2(rand_range(0.3, 0.6), 0.0).rotated(randf()*TAU), false)


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
			if lives > 10: lives = 10
		#	DefSys.health_bar.animatze_face(false, lives)
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
	DefSys.sfx.play("graze")
	return
	# Hmm
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	Bullets.set_property(bullet_id, "grazed", true)
	DefSys.graze += 1
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
