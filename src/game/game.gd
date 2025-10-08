class_name Game
extends Node3D

@onready var everything: Everything = %Everything

func _ready() -> void:
	Audio.play_music(Audio.MUSIC_OVERWORLD)
