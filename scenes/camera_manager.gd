extends Camera3D

const MOVEMENT_FORWARD: StringName = "movement_forward"
const MOVEMENT_BACKWARD: StringName = "movement_backward"
const MOVEMENT_LEFT: StringName = "movement_left"
const MOVEMENT_RIGHT: StringName = "movement_right"
const MOVEMENT_UP: StringName = "movement_up"
const MOVEMENT_DOWN: StringName = "movement_down"

@export var speed: float = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir_forward := 0.0
	var dir_up := 0.0
	var dir_right := 0.0
	
	if Input.is_action_pressed(MOVEMENT_FORWARD):
		dir_forward = 1.0
	elif Input.is_action_pressed(MOVEMENT_BACKWARD):
		dir_forward = -1.0
	
	if Input.is_action_pressed(MOVEMENT_UP):
		dir_up = 1.0
	elif Input.is_action_pressed(MOVEMENT_DOWN):
		dir_up = -1.0
	
	if Input.is_action_pressed(MOVEMENT_RIGHT):
		dir_right = 1.0
	elif Input.is_action_pressed(MOVEMENT_LEFT):
		dir_right = -1.0
	
	var dir := Vector3(dir_right, dir_up, -dir_forward).normalized()
	position += speed * delta * (basis * dir)
