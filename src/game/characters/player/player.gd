class_name Player extends ICharacter

enum State { MOVEMENT, ATTACK, BATTLE, CUTSCENE }

var direction: Vector3
var attack_distance := 1.5
var attack_time = 0.3
var current_state: State
var stats := preload("res://game/resources/player_stats.tres")
var talkable_npcs: Array[Node3D] = []
var talkable_state := false
var facing_behind := false
var attacking := false

@onready var visuals: Node3D = %Visuals
@onready var animated_sprite_3d: AnimatedSprite3D = %AnimatedSprite3D

@onready var movement_component: MovementComponent = %MovementComponent
@onready var overworld_attack_component: OverworldAttackComponent = %OverworldAttackComponent
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var personal_space_bubble: Area3D = $PersonalSpaceBubble

signal player_state_changed(new_state: State)
signal player_jump


func _ready():
	change_state(State.MOVEMENT)

	animated_sprite_3d.play(&"idle")
	personal_space_bubble.body_entered.connect(on_body_entered)
	personal_space_bubble.body_exited.connect(on_body_exited)

	if stats == null:
		push_error("Player stats not loaded!")
		return


func _physics_process(delta):
	# TODO: final code is going to be much more sophisticated than this


	if Dialogue.dialogue_is_running:
		movement_component.velocity = Vector3.ZERO
		movement_component.apply_gravity(delta, self)
		animation_handler(Vector3.ZERO)
		movement_component.move(self)
	else:
		movement_component.apply_gravity(delta, self)
		match current_state:
			State.MOVEMENT:
				handle_movement(delta)
			State.ATTACK:
				pass
			State.BATTLE:
				animation_handler(Vector3.ZERO)
				movement_component.move(self)
			State.CUTSCENE:
				animation_handler(Vector3.ZERO)
				movement_component.move(self)

func handle_movement(_delta):
	var movement_vector := get_movement_vector()
	direction = movement_vector.normalized()

	if Input.is_action_just_pressed("jump"):
		movement_component.jump(self)
		player_jump.emit()
		if facing_behind:
			animated_sprite_3d.play(&"jump_behind")
		else:
			animated_sprite_3d.play(&"jump")
		var ft3d := FloatingText.spawn(global_position + Vector3(0, 1, 2), "oop")
		FloatingText.colour(ft3d, Color.CORNFLOWER_BLUE)
		ft3d.scale *= 0.5
		var facing_mul := -1 if movement_component.facing_right else 1
		FloatingText.animate_towards(
			ft3d, ft3d.global_position + (Vector3(randf_range(0, 6) * facing_mul, 2, 0).normalized() * 2), 1
		)

	movement_component.accelerate_in_direction(direction)
	movement_component.move(self)

	if Input.is_action_just_pressed("attack_overworld"):
		if talkable_state:
			var closest_npc := talkable_npcs[0]
			for npc in talkable_npcs:
				if (npc.global_position - global_position).length_squared() < (closest_npc.global_position - global_position).length_squared():
					closest_npc = npc

			closest_npc.npc_component.interact_with_player()
		else:
			pass#handle_attack()

func animation_handler(movement_direction: Vector3):
	if (
		(movement_component.facing_right == true and movement_direction.x < 0.0)
		or (movement_component.facing_right == false and movement_direction.x > 0.0)
	):
		movement_component.swap_facing_direction()

	if movement_direction.length() > 0.0:
		if movement_direction.z >= 0.0:
			facing_behind = false
		else:
			facing_behind = true

	if not is_on_floor():
		return

	if attacking:
		return

	if movement_direction != Vector3.ZERO:
		if not facing_behind && animated_sprite_3d.animation != &"walk":
			print("walk")
			animated_sprite_3d.play(&"walk")
		elif facing_behind && animated_sprite_3d.animation != &"walk_behind":
			print("walk_behind")
			animated_sprite_3d.play(&"walk_behind")
	else:
		if facing_behind && animated_sprite_3d.animation != &"idle_behind":
			print("idle_behind")
			animated_sprite_3d.play(&"idle_behind")
		elif movement_direction == Vector3.ZERO && not facing_behind && animated_sprite_3d.animation != &"idle":
			print("idle")
			animated_sprite_3d.play(&"idle")

func get_movement_vector() -> Vector3:
	var input_dir := Vector2(Input.get_axis(&"left", &"right"), Input.get_axis(&"up", &"down"))
	var movement_vector := Vector3(input_dir.x, 0.0, input_dir.y)
	animation_handler(movement_vector)
	return movement_vector


# TODO: This should be handled by anim player
# TODO: disabling overworld attack because boars attack player and that's enough for now
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


func add_talkable_npc(body: Node3D):
	talkable_state = true
	talkable_npcs.append(body)


func remove_talkable_npc(body: Node3D):
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

	if current_state == State.BATTLE:
		facing_behind = false
		movement_component.facing_right = true

	if current_state == State.CUTSCENE:
		movement_component.velocity = Vector3.ZERO


func on_body_entered(_body):
	print("body entered player!")
	#if body in get_tree().get_nodes_in_group("followers"):
		#print("STOP!!!")
		#body.follower_component.stop_following_player()


func on_body_exited(body):
	if body in get_tree().get_nodes_in_group("followers"):
		if body is Rudolph and not Dialogue.finished_rudolph_intro:
			return
		body.follower_component.start_following_player()


func get_animated_sprite() -> AnimatedSprite3D:
	return animated_sprite_3d


func play_attack_visuals_one(target: ICharacter) -> void:
	assert(current_state == State.BATTLE)
	assert(not attacking)

	attacking = true


func play_attack_visuals_two(target: ICharacter) -> void:
	assert(current_state == State.BATTLE)
	assert(not attacking)

	attacking = true


func end_attack_visuals_one(target: ICharacter) -> void:
	assert(current_state == State.BATTLE)
	assert(attacking)

	animated_sprite_3d.play(&"tongueslap")
	await animated_sprite_3d.animation_finished
	attacking = false
	print("FINISHED ATK1")


func end_attack_visuals_two(target: ICharacter) -> void:
	assert(current_state == State.BATTLE)
	assert(attacking)

	animated_sprite_3d.play(&"tailwhip")
	await animated_sprite_3d.animation_finished
	attacking = false
	print("FINISHED ATK2")


func play_damaged_visual() -> void:
	assert(current_state == State.BATTLE)
	assert(not attacking)

	attacking = true
	animated_sprite_3d.play(&"hit")
	await animated_sprite_3d.animation_finished
	print("FINISHED HIT")
	attacking = false


func play_dodged_visual() -> void:
	assert(current_state == State.BATTLE)
	assert(not attacking)

	attacking = true
	var idle_frame := 0
	if animated_sprite_3d.animation == &"idle":
		idle_frame = animated_sprite_3d.frame

	animated_sprite_3d.play(&"idle_invisible")
	animated_sprite_3d.frame = idle_frame

	await get_tree().create_timer(1.0).timeout
	attacking = false
	print("FINISHED DODGE")
