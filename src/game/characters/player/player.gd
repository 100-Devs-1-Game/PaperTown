class_name Player extends ICharacter

enum State { MOVEMENT, ATTACK, BATTLE }

const STATS = preload("res://game/resources/stats.tres")

var direction
var attack_distance := 1.5
var attack_time = 0.3
var current_state: State
var stats = STATS
var talkable_npcs = []
var talkable_state := false
var facing_behind := false

@onready var visuals: Node3D = %Visuals
@onready var animated_sprite_3d: AnimatedSprite3D = %AnimatedSprite3D

@onready var movement_component = %MovementComponent
@onready var overworld_attack_component = %OverworldAttackComponent
@onready var collision_shape_3d = %CollisionShape3D
@onready var personal_space_bubble = $PersonalSpaceBubble

signal player_state_changed(new_state: State)


func _ready():
	change_state(State.MOVEMENT)

	personal_space_bubble.body_entered.connect(on_body_entered)
	personal_space_bubble.body_exited.connect(on_body_exited)

	if stats == null:
		push_error("Player stats not loaded!")
		return


func _physics_process(delta):
	# TODO: final code is going to be much more sophisticated than this

	match current_state:
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
		var ft3d := FloatingText.spawn(global_position + Vector3(0, 2, 0), "oop")
		ft3d.scale *= 0.25
		ft3d.randomize_position(Vector3(1, 0.5, 0))
		FloatingText.animate_towards(
			ft3d, ft3d.global_position + (Vector3(randf_range(-2, 2), 2, 0).normalized() * 2), 1
		)

	movement_component.accelerate_in_direction(direction)
	movement_component.move(self)

	if Input.is_action_just_pressed("attack_overworld"):
		if talkable_state:
			talkable_npcs[talkable_npcs.size() - 1].npc_component.interact_with_player()
		else:
			handle_attack()


func get_movement_vector():
	var input_dir := Vector2(Input.get_axis(&"left", &"right"), Input.get_axis(&"up", &"down"))

	if (
		(movement_component.facing_right == true and input_dir.x < 0.0)
		or (movement_component.facing_right == false and input_dir.x > 0.0)
	):
		movement_component.swap_facing_direction()

	if input_dir.length() > 0.0:
		if input_dir.y >= 0.0:
			facing_behind = false
			animated_sprite_3d.play(&"walk")
		else:
			facing_behind = true
			animated_sprite_3d.play(&"walk_behind")
	else:
		animated_sprite_3d.play(&"idle" if not facing_behind else &"idle_behind")

	return Vector3(input_dir.x, 0.0, input_dir.y)


# TODO: This should be handled by anim player
func handle_attack():
	if not is_on_floor():
		return

	change_state(State.ATTACK)
	var dir := 1.0 if movement_component.facing_right else -1.0
	overworld_attack_component.generate_attack(self, dir, attack_distance, attack_time)

	var ft3d := FloatingText.spawn(global_position + (Vector3.UP * 0.5), "boop")
	ft3d.scale *= 0.5
	ft3d.randomize_position(Vector3(0.25, 0.25, 0))
	FloatingText.animate_towards(
		ft3d, ft3d.position + (Vector3.RIGHT * dir * attack_distance) + Vector3.UP, 1
	)


func add_talkable_npc(body: CharacterBody3D):
	talkable_state = true
	talkable_npcs.append(body)


func remove_talkable_npc(body: CharacterBody3D):
	if body in talkable_npcs:
		talkable_npcs.erase(body)

	if talkable_npcs.is_empty():
		talkable_state = false


# This will likely get obsolete with an anim player
func exit_attack_state():
	change_state(State.MOVEMENT)


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	player_state_changed.emit(current_state)


func on_body_entered(body):
	print("body entered!")
	if body in get_tree().get_nodes_in_group("followers"):
		print("STOP!!!")
		body.follower_component.stop_following_player()


func on_body_exited(body):
	if body in get_tree().get_nodes_in_group("followers"):
		body.follower_component.start_following_player()
