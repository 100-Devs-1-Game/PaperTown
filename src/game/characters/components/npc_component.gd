extends Node

@export var talking_range: Area3D
@export var movement_component: MovementComponent

var is_talkable := true

signal interacted_with


func _ready():
	talking_range.body_entered.connect(on_body_entered)
	talking_range.body_exited.connect(on_body_exited)


func interact_with_player():
	print("debug talking yay!")
	interacted_with.emit()


func on_body_entered(body):
	if is_talkable and body in get_tree().get_nodes_in_group("player"):
		print("hi!")
		movement_component.face_position(body.global_position)
		body.add_talkable_npc(get_parent())


func on_body_exited(body):
	if is_talkable and body in get_tree().get_nodes_in_group("player"):
		print("bye!")
		body.remove_talkable_npc(get_parent())
