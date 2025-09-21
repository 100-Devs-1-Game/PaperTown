class_name Player extends CharacterBody3D

enum State { MOVEMENT, ATTACK }

const STATS = preload("res://game/resources/stats.tres")

var direction
var attack_distance := 1.5
var attack_time = 1.0
var player_state: State
var stats = STATS

@onready var movement_component = $MovementComponent
@onready var overworld_attack_component = $OverworldAttackComponent
@onready var collision_shape_3d = $CollisionShape3D


func _ready():
	player_state = State.MOVEMENT

	if stats == null:
		push_error("Player stats not loaded!")
		return

	print("Player Stats Loaded:")
	#print("Player Name: %s" % stats.player_name)
	print("Level: %s" % stats.level)
	#print("Max HP: %s" % stats.max_HP)
	#print("Current HP: %s" % stats.current_hp)
	#print("Attack: %s" % stats.attack)
	#print("Defense: %s" % stats.defense)
	#print("Speed: %s" % stats.speed)
	print("Luck: %s" % stats.luck)


func _physics_process(delta):
	# TODO: final code is going to be much more sophisticated than this

	match player_state:
		State.MOVEMENT:
			handle_movement(delta)
		State.ATTACK:
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
	var x_movement := Input.get_action_strength("right") - Input.get_action_strength("left")
	var z_movement := Input.get_action_strength("down") - Input.get_action_strength("up")

	if (
		(movement_component.facing_right == true and x_movement < 0.0)
		or (movement_component.facing_right == false and x_movement > 0.0)
	):
		movement_component.swap_facing_direction()

	return Vector3(x_movement, velocity.y, z_movement)


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
