@tool
class_name VisualFunction
extends Node3D

@export_enum("wave", "sin", "multi_wave", "ripple") var func_name: String
@export var data_range: Vector3
@export var shader: Shader

var parsed: Callable


func _ready() -> void:
	for child in get_children():
		remove_child(child)
		child.free()
	parsed = Callable(FuncUtils, func_name)

	var x := data_range.x
	var z: float = data_range.z
	while x < data_range.y:
		var node := CSGBox3D.new()
		node.size = Vector3(z, z, z)
		var material := ShaderMaterial.new()
		material.shader = shader
		node.material = material
		node.position = Vector3(x, 0, 0)
		add_child(node)
		x += z


func _process(_delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	for child in get_children():
		if child is CSGBox3D:
			child.position.y = parsed.call(child.position.x, time)
