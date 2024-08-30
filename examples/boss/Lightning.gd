extends "res://examples/enemy/Enemy.gd"

var orange_ball : PoolRealArray
var yellow_ball : PoolRealArray
#var balls = [grey_ball, red_ball, orange_ball, yellow_ball]


var lr := 1.0
var air_detonated := true
var floor_detonated := false

var MENTOS_DENSITY = [3, 4, 5, 6, 7]
var BALL_DENSITY = [2, 3, 3, 4, 5]

var speed_low = [1.7, 1.8, 1.9, 2.0, 2.5]
var speed_mid = [2.25, 2.5, 2.8, 3.25, 3.75]
var speed_high = [3.6, 4.0, 4.5, 5.0, 6.0]

func custom_ready():
	death_delay = 120.0
	
	orange_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.ORANGE)
	yellow_ball = DefSys.get_bullet_data(DefSys.BULLET_TYPE.BALL, DefSys.COLORS.YELLOW)
	DefSys.sfx.play("charge1")

func _process(delta):
	$Sprite.rotation += PI * delta * lr

func custom_action(t):
	if t == 60:
		health = -10
	
func custom_death():
	DefSys.sfx.play("explosion1")
	pass
	
	$Sprite.hide()
	monitoring = false
	$Hurtbox.monitorable = false
#	$Particles2D.emitting = false
	#position = Vector2(-1000, -1000)


func _on_Hurtbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	queue_free()
