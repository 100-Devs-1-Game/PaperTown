class_name Camera extends Camera3D

enum State {
	FOLLOW_PLAYER,
	MANUAL
}

@export var offset: Vector3 = Vector3.ZERO
@export var speed: float = 5.0
@export var state: State = State.FOLLOW_PLAYER
@export var target: Node3D
@export var target_angle: float = -20.0
@export var target_fov: float = 45.0


func _ready() -> void:
	if offset == Vector3.ZERO:
		offset = global_position

	if global_position == Vector3.ZERO:
		offset = Vector3(0, 6.0, 18.0)

	global_rotation.x = deg_to_rad(target_angle)
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	fov = move_toward(fov, target_fov, delta)
	global_rotation.x = deg_to_rad(target_angle)

	if state == State.FOLLOW_PLAYER:
		if !target:
			target = get_tree().get_first_node_in_group("player")
			if !target:
				return

	if !target:
		push_error("pls assign a target for the camera, thx")
		assert(false)
		return

	var distance := ((target.global_position + offset) - global_position).length()
	# a very well thought out smoothing function. yes.
	var speed_mul := 4 * clampf(distance / 10.0, 0.0, 1.0)
	#print(distance, " = ", speed_mul)
	global_position = global_position.move_toward(
		target.global_position + offset, delta * speed * speed_mul
	)
