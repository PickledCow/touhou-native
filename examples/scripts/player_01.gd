extends Area2D

export(Resource) var bullet_clear_kit
export(Resource) var item_text_kit

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
	position.x = clamp(position.x, 60, 1000 - 60)
	position.y = clamp(position.y, 60, 1000 - 60)
	
	get_node("itempoc/CollisionShape2D").disabled = position.y > 300
	
	hit = false
	


func _on_area_shape_entered(area_id, _area, area_shape, _local_shape):
	if !hit:
		hit = true
		var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
		call_deferred("remove_bullet", bullet_id)

func _on_itemcollection_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	call_deferred("remove_item", bullet_id)

func _on_itempoc_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	Bullets.set_property(bullet_id, "grazed", true)
	Bullets.set_property(bullet_id, "fading", true)
	Bullets.set_magnet_target(bullet_id, self)
	
	
func remove_bullet(bullet_id):
	var p = Bullets.get_property(bullet_id, "position")
	var s = Bullets.get_property(bullet_id, "scale")
	var c = Bullets.get_property(bullet_id, "fade_color")
	Bullets.add_bullet_clear(bullet_clear_kit, p, s, c, false)
	Bullets.add_bullet_clear(bullet_clear_kit, p, -s*2, c, false)
	Bullets.release_bullet(bullet_id)

func remove_item(bullet_id):
	if Bullets.get_property(bullet_id, "damage_type") == 0:
		var max_value = 150000
		var p = Bullets.get_property(bullet_id, "position")
		var value = max_value
		if !Bullets.get_property(bullet_id, "fading"):
			value *= min(1.0, 1.0 - (min(p.y, position.y) - 350.0) / 1300.0)
		var c = Color(value, 0, 1 if value == max_value else 0, 0)
		Bullets.add_bullet_clear(item_text_kit, p, 16, c, true)
		
	Bullets.release_bullet(bullet_id)


func _on_grazebox_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	Bullets.set_property(bullet_id, "grazed", true)
	

func _on_itembox_area_shape_entered(area_id, _area, area_shape, _local_shape):
	var bullet_id = Bullets.get_bullet_from_shape(area_id, area_shape)
	Bullets.set_property(bullet_id, "grazed", true)
	Bullets.set_magnet_target(bullet_id, self)




