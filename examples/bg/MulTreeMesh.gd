
extends MultiMeshInstance

export var lr := 1

#10, 5 each 30 tomes

func _ready():
	for i in range(0):
		var z = rand_range(-6, 6)# + self.translation.z
		if i % 2 == 0:
			z += lr * 15.0
		var x = i * 8# + self.translation.x 
		var xform = Transform(Basis(), Vector3(x, 0.0, z))
		self.multimesh.set_instance_transform(i, xform)
