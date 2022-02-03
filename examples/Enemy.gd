extends Node2D

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add
export(Resource) var item_kit

export(NodePath) var player_path
onready var player = get_node(player_path)

var first_bullet 

var t := 0
var dw := 0.0
var c := 0
var lr := 1.0
var a := 0.0

var density := 50

var health := 10000.0
var max_health := 10000.0

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

var attack_prefabs := [ preload("res://examples/boss/attacks/non1.tscn"), 
						preload("res://examples/boss/attacks/non2.tscn"), 
]
var attacks := []
var phase := 0

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

func _physics_process(delta):
	if t == 0:
		var attack_types = []
		for i in range(len(attacks) - 1, -1, -1):
			attack_types.append(attacks[i].attack_type)
		DefSys.boss_bar.set_phase_icons(attack_types)
	DefSys.boss_bar.health = health
	if t == 350:
		DefSys.background_controller.flash()
	if t == 375:
		galacta.position = Vector2(500, 350)
		#remilia.position.y = 150
		add_child(attacks[0])
	if t > 1200:
		health -= 0
	if t >= 35:
		if false:
			var bullets = Bullets.create_pattern_a1(bullet_kit, Constants.PATTERN.RING, Vector2(500, 500), 0.0, 10.0, randf()*TAU, density, 0, data, true)
			if Input.is_action_just_pressed("debug2"):
				density -= 1
			if Input.is_action_just_pressed("debug3"):
				density += 1
			DefSys.hacky_common_data = density

	t += 1
	
	if galacta_travel_timer < galacta_travel_time:
		galacta_travel_timer += 1.0
		galacta.position = galacta_start_position + (galacta_target_position - galacta_start_position) * smooth_interp(min(1.0, galacta_travel_timer / galacta_travel_time))

	if remilia_travel_timer < remilia_travel_time:
		remilia_travel_timer += 1.0
		remilia.position = remilia_start_position + (remilia_target_position - remilia_start_position) * smooth_interp(min(1.0, remilia_travel_timer / remilia_travel_time))

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
	health -= Bullets.get_property(bullet_id, "damage")
	call_deferred("remove_bullet", bullet_id)

func remove_bullet(bullet_id):
	Bullets.delete(bullet_id)
