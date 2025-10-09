class_name Game
extends Node3D

@onready var everything: Everything = %Everything
@onready var scale_count: Label = %ScaleCount

var overworld_manager: OverworldManager

func _ready() -> void:
	Audio.play_music(Audio.MUSIC_OVERWORLD)

	overworld_manager = get_tree().get_first_node_in_group(&"overworld")
	assert(overworld_manager)

func _physics_process(_delta: float) -> void:
	%Scales.visible = overworld_manager.num_rainbow_scales > 0
	scale_count.text = str(overworld_manager.num_rainbow_scales)
