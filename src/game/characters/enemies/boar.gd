class_name Enemy extends ICharacter

enum State { WANDER, ALERT, CHASE, BATTLE }

const STATS = preload("res://game/resources/stats.tres")

@export var friendly := false

var stats = STATS.duplicate(true)
var current_state: State
var target: CharacterBody3D = null
var chase_time := -1.0
var wander_cooldown := false

@onready var overworld_attack_component = $OverworldAttackComponent
@onready var movement_component = $MovementComponent
@onready var alert_timer = $AlertTimer
@onready var detection_bubble = $DetectionBubble
@onready var walk_timer = $WalkTimer
@onready var navigation_agent_3d = $NavigationAgent3D
@onready var debug_excla_mark = $Visuals/debug_excla_mark
@onready var animated_sprite_3d: AnimatedSprite3D = $Visuals/AnimatedSprite3D

signal enemy_state_changed(new_state: State)


func _ready():
	assert(alert_timer.one_shot)
	assert(walk_timer.one_shot)

	detection_bubble.body_entered.connect(on_detection_bubble_body_entered)
	detection_bubble.body_exited.connect(on_detection_bubble_body_exited)
	alert_timer.timeout.connect(on_alert_timeout)
	walk_timer.timeout.connect(on_walk_timeout)

	debug_excla_mark.text = ""

	change_state(State.WANDER)


func _physics_process(delta):
	movement_component.apply_gravity(delta, self)

	match current_state:
		State.WANDER:
			wander()
		State.ALERT:
			alert()
		State.CHASE:
			chase()


func wander():
	movement_component.move_to_target(navigation_agent_3d, self)
	if movement_component.reached_destination:
		animated_sprite_3d.play(&"idle")
	else:
		animated_sprite_3d.play(&"walk")


func alert():
	pass


func chase():
	if friendly:
		return

	movement_component.update_target_location(navigation_agent_3d, target.global_position)
	movement_component.move_to_target(navigation_agent_3d, self)
	animated_sprite_3d.play(&"charge")


func on_alert_timeout():
	if friendly:
		return

	change_state(State.CHASE)
	debug_excla_mark.text = ""
	var dir_to_player := (get_tree().get_first_node_in_group("player") as Node3D).global_position - global_position
	# min(1.5, dir_to_player.length())
	var _attack: IOverworldAttack = overworld_attack_component.generate_attack(self, dir_to_player.normalized().x, 0, -1)


func on_walk_timeout():
	if current_state != State.WANDER:
		return

	movement_component.get_random_spot(navigation_agent_3d, self)
	movement_component.move_to_target(navigation_agent_3d, self)
	walk_timer.start()


func on_detection_bubble_body_entered(body):
	if friendly:
		return

	if body in get_tree().get_nodes_in_group("player") and current_state == State.WANDER:
		change_state(State.ALERT)
		debug_excla_mark.text = "!!"
		target = body
		alert_timer.start()
		movement_component.face_position(target.global_position)


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	if friendly && new_state != State.WANDER:
		return

	current_state = new_state
	enemy_state_changed.emit(current_state)

	if current_state == State.WANDER:
		movement_component.update_target_location(navigation_agent_3d, global_position)
		movement_component.move_to_target(navigation_agent_3d, self)
		walk_timer.start()

func on_detection_bubble_body_exited(body):
	if body in get_tree().get_nodes_in_group("player") and (current_state == State.CHASE or current_state == State.ALERT):
		overworld_attack_component.resolve_attack()
		

func exit_attack_state():
	debug_excla_mark.text = ""
	change_state(State.WANDER)
