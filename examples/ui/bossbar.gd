extends Control

onready var healthbar_percent = $percent
onready var healthbar = $bossbar
onready var nametag = $name

onready var icons = $phases


onready var anim_player = $AnimationPlayer

var health := 0.0
var max_health := 1.0

var icons_fade_in := 0.0
var icons_fade_in_rate := 5.0
var icons_fade_offset := 0.05

#var should_update_healthbar := false

func _ready():
	DefSys.boss_bar = self
	healthbar.hide()
	healthbar_percent.hide()
	nametag.hide()
	
	icons.hide()
	
func _process(delta):
	if !anim_player.is_playing():
		healthbar.value = 7 + max(health / max_health, 0.0) * 93.0
	if icons.visible && icons_fade_in < 10.0:
		icons_fade_in += delta * icons_fade_in_rate
		var i = 0.0
		for icon in icons.get_children():
			var interp = clamp(icons_fade_in - icons_fade_offset * i, 0.0, 1.0)
			icon.position.y = -64.0 + 64 * interp
			icon.modulate.a = interp
			icon.z_index = -1 if (interp) < 0.9 else 0
			i += 1.0

func entry_anim():
	anim_player.play("show")

func update_healthbar(value):
	healthbar.material.set_shader_param("progress", value*0.01)
	healthbar_percent.rect_position.x = 56 + value * 0.01 * healthbar.rect_size.x
	var percent : String
	if !anim_player.is_playing():
		percent = str(ceil(100.0 * clamp(health / max_health, 0.0, 1.0))) + "%"
	else:
		percent = str(ceil(healthbar.value)) + "%"
	healthbar_percent.text = percent
	#healthbar_percent.visible = health > 0
	
func _on_bossbar_value_changed(value):
	update_healthbar(value)

func start_icon_fade():
	icons.show()
	icons_fade_in = 0.0

func set_phase_icons(phases : Array):
	var i = 0
	for icon in icons.get_children():
		var x = phases[i] if i < len(phases) else 0
		icon.region_rect.position.x = 128 * x
		i += 1
