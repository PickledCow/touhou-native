extends Control

onready var healthbar_percent := $percent
onready var healthbar := $bossbar
onready var nametag := $name
onready var healthbar_color := $healthbarcolor

onready var icons := $phases

onready var timer := $timer

onready var anim_player := $AnimationPlayer

onready var spell_box := $spellclip/spell
onready var spell_box_anim_player := $spellclip/spell/AnimationPlayer
onready var spell_name := $spellclip/spell/name
onready var spell_bonus := $spellclip/spell/bonus
onready var spell_bonus_icon := $spellclip/spell/pointicon

var health := 0.0
var max_health := 1.0

var icons_fade_in := 0.0
var icons_fade_in_rate := 5.0
var icons_fade_offset := 0.05
var icon_being_removed := -1
var icon_fade_out := 0.0
var icon_fade_out_rate := 3.0

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
			icon.position.y = -64.0 + 64.0 * interp
			icon.modulate.a = interp
			icon.z_index = -1 if (interp) < 0.9 else 0
			i += 1.0
			
	if icon_being_removed != -1:
		var icon = icons.get_child(icon_being_removed)
		icon_fade_out += delta * icon_fade_out_rate
		if icon_fade_out >= 1.0:
			icon_being_removed = -1
			icon_fade_out = 1.0
		icon.position.y = -64.0 * icon_fade_out
		icon.modulate.a = 1.0 - icon_fade_out
		icon.z_index = -1 if (icon_fade_out) > 0.9 else 0
	

func entry_anim():
	anim_player.play("show")

func fill_healthbar():
	anim_player.play("fill")
	
func hide_healthbar():
	anim_player.play("hide")
	
func spell_result(success: bool):
	$spellresultplayer.play("capture" if success else "failed")

func update_healthbar(value):
	healthbar.material.set_shader_param("progress", value*0.01)
	healthbar_percent.rect_position.x = 24 + value * 0.01 * healthbar.rect_size.x
	var percent : String
	if !anim_player.is_playing():
		percent = str(ceil(100.0 * clamp(health / max_health, 0.0, 1.0))) + "%"
	else:
		percent = str(ceil(healthbar.value)) + "%"
	healthbar_percent.text = percent
	
	
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

func remove_phase_icon(index: int):
	icon_fade_out = 0.0
	icon_being_removed = index

func set_timer(t: int):
# warning-ignore:integer_division
# warning-ignore:integer_division
	timer.bbcode_text = ("[center]%02d[b].%02d" % [t / 60, (t % 60) * 100 / 60]).replace('0', 'O')

func declare_spell(name: String, bonus: int):
	spell_box.visible = true
	spell_name.bbcode_text = "[right]" + name
	spell_bonus.text = str(bonus).replace('0', 'O') + "  "
	spell_box_anim_player.play("spawn")
	spell_bonus_icon.visible = true

func fail_spell():
	spell_bonus.text = "FAILED"
	spell_bonus_icon.visible = false
	
func end_spell():
	spell_box.visible = false

func healthbar_timeout(timeout: bool):
	if timeout:
		healthbar_color.play("timeout")
	else:
		healthbar_color.play_backwards("timeout")
