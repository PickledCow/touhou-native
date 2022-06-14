extends Control

var selection := 0
var menu_lock := false

var is_settings_menu := false
var settings_menu_selection_heights := [350, 414, 526, 590, 702, 798]

var game_over_volume := 0.0
var game_over_volume_change_rate := 0.25

var is_game_over_menu := false

func _ready():
	var interp = float(DefSys.fullscreen)
	$SettingsMenu/Windowed.modulate = Color(1.0 - interp * 0.4, 1.0 - interp * 0.4, 1.0 - interp * 0.4)
	$SettingsMenu/Fullscreen.modulate = Color(0.6 + interp * 0.4, 0.6 + interp * 0.4, 0.6 + interp * 0.4)
	
	$SettingsMenu/MusicLevel.value = 10.0 + DefSys.music_percent * 0.01 * 90.0
	$SettingsMenu/MusicLevel/value.text = str(DefSys.music_percent) + "%"
	$SettingsMenu/MusicLevel.material.set_shader_param("progress", $SettingsMenu/MusicLevel.value / 100.0)
	$SettingsMenu/MusicLevel/value.rect_position.x = -46 + 5.4 * DefSys.music_percent
	
	$SettingsMenu/SFXLevel.value = 10.0 + DefSys.sfx_percent * 0.01 * 90.0
	$SettingsMenu/SFXLevel/value.text = str(DefSys.sfx_percent) + "%"
	$SettingsMenu/SFXLevel.material.set_shader_param("progress", $SettingsMenu/SFXLevel.value / 100.0)
	$SettingsMenu/SFXLevel/value.rect_position.x = -46 + 5.4 * DefSys.sfx_percent
	
	$SettingsMenu/BGLevel.value = 14.0 + (DefSys.bg_scale - 20) / (180.0) * 86.0
	$SettingsMenu/BGLevel/value.text = str(DefSys.bg_scale) + "%"
	$SettingsMenu/BGLevel.material.set_shader_param("progress", $SettingsMenu/BGLevel.value / 100.0)
	$SettingsMenu/BGLevel/value.rect_position.x = -23 + (495 + 23) * (DefSys.bg_scale - 20) / (180.0)
	#DefSys.background_controller.change_scale(DefSys.bg_scale)
	
	hide()
	DefSys.pause_menu = self
	get_tree().paused = false

func set_fullscreen(fs: bool) -> void:
	var interp = float(fs)
	$SettingsMenu/Windowed.modulate = Color(1.0 - interp * 0.4, 1.0 - interp * 0.4, 1.0 - interp * 0.4)
	$SettingsMenu/Fullscreen.modulate = Color(0.6 + interp * 0.4, 0.6 + interp * 0.4, 0.6 + interp * 0.4)
	if DefSys.fullscreen != fs:
		DefSys.fullscreen = fs
		if DefSys.fullscreen:
			DefSys.size_before_fullscreen = OS.window_size
			DefSys.position_before_fullscreen = OS.window_position
		OS.window_maximized = DefSys.fullscreen
		OS.window_borderless = DefSys.fullscreen
		if DefSys.fullscreen:
			OS.window_size.y += 32
			OS.window_position.x += 8
		else:
			OS.window_size = DefSys.size_before_fullscreen
			OS.window_position = DefSys.position_before_fullscreen

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT && !is_game_over_menu:
		if !get_tree().paused:
			get_tree().paused = true
			selection = 0
			is_settings_menu = false
			$pause.play()
			$Main.show()
			$GameOver.hide()
			$SettingsMenu.hide()
			show()

func game_over():
	get_tree().paused = true
	is_game_over_menu = true
	selection = 0
	is_settings_menu = false
	$Main.hide()
	$GameOver.show()
	$SettingsMenu.hide()
	$gameover.play()
	show()

func _process(delta):
	if !is_game_over_menu:
		if Input.is_action_just_pressed("pause"):
			get_tree().paused = !get_tree().paused
			if get_tree().paused:
				selection = 0
				is_settings_menu = false
				$pause.play()
				$Main.show()
				$GameOver.hide()
				$SettingsMenu.hide()
				show()
			else:
				$select.play()
				hide()
		if Input.is_action_just_pressed("reset"):
				selection = 1
				$select.play()
				get_tree().reload_current_scene()
			
		if get_tree().paused:
			if Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("down"):
				selection += 1
				$change.play()
			elif Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("up"):
				selection -= 1
				$change.play()
			elif Input.is_action_just_pressed("bomb"):
				selection = -1
				$change.play()
			if !is_settings_menu:
				selection = (selection + 4) % 4
				$Selection.rect_position.y = 510 + selection * 64
			else:
				selection = (selection + 6) % 6
				$Selection.rect_position.y = settings_menu_selection_heights[selection]
			
			if is_settings_menu:
				var change = 0
				if Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("right"):
					change = 10
					$change.play()
				elif Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("left"):
					change = -10
					$change.play()
				if change:
					if selection == 2:
						DefSys.change_volume(change, true)
						$SettingsMenu/MusicLevel.value = 10.0 + DefSys.music_percent * 0.01 * 90.0
						$SettingsMenu/MusicLevel/value.text = str(DefSys.music_percent) + "%"
						$SettingsMenu/MusicLevel.material.set_shader_param("progress", $SettingsMenu/MusicLevel.value / 100.0)
						$SettingsMenu/MusicLevel/value.rect_position.x = -46 + 5.4 * DefSys.music_percent
					elif selection == 3:
						DefSys.change_volume(change, false)
						$SettingsMenu/SFXLevel.value = 10.0 + DefSys.sfx_percent * 0.01 * 90.0
						$SettingsMenu/SFXLevel/value.text = str(DefSys.sfx_percent) + "%"
						$SettingsMenu/SFXLevel.material.set_shader_param("progress", $SettingsMenu/SFXLevel.value / 100.0)
						$SettingsMenu/SFXLevel/value.rect_position.x = -46 + 5.4 * DefSys.sfx_percent
					elif selection == 4:
						DefSys.bg_scale = int(clamp(change + DefSys.bg_scale, 20, 200))
						$SettingsMenu/BGLevel.value = 14.0 + (DefSys.bg_scale - 20) / (180.0) * 86.0
						$SettingsMenu/BGLevel/value.text = str(DefSys.bg_scale) + "%"
						$SettingsMenu/BGLevel.material.set_shader_param("progress", $SettingsMenu/BGLevel.value / 100.0)
						$SettingsMenu/BGLevel/value.rect_position.x = -23 + (495 + 23) * (DefSys.bg_scale - 20) / (180.0)
						DefSys.background_controller.change_scale(DefSys.bg_scale)
					
			
			if !is_settings_menu:
				if Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed("shoot"):
					$select.play()
					match selection:
						0:
							get_tree().paused = false
							hide()
						1:
							get_tree().paused = false
							get_tree().reload_current_scene()
						2:
							is_settings_menu = true
							$Main.hide()
							$SettingsMenu.show()
							selection = 0
						3:
							get_tree().change_scene("res://examples/mainmenu.tscn")
			else:
				if Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed("shoot"):
					match selection:
						0:
							set_fullscreen(false)
							$select.play()
						1:
							set_fullscreen(true)
							$select.play()
						5:
							is_settings_menu = false
							$Main.show()
							$SettingsMenu.hide()
							selection = 2
							$select.play()
	else:
		if game_over_volume < 1.0:
			game_over_volume = min(1.0, game_over_volume + game_over_volume_change_rate * delta)
			$gameover.volume_db = linear2db(game_over_volume)
		
		if Input.is_action_just_pressed("reset"):
			selection = 0
			$select.play()
			get_tree().paused = false
			get_tree().reload_current_scene()
		
		if Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("down"):
			selection += 1
			$change.play()
		elif Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("up"):
			selection -= 1
			$change.play()
		elif Input.is_action_just_pressed("bomb"):
			selection = -1
			$change.play()
		if !is_settings_menu:
			selection = (selection + 3) % 3
			$Selection.rect_position.y = 510 + selection * 64
		else:
			selection = (selection + 6) % 6
			$Selection.rect_position.y = settings_menu_selection_heights[selection]
		
		if is_settings_menu:
			var change = 0
			if Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("right"):
				change = 10
				$change.play()
			elif Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("left"):
				change = -10
				$change.play()
			if change:
				if selection == 2:
					DefSys.change_volume(change, true)
					$SettingsMenu/MusicLevel.value = 10.0 + DefSys.music_percent * 0.01 * 90.0
					$SettingsMenu/MusicLevel/value.text = str(DefSys.music_percent) + "%"
					$SettingsMenu/MusicLevel.material.set_shader_param("progress", $SettingsMenu/MusicLevel.value / 100.0)
					$SettingsMenu/MusicLevel/value.rect_position.x = -46 + 5.4 * DefSys.music_percent
				elif selection == 3:
					DefSys.change_volume(change, false)
					$SettingsMenu/SFXLevel.value = 10.0 + DefSys.sfx_percent * 0.01 * 90.0
					$SettingsMenu/SFXLevel/value.text = str(DefSys.sfx_percent) + "%"
					$SettingsMenu/SFXLevel.material.set_shader_param("progress", $SettingsMenu/SFXLevel.value / 100.0)
					$SettingsMenu/SFXLevel/value.rect_position.x = -46 + 5.4 * DefSys.sfx_percent
				elif selection == 4:
					DefSys.bg_scale = int(clamp(change + DefSys.bg_scale, 20, 200))
					$SettingsMenu/BGLevel.value = 14.0 + (DefSys.bg_scale - 20) / (180.0) * 86.0
					$SettingsMenu/BGLevel/value.text = str(DefSys.bg_scale) + "%"
					$SettingsMenu/BGLevel.material.set_shader_param("progress", $SettingsMenu/BGLevel.value / 100.0)
					$SettingsMenu/BGLevel/value.rect_position.x = -23 + (495 + 23) * (DefSys.bg_scale - 20) / (180.0)
					DefSys.background_controller.change_scale(DefSys.bg_scale)
				
		
		if !is_settings_menu:
			if Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed("shoot"):
				$select.play()
				match selection:
					0:
						get_tree().reload_current_scene()
					1:
						is_settings_menu = true
						$GameOver.hide()
						$SettingsMenu.show()
						selection = 0
					2:
						get_tree().change_scene("res://examples/mainmenu.tscn")
		else:
			if Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed("shoot"):
				match selection:
					0:
						set_fullscreen(false)
						$select.play()
					1:
						set_fullscreen(true)
						$select.play()
					5:
						is_settings_menu = false
						$GameOver.show()
						$SettingsMenu.hide()
						selection = 2
						$select.play()

