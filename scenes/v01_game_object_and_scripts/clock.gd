@tool
class_name Clock
extends CSGCylinder3D

const CLICK_COUNT_PREFIX        := "ClockCount"
const NAME_SECOND_POINTER       := "SecondPointer"
const NAME_MINUTE_POINTER       := "MinutePointer"
const NAME_HOUR_POINTER         := "HourPointer"
const COLOR_MINUTE_HOUR_POINTER := Color(0, 0, 0)
const COLOR_SECOND_POINTER      := Color(1, 0, 0)
@export var real_time := true
@export var smoothly := true
@export var material_counter: StandardMaterial3D
@export var material_pointer: StandardMaterial3D

var second_pointer: CSGBox3D
var minute_pointer: CSGBox3D
var hour_pointer: CSGBox3D


func _ready():
	for node in get_children():
		if node is CSGBox3D and node.get_name().begins_with(CLICK_COUNT_PREFIX):
			var idx: int             = int(node.get_name().replace(CLICK_COUNT_PREFIX, "")) % 12
			var duplicated: Resource = material_counter.duplicate()
			if duplicated is StandardMaterial3D:
				duplicated.albedo_color = Color.SLATE_GRAY if (idx % 3 == 0) else Color.DARK_GRAY
				node.material = duplicated
			node.position = Vector3(0, 0.06, 0)
			node.rotation = Vector3.ZERO
			node.rotate(Vector3.DOWN, 2 * PI * idx / 12)
			node.transform = node.transform.translated(-node.transform.basis.z * 0.8)

	second_pointer = get_node(NAME_SECOND_POINTER)
	minute_pointer = get_node(NAME_MINUTE_POINTER)
	hour_pointer = get_node(NAME_HOUR_POINTER)

	init_pointer_position()
	init_pointer_rotation()


func init_pointer_position():
	second_pointer.position = Vector3(0, 0.24, 0)
	minute_pointer.position = Vector3(0, 0.12, 0)
	hour_pointer.position = Vector3(0, 0.18, 0)


func init_pointer_rotation():
	second_pointer.rotation = Vector3.ZERO
	minute_pointer.rotation = Vector3.ZERO
	hour_pointer.rotation = Vector3.ZERO


func _process(delta):
	var duplicated: Resource = material_pointer.duplicate()
	if duplicated is StandardMaterial3D:
		duplicated.albedo_color = COLOR_SECOND_POINTER
		second_pointer.material = duplicated

	var duplicated2: Resource = material_pointer.duplicate()
	if duplicated2 is StandardMaterial3D:
		duplicated2.albedo_color = COLOR_MINUTE_HOUR_POINTER
		minute_pointer.material = duplicated2
		hour_pointer.material = duplicated2

	init_pointer_position()
	if real_time:
		init_pointer_rotation()

		var subsec: float = 0.0
		if smoothly:
			var timestamp: float = Time.get_unix_time_from_system()
			subsec = timestamp - int(timestamp)
		var now: Dictionary = Time.get_time_dict_from_system()

		var seconds: float = now["second"] + subsec
		var minutes: float = now["minute"] + seconds / 60
		var hours: float   = now["hour"] + minutes / 60

		second_pointer.rotate(-second_pointer.transform.basis.y, seconds / 60.0 * TAU)
		minute_pointer.rotate(-minute_pointer.transform.basis.y, minutes / 60.0 * TAU)
		hour_pointer.rotate(-hour_pointer.transform.basis.y, hours / 12.0 * TAU)
	else:
		second_pointer.rotate(-second_pointer.transform.basis.y, delta / 60.0 * TAU)
		minute_pointer.rotate(-minute_pointer.transform.basis.y, delta / 3600.0 * TAU)
		hour_pointer.rotate(-hour_pointer.transform.basis.y, delta / (3600.0 * 12) * TAU)

	second_pointer.translate(Vector3.FORWARD * 0.3)
	minute_pointer.translate(Vector3.FORWARD * 0.2)
	hour_pointer.translate(Vector3.FORWARD * 0.05)
