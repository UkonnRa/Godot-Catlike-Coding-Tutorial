@tool
class_name ComputeShaderV06
extends Node3D

static var CHILD_COUNT := 5
static var FLOATS_PER_DATA_IN_SHADER := 16

@export_range(1, 10) var depth: int = 1

var rd: RenderingDevice
var shader_file: RDShaderFile
var shader_spirv: RDShaderSPIRV
var pipeline: RID
var buffer: RID
var uniform_set: RID

var _compute_shader: RID


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		remove_child(child)
		child.free()

	rd = RenderingServer.get_rendering_device()
	shader_file = load("res://scenes/v06_fractal/compute_shader.glsl") as RDShaderFile
	shader_spirv = shader_file.get_spirv()
	_compute_shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(_compute_shader)
	_print_error()

	buffer = _create_data_buffer()

	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0
	uniform.add_id(buffer)
	# Even though we're using 3 sets, they are identical, so we're kinda cheating.
	uniform_set = rd.uniform_set_create([uniform], _compute_shader, 0)
	_print_error()

	# TODO: change to Particle
	for idx in range(_total_count_in_depth(depth - 1)):
		var child := MeshInstance3D.new()
		child.mesh = BoxMesh.new()
		add_child(child)


func _process(delta: float) -> void:
	_compute(delta)
	var new_data := _get_data_from_buffer()
	var children := get_children()

	# TODO: change to Particle
	for data in new_data:
		var child := children[data.idx] as MeshInstance3D
		child.position = data.position
		child.quaternion = data.world_quaternion
		child.scale = data.scale


func _total_count_in_depth(current: int) -> int:
	return round((CHILD_COUNT ** (current + 1) - 1) / 4.0)


func _create_data_buffer() -> RID:
	var input := PackedFloat32Array()
	input.resize(FLOATS_PER_DATA_IN_SHADER * _total_count_in_depth(depth - 1))
	input.fill(0)

	var input_bytes := input.to_byte_array()
	return rd.storage_buffer_create(input_bytes.size(), input_bytes)


func _compute(delta: float):
	for current in range(depth):
		var push_constant := PackedFloat32Array([current, delta, 0, 0]).to_byte_array()
		var compute_list := rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
		rd.compute_list_dispatch(compute_list, CHILD_COUNT ** current, 1, 1)
		rd.compute_list_end()
		# Submit to GPU and wait for sync
		rd.submit()
		rd.sync()
		_print_error()


func _get_data_from_buffer() -> Array[FractalData]:
	var data := rd.buffer_get_data(buffer).to_float32_array()
	var results: Array[FractalData] = []

	var idx := 0
	while idx < len(data):
		var result := FractalData.new(int(data[idx]), int(data[idx + 1]), int(data[idx + 2]))
		result.position = Vector3(data[idx + 4], data[idx + 5], data[idx + 6])
		result.world_quaternion = Quaternion(
			data[idx + 8], data[idx + 9], data[idx + 10], data[idx + 11]
		)
		result.spin_angle = data[idx + 12]
		idx += FLOATS_PER_DATA_IN_SHADER
		results.push_back(result)

	return results


func _print_error():
	if shader_spirv.compile_error_compute:
		printerr("Compute Shader Error: ", shader_spirv.compile_error_compute)
	if shader_spirv.compile_error_fragment:
		printerr("Fragment Error: ", shader_spirv.compile_error_fragment)
	if shader_spirv.compile_error_tesselation_control:
		printerr("Tess Control Error: ", shader_spirv.compile_error_tesselation_control)
	if shader_spirv.compile_error_tesselation_evaluation:
		printerr("Tess Eval Error: ", shader_spirv.compile_error_tesselation_evaluation)
	if shader_spirv.compile_error_vertex:
		printerr("Vertx Error: ", shader_spirv.compile_error_vertex)
