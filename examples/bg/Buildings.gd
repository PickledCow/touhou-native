extends MultiMeshInstance


func _ready():
	for i in len(multimesh.instance_count):
		multimesh.set_instance_custom_data(i, Color(i, 0.0, 0.0, 0.0))

