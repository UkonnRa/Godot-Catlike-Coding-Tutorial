# Comparing with Fractal:
#   The starting up is quite faster, since no recursive overhead
#     * Fractal[depth = 7] is not startable at all!
#   The process workflow is equal, maybe the Fractal mode is faster, since Fractal is only rotating the root node itself

@tool
class_name FractalFlat
extends Node3D

static var ZERO: FractalData = FractalData.new(0, 0, -1)

const COLORS := [
	Color.RED,
	Color.DARK_ORANGE,
	Color.YELLOW,
	Color.GREEN,
	Color.CYAN,
	Color.BLUE,
	Color.PURPLE,
]

const DIRECTION_ROTATIONS: Array[Array] = [
	[Vector3.UP, Vector3.ZERO],
	[Vector3.RIGHT, Vector3(0, 0, -0.5 * PI)],
	[Vector3.LEFT, Vector3(0, 0, 0.5 * PI)],
	[Vector3.FORWARD, Vector3(-0.5 * PI, 0, 0)],
	[Vector3.BACK, Vector3(0.5 * PI, 0, 0)]
]

@export_range(1, 10) var depth: int
@export var mesh: Mesh
@export var material: ShaderMaterial

var data_list: Array[Array] = []
var matrices: Array[Array] = []


func _ready() -> void:
	for child in get_children():
		remove_child(child)
		child.free()

	for i in range(depth):
		data_list.push_back([])
		matrices.push_back([])

	_gen_data()

	for curr_depth in range(len(data_list)):
		var mat_override: Material
		if material == null:
			mat_override = StandardMaterial3D.new()
			(mat_override as StandardMaterial3D).albedo_color = COLORS[curr_depth]
		else:
			mat_override = material.duplicate()
			(mat_override as ShaderMaterial).set_shader_parameter("depth", curr_depth)

		for data in data_list[curr_depth]:
			var node := MeshInstance3D.new()
			node.name = data.name
			node.mesh = mesh
			node.scale_object_local(data.scale)
			node.set_surface_override_material(0, mat_override)
			add_child(node)


func _process(delta: float) -> void:
	var children := get_children()
	var delta_angle := -PI / 8 * delta

	for current_depth in range(len(data_list)):
		var sub_data := data_list[current_depth]
		if current_depth == 0:
			var data: FractalData = sub_data[0]
			data.spin_angle += delta_angle
			data.world_quaternion = (Quaternion.from_euler(Vector3(0, data.spin_angle, 0)))
		else:
			for idx_in_depth in range(len(data_list[current_depth])):
				var dir_rot := DIRECTION_ROTATIONS[idx_in_depth % 5]
				var data: FractalData = sub_data[idx_in_depth]
				var parent: FractalData = data_list[current_depth - 1][data.parent_idx]
				data.spin_angle += delta_angle
				data.world_quaternion = (
					parent.world_quaternion
					* Quaternion.from_euler(dir_rot[1])
					* Quaternion.from_euler(Vector3(0, data.spin_angle, 0))
				)
				data.position = (
					parent.position + parent.world_quaternion * dir_rot[0] * 1.5 * data.scale
				)

		for idx_in_depth in range(len(data_list[current_depth])):
			var data: FractalData = sub_data[idx_in_depth]
			var total_count_before := int((1 - 5 ** current_depth) / (1 - 5))
			var child_idx := 0 if current_depth == 0 else total_count_before + idx_in_depth
			var child: MeshInstance3D = children[child_idx]
			child.position = data.position
			child.quaternion = data.world_quaternion


func _gen_data(parent: FractalData = null) -> void:
	if parent == null:
		if depth <= 0:
			return
		var data := ZERO
		data_list[0] = [data]
		matrices[0] = [FractalFlat._transform_trs(data.position, data.world_quaternion, 1)]
		_gen_data(data)
		return

	var curr_depth := parent.depth + 1
	if curr_depth >= depth:
		return

	for i in range(len(DIRECTION_ROTATIONS)):
		var idx: int = parent.idx * len(DIRECTION_ROTATIONS) + i
		var data := FractalData.new(curr_depth, idx, parent.idx)
		var curr_data := data_list[curr_depth]
		curr_data.push_back(data)

		var sub_matrices := matrices[curr_depth]
		sub_matrices.push_back(FractalFlat._transform_trs(data.position, data.world_quaternion, 1))

		_gen_data(data)


static func _transform_trs(trans: Vector3, rot: Quaternion, m_scale: float) -> Transform3D:
	var result := Transform3D.IDENTITY.translated_local(trans)
	var rot_axis := rot.get_axis()
	if rot_axis.is_normalized():
		result = result.rotated_local(rot_axis, rot.get_angle())
	return result.scaled_local(Vector3.ONE * m_scale)
