extends CharacterBody3D

@export var player : CharacterBody3D

@onready var follower_component = $FollowerComponent
@onready var movement_component = $MovementComponent
@onready var navigation_agent_3d = $NavigationAgent3D



func _physics_process(delta):
	movement_component.apply_gravity(delta, self)
	follower_component.follow_player(navigation_agent_3d, movement_component, player, self)
