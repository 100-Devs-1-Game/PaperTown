extends Node

@export var overworld_attack: PackedScene
var on_attack_cooldown := false
var attack: IOverworldAttack


# TODO: Link to an anim player
func generate_attack(
	character_body: CharacterBody3D, dir: float, dist: float, time: float
) -> IOverworldAttack:
	if on_attack_cooldown:
		return null

	attack = overworld_attack.instantiate()
	assert(attack)

	character_body.add_child(attack)
	attack.global_position = Vector3(
		character_body.global_position.x + (dist * dir),
		character_body.global_position.y,
		character_body.global_position.z
	)
	if time > 0:
		attack.lasting_timer.timeout.connect(on_timer_timeout)
		attack.start_timer(time)
	on_attack_cooldown = true
	return attack


# Below will be obsolete with anim player
func resolve_attack():
	if attack != null:
		attack.queue_free()
	on_attack_cooldown = false
	get_parent().exit_attack_state()


func on_timer_timeout():
	resolve_attack()
