class_name FollowerComponent extends Node

const MAX_DISTANCE_AWAY_FROM_PLAYER = 150.0

var following_player := false


func stop_following_player():
	following_player = false


func start_following_player():
	following_player = true


func follow_player(
	navigation_agent_3d: NavigationAgent3D,
	movement_component: MovementComponent,
	player: CharacterBody3D,
	follower: CharacterBody3D
):
	assert(player)
	assert(follower)
	assert(get_parent())
	assert(navigation_agent_3d)
	assert(movement_component)

	if following_player:
		if (follower.global_position - player.global_position).length_squared() > MAX_DISTANCE_AWAY_FROM_PLAYER:
			follower.global_position = Vector3(player.global_position.x - 3.0, player.global_position.y, player.global_position.z)
		#print(get_parent().name, " is following player, going to ", player.global_position, " and is now at ", get_parent().global_position)
		movement_component.update_target_location(navigation_agent_3d, player.global_position)
		movement_component.move_to_target(navigation_agent_3d, follower)
	else:
		#print(get_parent().name, " is not following player, going to ", follower.global_position, " and is now at ", get_parent().global_position)
		movement_component.update_target_location(navigation_agent_3d, follower.global_position)
		movement_component.move_to_target(navigation_agent_3d, follower)
