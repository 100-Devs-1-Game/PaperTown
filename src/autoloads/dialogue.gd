extends Node

var player: Player:
	get():
		return get_tree().get_first_node_in_group("player")

var finished_rudolph_intro := false
var started_acorn_quest := false
var finished_acorn_quest := false
var can_finish_acorn_quest := false

var dialogue_is_running := false:
	get:
		return dialogue_is_running
	set(value):
		if not value:
			await get_tree().create_timer(0.25).timeout
		dialogue_is_running = value
