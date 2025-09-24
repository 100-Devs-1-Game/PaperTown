class_name Player extends CharacterBody3D

enum State { MOVEMENT, ATTACK, BATTLE }

const STATS = preload("res://game/resources/stats.tres")

var direction
var attack_distance := 1.5
var attack_time = 1.0
var player_state: State
var stats = STATS

@onready var visuals: Node3D = %Visuals
@onready var animated_sprite_3d: AnimatedSprite3D = %AnimatedSprite3D

@onready var movement_component = %MovementComponent
@onready var overworld_attack_component = %OverworldAttackComponent
@onready var collision_shape_3d = %CollisionShape3D


func _ready():
	player_state = State.MOVEMENT

	if stats == null:
		push_error("Player stats not loaded!")
		return


func _physics_process(delta):
	# TODO: final code is going to be much more sophisticated than this

	match player_state:
		State.MOVEMENT:
			handle_movement(delta)
		State.ATTACK:
			pass
		State.BATTLE:
			pass


func handle_movement(delta):
	movement_component.apply_gravity(delta, self)
	var movement_vector = get_movement_vector()
	direction = movement_vector.normalized()

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		movement_component.jump(self)

	movement_component.accelerate_in_direction(direction)
	movement_component.move(self)

	if Input.is_action_just_pressed("attack_overworld"):
		handle_attack()


func get_movement_vector():
	var input_dir := (
		Vector2(Input.get_axis(&"left", &"right"), Input.get_axis(&"up", &"down")).normalized()
	)

	if (
		(movement_component.facing_right == true and input_dir.x < 0.0)
		or (movement_component.facing_right == false and input_dir.x > 0.0)
	):
		movement_component.swap_facing_direction()

	return Vector3(input_dir.x, velocity.y, input_dir.y)


# TODO: This should be handled by anim player
func handle_attack():
	if not is_on_floor():
		return

	player_state = State.ATTACK
	var dir = 1.0 if movement_component.facing_right else -1.0
	overworld_attack_component.generate_attack(self, dir, attack_distance, attack_time)


# This will likely get obsolete with an anim player
func exit_attack_state():
	player_state = State.MOVEMENT


func set_battle_state(in_battle: bool) -> void:
	if in_battle:
		player_state = State.BATTLE
	else:
		player_state = State.MOVEMENT
