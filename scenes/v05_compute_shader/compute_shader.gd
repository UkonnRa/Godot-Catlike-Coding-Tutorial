extends Node3D
class_name ComputeShader

const MAX_IN_EDITOR_RESOLUTION: int = 1000

var resolution: int = 1000
var rd: RenderingDevice
var shader_file: RDShaderFile
var shader_spirv: RDShaderSPIRV
var _compute_shader: RID
var pipeline: RID
var texture: RID
var uniform_set: RID


var x_group_size: int:
	get:
		return ceil(resolution * resolution / 32.0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		resolution = min(resolution, MAX_IN_EDITOR_RESOLUTION)
	_initialize()


func _initialize() -> void:
	rd = RenderingServer.get_rendering_device()
	shader_file = load("res://scenes/v05_compute_shader/compute_shader.glsl") as RDShaderFile
	shader_spirv = shader_file.get_spirv()
	_compute_shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(_compute_shader)
	_print_error()
	
	# Create our textures to manage our wave.
	var tf : RDTextureFormat = RDTextureFormat.new()
	tf.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tf.width = resolution
	tf.height = resolution
	tf.depth = 1
	tf.array_layers = 1
	tf.mipmaps = 1
	tf.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT + RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT + RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT

	texture = rd.texture_create(tf, RDTextureView.new())
	rd.texture_clear(texture, Color(1, 0, 0, 1), 0, 1, 0, 1)

	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = 0
	uniform.add_id(texture)
	# Even though we're using 3 sets, they are identical, so we're kinda cheating.
	uniform_set = rd.uniform_set_create([uniform], _compute_shader, 0)


func _compute(time: float, func_index: int): 
#	var now := Time.get_ticks_msec()
	# The final 0.0 is for padding
	var push_constant := PackedFloat32Array([float(resolution), time, float(func_index), 0.0]).to_byte_array()
	# Create a compute pipeline
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
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
