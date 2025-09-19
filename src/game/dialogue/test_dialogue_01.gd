extends Node3D

const BALLOON := preload("res://game/dialogue/balloon.tscn")
const DIALOGUE := preload("res://game/dialogue/test_dialogue_01.dialogue")

var super_cool_test_var: bool = false


func _ready() -> void:
	#DialogueManager.show_example_dialogue_balloon(DIALOGUE)
	DialogueManager.show_dialogue_balloon_scene(BALLOON, DIALOGUE, "start", [self])


func _physics_process(delta: float) -> void:
	$FloatingText3D.position.z -= 4 * delta
	pass
