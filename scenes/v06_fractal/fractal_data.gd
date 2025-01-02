class_name FractalData


var depth: int
var idx: int
var parent_idx: int
var position: Vector3
var world_quaternion: Quaternion
var spin_angle: float

var name: String:
	get:
		return "FractalData[depth = {0}, idx = {1}, parent_idx = {2}]".format(
			[depth, idx, parent_idx]
		)

var scale: Vector3:
	get:
		return (0.5 ** depth) * Vector3.ONE


func _init(new_depth: int, new_idx: int, new_parent_idx: int) -> void:
	depth = new_depth
	idx = new_idx
	parent_idx = new_parent_idx
	position = Vector3.ZERO
	world_quaternion = Quaternion.IDENTITY
	spin_angle = 0
