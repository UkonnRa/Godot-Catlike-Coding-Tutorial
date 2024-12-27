@tool
class_name VisualFunctionV05
extends ComputeShader

@export var func_index: int = 0
@export var shader: Shader
@export var duration_interval: float = 2
@export var lerp_interval: float = 1

var func_list: Array[String] = ["wave", "multi_wave", "ripple", "bun", "sphere", "sphere_verticle_band", "sphere_horizontal_band", "sphere_twisted_band", "torus"]
var duration: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	for child in get_children():
		remove_child(child)
		child.free()

	var step := 2.0 / resolution
	for idx in range(resolution * resolution):
		var node     := CSGBox3D.new()
		node.size = Vector3(step, step, step)
		var material := ShaderMaterial.new()
		material.shader = shader
		node.material = material
		add_child(node)


func _process(delta: float) -> void:
	duration += delta
	var next_index = (func_index + 1) % len(func_list)
	if duration >= duration_interval + lerp_interval:
		duration = 0
		func_index = next_index

	var time := Time.get_ticks_msec() / 1000.0
	var children := get_children()

	var current_position := calculate(time, func_index)
	var next_position    :=  calculate(time, next_index)
	for idx in range(len(children)):
		var child := children[idx]
		if child is CSGBox3D:
			var x: int = 3 * idx
			var y: int = 3 * idx + 1
			var z: int = 3 * idx + 2
			
			var current := Vector3(current_position[x], current_position[y], current_position[z])
			var next := Vector3(next_position[x], next_position[y], next_position[z])
			child.position = lerp(current, next, clamp(duration / lerp_interval, 0, 1))
