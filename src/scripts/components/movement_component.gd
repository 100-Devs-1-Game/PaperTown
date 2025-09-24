class_name MovementComponent
extends Node

@export var max_movement_speed: float = 5.0
@export var jump_strength: float = 5.0
@export var gravity: float = 5.0
@export var friction: float = 0.8
@export var unit_travel := 30.0
@export var target_position: Vector3

var snap_vector := Vector3.DOWN
var velocity = Vector3.ZERO
var facing_right := false
var reached_destination := false


func accelerate_in_direction(direction: Vector3):
	velocity = direction * max_movement_speed
	facing_right = velocity.x > 0


func update_target_location(nav_agent, target_location):
	reached_destination = false
	nav_agent.set_target_position(target_location)


func move_to_target(nav_agent: NavigationAgent3D, character_body: CharacterBody3D):
	if reached_destination:
		return

	var next_location = nav_agent.get_next_path_position()
	var local_location = next_location - character_body.global_position

	var direction = local_location.normalized()
	accelerate_in_direction(direction)
	move(character_body)

	if nav_agent.is_navigation_finished():
		reached_destination = true


func apply_gravity(delta, character_body: CharacterBody3D):
	character_body.velocity.y -= gravity * delta


func get_random_spot(nav_agent, character_body: CharacterBody3D):
	reached_destination = false
	var x_movement_coefficient = randi_range(-1, 1)
	var z_movement_coefficient = randi_range(-1, 1)

	var current_position = character_body.position

	target_position = Vector3(
		current_position.x + (unit_travel * x_movement_coefficient),
		current_position.y,
		current_position.z + (unit_travel * z_movement_coefficient)
	)
	update_target_location(nav_agent, target_position)


func move(character_body: CharacterBody3D):
	character_body.velocity.x = velocity.x
	character_body.velocity.z = velocity.z
	character_body.move_and_slide()
	velocity = character_body.velocity


func jump(character_body: CharacterBody3D):
	character_body.velocity.y += jump_strength


func swap_facing_direction():
	facing_right = not facing_right
