class_name Rudolph extends ICharacter

enum State { NPC, FOLLOWER, BATTLE }

@export var player: CharacterBody3D
@export var stats: RudolphStats

var current_state: State
var facing_behind := false
var attacking := false

@onready var npc_component: NPCComponent = $NPCComponent
@onready var follower_component:FollowerComponent = $FollowerComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animated_sprite_3d: AnimatedSprite3D = $Visuals/AnimatedSprite3D
@onready var left_behind_range: Area3D = $LeftBehindRange
@onready var jump_timer = $JumpTimer

signal rudolph_state_changed

func _ready():
	await get_parent().ready
	animated_sprite_3d.play(&"idle")

	if player:
		player.player_jump.connect(on_player_jump)

	npc_component.interacted_with.connect(on_interacted_with)
	left_behind_range.body_exited.connect(
		func(body: Node3D):
			if current_state == State.BATTLE:
				return

			assert(body)
			assert(player)

			if body != player:
				return

			if not Dialogue.finished_rudolph_intro:
				Dialogue.finished_rudolph_intro = true
				npc_component.interact_with_player("leftbehind")
				follower_component.start_following_player()
				left_behind_range.set_deferred(&"monitoring", false)
	)


func _physics_process(delta):
	if !player:
		player = get_tree().get_first_node_in_group(&"player")
		player.player_jump.connect(on_player_jump)

	movement_component.apply_gravity(delta, self)

	play_walking_animations()

	match current_state:
		State.NPC:
			follow_player()
		State.FOLLOWER:
			follow_player()
		State.BATTLE:
			movement_component.facing_right = true
			movement_component.move(self)


func follow_player():
	if current_state == State.BATTLE:
		return

	follower_component.follow_player(navigation_agent_3d, movement_component, player, self)
	facing_behind = true if velocity.z < 0 else false


func on_interacted_with():
	if current_state == State.BATTLE:
		return

	print("RUDOLPH IS NOW FOLLOWING")
	change_state(State.FOLLOWER)  # TODO: full code has to be a bit more complex


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	rudolph_state_changed.emit(current_state)

	if current_state == State.BATTLE:
		movement_component.facing_right = true


func play_walking_animations():
	if movement_component.landed_after_jump == false:
		return

	if attacking:
		return

	var animation_name := ""

	if Vector2(movement_component.velocity.x, movement_component.velocity.z).length_squared() < 0.1:
		animation_name += "idle"
	else:
		animation_name += "walk"

	if facing_behind:
		animation_name += "_behind"


	animated_sprite_3d.play(animation_name)

func play_jumping_animations():
	if attacking:
		return

	if facing_behind:
		animated_sprite_3d.play(&"jump_behind")
	else:
		animated_sprite_3d.play(&"jump")

	var ft3d := FloatingText.spawn(global_position + Vector3(0, 1, 2), "oop")
	ft3d.scale *= 0.5
	var facing_mul := -1 if movement_component.facing_right else 1
	FloatingText.animate_towards(
		ft3d, ft3d.global_position + (Vector3(randf_range(0, 6) * facing_mul, 2, 0).normalized() * 2), 1
	)


func on_player_jump():
	if not follower_component.following_player:
		return

	jump_timer.start()
	await jump_timer.timeout
	movement_component.jump(self)
	play_jumping_animations()


func exit_attack_state():
	change_state(State.FOLLOWER)

func take_damage(amount: int):
	stats.take_damage(amount)
	Signals.health_changed.emit(stats.current_hp, stats.max_hp)

func heal(amount: int):
	stats.heal(amount)
	Signals.health_changed.emit(stats.current_hp, stats.max_hp)

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

	animated_sprite_3d.play(&"heal")
	await animated_sprite_3d.animation_finished
	attacking = false


func end_attack_visuals_two(target: ICharacter) -> void:
	assert(current_state == State.BATTLE)
	assert(attacking)

	animated_sprite_3d.play(&"heal")
	await animated_sprite_3d.animation_finished
	attacking = false


func play_damaged_visual() -> void:
	assert(current_state == State.BATTLE)
	assert(not attacking)

	attacking = true
	animated_sprite_3d.play(&"hit")
	await animated_sprite_3d.animation_finished
	attacking = false
