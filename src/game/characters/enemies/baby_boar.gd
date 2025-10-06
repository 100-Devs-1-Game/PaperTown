extends CharacterBody3D

enum State { IDLE, FOLLOWER, BATTLE }

@export var player: CharacterBody3D

var current_state: State = State.FOLLOWER

@onready var follower_component = $FollowerComponent
@onready var movement_component = $MovementComponent
@onready var navigation_agent_3d = $NavigationAgent3D
@onready var animated_sprite_3d = $Visuals/AnimatedSprite3D


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
	if not follower_component.following_player:
		animated_sprite_3d.frame = 2
		animated_sprite_3d.pause()
	else:
		animated_sprite_3d.play("default")


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
