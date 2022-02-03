extends Control


var thread
var mutex

var fullscreen := false
var size_before_fullscreen := Vector2(1280, 720)
var position_before_fullscreen : Vector2

func _ready():
	Engine.target_fps = 60
	get_tree().get_root().set_transparent_background(true)
	OS.window_per_pixel_transparency_enabled = true
	thread = Thread.new()
	mutex = Mutex.new()
	
	# fancy titlebar
	if !OS.window_borderless || !DefSys.borderlessed:
		DefSys.borderlessed = true
		OS.window_borderless = true
		OS.window_borderless = false
	#toggle_fullscreen()
	

func _on_Player_hit(extra_arg_0):
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("debug1"):
		toggle_fullscreen()
		#snap(get_viewport())
	if Input.is_action_just_pressed("debug5"):
		get_tree().reload_current_scene()

func toggle_fullscreen():
	fullscreen = !fullscreen
	if fullscreen:
		size_before_fullscreen = OS.window_size
		position_before_fullscreen = OS.window_position
	OS.window_maximized = fullscreen
	OS.window_borderless = fullscreen
	if fullscreen:
		OS.window_size.y += 32
		OS.window_position.x += 8
	else:
		OS.window_size = size_before_fullscreen
		OS.window_position = position_before_fullscreen
	

var queue = []
const MAX_QUEUE_LENGTH = 4


func _exit_tree():
	if thread.is_active():
		thread.wait_to_finish()


func snap(var viewport : Viewport):
	
	var dt = OS.get_datetime()
	var timestamp = "%04d%02d%02d%02d%02d%02d" % [dt["year"], dt["month"], dt["day"], dt["hour"], dt["minute"], dt["second"]]
	
	var image = viewport.get_texture().get_data()
	
	save(image, "user://screenshot-" + timestamp + ".png")


func save(var image : Image, path : String):
	
	mutex.lock()
	
	if queue.size() < MAX_QUEUE_LENGTH:
		queue.push_back({"image" : image, "path" : path})
	else:
		print("Screenshot queue overflow")
	
	if queue.size() == 1:
		if thread.is_active():
			thread.wait_to_finish()
		thread.start(self, "worker_function")
	
	mutex.unlock()


func worker_function(_userdata):
	
	mutex.lock()
	while not queue.empty():
		var item = queue.front()
		mutex.unlock()
		
		print("Saving screenshot to " + item["path"])
		
		item["image"].flip_y()
		item["image"].save_png(item["path"])
		
		mutex.lock()
		queue.pop_front()
	
	mutex.unlock()
