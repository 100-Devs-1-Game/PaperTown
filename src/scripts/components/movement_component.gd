extends Node

@export var max_movement_speed: float = 5.0
@export var jump_strength: float = 5.0
@export var gravity: float = 5.0
@export var friction: float = 0.8

var snap_vector := Vector3.DOWN
var velocity = Vector3.ZERO
var facing_right := false


func accelerate_in_direction(direction: Vector3):
	velocity = direction * max_movement_speed


func apply_gravity(delta, character_body: CharacterBody3D):
	character_body.velocity.y -= gravity * delta


func move(character_body: CharacterBody3D):
	character_body.velocity.x = velocity.x
	character_body.velocity.z = velocity.z
	character_body.move_and_slide()
	velocity = character_body.velocity


func jump(character_body: CharacterBody3D):
	character_body.velocity.y += jump_strength


func swap_facing_direction():
	facing_right = not facing_right
