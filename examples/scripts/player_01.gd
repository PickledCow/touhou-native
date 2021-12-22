extends Area2D

export(Resource) var bullet_clear_kit

export(float, 0, 1000) var speed = 500.0
export(float, 0, 1000) var focus_speed = 200.0

var hit := false

func _physics_process(delta):
	var velocity = Vector2()
	
	if(Input.is_action_pressed("ui_up")):
		velocity.y -= 1
	if(Input.is_action_pressed("ui_down")):
		velocity.y += 1
	if(Input.is_action_pressed("ui_left")):
		velocity.x -= 1
	if(Input.is_action_pressed("ui_right")):
		velocity.x += 1
	
	if(velocity.length() > 0):
		velocity = velocity.normalized() * (focus_speed if Input.is_action_pressed("focus") else speed)
	
	position += velocity * delta
	global_position.x = clamp(global_position.x, 12, get_viewport_rect().size.x - 12)
	global_position.y = clamp(global_position.y, 12, get_viewport_rect().size.y - 12)
	
	hit = false
	


func _on_area_shape_entered(area_id, _area, area_shape, _local_shape):
	if !hit:
		hit = true
		var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
		#var kit = Bullets.get_kit_from_bullet(bullet_id)
		#var bullet_hit = kit.data.hit_scene.instance()
		#add_child(bullet_hit)
		#bullet_hit.global_position = Bullets.get_bullet_property(bullet_id, "transform").get_origin()
		
		#Bullets.release_bullet(bullet_id)
		call_deferred("remove_bullet", bullet_id)

func remove_bullet(bullet_id):
	var p = Bullets.get_property(bullet_id, "position")
	var s = Bullets.get_property(bullet_id, "scale")
	var c = Bullets.get_property(bullet_id, "fade_color")
	#var xform = Transform2D(randf()*TAU, Vector2(0,0)).scaled(Vector2(s, abs(s)))
	#xform.origin = p
	#Bullets.spawn_bullet(bullet_clear_kit, { "transform": xform, "scale": s, "lifespan": 30, "lifetime": 0, "fade_color": c })
	Bullets.add_bullet_clear(bullet_clear_kit, p, s, c)
	Bullets.add_bullet_clear(bullet_clear_kit, p, -s*2, c)
	#var clear = Bullets.spawn_bullet(bullet_clear_kit, { "position": p, "scale": s, "lifespan": 60 })
	#var clear = Bullets.obtain_bullet(bullet_clear_kit)
	#Bullets.set_property(clear, "scale", 64)
	Bullets.release_bullet(bullet_id)
