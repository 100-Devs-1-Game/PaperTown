extends Node

var following_player := false

func stop_following_player():
	following_player = false

func start_following_player():
	following_player = true

func follow_player(navigation_agent_3d: NavigationAgent3D, movement_component: MovementComponent, player: CharacterBody3D, follower: CharacterBody3D):
	if following_player:
		movement_component.update_target_location(navigation_agent_3d, player.global_position)
		movement_component.move_to_target(navigation_agent_3d, follower)
