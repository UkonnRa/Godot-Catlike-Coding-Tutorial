@tool
class_name VisualFunctionV05
extends ComputeShader

@export var func_index: int = 0
@export var duration_interval: float = 2
@export var lerp_interval: float = 1
@export var shader_point: Shader

var gpu_particle: GPUParticles3D

var func_list: Array[String] = ["wave", "multi_wave", "ripple", "bun", "sphere", "sphere_verticle_band", "sphere_horizontal_band", "sphere_twisted_band", "torus"]
var duration: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	gpu_particle = get_node("GPUParticles3D") as GPUParticles3D
	gpu_particle.local_coords = true
	gpu_particle.visibility_aabb.position = Vector3(-1, -1, -1)
	gpu_particle.visibility_aabb.size = Vector3(2, 2, 2)
	var process_material := gpu_particle.process_material
	if process_material is ShaderMaterial:
		process_material.set_shader_parameter("resolution", resolution)
		var texture_position = process_material.get_shader_parameter("texture_position")
		if texture_position is Texture2DRD:
			texture_position.texture_rd_rid = texture
	var mesh := BoxMesh.new()
	var mesh_material := ShaderMaterial.new()
	mesh_material.shader = shader_point
	mesh.material = mesh_material
	var size := 2.0 / resolution
	mesh.size = Vector3(size, size, size)
	gpu_particle.draw_pass_1 = mesh
	gpu_particle.amount = resolution * resolution


func _process(delta: float) -> void:
	duration += delta
	var next_index := (func_index + 1) % len(func_list)
	if duration >= duration_interval + lerp_interval:
		duration = 0
		func_index = next_index

	var time := Time.get_ticks_msec() / 1000.0
	_compute(time, func_index)
