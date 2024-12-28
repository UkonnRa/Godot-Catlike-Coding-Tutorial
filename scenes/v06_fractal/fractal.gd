@tool
extends MeshInstance3D
class_name Fractal

const COLORS := [
				Color.RED,
				Color.DARK_ORANGE,
				Color.YELLOW,
				Color.GREEN,
				Color.CYAN,
				Color.BLUE,
				Color.PURPLE,
				]

@export var max_depth: int = 1
var depth: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_children()
	print("Child Count: ", get_children().size())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _generate_children() -> void:
#	print("= Parent: ", name)
#	print("  Position: ", position)
#	print("  Mesh: ", (mesh as BoxMesh).size)
#	print("= End Parent: ", name)
	
	for child in get_children():
		remove_child(child)
		child.free()

	if depth >= max_depth - 1:
		return

	var child_depth := depth + 1
	var child_mesh = mesh.duplicate()
	if child_mesh is BoxMesh and mesh is BoxMesh:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = COLORS[child_depth]
		child_mesh.surface_set_material(0, mat)
		child_mesh.size = mesh.size * 0.75
		for idx in range(2):
			var child: Fractal = Fractal.new()
			child.name = "Fractal {depth} - {idx}".format({ "depth": child_depth, "idx": idx })
			child.depth = child_depth
			child.max_depth = max_depth
			child.position = (1 if idx == 0 else -1) * child.transform.basis.x * sqrt(2) * child_mesh.size
			child.rotate(child.transform.basis.z, child_depth * 0.25 * PI)
			child.mesh = child_mesh
			add_child(child)
			child._generate_children()
