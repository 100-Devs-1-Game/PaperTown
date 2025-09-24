@tool
extends Node

# Update the target's angle so it flips around slowly

@export var target: Node3D:
	set(v):
		target = v
		update_configuration_warnings()
@export var movement_component: MovementComponent:
	set(v):
		movement_component = v
		update_configuration_warnings()

@export var speed: float = 360.0 * 3  # angle per second
@export var inverse: bool = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not target:
		warnings.append("Select a target to flip")

	if not movement_component:
		warnings.append("Select a movement component")

	return warnings


func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(false)


func _process(delta: float) -> void:
	if target and movement_component:
		var angle := 180.0 if movement_component.facing_right else 0.0
		if inverse:
			angle *= -1

		target.rotation_degrees.y = move_toward(target.rotation_degrees.y, angle, speed * delta)
