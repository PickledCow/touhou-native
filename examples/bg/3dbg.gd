extends Spatial

onready var anim_player = $AnimationPlayer

var phase := 0

const SUNSET_AMBIENT_LIGHT_COLOUR_START := Color('4d3800')
const SUNSET_AMBIENT_LIGHT_COLOUR_END := Color('00154d')
const SUNSET_SKY_TOP_COLOUR_START := Color('044781')
const SUNSET_SKY_TOP_COLOUR_END := Color('001528')
const SUNSET_SKY_HORIZON_COLOUR_START := Color('ff5418')
const SUNSET_SKY_HORIZON_COLOUR_END := Color('001528')
const SUNSET_GROUND_BOTTOM_COLOUR_START := Color('ffbab0')
const SUNSET_GROUND_BOTTOM_COLOUR_END := Color('9fc9ee')
const SUNSET_GROUND_HORIZON_COLOUR_START := Color('ff9081')
const SUNSET_GROUND_HORIZON_COLOUR_END := Color('9fc9ee')
const CLOUD_COLOUR_START := Color('ffffff')
const CLOUD_COLOUR_END := Color('46484d')
const CLOUD_TOP_SHADE_COLOUR_START := Color('ca8e7a')
const CLOUD_TOP_SHADE_COLOUR_END := Color('07011b')
const CLOUD_BOTTOM_SHADE_COLOUR_START := Color('ca8e7a')
const CLOUD_BOTTOM_SHADE_COLOUR_END := Color('07011b')

const SUN_LATITUDE_START := 5.0
const SUN_LATITUDE_END := -10.0
const LIGHT_ANGLE_START := -20.0
const LIGHT_ANGLE_END := 0.0
const LIGHT_ENERGY_START := 0.75
const LIGHT_ENERGY_END := 0.0

onready var we := $WorldEnvironment
onready var light := $Mount/DirectionalLight
onready var top_cloud := $Mount/CloudUp
onready var bottom_cloud := $Mount/CloudDown

# 0 to 3
var sunset_stage := 0
const SUNSET_MAX := 3

func _ready():
	pass
	#update_sunset()
	#anim_player.play("4")

func update_sunset():
	var l1 = clamp(float(sunset_stage) / float(SUNSET_MAX), 0.0, 1.0)
	var l2 = clamp(float(sunset_stage - 1.0) / float(SUNSET_MAX - 1.0), 0.0, 1.0)
	var l3 = clamp(float(sunset_stage) / float(SUNSET_MAX - 1.0), 0.0, 1.0)
	var l4 = clamp(float(sunset_stage - 1.0) / float(SUNSET_MAX - 1.75), 0.0, 1.0)
	
	var env : Environment = we.environment
	var sky : ProceduralSky = env.background_sky
	
	sky.sun_latitude = (1 - l1) * SUN_LATITUDE_START + l1 * SUN_LATITUDE_END
	light.rotation_degrees.x = (1 - l1) * LIGHT_ANGLE_START + l1 * LIGHT_ANGLE_END
	
	light.light_energy = (1 - l3) * LIGHT_ENERGY_START + l3 * LIGHT_ENERGY_END
	
	env.ambient_light_color = SUNSET_AMBIENT_LIGHT_COLOUR_START.linear_interpolate(SUNSET_AMBIENT_LIGHT_COLOUR_END, l2)
	sky.sky_top_color = SUNSET_SKY_TOP_COLOUR_START.linear_interpolate(SUNSET_SKY_TOP_COLOUR_END, l2)
	sky.sky_horizon_color = SUNSET_SKY_HORIZON_COLOUR_START.linear_interpolate(SUNSET_SKY_HORIZON_COLOUR_END, l2)
	sky.ground_bottom_color = SUNSET_GROUND_BOTTOM_COLOUR_START.linear_interpolate(SUNSET_GROUND_BOTTOM_COLOUR_END, l4)
	sky.ground_horizon_color = SUNSET_GROUND_HORIZON_COLOUR_START.linear_interpolate(SUNSET_GROUND_HORIZON_COLOUR_END, l4)
	
	top_cloud.cloud_color = CLOUD_COLOUR_START.linear_interpolate(CLOUD_COLOUR_END, l2)
	bottom_cloud.cloud_color = CLOUD_COLOUR_START.linear_interpolate(CLOUD_COLOUR_END, l2)
	
	top_cloud.shade_color = CLOUD_TOP_SHADE_COLOUR_START.linear_interpolate(CLOUD_TOP_SHADE_COLOUR_END, l2)
	bottom_cloud.shade_color = CLOUD_BOTTOM_SHADE_COLOUR_START.linear_interpolate(CLOUD_BOTTOM_SHADE_COLOUR_END, l2)
	
	top_cloud._regen_mesh( )
	bottom_cloud._regen_mesh( )

func _process(_delta):
	if Input.is_action_just_pressed("debug_plus"):
		sunset_stage += 1
		update_sunset()
	elif Input.is_action_just_pressed("debug_minus"):
		sunset_stage -= 1
		update_sunset()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name in [0]:
		var next_animation = str(int(anim_name) + 1)
		if anim_player.has_animation(next_animation):
			anim_player.play(next_animation)

func play_anim(id: int, t_start=0.0):
	phase = id
	$AnimationPlayer.play(str(id))
	if t_start > 0.0:
		$AnimationPlayer.seek(t_start, true)
