@tool
class_name Fractal
extends MeshInstance3D

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_object_local(Vector3.DOWN, PI / 8 * delta)


func _generate_children() -> void:
#	print("= Parent: ", name)
#	print("  Position: ", position)
#	print("  Mesh: ", (mesh as BoxMesh).size)
#	print("= End Parent: ", name)
	var mat := mesh.surface_get_material(0)
	if mat == null:
		mat = StandardMaterial3D.new()
		mesh.surface_set_material(0, mat)
	if mat is StandardMaterial3D:
		mat.albedo_color = COLORS[depth]

	for child in get_children():
		remove_child(child)
		child.free()

	if depth >= max_depth - 1:
		return

	var child_depth := depth + 1
	var child_mesh := mesh.duplicate() as Mesh
	var child_mat := mat.duplicate() as StandardMaterial3D
	child_mesh.surface_set_material(0, child_mat)
	_gen_child(child_depth, child_mesh, 0, Vector3.UP)
	_gen_child(
		child_depth, child_mesh, 1, Vector3.RIGHT, Quaternion.from_euler(Vector3(0, 0, -0.5 * PI))
	)
	_gen_child(
		child_depth, child_mesh, 2, Vector3.LEFT, Quaternion.from_euler(Vector3(0, 0, 0.5 * PI))
	)
	_gen_child(
		child_depth, child_mesh, 3, Vector3.FORWARD, Quaternion.from_euler(Vector3(-0.5 * PI, 0, 0))
	)
	_gen_child(
		child_depth, child_mesh, 4, Vector3.BACK, Quaternion.from_euler(Vector3(0.5 * PI, 0, 0))
	)


func _gen_child(
	child_depth: int,
	child_mesh: Mesh,
	idx: int,
	direction: Vector3,
	quat: Quaternion = Quaternion.IDENTITY
):
	var child: Fractal = Fractal.new()
	child.name = "Fractal {depth}-{idx}".format({"depth": child_depth, "idx": idx})
	child.depth = child_depth
	child.max_depth = max_depth
	child.position = 0.75 * direction
	child.scale_object_local(Vector3.ONE * 0.5)
	child.mesh = child_mesh
	child.quaternion = quat
	add_child(child)
	child._generate_children()
