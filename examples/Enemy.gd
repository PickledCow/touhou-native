extends Sprite

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

export(NodePath) var player_path
onready var player = get_node(player_path)

var t := 0
var dw := 0.0
var c := 0
var lr := 1

var density := 30

var data: PoolRealArray
var data2: PoolRealArray

func _ready():
	print("angle".hash())
	
	data = PoolRealArray()
	data.resize(10)
	data[0] = 64 * 6			# source x (integer) # (16+8*(c/4))
	data[1] = 64 * 4		# source y (integer) # (24+2*(c%4))
	data[2] = 64				# source width (integer)
	data[3] = 64				# source height (integer)
	data[4] = 32.0				# bullet size [0, inf)
	data[5] = 0.5				# hitbox ratio [0, 1]
	data[6] = 0					# Sprite offset y (integer)
	data[7] = 1					# anim frame, 1 for no animation (integer)
	data[8] = 0					# spin
	data[9] = 0
	
	data2 = PoolRealArray()
	data2.resize(10)
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

func _physics_process(delta):
	if t % 30 == 0:
		lr *= -1
		var o : float = t*0.015+ PI * 0.5
		var bullets = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.POLYGON, position, 30.0, 3.0, o, 20, 6, data, true)
		#Bullets.add_transform_bulk(bullets, Constants.TRIGGER.TIME, 60, {"speed": 10.0})
		#var bullet = Bullets.create_shot_a1(bullet_kit, position, 2.0, 0.0, data, true)
		#Bullets.set_properties_bulk(bullets, {"speed": 10})
		#Bullets.add_aim_at_object_bulk(bullets, 0, 60, player)
		Bullets.add_change_bullet_bulk(bullets, 0, 60, data2, true)
		#Bullets.add_transform(bullet, Constants.TRIGGER.TIME, 60, {"speed": 10.0, "angle": PI*0.5})
		c = (c + 1) % 8
		
	
	t += 1
	if Input.is_action_just_pressed("lessbullet"):
		density = max(density-10, 10)
	if Input.is_action_just_pressed("morebullet"):
		density = min(density+10, 1000)
		
