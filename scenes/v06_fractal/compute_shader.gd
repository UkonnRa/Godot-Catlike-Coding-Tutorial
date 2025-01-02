@tool
class_name ComputeShaderV06
extends Node3D

var rd: RenderingDevice
var shader_file: RDShaderFile
var shader_spirv: RDShaderSPIRV
var pipeline: RID
var buffer_parent: RID
var uniform_set_parent: RID
var buffer_current: RID
var uniform_set_current: RID

var _compute_shader: RID


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rd = RenderingServer.get_rendering_device()
	shader_file = load("res://scenes/v06_fractal/compute_shader.glsl") as RDShaderFile
	shader_spirv = shader_file.get_spirv()
	_compute_shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(_compute_shader)
	_print_error()

	var data_0 := FractalData.new(0, 1, 2)
	data_0.position = Vector3(3, 4, 5)
	data_0.world_quaternion = Quaternion(6, 7, 8, 9)
	data_0.spin_angle = 10
	buffer_parent = _create_data_buffer([data_0])

	var uniform_parent := RDUniform.new()
	uniform_parent.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform_parent.binding = 0
	uniform_parent.add_id(buffer_parent)
	# Even though we're using 3 sets, they are identical, so we're kinda cheating.
	uniform_set_parent = rd.uniform_set_create([uniform_parent], _compute_shader, 0)

	var data_1 := FractalData.new(100, 101, 102)
	data_1.position = Vector3(103, 104, 105)
	data_1.world_quaternion = Quaternion(106, 107, 108, 109)
	data_1.spin_angle = 110
	var data_2 := FractalData.new(200, 201, 202)
	data_2.position = Vector3(203, 204, 205)
	data_2.world_quaternion = Quaternion(206, 207, 208, 209)
	data_2.spin_angle = 210
	buffer_current = _create_data_buffer([data_1, data_2])
	_print_error()

	var uniform_data := RDUniform.new()
	uniform_data.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform_data.binding = 0
	uniform_data.add_id(buffer_current)
	# Even though we're using 3 sets, they are identical, so we're kinda cheating.
	uniform_set_current = rd.uniform_set_create([uniform_data], _compute_shader, 1)
	_print_error()

	print("== Before ==")
	_print_data()
	print("== End Before ==")
	_compute(2)
	print("== After ==")
	_print_data()
	print("== End After ==")


func _create_data_buffer(data: Array[FractalData]) -> RID:
	var input := PackedFloat32Array()

	for datum in data:
		input.push_back(float(datum.depth))
		input.push_back(float(datum.idx))
		input.push_back(float(datum.parent_idx))
		input.push_back(0)
		input.push_back(datum.position.x)
		input.push_back(datum.position.y)
		input.push_back(datum.position.z)
		input.push_back(0)
		input.push_back(datum.world_quaternion.x)
		input.push_back(datum.world_quaternion.y)
		input.push_back(datum.world_quaternion.z)
		input.push_back(datum.world_quaternion.w)
		input.push_back(datum.spin_angle)
		input.push_back(0)
		input.push_back(0)
		input.push_back(0)

	var input_bytes := input.to_byte_array()
	return rd.storage_buffer_create(input_bytes.size(), input_bytes)


func _compute(delta: float):
	var push_constant := PackedFloat32Array([delta, 0, 0, 0]).to_byte_array()

	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set_parent, 0)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set_current, 1)
	rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
	rd.compute_list_dispatch(compute_list, 1, 1, 1)
	rd.compute_list_end()
	# Submit to GPU and wait for sync
	rd.submit()
	rd.sync()
	_print_error()


func _print_data():
	var parent := rd.buffer_get_data(buffer_parent).to_float32_array()
	print("Parent: ", parent)
	var data := rd.buffer_get_data(buffer_current).to_float32_array()
	print("Data:   ", data)


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
