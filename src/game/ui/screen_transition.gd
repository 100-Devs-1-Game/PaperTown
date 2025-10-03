class_name ScreenTransition
extends Control

const BATTLE_START_TRANSITION_FRAME = 25

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

signal transition_halfway

func _physics_process(delta):
	if animated_sprite_2d.frame == BATTLE_START_TRANSITION_FRAME:
		transition_halfway.emit()

func do_transition():
	get_tree().paused = true
	animated_sprite_2d.play("battle_start")
	await animated_sprite_2d.animation_finished
	get_tree().paused = false
	self.queue_free()
