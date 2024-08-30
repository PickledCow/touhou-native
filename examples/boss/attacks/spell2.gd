extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

func interp(x: float) -> float:
	return 1.0 - (2.0 * x - 1.0) * (2.0 * x - 1.0)

enum PUMP {
	BOTTOM, LEFT, RIGHT
}

onready var set_1 = [$Bottom, $Left, $Right]
onready var set_2 = [$Bottom2, $Left2, $Right2]
onready var set_3 = [$Bottom3, $Left3, $Right3]

var starting_position_1 := Vector2()
var starting_position_2 := Vector2()
var starting_position_3 := Vector2()

var true_starting_positions = [Vector2(0, 2500), Vector2(-1500, 0), Vector2(2500, 0)]

var component = [Vector2(1, 0), Vector2(0, 1), Vector2	(0, 1)]
var component_inv = [Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]

var pump_direction_1 = PUMP.BOTTOM
var pump_direction_2 = PUMP.BOTTOM
var pump_direction_3 = PUMP.BOTTOM

const MOVE_AMOUNT := 1200.0
const PUMP_CYCLE := 300
const PUMP_DURATION := 120
const PUMP_STAGGER := 30

const Y_BIAS := 200.0

var l1_y := 0.0
var l2_y := 0.0
var r1_y := 0.0
var r2_y := 0.0

var a_l := 0.0
var a_r := 0.0
var s_l := 0.0
var s_r := 0.0

var lr := -1.0

var a := 0.0

var blue_ball : PoolRealArray
var blue_mentos : PoolRealArray

var OFFSET := 120.0


var DENSITY = [15, 24, 36, 42, 60]

func attack_init():
	blue_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.BLUE)
	blue_mentos = DefSys.get_bullet_data(DefSys.BULLET_TYPE.MENTOS, DefSys.COLORS_LARGE.BLUE)

func attack(t: int):
	if t >= 0:
		behaviour_2(t)

func behaviour_1(t: int):
	if t % PUMP_CYCLE == 0:
		var player_position := DefSys.player.position
		
		if player_position.y - Y_BIAS > player_position.x and player_position.y - Y_BIAS > 1000.0 - player_position.x:
			pump_direction_1 = PUMP.BOTTOM
		elif player_position.x > 1000.0 - player_position.x:
			pump_direction_1 = PUMP.RIGHT
		else:
			pump_direction_1 = PUMP.LEFT
		
		var comp : Vector2 = component[pump_direction_1]
		
		set_1[pump_direction_1].show()
		set_1[pump_direction_1].monitoring = true
		set_1[pump_direction_1].position = true_starting_positions[pump_direction_1] - position + Vector2(player_position.x * comp.x, player_position.y * comp.y)
		starting_position_1 = set_1[pump_direction_1].position
		
		DefSys.sfx.play("pump")
		
	elif t % PUMP_CYCLE == PUMP_STAGGER:
		var player_position := DefSys.player.position
		
		if player_position.y - Y_BIAS > player_position.x and player_position.y- Y_BIAS > 1000.0 - player_position.x:
			pump_direction_2 = PUMP.BOTTOM
		elif player_position.x > 1000.0 - player_position.x:
			pump_direction_2 = PUMP.RIGHT
		else:
			pump_direction_2 = PUMP.LEFT
		var comp : Vector2 = component[pump_direction_2]
		
		set_2[pump_direction_2].show()
		set_2[pump_direction_2].monitoring = true
		set_2[pump_direction_2].position = true_starting_positions[pump_direction_2] - position + Vector2(player_position.x * comp.x, player_position.y * comp.y)
		starting_position_2 = set_2[pump_direction_2].position
		DefSys.sfx.play("pump")
		
	elif t % PUMP_CYCLE == PUMP_STAGGER * 2:
		var player_position := DefSys.player.position
		
		if player_position.y - Y_BIAS > player_position.x and player_position.y- Y_BIAS > 1000.0 - player_position.x:
			pump_direction_3 = PUMP.BOTTOM
		elif player_position.x > 1000.0 - player_position.x:
			pump_direction_3 = PUMP.RIGHT
		else:
			pump_direction_3 = PUMP.LEFT
		var comp : Vector2 = component[pump_direction_3]
		
		set_3[pump_direction_3].show()
		set_3[pump_direction_3].monitoring = true
		set_3[pump_direction_3].position = true_starting_positions[pump_direction_3] - position + Vector2(player_position.x * comp.x, player_position.y * comp.y)
		starting_position_3 = set_3[pump_direction_3].position
		DefSys.sfx.play("pump")
		
	elif t % PUMP_CYCLE == PUMP_DURATION:
		set_1[pump_direction_1].hide()
		set_1[pump_direction_1].monitoring = false
			
	elif t % PUMP_CYCLE == PUMP_DURATION + PUMP_STAGGER:
		set_2[pump_direction_2].hide()
		set_2[pump_direction_2].monitoring = false
		
	elif t % PUMP_CYCLE == PUMP_DURATION + PUMP_STAGGER * 2:
		set_3[pump_direction_3].hide()
		set_3[pump_direction_3].monitoring = false


	if t % PUMP_CYCLE <= PUMP_DURATION:
		set_1[pump_direction_1].position = interp(float(t % PUMP_CYCLE) / float(PUMP_DURATION)) * MOVE_AMOUNT * component_inv[pump_direction_1] + starting_position_1
		
	if t % PUMP_CYCLE >= PUMP_STAGGER and t % PUMP_CYCLE <= PUMP_DURATION + PUMP_STAGGER:
		set_2[pump_direction_2].position = interp(float((t - PUMP_STAGGER) % PUMP_CYCLE) / float(PUMP_DURATION)) * MOVE_AMOUNT * component_inv[pump_direction_2] + starting_position_2

	if t % PUMP_CYCLE>= PUMP_STAGGER * 2 and t % PUMP_CYCLE <= PUMP_DURATION + PUMP_STAGGER * 2:
		set_3[pump_direction_3].position = interp(float((t - PUMP_STAGGER * 2) % PUMP_CYCLE) / float(PUMP_DURATION)) * MOVE_AMOUNT * component_inv[pump_direction_3] + starting_position_3


func behaviour_2(t: int):
	if t % 240 == 0:
		var player_position := DefSys.player.position
		var comp : Vector2 = component[PUMP.LEFT]
		
		player_position.y = 350#rand_range(350, 600)
		
		$Left.show()
		$Left.monitoring = true
		$Left.position = true_starting_positions[PUMP.LEFT] + Vector2(0.0, player_position.y) - position 
		l1_y = player_position.y
		
		DefSys.sfx.play("pump")
		
	if t % 240 == 30:
		var player_position := DefSys.player.position
		var comp : Vector2 = component[PUMP.RIGHT]
		
		player_position.y = 500#rand_range(350, 600)
		
		$Right2.show()
		$Right2.monitoring = true
		$Right2.position = true_starting_positions[PUMP.RIGHT] + Vector2(0.0, player_position.y) - position 
		r2_y = player_position.y
		
		DefSys.sfx.play("pump")
	
	if t % 240 == 120:
		var player_position := DefSys.player.position
		var comp : Vector2 = component[PUMP.RIGHT]
		
		player_position.y = 350 #rand_range(350, 600)
		
		$Right.show()
		$Right.monitoring = true
		$Right.position = true_starting_positions[PUMP.RIGHT] + Vector2(0.0, player_position.y) - position 
		r1_y = player_position.y
		
		DefSys.sfx.play("pump")
		
	if t % 240 == 150:
		var player_position := DefSys.player.position
		var comp : Vector2 = component[PUMP.LEFT]
		
		player_position.y = 500 #rand_range(350, 600)
		
		$Left2.show()
		$Left2.monitoring = true
		$Left2.position = true_starting_positions[PUMP.LEFT] + Vector2(0.0, player_position.y) - position 
		l2_y = player_position.y
		
		DefSys.sfx.play("pump")
	
	if t % 240 <= 100:
		var move := interp(float((t) % 240) / float(100)) * MOVE_AMOUNT
		$Left.position = Vector2(true_starting_positions[PUMP.LEFT].x + move, l1_y) - position
	if t % 240 >= 120 and t % 240 <= 220:
		var move := interp(float((t - 120) % 240) / float(100)) * MOVE_AMOUNT
		$Right.position = Vector2(true_starting_positions[PUMP.RIGHT].x - move, r1_y) - position
	
	
	if t % 240 <= 130 and t >= 30:
		var move := interp(float((t - 30) % 240) / float(100)) * MOVE_AMOUNT
		$Right2.position = Vector2(true_starting_positions[PUMP.RIGHT].x - move, r2_y) - position
	if t % 240 >= 150 or (t % 240 <= 10 and t >= 240):
		var move := interp(float((t - 150) % 240) / float(100)) * MOVE_AMOUNT
		$Left2.position = Vector2(true_starting_positions[PUMP.LEFT].x + move, l2_y) - position
	
	
	
	
	if t % 240 == 0:
		a_l = PI
		s_l = 10.0
	elif t % 240 == 120:
		a_r = 0.0
		s_r = 10.0
	
	for i in 0:
		Bullets.create_shot_a1(bullet_kit, position, rand_range(2.0, 4.0), randf()*TAU, blue_ball, true)
	if t % 60 == 0:
		DefSys.sfx.play("shoot1")
		a = randf()*TAU
		for i in 10:
			Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 64.0, 4.0 - i * 0.1, a - lr * i*0.0075, DENSITY[difficulty], 0.0, blue_ball, true)
		lr *= -1.0
		
	if t % 60 == 20:
		DefSys.sfx.play("shoot1")
		var i = 10.0
		Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, position, 64.0, 4.0 - i * 0.1, a - lr * i*0.0075, DENSITY[difficulty] / 2, 0.0, blue_mentos, true)
	
	if t % 480 == 30 and t > 480:
		var x := rand_range(350, 650)
		var y := rand_range(250, 325)
		set_boss_dest(Vector2(x, y), 60)
