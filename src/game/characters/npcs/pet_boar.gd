extends CharacterBody3D

@export var player: CharacterBody3D
@export var space_from_player: float = 1.0

var following_player := true

@onready var navigation_agent_3d = $NavigationAgent3D
@onready var movement_component = $MovementComponent
@onready var collision_shape_3d = $CollisionShape3D


func _ready():
	player.stop_moving_companion.connect(on_player_wants_space)
	player.start_moving_companion.connect(on_player_space_exited)


func _physics_process(delta):
	movement_component.apply_gravity(delta, self)
	if following_player:
		movement_component.update_target_location(navigation_agent_3d, player.global_position)
		movement_component.move_to_target(navigation_agent_3d, self)


func calculate_target_position():
	return


func on_player_wants_space():
	print("entered!")
	following_player = false
	#navigation_agent_3d.target_position = global_position
	#movement_component.move_to_target(navigation_agent_3d, self)


func on_player_space_exited():
	following_player = true
