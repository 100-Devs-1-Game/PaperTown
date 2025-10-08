extends CharacterBody3D

enum State { IDLE, FOLLOWER, BATTLE }

@export var player: CharacterBody3D

var current_state: State = State.FOLLOWER

@onready var follower_component = $FollowerComponent
@onready var movement_component = $MovementComponent
@onready var navigation_agent_3d = $NavigationAgent3D
@onready var animated_sprite_3d = $Visuals/AnimatedSprite3D
@onready var npc_component: NPCComponent = %NPCComponent

func _ready():
	change_state(State.FOLLOWER)


func _physics_process(delta):
	if !player:
		player = get_tree().get_first_node_in_group(&"player")

	if current_state == State.FOLLOWER:
		movement_component.apply_gravity(delta, self)
		follower_component.follow_player(navigation_agent_3d, movement_component, player, self)
		play_animations()


func play_animations():
	if not follower_component.following_player and not Dialogue.can_finish_acorn_quest:
		animated_sprite_3d.play(&"sleeping")
	elif absf(movement_component.velocity.x) > 0 || absf(movement_component.velocity.z) > 0 || absf(velocity.x) > 0 || absf(velocity.z) > 0:
		animated_sprite_3d.play(&"walk")
	else:
		animated_sprite_3d.play(&"walk")
		animated_sprite_3d.frame = 2
		animated_sprite_3d.pause()


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
