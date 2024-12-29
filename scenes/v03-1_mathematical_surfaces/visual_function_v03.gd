@tool
class_name VisualFunctionV03
extends Node3D

@export var func_index: int = 0
@export var resolution: int = 10
@export var shader: Shader
@export var duration_interval: float = 2
@export var lerp_interval: float = 1

var func_list: Array[String] = [
	"wave",
	"multi_wave",
	"ripple",
	"bun",
	"sphere",
	"sphere_verticle_band",
	"sphere_horizontal_band",
	"sphere_twisted_band",
	"torus"
]

var parsed: Callable
var duration: float


func _ready() -> void:
	for child in get_children():
		remove_child(child)
		child.free()
	parsed = Callable(FuncUtilsV03, func_list[func_index])

	var step := 2.0 / resolution
	for idx in range(resolution * resolution):
		var node := CSGBox3D.new()
		node.size = Vector3(step, step, step)
		var material := ShaderMaterial.new()
		material.shader = shader
		node.material = material
		add_child(node)


func _process(delta: float) -> void:
	duration += delta
	if duration >= duration_interval + lerp_interval:
		duration = 0
		func_index = (func_index + 1) % len(func_list)
		parsed = Callable(FuncUtilsV03, func_list[func_index])

	var time := Time.get_ticks_msec() / 1000.0
	var step := 2.0 / resolution
	var children := get_children()

	var next_parsed = Callable(FuncUtilsV03, func_list[(func_index + 1) % len(func_list)])
	for idx in range(len(children)):
		var child := children[idx]
		if child is CSGBox3D:
			var x := idx / resolution
			var z := idx % resolution
			var u := (x + 0.5) * step - 1
			var v := (z + 0.5) * step - 1
			var current: Vector3 = parsed.call(u, v, time)
			var next: Vector3 = next_parsed.call(u, v, time)
			child.position = lerp(current, next, clamp(duration / lerp_interval, 0, 1))
