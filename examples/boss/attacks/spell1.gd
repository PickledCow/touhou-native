extends "res://examples/boss/attacks/attack.gd"

export(Resource) var bullet_kit
export(Resource) var bullet_kit_add

onready var Meteor := preload("res://examples/enemy/Boss/Meteor.tscn")

#var a := PI*0.5
var a2 := 0.0
var a3 := PI * 0.4
var lr := 1
var alt_col := true
var alt_col2 := false

var p : Vector2

var rate = [40, 36, 30, 25, 20]
var speed = [5.5, 6, 6.5, 7, 8]

func attack_init():
	pass

func attack(t):
	if t >= 0:
		if t % rate[difficulty] == 0:
			if (t % (20 * 60)) < (9 * 60):
				var v = Vector2(1, 1) * speed[difficulty]
				var parent = get_parent()
				DefSys.sfx.play("warning1")
				var meteor = Meteor.instance()
				meteor.position = Vector2(rand_range(-100, 1000), -100)
				meteor.velocity = v
				meteor.lr = -1.0
				parent.add_child(meteor)
				
				var meteor2 = Meteor.instance()
				meteor2.position = Vector2(-100, rand_range(-100, 1000))
				meteor2.velocity = v
				meteor.lr = -1.0
				parent.add_child(meteor2)
			elif (t % (20 * 60)) >= (10 * 60) and (t % (20 * 60)) < (19 * 60):
				var v = Vector2(-1, 1) * speed[difficulty]
				var parent = get_parent()
				DefSys.sfx.play("warning1")
				var meteor = Meteor.instance()
				meteor.position = Vector2(rand_range(0, 1100), -100)
				meteor.velocity = v
				parent.add_child(meteor)
				
				var meteor2 = Meteor.instance()
				meteor2.position = Vector2(1100, rand_range(0, 1100))
				meteor2.velocity = v
				parent.add_child(meteor2)
		if t % 150 == 0:
			set_boss_dest(Vector2(rand_range(300, 700), rand_range(250, 350)), 60)
