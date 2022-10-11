extends MeshInstance


func _ready():
	get_active_material(0).render_priority = 1
