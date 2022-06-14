extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum MENU { MAIN, PLAYER, SETTINGS }
var selection_size := [3, 3, 10]
var menu := 0
var selection := 0


var settings_menu_selection_heights := [338-128, 402-128, 514-128, 578-128, 690-128, 690 + 64-128, 690, 690 + 96, 690 + 64 + 96, 786+64*2.5]
var player_menu_selection_heights := [503, 503 + 96, 503 + 96 * 3]


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	# fancy titlebar
	Engine.target_fps = 60
	get_tree().get_root().set_transparent_background(true)
	OS.window_per_pixel_transparency_enabled = true
	if !OS.window_borderless || !DefSys.borderlessed:
		DefSys.borderlessed = true
		OS.window_borderless = true
		OS.window_borderless = false
	
	
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
	
	$selection.rect_position.x = 760.0

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

func set_2d3d(set: bool) -> void:
	DefSys.is_3d = set
	var interp = float(DefSys.is_3d)
	get_node("SettingsMenu/2d").modulate = Color(1.0 - interp * 0.4, 1.0 - interp * 0.4, 1.0 - interp * 0.4)
	get_node("SettingsMenu/3d").modulate = Color(0.6 + interp * 0.4, 0.6 + interp * 0.4, 0.6 + interp * 0.4)

func set_transparent(is_transparent: bool):
	DefSys.transluscent = is_transparent
	get_tree().get_root().set_transparent_background(is_transparent)
	OS.window_per_pixel_transparency_enabled = is_transparent
	if (!OS.window_borderless || !DefSys.borderlessed) && is_transparent:
		DefSys.borderlessed = true
		OS.window_borderless = true
		OS.window_borderless = false
	$glass.visible = !is_transparent
	var interp = float(is_transparent)
	get_node("SettingsMenu/streamer").modulate = Color(1.0 - interp * 0.4, 1.0 - interp * 0.4, 1.0 - interp * 0.4)
	get_node("SettingsMenu/transparent").modulate = Color(0.6 + interp * 0.4, 0.6 + interp * 0.4, 0.6 + interp * 0.4)

func _process(_delta):
	if Input.is_action_just_pressed("up") || Input.is_action_just_pressed("ui_up"):
		selection -= 1
		$change.play()
	if Input.is_action_just_pressed("down") || Input.is_action_just_pressed("ui_down"):
		selection += 1
		$change.play()
	selection = (selection + selection_size[menu]) % selection_size[menu]
	if Input.is_action_just_pressed("bomb") || Input.is_action_just_pressed("ui_cancel"):
		selection = selection_size[menu] - 1
		$change.play()
	
	match menu:
		MENU.MAIN:
			$selection.rect_position.y = 600 + selection * 96.0
		MENU.PLAYER:
			$selection.rect_position.y = player_menu_selection_heights[selection]
		MENU.SETTINGS:
			$selection.rect_position.y = settings_menu_selection_heights[selection]
	
	if menu == MENU.SETTINGS:
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
			elif selection == 6:
				DefSys.bg_scale = int(clamp(change + DefSys.bg_scale, 20, 200))
				$SettingsMenu/BGLevel.value = 14.0 + (DefSys.bg_scale - 20) / (180.0) * 86.0
				$SettingsMenu/BGLevel/value.text = str(DefSys.bg_scale) + "%"
				$SettingsMenu/BGLevel.material.set_shader_param("progress", $SettingsMenu/BGLevel.value / 100.0)
				$SettingsMenu/BGLevel/value.rect_position.x = -23 + (495 + 23) * (DefSys.bg_scale - 20) / (180.0)
			#	DefSys.background_controller.change_scale(DefSys.bg_scale)
	
	if Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("ui_accept"):
		$select.play()
		match menu:
			MENU.MAIN:
				match selection:
					0:
						menu = MENU.PLAYER
						selection = 0
						$Main.hide()
						$Charcter.show()
					1:
						menu = MENU.SETTINGS
						selection = 0
						$Main.hide()
						$SettingsMenu.show()
						$selection/selection2.hide()
						$selection.rect_position.x = 364
					2:
						get_tree().quit()
			MENU.PLAYER:
				match selection:
					0:
						DefSys.player_id = DefSys.PLAYER_ID.REIMU
						#DefSys.background_node = load("res://examples/bg/bg.tscn" if DefSys.is_3d else "res://examples/bg/2dbg.tscn")
						get_tree().change_scene("res://examples/example_01.tscn")
					1:
						DefSys.player_id = DefSys.PLAYER_ID.MARISA
						#DefSys.background_node = load("res://examples/bg/bg.tscn" if DefSys.is_3d else "res://examples/bg/2dbg.tscn")
						get_tree().change_scene("res://examples/example_01.tscn")
					2:
						menu = MENU.MAIN
						selection = 0
						$Main.show()
						$Charcter.hide()
						$selection.rect_position.x = 760.0
			MENU.SETTINGS:
				match selection:
					0:
						set_fullscreen(false)
					1:
						set_fullscreen(true)
					4:
						set_2d3d(false)
					5:
						set_2d3d(true)
					7:
						set_transparent(false)
					8:
						set_transparent(true)
					9:
						menu = MENU.MAIN
						selection = 0
						$Main.show()
						$SettingsMenu.hide()
						$selection/selection2.show()
						$selection.rect_position.x = 760.0
