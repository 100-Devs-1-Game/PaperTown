class_name Enemy extends CharacterBody3D

enum State { WANDER, ALERT, CHASE, BATTLE }

const STATS = preload("res://game/resources/stats.tres")

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
	detection_bubble.body_entered.connect(on_detection_bubble_body_entered)
	alert_timer.timeout.connect(on_alert_timeout)
	walk_timer.timeout.connect(on_walk_timeout)

	debug_excla_mark.text = ""

	change_state(State.WANDER)

	movement_component.get_random_spot(navigation_agent_3d, self)
	walk_timer.start()


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
	movement_component.update_target_location(navigation_agent_3d, target.global_position)
	movement_component.move_to_target(navigation_agent_3d, self)
	animated_sprite_3d.play(&"charge")


func on_alert_timeout():
	change_state(State.CHASE)
	debug_excla_mark.text = ""
	overworld_attack_component.generate_attack(self, 0.0, 0.0, -1.0)


func on_walk_timeout():
	if current_state != State.WANDER:
		return

	movement_component.get_random_spot(navigation_agent_3d, self)
	movement_component.move_to_target(navigation_agent_3d, self)
	walk_timer.start()


func on_detection_bubble_body_entered(body):
	if body in get_tree().get_nodes_in_group("player") and current_state == State.WANDER:
		change_state(State.ALERT)
		debug_excla_mark.text = "!!"
		target = body
		alert_timer.start()


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	enemy_state_changed.emit(current_state)
