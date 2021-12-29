extends Sprite

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add
export(Resource) var item_kit

export(NodePath) var player_path
onready var player = get_node(player_path)

var t := 0
var dw := 0.0
var c := 0
var lr := 1

var density := 30

var data: PoolRealArray
var data2: PoolRealArray

var item_data: PoolRealArray
var item_data2: PoolRealArray

func _ready():
	
	data = PoolRealArray()
	data.resize(15)
	data[0] = 64 * 0			# source x (integer) # (16+8*(c/4))
	data[1] = 64 * 0		# source y (integer) # (24+2*(c%4))
	data[2] = 64				# source width (integer)
	data[3] = 64				# source height (integer)
	data[4] = 32.0				# bullet size [0, inf)
	data[5] = 0.15				# hitbox ratio [0, 1]
	data[6] = 0					# Sprite offset y (integer)
	data[7] = 1					# anim frame, 1 for no animation (integer)
	data[8] = 0					# spin
	data[9] = 0					# layer
	data[10] = 0.3				# rgb
	data[11] = 0.3
	data[12] = 0.9
	data[13] = 0
	data[14] = 0
	
	data2 = PoolRealArray()
	data2.resize(15)
	data2[0] = 64 * 6			# source x (integer) # (16+8*(c/4))
	data2[1] = 64 * 3		# source y (integer) # (24+2*(c%4))
	data2[2] = 64			# source width (integer)
	data2[3] = 64				# source height (integer)
	data2[4] = 32.0				# bullet size [0, inf)
	data2[5] = 0.5				# hitbox ratio [0, 1]
	data2[6] = 0					# Sprite offset y (integer)
	data2[7] = 1					# anim frame, 1 for no animation (integer)
	data2[8] = 0					# spin
	data2[9] = 0
	data[10] = 0
	data[10] = 0.2				# rgb
	data[11] = 0.2
	data[12] = 0.9
	data[13] = 0
	data[14] = 0
	
	
	item_data = PoolRealArray()
	item_data.resize(11)
	item_data[0] = 128 * 4			# source x (integer) # (16+8*(c/4))
	item_data[1] = 128 * 0		# source y (integer) # (24+2*(c%4))
	item_data[2] = 128				# source width (integer)
	item_data[3] = 128				# source height (integer)
	item_data[4] = 64.0				# bullet size [0, inf)
	item_data[5] = 1.0				# hitbox ratio [0, 1]
	item_data[6] = 0					# Sprite offset y (integer)
	item_data[7] = 0					# anim frame, 1 for no animation (integer)
	item_data[8] = 0					# layer
	item_data[9] = 1					# type
	item_data[10] = 1					# value
	
	item_data2 = PoolRealArray()
	item_data2.resize(11)
	item_data2[0] = 64 * 13			# source x (integer) # (16+8*(c/4))
	item_data2[1] = 64 * 0		# source y (integer) # (24+2*(c%4))
	item_data2[2] = 64				# source width (integer)
	item_data2[3] = 64				# source height (integer)
	item_data2[4] = 32.0				# bullet size [0, inf)
	item_data2[5] = 1.0				# hitbox ratio [0, 1]
	item_data2[6] = 0					# Sprite offset y (integer)
	item_data2[7] = 1					# anim frame, 1 for no animation (integer)
	item_data2[8] = 1					# layer
	item_data2[9] = 0					# type
	item_data2[10] = 0					# value

func _physics_process(delta):
	if t % 10 == 0 :
		lr *= -1
		var o : float = t*t*0.000015+ PI * 0.5
		#var bullets = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.POLYGON, position, 30.0, 3.0, o, 19, 5, data, true)
		#var bullets = Bullets.create_pattern_a2(bullet_kit, Constants.PATTERN_ADV.RING, position, 60.0, 60.0, 3.0, 6.0, randf()*TAU, 150, 1, PI*0.5, data, true)
		#for i in 1:
		var bullet = Bullets.create_shot_a1(bullet_kit, position, 3, TAU/4, data, false)
		for i in 20:
			#pass
			Bullets.create_item(item_kit, item_data2, position, rand_range(3, 6), randf()*TAU, (randi()%2-0.5)*2.0*0.5)
			#Bullets.create_item(item_kit, item_data2, Vector2(rand_range(0,1000), -300), 0*rand_range(3, 6), randf()*TAU, (randi()%2-1)*1)
		#Bullets.set_properties_bulk(bullets, {"wvel": 0.05})
		#item_kit.time_scale = 0.1
		#Bullets.add_transform_bulk(bullets, Constants.TRIGGER.TIME, 60, {"wvel": 0.0})
		#Bullets.add_aim_at_object_bulk(bullets, 0, 60, player)
		#Bullets.add_change_bullet_bulk(bullets, 0, 60, data2, true)
		#Bullets.add_multiply(bullet, Constants.TRIGGER.TIME, 60, {"speed": 10.0})
		c = (c + 1) % 8
		
	
	t += 1
	if Input.is_action_just_pressed("lessbullet"):
		density = max(density-10, 10)
	if Input.is_action_just_pressed("morebullet"):
		density = min(density+10, 1000)
		
