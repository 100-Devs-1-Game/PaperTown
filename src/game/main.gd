class_name Main
extends Node

@onready var game: Game = %Game
@onready var screen: Screen = %Screen


func _ready() -> void:
	self.process_mode = PROCESS_MODE_ALWAYS
	game.process_mode = Node.PROCESS_MODE_PAUSABLE
	screen.process_mode = PROCESS_MODE_ALWAYS
	get_tree().paused = true

	screen.finished_fadeout.connect(func(): get_tree().paused = false)
	screen.finished_fadein.connect(func(): get_tree().paused = true)
