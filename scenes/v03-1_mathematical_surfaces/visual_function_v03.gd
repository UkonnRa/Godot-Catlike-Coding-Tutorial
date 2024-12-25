@tool
class_name VisualFunctionV03
extends Node3D

@export_enum("wave", "multi_wave", "ripple", "bun", "sphere", "sphere_verticle_band", "sphere_horizontal_band", "sphere_twisted_band", "torus") var func_name: String
@export var resolution: int = 40
@export var shader: Shader

var parsed: Callable


func _ready() -> void:
	for child in get_children():
		remove_child(child)
		child.free()
	parsed = Callable(FuncUtilsV03, func_name)

	var step := 2.0 / resolution
	for idx in range(resolution * resolution):
		var node     := CSGBox3D.new()
		node.size = Vector3(step, step, step)
		var material := ShaderMaterial.new()
		material.shader = shader
		node.material = material
		add_child(node)



func _process(_delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	var step := 2.0 / resolution
	var children := get_children()
	
	for idx in range(len(children)):
		var child := children[idx]
		if child is CSGBox3D:
			var x := idx / resolution
			var z := idx % resolution
			var u := (x + 0.5) * step - 1
			var v := (z + 0.5) * step - 1
			child.position = parsed.call(u, v, time)
