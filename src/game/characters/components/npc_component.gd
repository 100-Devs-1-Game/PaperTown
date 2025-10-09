class_name NPCComponent extends Node

const BALLOON := preload("res://game/dialogue/balloon.tscn")

@export var talking_range: Area3D
@export var movement_component: MovementComponent
@export var dialogue: DialogueResource

var is_talkable := true

signal interacted_with


func _ready():
	assert(dialogue)
	talking_range.body_entered.connect(on_body_entered)
	talking_range.body_exited.connect(on_body_exited)
	var bodies := talking_range.get_overlapping_bodies()
	for body in bodies:
		on_body_entered(body)

func interact_with_player(title: String = "start"):
	Dialogue.player.movement_component.face_position(get_parent().global_position)
	interacted_with.emit()
	DialogueManager.show_dialogue_balloon_scene(BALLOON, dialogue, title, [self])


func on_body_entered(body):
	if not is_talkable:
		return

	var player := body as Player
	if not player:
		return

	if movement_component:
		movement_component.face_position(body.global_position)
	player.add_talkable_npc(get_parent())


func on_body_exited(body):
	var player := body as Player
	if not player:
		return

	body.remove_talkable_npc(get_parent())
