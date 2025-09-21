class_name Enemy extends CharacterBody3D

enum State { WANDER, ALERT, CHASE }

const STATS = preload("res://game/resources/stats.tres")

var stats = STATS.duplicate(true)
var state: State
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


func _ready():
	detection_bubble.body_entered.connect(on_detection_bubble_body_entered)
	alert_timer.timeout.connect(on_alert_timeout)
	walk_timer.timeout.connect(on_walk_timeout)

	debug_excla_mark.text = ""

	state = State.WANDER

	movement_component.get_random_spot(navigation_agent_3d, self)
	walk_timer.start()


func _physics_process(delta):
	movement_component.apply_gravity(delta, self)

	match state:
		State.WANDER:
			wander()
		State.ALERT:
			alert()
		State.CHASE:
			chase()


func wander():
	movement_component.move_to_target(navigation_agent_3d, self)


func alert():
	pass


func chase():
	movement_component.update_target_location(navigation_agent_3d, target.global_position)
	movement_component.move_to_target(navigation_agent_3d, self)


func on_alert_timeout():
	state = State.CHASE
	debug_excla_mark.text = ""
	overworld_attack_component.generate_attack(self, 0.0, 0.0, -1.0)


func on_walk_timeout():
	if state != State.WANDER:
		return

	movement_component.get_random_spot(navigation_agent_3d, self)
	movement_component.move_to_target(navigation_agent_3d, self)
	walk_timer.start()


func on_detection_bubble_body_entered(body):
	if (
		body in get_tree().get_nodes_in_group("player")
		and state != State.ALERT
		and state != State.CHASE
	):
		state = State.ALERT
		debug_excla_mark.text = "!!"
		target = body
		alert_timer.start()
