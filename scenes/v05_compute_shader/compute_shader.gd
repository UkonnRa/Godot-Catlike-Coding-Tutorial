extends Node
class_name ComputeShader

@export_range(0, 250) var resolution: int = 10

var buffer: RID
var uniform_set: RID

@onready var rd := RenderingServer.create_local_rendering_device()
@onready var shader_file := load("res://scenes/v05_compute_shader/compute_shader.glsl") as RDShaderFile
@onready var shader_spirv := shader_file.get_spirv()
@onready var _compute_shader := rd.shader_create_from_spirv(shader_spirv)
@onready var x_group_size: int = ceil(resolution * resolution / 32.0)

const ADDITIONAL_FLOATS := 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_print_error()

	# Prepare our data. We use floats in the shader, so we need 32 bit.
	var input := PackedFloat32Array()
	input.resize(resolution * resolution * 3 + ADDITIONAL_FLOATS)
	var input_bytes := input.to_byte_array()

	# Create a storage buffer that can hold our float values.
	# Each float has 4 bytes (32 bit) so 10 x 4 = 40 bytes
	buffer = rd.storage_buffer_create(input_bytes.size(), input_bytes)
	# Create a uniform to assign the buffer to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0  # this needs to match the "binding" in our shader file
	uniform.add_id(buffer)
	# the last parameter (the 0) needs to match the "set" in our shader file
	uniform_set = rd.uniform_set_create([uniform], _compute_shader, 0)
	print("Input: {size} == {values} ".format({"size": len(input), "values": input.slice(0, 10)}))


func calculate(time: float, func_index: int) -> PackedFloat32Array:
	var now := Time.get_ticks_msec()
	var new_bytes := PackedFloat32Array([float(resolution), time, func_index]).to_byte_array()
	rd.buffer_update(buffer, 0, new_bytes.size(), new_bytes)
	_compute()
	# Read back the data from the buffer
	var output_bytes := rd.buffer_get_data(buffer)
	var output := output_bytes.to_float32_array().slice(ADDITIONAL_FLOATS)
#	print("Calculate: {millis} ms".format({ "millis": Time.get_ticks_msec() - now }))
#	print("Output: {size} == {values} ".format({"size": len(output), "values": output.slice(0, 10)}))
	return output


func _compute():
	var now := Time.get_ticks_msec()
	# Create a compute pipeline
	var pipeline := rd.compute_pipeline_create(_compute_shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, x_group_size, 1, 1)
	rd.compute_list_end()

	# Submit to GPU and wait for sync
	rd.submit()
	rd.sync()
	_print_error()
#	print("GPU: {millis} ms".format({ "millis": Time.get_ticks_msec() - now }))


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
