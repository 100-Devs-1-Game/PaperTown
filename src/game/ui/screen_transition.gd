class_name ScreenTransition
extends Control

enum TransitionType { NONE, BATTLE_START, BATTLE_WON, BATTLE_LOST }

var current_transition := TransitionType.NONE

var transition_dictionary = {
	TransitionType.NONE: {"animation_name": "", "scene_transition_frame": 0},
	TransitionType.BATTLE_START: {"animation_name": "battle_start", "scene_transition_frame": 25},
	TransitionType.BATTLE_WON: {"animation_name": "battle_victory", "scene_transition_frame": 27},
	TransitionType.BATTLE_LOST: {"animation_name": "battle_defeat", "scene_transition_frame": 25}
}

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

signal transition_halfway


func _physics_process(_delta):
	if (
		animated_sprite_2d.frame
		== transition_dictionary[current_transition]["scene_transition_frame"]
	):
		transition_halfway.emit()


func do_transition(new_transition: TransitionType):
	get_tree().paused = true

	current_transition = new_transition

	var transition_animation = transition_dictionary[current_transition]["animation_name"]

	animated_sprite_2d.play(transition_animation)
	await animated_sprite_2d.animation_finished
	get_tree().paused = false
	self.queue_free()
