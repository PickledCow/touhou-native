extends Node2D

export(String, FILE, "*.txt") var dialogue_path

var dialogue_started := false
var dialogue_line := 0
var dialogue_timer := 0.0

var current_speaker := 4
var skippable := false

var root : Root

# character, skippable, decay, message
var dialogue = []



func load_dialogue():
	dialogue.clear()
	var f = File.new()
	f.open(dialogue_path, File.READ)
	while !f.eof_reached():
		var line = f.get_line()
		var dialogue_line = Array(line.split('|'))
		for i in 3:
			dialogue_line[i] = int(dialogue_line[i])
		dialogue.append(dialogue_line)

func _ready():
	load_dialogue()
	#dialogue_started = true
	#root = get_parent().root
	
func _process(delta):
	if dialogue_started:
		if dialogue_timer <= 0.0:
			if dialogue_line < len(dialogue):
				var d = dialogue[dialogue_line]
				dialogue_line += 1
				if current_speaker >= 4 and d[0] == 0:
					$AnimationPlayer.play("player")
					$MarisaCorner.show()
					$HakkeroCorner.hide()
					$Panel.show()
				elif current_speaker > 0 and d[0] == 0:
					$AnimationPlayer.play_backwards("ally")
					$MarisaCorner.show()
					$HakkeroCorner.hide()
				elif current_speaker == 0 and d[0] == 4:
					$AnimationPlayer.play_backwards("player")
					$MarisaCorner.hide()
					$HakkeroCorner.hide()
					$Panel.hide()
				elif current_speaker == 0 and d[0] == 3:
					$AnimationPlayer.play_backwards("player")
					$MarisaCorner.hide()
					$HakkeroCorner.hide()
				#	$Panel.hide()
				elif current_speaker == 0 and d[0] > 0:
					$AnimationPlayer.play("ally")
					$MarisaCorner.hide()
					$HakkeroCorner.show()
				
				current_speaker = d[0]
				skippable = d[1] == 1
				dialogue_timer = d[2]
				
				if current_speaker == 4:
					get_node("../AnimationPlayer").play("Entry")
				elif current_speaker == 5:
					get_node("../AnimationPlayer").play("Exit")
				
				$RichTextLabel.text = d[3]
			else:
				$AnimationPlayer.play_backwards("player")
				dialogue_started = false
				skippable = false
				$MarisaCorner.hide()
				$HakkeroCorner.hide()
				$Panel.hide()
				$RichTextLabel.hide()
				root.start_section(5)
				
		dialogue_timer -= delta
		
		if Input.is_action_just_pressed("shoot") and skippable:
			dialogue_timer = 0.0
