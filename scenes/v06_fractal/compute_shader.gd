@tool
class_name ComputeShaderV06
extends Node3D

static var CHILD_COUNT := 5
static var FLOATS_PER_DATA_IN_SHADER := 16


static func _total_count_in_depth(current: int) -> int:
	return round((CHILD_COUNT ** (current + 1) - 1) / 4.0)


@export_range(1, 10) var depth: int = 1
@export var shader_point: Shader

var total_count: int:
	get:
		return _total_count_in_depth(depth - 1)

var rd: RenderingDevice
var shader_file: RDShaderFile
var shader_spirv: RDShaderSPIRV
var pipeline: RID
var buffer: RID
var uniform_set: RID
var texture_position: RID
var uniform_set_position: RID
var texture_rotation: RID
var uniform_set_rotation: RID
var texture_data_info: RID
var uniform_set_data_info: RID

var _compute_shader: RID


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

	texture_position = _create_texture()

	var uniform_position := RDUniform.new()
	uniform_position.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform_position.binding = 0
	uniform_position.add_id(texture_position)
	# Even though we're using 3 sets, they are identical, so we're kinda cheating.
	uniform_set_position = rd.uniform_set_create([uniform_position], _compute_shader, 1)

	texture_rotation = _create_texture()

	var uniform_rotation := RDUniform.new()
	uniform_rotation.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform_rotation.binding = 0
	uniform_rotation.add_id(texture_rotation)
	# Even though we're using 3 sets, they are identical, so we're kinda cheating.
	uniform_set_rotation = rd.uniform_set_create([uniform_rotation], _compute_shader, 2)


	texture_data_info = _create_texture()

	var uniform_data_info := RDUniform.new()
	uniform_data_info.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform_data_info.binding = 0
	uniform_data_info.add_id(texture_data_info)
	# Even though we're using 3 sets, they are identical, so we're kinda cheating.
	uniform_set_data_info = rd.uniform_set_create([uniform_data_info], _compute_shader, 3)

	_print_error()

	var gpu_particle := get_node("GPUParticles3D") as GPUParticles3D
	gpu_particle.local_coords = true
	var mesh := SphereMesh.new()
	var mesh_material := ShaderMaterial.new()
	mesh_material.shader = shader_point
	mesh.material = mesh_material
	gpu_particle.draw_pass_1 = mesh
	gpu_particle.amount = total_count

	var process_material := gpu_particle.process_material as ShaderMaterial
	process_material.set_shader_parameter("total", total_count)

	var param_position = process_material.get_shader_parameter("position")
	if param_position == null:
		param_position = Texture2DRD.new()
		process_material.set_shader_parameter("position", param_position)
	param_position.texture_rd_rid = texture_position

	var param_rotation = process_material.get_shader_parameter("rotation")
	if param_rotation == null:
		param_rotation = Texture2DRD.new()
		process_material.set_shader_parameter("rotation", param_rotation)
	param_rotation.texture_rd_rid = texture_rotation

	var param_data_info = process_material.get_shader_parameter("data_info")
	if param_data_info == null:
		param_data_info = Texture2DRD.new()
		process_material.set_shader_parameter("data_info", param_data_info)
	param_data_info.texture_rd_rid = texture_data_info


var interval := 0.0
func _process(delta: float) -> void:
	_compute(delta)
#	for item in _get_data_from_buffer():
#		print("Position for {0}: {1}".format([item.idx, item.position]))
#
	
#	interval += delta
#	if interval > 10.0:
#		print("=== Debug Texture ===")
#		var data_info_data := rd.texture_get_data(texture_data_info, 0).to_float32_array()
#		print("data_info_data: ", data_info_data)
#		var idx := 0
#		while idx < len(data_info_data) - 4:
#			print("  Idx: {0}, Parent: {1}, Depth: {2}".format([data_info_data[idx], data_info_data[idx + 1], data_info_data[idx + 2]]))
#			idx += 4
#		
#		interval = 0.0
#		print("=== End Texture ===")


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
		rd.compute_list_bind_uniform_set(compute_list, uniform_set_position, 1)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set_rotation, 2)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set_data_info, 3)
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


func _create_texture() -> RID:
	var tf: RDTextureFormat = RDTextureFormat.new()
	tf.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tf.width = total_count
	tf.height = 1
	tf.depth = 1
	tf.array_layers = 1
	tf.mipmaps = 1
	tf.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
		+ RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT
		+ RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
		+ RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
		+ RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
		+ RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	)

	var texture := rd.texture_create(tf, RDTextureView.new())
	rd.texture_clear(texture, Color(0, 0, 0, 0), 0, 1, 0, 1)
	return texture
