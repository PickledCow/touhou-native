extends Node
var sfx #: SFX_manager
var warp_effect #: Warp
var health_bar
var boss_bar
var markers
var background_controller
var playfield_root
var playfield
var pause_menu

var is_3d := true

var transluscent := true

# Global data
enum PLAYER_ID { REIMU, MARISA, SNIPER, ENGINEER }
var player_id: int = PLAYER_ID.MARISA

var spell_bonus := true
var score := 0
var piv := 1000
var graze := 0

var music_percent := 50.0
var sfx_percent := 40.0

var bg_scale := 80

var hacky_common_data := 0

var item_data := []
var bullet_data := []
var null_bullet_data

const playfield_size := Vector2(1000, 1000)

# for transparent titlebar 
var borderlessed := false
var fullscreen := false
var size_before_fullscreen := Vector2(1280, 720)
var position_before_fullscreen : Vector2

enum ITEM_TYPE { BIG_POWER, LIFE_FRAGMENT, LIFE, BOMB_FRAGMENT, BOMB, FULL_POWER, POWER, POINT, PIV }

# These are suggestions on how to access and create shot data, if another way works for you then go ahead

enum ATTACK_TYPE { NULL, NON, SPELL, TIMEOUT, PENULTIMATE, FINAL }

enum BULLET_TYPE {	STRAIGHT_LASER, ARROWHEAD, BALL_OUTLINE, BALL, RICE, KUNAI, ICE, AMULET, BULLET, BACTERIA, STAR, DROPLET, # 0 - 11
					POPCORN, RICE_SMALL, SNOWBALL, COIN, # 12 - 15
					STAR_LARGE, MENTOS, BUTTERFLY, KNIFE, JELLYBEAN, #16 - 20
					BUBBLE, #21
					HEART, ARROW, REST, ICE_LARGE, FIREBALL, # 22 - 26
					DIVINE_SPIRIT, # 27
					LASER, # 28
					LIGHTNING, # 29
					GEAR, # 30
					SAW, # 31
					GEAR_SMALL, # 32
					SAW_SMALL, # 33
					MONEY, # 34
					NOTE, # 35
}

const BULLET_SIZES := [  0.3, 0.3, 0.3, 0.3, 0.25, 0.25, 0.3, 0.28, 0.25, 0.25, 0.3, 0.2,
						 0.2, 0.15, 0.2, 0.3,
						 0.3, 0.4, 0.2, 0.1, 0.2,
						 0.25,
						 0.4, 0.05, 0.025, 0.4, 0.2,
						 0.25,
]

enum LAYERS { BUBBLE, LARGE_BULLETS = 2, SMALL_BULLETS = 5, TINY_BULLETS = 8 }

enum COLORS {GREY, RED_D, RED, PURPLE_D, PURPLE, BLUE_D, BLUE, CYAN_D, CYAN, TEAL_D, TEAL, GREEN, YELLOW_D, YELLOW, ORANGE, WHITE}
enum COLORS_LARGE {GREY, RED, PURPLE, BLUE, CYAN, GREEN, YELLOW, ORANGE}
enum COLORS_NOTE { RED, PURPLE, BLUE, YELLOW}
enum COLORS_DIVINE_SPIRIT {GREY, RED, PURPLE, BLUE, CYAN, GREEN, YELLOW, WHITE, ORANGE, RED_D, PURPLE_D, BLUE_D, CYAN_D, GREEN_D, YELLOW_D, GREY_D}
enum COLORS_SAW {NORMAL, BLOOD, BLOOD2}
enum COLORS_COIN {RED, PURPLE, BLUE, CYAN, GREEN, GOLD, SILVER, BRONZE}

const COLOR_RGB := [
	Vector3(0.75, 0.75, 0.75), # Grey
	Vector3(0.8, 0.25, 0.25), Vector3(0.9, 0.3, 0.3), # Red
	Vector3(0.8, 0.25, 0.8), Vector3(0.9, 0.3, 0.9),  # Purple
	Vector3(0.25, 0.25, 0.8), Vector3(0.3, 0.3, 0.9),  # Blue
	Vector3(0.25, 0.8, 0.8), Vector3(0.3, 0.9, 0.9),  # Cyan
	Vector3(0.25, 0.8, 0.52), Vector3(0.3, 0.9, 0.6),  # Teal
	Vector3(0.3, 0.9, 0.3),  # Green
	Vector3(0.8, 0.8, 0.25), Vector3(0.9, 0.9, 0.3),  # Yellow
	Vector3(0.9, 0.6, 0.3),  # Orange
	Vector3(0.85, 0.85, 0.85), # White
]

const LARGE_RGB := [
	Vector3(0.75, 0.75, 0.75), # Grey
	Vector3(0.9, 0.3, 0.3), # Red
	Vector3(0.9, 0.3, 0.9),  # Purple
	Vector3(0.3, 0.3, 0.9),  # Blue
	Vector3(0.3, 0.9, 0.9),  # Cyan
	Vector3(0.3, 0.9, 0.3),  # Green
	Vector3(0.9, 0.9, 0.3),  # Yellow
	Vector3(0.9, 0.6, 0.3),  # Orange
]
	
const COIN_RGB := [ 
	Vector3(0.8, 0.25, 0.25), # Red
	Vector3(0.8, 0.25, 0.8), # Purple
	Vector3(0.25, 0.25, 0.8), # Blue
	Vector3(0.25, 0.8, 0.8), # Cyan
	Vector3(0.25, 0.8, 0.25),  # Green
	Vector3(0.9, 0.9, 0.3),  # Gold
	Vector3(0.8, 0.8, 0.8), # Silver
	Vector3(0.8, 0.52, 0.25),  # Bronze
]

const DIVINE_RGB := [ 
	Vector3(0.75, 0.75, 0.75),	# Grey
	Vector3(0.9, 0.3, 0.3),		# Red
	Vector3(0.9, 0.3, 0.9),		# Purple
	Vector3(0.3, 0.3, 0.9),		# Blue
	Vector3(0.3, 0.9, 0.9),		# Cyan
	Vector3(0.3, 0.9, 0.3),		# Green
	Vector3(0.9, 0.9, 0.3),		# Yellow
	Vector3(0.8, 0.8, 0.8),		# White
	Vector3(0.9, 0.6, 0.3),		# Orange
	Vector3(0.8, 0.25, 0.25),	# Red dark
	Vector3(0.8, 0.25, 0.8),	# Purple dark
	Vector3(0.25, 0.25, 0.8),	# Blue dark
	Vector3(0.25, 0.8, 0.8),	# Cyan dark
	Vector3(0.25, 0.8, 0.25),	# Green dark
	Vector3(0.8, 0.8, 0.25),	# Yellow dark
	Vector3(0.66, 0.66, 0.66),	# Grey dark
]

func generate_bullet_data():
	# Generate Bullet Data 
	
	# Null
	null_bullet_data = PoolRealArray()
	null_bullet_data.resize(15)
	null_bullet_data[7] = 1
	
	# Small bullets
	for i in BULLET_TYPE.POPCORN:
		var array := []
		for j in 16:
			var data := PoolRealArray()
			data.resize(15)
			data[0] = 64 * j			# source x (integer) # (16+8*(c/4))
			data[1] = 64 * i			# source y (integer) # (24+2*(c%4))
			data[2] = 64				# source width (integer)
			data[3] = 64				# source height (integer)
			data[4] = 32.0				# bullet size [0, inf)
			data[5] = BULLET_SIZES[i] 	# hitbox ratio [0, 1]
			data[6] = 0					# Sprite offset y (integer)
			data[7] = 1					# anim frame, 1 for no animation (integer)
			data[8] = 0					# spin
			data[9] = LAYERS.SMALL_BULLETS # layer
			data[10] = COLOR_RGB[j].x	# rgb
			data[11] = COLOR_RGB[j].y
			data[12] = COLOR_RGB[j].z
			data[13] = 0				# damage type
			data[14] = 0				# damage amount
			
			array.append(data)
		bullet_data.append(array)
	
	# Tiny bullets
	var tiny_offsets := [Vector2(0, 64 * 12), Vector2(32 * 8, 64 * 12), Vector2(0, 64 * 15)]
	for i in range(BULLET_TYPE.POPCORN, BULLET_TYPE.COIN):
		var array := []
		for j in 16:
			var data := PoolRealArray()
			data.resize(15)
			data[0] = tiny_offsets[i - BULLET_TYPE.POPCORN].x + 32 * (j % 8) # source x (integer)
			data[1] = tiny_offsets[i - BULLET_TYPE.POPCORN].y + 32 * (j / 8) # source y (integer)
			data[2] = 32				# source width (integer)
			data[3] = 32				# source height (integer)
			data[4] = 16.0				# bullet size [0, inf)
			data[5] = BULLET_SIZES[i] 	# hitbox ratio [0, 1]
			data[6] = 0					# Sprite offset y (integer)
			data[7] = 1					# anim frame, 1 for no animation (integer)
			data[8] = 0					# spin
			data[9] = LAYERS.TINY_BULLETS # layer
			data[10] = COLOR_RGB[j].x	# rgb
			data[11] = COLOR_RGB[j].y
			data[12] = COLOR_RGB[j].z
			data[13] = 0				# damage type
			data[14] = 0				# damage amount
			
			array.append(data)
		bullet_data.append(array)

	# Coin
	if true: # Local scoping
		var array := []
		for j in 8:
			var data := PoolRealArray()
			data.resize(15)
			data[0] = 64 * (8 + j) # source x (integer)
			data[1] = 64 * 12 # source y (integer)
			data[2] = 64				# source width (integer)
			data[3] = 64				# source height (integer)
			data[4] = 32.0				# bullet size [0, inf)
			data[5] = BULLET_SIZES[BULLET_TYPE.COIN] # hitbox ratio [0, 1]
			data[6] = 0					# Sprite offset y (integer)
			data[7] = 1					# anim frame, 1 for no animation (integer)
			data[8] = 0					# spin
			data[9] = LAYERS.SMALL_BULLETS	# layer
			data[10] = COIN_RGB[j].x	# rgb
			data[11] = COIN_RGB[j].y
			data[12] = COIN_RGB[j].z
			data[13] = 0				# damage type
			data[14] = 0				# damage amount
			
			array.append(data)
		bullet_data.append(array)
	
	# Large bullets
	for i in range(BULLET_TYPE.STAR_LARGE, BULLET_TYPE.BUBBLE):
		var array := []
		for j in 8:
			var data := PoolRealArray()
			data.resize(15)
			data[0] = 64 * 16 + 128 * j	# source x (integer) # (16+8*(c/4))
			data[1] = 128 * (i - BULLET_TYPE.STAR_LARGE) # source y (integer) # (24+2*(c%4))
			data[2] = 128				# source width (integer)
			data[3] = 128				# source height (integer)
			data[4] = 64.0				# bullet size [0, inf)
			data[5] = BULLET_SIZES[i] 	# hitbox ratio [0, 1]
			data[6] = 0	if i != BULLET_TYPE.KNIFE else 16 # Sprite offset y (integer) 18 normally test 16
			data[7] = 1					# anim frame, 1 for no animation (integer)
			data[8] = 0					# spin
			data[9] = LAYERS.LARGE_BULLETS	# layer
			data[10] = LARGE_RGB[j].x	# rgb
			data[11] = LARGE_RGB[j].y
			data[12] = LARGE_RGB[j].z
			data[13] = 0				# damage type
			data[14] = 0				# damage amount
			
			array.append(data)
		bullet_data.append(array)

	# Bubble
	var bubble_offsets := [ Vector2(0, 64 * 16), Vector2(0, 64 * 16 + 256), Vector2(256, 64 * 16), Vector2(256, 64 * 16 + 256),
							Vector2(256*2, 64 * 16), Vector2(256*2, 64 * 16 + 256), Vector2(256*3, 64 * 16 + 256), Vector2(256*3, 64 * 16)
	]
	if true: # Local scoping
		var array := []
		for j in 8:
			var data := PoolRealArray()
			data.resize(15)
			data[0] = bubble_offsets[j].x # source x (integer)
			data[1] = bubble_offsets[j].y # source y (integer)
			data[2] = 256				# source width (integer)
			data[3] = 256				# source height (integer)
			data[4] = 128.0				# bullet size [0, inf)
			data[5] = BULLET_SIZES[BULLET_TYPE.BUBBLE] # hitbox ratio [0, 1]
			data[6] = 0					# Sprite offset y (integer)
			data[7] = 1					# anim frame, 1 for no animation (integer)
			data[8] = 2.39996322972865332# spin
			data[9] = LAYERS.BUBBLE		# layer
			data[10] = LARGE_RGB[j].x	# rgb
			data[11] = LARGE_RGB[j].y
			data[12] = LARGE_RGB[j].z
			data[13] = 0				# damage type
			data[14] = 0				# damage amount
			
			array.append(data)
		bullet_data.append(array)

	# Large bullets 2
	for i in range(BULLET_TYPE.HEART, BULLET_TYPE.FIREBALL):
		var array := []
		for j in 8:
			var data := PoolRealArray()
			data.resize(15)
			data[0] = 64 * 16 + 128 * j	# source x (integer) # (16+8*(c/4))
			data[1] = 128 * (i - BULLET_TYPE.HEART + 8) # source y (integer) # (24+2*(c%4))
			data[2] = 128				# source width (integer)
			data[3] = 128				# source height (integer)
			data[4] = 64.0				# bullet size [0, inf)
			data[5] = BULLET_SIZES[i] 	# hitbox ratio [0, 1]
			data[6] = 0 if i != BULLET_TYPE.ARROW else 37 # Sprite offset y (integer)
			data[7] = 1					# anim frame, 1 for no animation (integer)
			data[8] = 0					# spin
			data[9] = LAYERS.LARGE_BULLETS	# layer
			data[10] = LARGE_RGB[j].x	# rgb
			data[11] = LARGE_RGB[j].y
			data[12] = LARGE_RGB[j].z
			data[13] = 0				# damage type
			data[14] = 0				# damage amount
			
			array.append(data)
		bullet_data.append(array)

	# Fireball
	var fireball_offsets := [ Vector2(64 * 16 + 128 * 4, 128 * 15), Vector2(64 * 16, 128 * 12), Vector2(64 * 16 + 128 * 4, 128 * 12),  Vector2(64 * 16, 128 * 13), 
							  Vector2(64 * 16, 128 * 14), Vector2(64 * 16 + 128 * 4, 128 * 14), Vector2(64 * 16, 128 * 15), Vector2(64 * 16 + 128*4, 128 * 13), ]
	if true: # Local scoping
		var array := []
		for j in 8:
			var data := PoolRealArray()
			data.resize(15)
			data[0] = fireball_offsets[j].x # source x (integer)
			data[1] = fireball_offsets[j].y # source y (integer)
			data[2] = 128				# source width (integer)
			data[3] = 128				# source height (integer)
			data[4] = 64.0				# bullet size [0, inf)
			data[5] = BULLET_SIZES[BULLET_TYPE.FIREBALL] # hitbox ratio [0, 1]
			data[6] = 8					# Sprite offset y (integer)
			data[7] = 4					# anim frame, 1 for no animation (integer)
			data[8] = 0					# spin
			data[9] = LAYERS.LARGE_BULLETS	# layer
			data[10] = LARGE_RGB[j].x	# rgb
			data[11] = LARGE_RGB[j].y
			data[12] = LARGE_RGB[j].z
			data[13] = 0				# damage type
			data[14] = 0				# damage amount
			
			array.append(data)
		bullet_data.append(array)
	
	# Divine Spirit
	#{GREY, RED, PURPLE, BLUE, CYAN, GREEN, YELLOW, WHITE, ORANGE, RED_D, PURPLE_D, BLUE_D, CYAN_D, GREEN_D, YELLOW_D, GREY_D}
# warning-ignore:unused_variable
	var divine_offsets := [ Vector2(0, 1536), Vector2(256, 1536), Vector2(256 * 2, 1536), Vector2(256 * 3, 1536),
							Vector2(0, 1536 + 256), Vector2(256, 1536 + 256), Vector2(0, 1536 + 256), 
	]
	if true: # Local scoping
		var array := []
		for j in 16:
			var data := PoolRealArray()
			data.resize(15)
			data[0] = 256 * (j % 4) 		# source x (integer)
			data[1] = 1536 + 256 * (j / 4) 	# source y (integer)
			data[2] = 256				# source width (integer)
			data[3] = 256				# source height (integer)
			data[4] = 128.0				# bullet size [0, inf)
			data[5] = BULLET_SIZES[BULLET_TYPE.DIVINE_SPIRIT] # hitbox ratio [0, 1]
			data[6] = 0					# Sprite offset y (integer)
			data[7] = 1					# anim frame, 1 for no animation (integer)
			data[8] = 0					# spin
			data[9] = LAYERS.LARGE_BULLETS	# layer
			data[10] = DIVINE_RGB[j].x	# rgb
			data[11] = DIVINE_RGB[j].y
			data[12] = DIVINE_RGB[j].z
			data[13] = 0				# damage type
			data[14] = 0				# damage amount
			
			array.append(data)
		bullet_data.append(array)
	
	
	
	# Generate item data
	
	# Large items
	for i in 6:
		var array = PoolRealArray()
		array.resize(11)
		array[0] = 128 * i			# source x (integer) # (16+8*(c/4))
		array[1] = 0		# source y (integer) # (24+2*(c%4))
		array[2] = 128				# source width (integer)
		array[3] = 128				# source height (integer)
		array[4] = 96.0				# bullet size [0, inf)
		array[5] = 1.0				# hitbox ratio [0, 1]
		array[6] = 0					# Sprite offset y (integer)
		array[7] = 0					# anim frame, 1 for no animation (integer)
		array[8] = 0					# layer
		array[9] = i					# type
		array[10] = 0					# value
		item_data.append(array)
		
	# Small items
	for i in 3:
		var array = PoolRealArray()
		array.resize(11)
		array[0] = 128 * 6 + 64 * i			# source x (integer) # (16+8*(c/4))
		array[1] = 0		# source y (integer) # (24+2*(c%4))
		array[2] = 64				# source width (integer)
		array[3] = 64				# source height (integer)
		array[4] = 32.0				# bullet size [0, inf)
		array[5] = 1.0				# hitbox ratio [0, 1]
		array[6] = 0					# Sprite offset y (integer)
		array[7] = 0					# anim frame, 1 for no animation (integer)
		array[8] = 0					# layer
		array[9] = 6+i					# type
		array[10] = 0					# value
		item_data.append(array)
	

func _ready():
	generate_bullet_data()
	change_volume(0.0, false)
	change_volume(0.0, true)

func reset():
	score = 0
	piv = 1000
	graze = 0

func get_bullet_data(type: int, color: int):
	return bullet_data[type][color]

func get_item_data(type: int):
	return item_data[type]

func change_volume(change: float, is_music: bool):
	if is_music:
		music_percent = clamp(music_percent + change, 0, 100)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(music_percent * 0.01))
	else:
		sfx_percent = clamp(sfx_percent + change, 0, 100)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_percent * 0.01))
