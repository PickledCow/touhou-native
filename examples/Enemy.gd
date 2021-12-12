extends Sprite

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

export(NodePath) var player_path
onready var player = get_node(player_path)

var t := 0
var dw := 0.0
var c := 0
var lr := 1

var density := 4

var data: PoolRealArray
var data2: PoolRealArray

func _ready():
	data = PoolRealArray()
	data.resize(10)
	data[0] = 64 * 6			# source x (integer) # (16+8*(c/4))
	data[1] = 64 * 3		# source y (integer) # (24+2*(c%4))
	data[2] = 64				# source width (integer)
	data[3] = 64				# source height (integer)
	data[4] = 32.0				# bullet size [0, inf)
	data[5] = 0.5				# hitbox ratio [0, 1]
	data[6] = 0					# Sprite offset y (integer)
	data[7] = 1					# anim frame, 1 for no animation (integer)
	data[8] = 0					# spin
	data[9] = 1
	
	data2 = PoolRealArray()
	data2.resize(10)
	data2[0] = 64 * 16			# source x (integer) # (16+8*(c/4))
	data2[1] = 64 * 2		# source y (integer) # (24+2*(c%4))
	data2[2] = 128			# source width (integer)
	data2[3] = 128				# source height (integer)
	data2[4] = 64.0				# bullet size [0, inf)
	data2[5] = 0.5				# hitbox ratio [0, 1]
	data2[6] = 0					# Sprite offset y (integer)
	data2[7] = 1					# anim frame, 1 for no animation (integer)
	data2[8] = 0					# spin
	data2[9] = 0

func _physics_process(delta):
	if t % 4 == 0 && t >= 120:
		lr *= -1
		var o : float = t*0.015+ PI * 0.5
		for i in density:
			var angle : float = o + i * TAU / density
			var speed = 3.0
			var bullet: PoolIntArray = Bullets.create_shot_a1(bullet_kit, position, speed, angle, data, true)
			Bullets.add_change_bullet(bullet, 0, 60, data2, true)
			#Bullets.set_bullet_property(bullet, "max_wvel", 0.1)
			#Bullets.set_bullet_property(bullet, "waccel", 0.0001)
		c = (c + 1) % 8
		
	if t % 12 == 120 && t >= 0:
		lr *= -1
		var o : float = t*0.015+ PI * 0.5
		for i in density:
			var angle : float = o + i * TAU / density
			var speed = 6.0
			var bullet: PoolIntArray = Bullets.create_shot_a1(bullet_kit, position, speed, angle, data, true)
			#Bullets.set_bullet_property(bullet, "scale", 128.0)
			#Bullets.add_transform(bullet, 0, 30, {"max_scale": 256.0, "scale_vel": 1.0})
			#Bullets.add_transform(bullet, 0, 30, {"layer": 8.0})
		c = (c + 1) % 8
	
	
	t += 1
	if Input.is_action_just_pressed("lessbullet"):
		density = max(density-10, 10)
	if Input.is_action_just_pressed("morebullet"):
		density = min(density+10, 1000)
		
