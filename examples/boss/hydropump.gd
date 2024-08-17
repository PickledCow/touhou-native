extends Area2D

export var push_direction := Vector2(0, -1)

func interp(x: float) -> float:
	return (2.0 * x * x * x - 3.0 * x * x + 1.0) * 0.5 + 0.5

const MAX_STRENGTH := 5.0

const EXTENTS := 50.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Left.emitting = true
	$Right.emitting = true

func _physics_process(delta):
	if monitoring and false:
		for player in get_overlapping_areas():
			var dist := abs(player.position.y - position.y - get_parent().position.y) if push_direction.y == 0.0 else abs(player.position.x - position.x - get_parent().position.x)
			
			var push_strength := MAX_STRENGTH# * interp(clamp(dist / EXTENTS, 0.0, 1.0))
			
			var push := push_direction * push_strength
			
			
			player.external_velocity = push
			

func _on_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	var v : Vector2 = Bullets.get_bullet_property(bullet_id, "direction") * Bullets.get_bullet_property(bullet_id, "speed")
	v += push_direction * MAX_STRENGTH
	var s := v.length()
	var a := atan2(v.y, v.x)
	Bullets.set_bullet_properties(bullet_id, {"speed": s, "angle": a})
